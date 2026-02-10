import os
import subprocess
from dataclasses import dataclass, field
from functools import update_wrapper
from inspect import signature
from pathlib import Path
from typing import Dict, Optional, Union


@dataclass
class LocalEnvConfig:
    """
    Configuration holder for `LocalEnv`.

    Attributes:
        workplace_name: Logical workspace folder name (mirrors Docker's workplace).
        local_root: Root directory that contains the workplace folder.
        shell: Optional shell executable to use when running commands. If not
            provided, a sensible default is chosen based on the current platform.
        encoding: Encoding used to decode command outputs.
        inherit_env: Whether to inherit the current process environment variables.
        extra_env: Additional environment variables to set for command execution.
        create_workplace: If True, ensure the workplace directory exists when
            initializing the environment.
    """

    workplace_name: str
    local_root: str = field(default_factory=os.getcwd)
    shell: Optional[str] = None
    encoding: Optional[str] = None  # None means auto-detect based on platform
    inherit_env: bool = True
    extra_env: Optional[Dict[str, str]] = None
    create_workplace: bool = True


class LocalEnv:
    """
    A drop-in replacement for `DockerEnv` that executes commands directly on the
    host machine while preserving the same interface.
    """

    def __init__(self, config: Union[LocalEnvConfig, Dict]):
        if isinstance(config, dict):
            config = LocalEnvConfig(**config)

        self.workplace_name = config.workplace_name
        self.local_root = os.path.abspath(config.local_root)
        self.local_workplace = os.path.abspath(os.path.join(self.local_root, self.workplace_name))
        self.docker_workplace = self.local_workplace  # mimic DockerEnv attribute
        self.create_workplace = config.create_workplace

        if config.create_workplace:
            os.makedirs(self.local_workplace, exist_ok=True)

        # Auto-detect encoding if not specified
        if config.encoding is None:
            # On Windows, PowerShell/CMD typically use GBK/cp936 for Chinese systems
            # On Unix-like systems, usually UTF-8
            if os.name == "nt":  # Windows
                import locale
                # Try to get system encoding, fallback to GBK
                try:
                    system_encoding = locale.getpreferredencoding()
                    # Use GBK for Chinese Windows systems, UTF-8 for others
                    if '936' in system_encoding or 'gb' in system_encoding.lower():
                        self.encoding = 'gbk'
                    else:
                        self.encoding = 'utf-8'
                except:
                    self.encoding = 'gbk'  # Default to GBK on Windows
            else:
                self.encoding = 'utf-8'
        else:
            self.encoding = config.encoding
        self._shell = config.shell or self._default_shell()
        self._env = self._build_env(config)

    def init_container(self):
        """
        Maintain parity with DockerEnv.init_container(). For LocalEnv there is
        no container to start, so we simply ensure the workplace directory exists
        if create_workplace is True.
        """
        if self.create_workplace:
            os.makedirs(self.local_workplace, exist_ok=True)

    def stop_container(self):
        """
        Placeholder for API compatibility. Local environments do not need an
        explicit teardown routine.
        """

    def run_command(self, command: str, stream_callback=None):
        """
        Execute `command` on the host machine. The return format mirrors
        DockerEnv: a dict containing `status` (process return code) and `result`
        (aggregated stdout/stderr).
        """
        # Convert common CMD commands to PowerShell equivalents on Windows
        if os.name == "nt" and "powershell" in self._shell.lower():
            command = self._convert_cmd_to_powershell(command)
        
        popen_kwargs = self._build_popen_kwargs(command)
        output_chunks = []

        # Determine working directory: use local_workplace if it exists, otherwise use current directory
        work_dir = self.local_workplace
        if not os.path.exists(work_dir):
            # If workplace doesn't exist, use current working directory instead
            work_dir = os.getcwd()

        try:
            with subprocess.Popen(
                **popen_kwargs,
                cwd=work_dir,
                env=self._env,
                stdout=subprocess.PIPE,
                stderr=subprocess.STDOUT,
                text=True,
                encoding=self.encoding,
                errors="replace",
            ) as process:
                assert process.stdout is not None  # for type checkers
                for line in process.stdout:
                    if stream_callback:
                        stream_callback(line.rstrip("\r\n"))
                    output_chunks.append(line)
                process.wait()
                status = process.returncode
        except FileNotFoundError as exc:
            status = -1
            output_chunks.append(str(exc))
        except Exception as exc:  # pragma: no cover - safeguard
            status = -1
            output_chunks.append(str(exc))

        result_text = "".join(output_chunks)
        return {"status": status, "result": result_text}

    # ------------------------------------------------------------------ #
    # Helpers
    # ------------------------------------------------------------------ #

    def _convert_cmd_to_powershell(self, command: str) -> str:
        """
        Convert common CMD commands to PowerShell equivalents.
        This helps when commands are written for CMD but executed in PowerShell.
        """
        import re
        
        # Convert dir /b to Get-ChildItem -Name (or ls -Name)
        # Pattern: dir /b <path> or dir /b <path> <options>
        if re.match(r'^\s*dir\s+/b\s+', command, re.IGNORECASE):
            # Extract the path and any additional arguments
            match = re.match(r'^\s*dir\s+/b\s+(.+)$', command, re.IGNORECASE)
            if match:
                rest = match.group(1).strip()
                return f"Get-ChildItem -Name {rest}"
        
        # Convert dir to Get-ChildItem (or ls)
        if re.match(r'^\s*dir\s+', command, re.IGNORECASE) and '/b' not in command:
            # Simple dir command without /b
            match = re.match(r'^\s*dir\s+(.+)$', command, re.IGNORECASE)
            if match:
                rest = match.group(1).strip()
                return f"Get-ChildItem {rest}"
        
        # Return original command if no conversion needed
        return command

    def _default_shell(self) -> Optional[str]:
        """
        Select a platform-specific shell when none is explicitly provided.
        """
        if os.name == "nt":
            return "powershell"

        candidate = Path("/bin/bash")
        if candidate.exists():
            return str(candidate)

        return None  # fall back to the system default behaviour

    def _build_env(self, config: LocalEnvConfig) -> Dict[str, str]:
        base_env = os.environ.copy() if config.inherit_env else {}
        extra = config.extra_env or {}
        base_env.update(extra)
        return base_env

    def _build_popen_kwargs(self, command: str) -> Dict:
        """
        Build keyword arguments for subprocess.Popen that respect the selected
        shell configuration.
        """
        if self._shell is None:
            return {"args": command, "shell": True}

        shell_lower = self._shell.lower()
        if "powershell" in shell_lower:
            executable = self._shell
            if os.name == "nt" and not executable.lower().endswith(".exe"):
                executable += ".exe"
            return {
                "args": [executable, "-NoLogo", "-NoProfile", "-ExecutionPolicy", "Bypass", "-Command", command],
                "shell": False,
            }

        # Treat everything else as a standard shell executable (e.g. /bin/bash)
        return {"args": command, "shell": True, "executable": self._shell}


def with_env(env: LocalEnv):
    """
    Mirror `docker_env.with_env` so tools written for DockerEnv interoperate
    transparently with LocalEnv.
    """

    def decorator(func):
        def wrapped(*args, **kwargs):
            return func(env=env, *args, **kwargs)

        update_wrapper(wrapped, func)
        wrapped.__signature__ = signature(func).replace(
            parameters=[p for p in signature(func).parameters.values() if p.name != "env"]
        )
        if func.__doc__:
            try:
                wrapped.__doc__ = func.__doc__.format(docker_workplace=env.docker_workplace, local_workplace=env.local_workplace)
            except (KeyError, IndexError, ValueError):
                wrapped.__doc__ = func.__doc__
        return wrapped

    return decorator

