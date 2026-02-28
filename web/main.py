"""
PaperRepro Web UI: upload paper/code/repro items, configure env, run evaluation, download report.
"""
import io
import os
import zipfile
import uuid
import asyncio
from pathlib import Path
from typing import Optional
from contextlib import asynccontextmanager

from fastapi import FastAPI, UploadFile, File, Form, HTTPException, BackgroundTasks
from fastapi.responses import FileResponse, HTMLResponse
from fastapi.staticfiles import StaticFiles
from pydantic import BaseModel

# Project root (parent of web/)
PROJECT_ROOT = Path(__file__).resolve().parent.parent
WORKSPACES_DIR = PROJECT_ROOT / "workspaces"
ENV_FILE = PROJECT_ROOT / ".env"

# In-memory job progress: job_id -> { status, agents, error, report_path }
job_progress: dict[str, dict] = {}


def ensure_workspaces_dir():
    WORKSPACES_DIR.mkdir(parents=True, exist_ok=True)


def parse_agent_progress(line: str) -> Optional[str]:
    """Return agent name when line indicates that agent completed or was skipped."""
    if "Setup Agent completed" in line or ("Setup Agent" in line and "SKIPPED" in line):
        return "setup"
    if "Execution Agent completed" in line or ("Execution Agent" in line and "SKIPPED" in line):
        return "execution"
    if "Scoring Agent completed" in line or ("Scoring Agent" in line and "SKIPPED" in line):
        return "scoring"
    if "Summary Report Agent completed" in line or ("Summary Report Agent" in line and "SKIPPED" in line):
        return "summary"
    return None


def run_evaluation_sync(job_id: str, workspace_dir: str, env_overrides: dict):
    """Run evaluation in subprocess; stdout is written to a log file so the main thread only waits (avoids pipe deadlock)."""
    import subprocess
    import sys

    job_progress[job_id]["status"] = "running"
    job_progress[job_id]["agents"] = {
        "setup": "pending",
        "execution": "pending",
        "scoring": "pending",
        "summary": "pending",
    }
    job_progress[job_id]["log"] = []
    job_progress[job_id]["error"] = None
    job_progress[job_id]["log_file"] = None
    env = os.environ.copy()
    env.update(env_overrides)
    env["PYTHONUNBUFFERED"] = "1"
    env["PYTHONPATH"] = str(PROJECT_ROOT)
    env["PYTHONIOENCODING"] = "utf-8"
    work_dir = PROJECT_ROOT / "research_agent"
    cmd = [sys.executable, "-u", "examples/run_reproducibility_evaluation.py", workspace_dir]
    log_path = Path(workspace_dir) / "run_log.txt"
    log_file = open(log_path, "w", encoding="utf-8", errors="replace")
    job_progress[job_id]["log_file"] = str(log_path)
    try:
        proc = subprocess.Popen(
            cmd,
            cwd=str(work_dir),
            env=env,
            stdout=log_file,
            stderr=subprocess.STDOUT,
            text=True,
            encoding="utf-8",
            errors="replace",
        )
        proc.wait()
        log_file.close()
        log_file = None
        if log_path.exists():
            with open(log_path, "r", encoding="utf-8", errors="replace") as f:
                log_lines = [line.rstrip("\n\r") for line in f]
            job_progress[job_id]["log"] = log_lines[-500:]
            for line in log_lines:
                agent = parse_agent_progress(line)
                if agent:
                    job_progress[job_id]["agents"][agent] = "done"
        if proc.returncode != 0:
            job_progress[job_id]["status"] = "error"
            tail = "\n".join(job_progress[job_id]["log"][-40:]) if job_progress[job_id]["log"] else "(no output)"
            job_progress[job_id]["error"] = f"Process exited with code {proc.returncode}\n\n--- Last 40 lines ---\n{tail}"
            return
    except Exception as e:
        job_progress[job_id]["status"] = "error"
        job_progress[job_id]["error"] = str(e)
        if log_path.exists():
            try:
                with open(log_path, "r", encoding="utf-8", errors="replace") as f:
                    job_progress[job_id]["log"] = f.read().splitlines()[-500:]
            except Exception:
                pass
        log = job_progress[job_id].get("log", [])
        if log:
            job_progress[job_id]["error"] = str(e) + "\n\n--- Subprocess output ---\n" + "\n".join(log[-30:])
        return

    job_progress[job_id]["status"] = "done"
    report_md = Path(workspace_dir) / "reproducibility_report.md"
    report_pdf = Path(workspace_dir) / "reproducibility_report.pdf"
    if report_pdf.exists():
        job_progress[job_id]["report_path"] = str(report_pdf)
        job_progress[job_id]["report_type"] = "pdf"
    elif report_md.exists():
        job_progress[job_id]["report_path"] = str(report_md)
        job_progress[job_id]["report_type"] = "md"
    else:
        job_progress[job_id]["report_path"] = None
        job_progress[job_id]["report_type"] = None


@asynccontextmanager
async def lifespan(app: FastAPI):
    ensure_workspaces_dir()
    yield
    # cleanup if needed
    pass


app = FastAPI(title="PaperRepro Web", lifespan=lifespan)

# Mount static files (index.html and assets)
static_dir = Path(__file__).parent / "static"
static_dir.mkdir(exist_ok=True)
app.mount("/static", StaticFiles(directory=str(static_dir)), name="static")


# ---------- API ----------

class ConfigRead(BaseModel):
    OPENAI_API_BASE: str = ""
    OPENAI_API_KEY: str = ""
    SETUP_AGENT_MODEL: str = ""
    EXECUTION_AGENT_MODEL: str = ""
    SCORING_AGENT_MODEL: str = ""
    SUMMARY_AGENT_MODEL: str = ""
    STATA_PATH: str = ""
    STATA_EDITION: str = ""
    SKIP_CACHE: str = "0"


class ConfigWrite(BaseModel):
    OPENAI_API_BASE: Optional[str] = None
    OPENAI_API_KEY: Optional[str] = None
    SETUP_AGENT_MODEL: Optional[str] = None
    EXECUTION_AGENT_MODEL: Optional[str] = None
    SCORING_AGENT_MODEL: Optional[str] = None
    SUMMARY_AGENT_MODEL: Optional[str] = None
    STATA_PATH: Optional[str] = None
    STATA_EDITION: Optional[str] = None
    SKIP_CACHE: Optional[str] = None


def read_env_to_config() -> dict:
    """Read .env into a dict (mask API key for display)."""
    out = {
        "OPENAI_API_BASE": "",
        "OPENAI_API_KEY": "",
        "SETUP_AGENT_MODEL": "",
        "EXECUTION_AGENT_MODEL": "",
        "SUMMARY_AGENT_MODEL": "",
        "SCORING_AGENT_MODEL": "",
        "STATA_PATH": "",
        "STATA_EDITION": "",
        "SKIP_CACHE": "0",
    }
    if not ENV_FILE.exists():
        return out
    with open(ENV_FILE, "r", encoding="utf-8") as f:
        for line in f:
            line = line.strip()
            if not line or line.startswith("#"):
                continue
            if "=" in line:
                key, _, value = line.partition("=")
                key = key.strip()
                value = value.strip().strip('"').strip("'")
                if key in out:
                    if key == "OPENAI_API_KEY" and value:
                        out[key] = value[:8] + "***" if len(value) > 8 else "***"
                    else:
                        out[key] = value
    return out


def write_config_to_env(data: ConfigWrite):
    """Merge config into .env (read existing, update given keys, write back)."""
    lines_out = []
    updated_keys = set()
    keys_to_update = [
        "OPENAI_API_BASE", "OPENAI_API_KEY", "SETUP_AGENT_MODEL", "EXECUTION_AGENT_MODEL",
        "SCORING_AGENT_MODEL", "SUMMARY_AGENT_MODEL", "STATA_PATH", "STATA_EDITION", "SKIP_CACHE"
    ]
    if ENV_FILE.exists():
        with open(ENV_FILE, "r", encoding="utf-8") as f:
            for line in f:
                if not line.strip() or line.strip().startswith("#"):
                    lines_out.append(line.rstrip("\n"))
                    continue
                if "=" in line:
                    key = line.split("=", 1)[0].strip()
                    if key in keys_to_update:
                        val = getattr(data, key, None)
                        if val is not None and val != "":
                            lines_out.append(f"{key}={val}")
                            updated_keys.add(key)
                        else:
                            lines_out.append(line.rstrip("\n"))
                    else:
                        lines_out.append(line.rstrip("\n"))
                else:
                    lines_out.append(line.rstrip("\n"))
    for key in keys_to_update:
        if key not in updated_keys:
            val = getattr(data, key, None)
            if val is not None and val != "":
                lines_out.append(f"{key}={val}")
    with open(ENV_FILE, "w", encoding="utf-8") as f:
        f.write("\n".join(lines_out) + "\n")


@app.get("/api/config", response_model=ConfigRead)
def get_config():
    """Return current .env config (API key masked)."""
    return ConfigRead(**read_env_to_config())


@app.post("/api/config")
def post_config(data: ConfigWrite):
    """Update .env with provided config."""
    write_config_to_env(data)
    return {"ok": True}


@app.post("/api/upload")
async def upload(
    background_tasks: BackgroundTasks,
    paper: Optional[UploadFile] = File(None),
    code_zip: Optional[UploadFile] = File(None),
    should_reproduce: Optional[str] = Form(None),
):
    """
    Create a new workspace: upload paper (PDF), code (zip), and should_reproduce text.
    Returns job_id (workspace id) for use in /api/run.
    """
    ensure_workspaces_dir()
    job_id = str(uuid.uuid4())[:8]
    workspace_dir = WORKSPACES_DIR / job_id
    workspace_dir.mkdir(parents=True, exist_ok=True)
    rep_pkg = workspace_dir / "replication_package"
    rep_pkg.mkdir(exist_ok=True)

    if paper:
        path = workspace_dir / "paper.pdf"
        content = await paper.read()
        with open(path, "wb") as f:
            f.write(content)
    if code_zip:
        content = await code_zip.read()
        with zipfile.ZipFile(io.BytesIO(content), "r") as z:
            z.extractall(rep_pkg)
    if should_reproduce is not None:
        path = workspace_dir / "should_reproduce.txt"
        with open(path, "w", encoding="utf-8") as f:
            f.write(should_reproduce.strip())

    job_progress[job_id] = {
        "status": "idle",
        "agents": {"setup": "pending", "execution": "pending", "scoring": "pending", "summary": "pending"},
        "error": None,
        "report_path": None,
        "report_type": None,
    }
    return {"job_id": job_id, "workspace_dir": str(workspace_dir)}


@app.get("/api/run/{job_id}/status")
def run_status(job_id: str):
    """Get current run status and agent progress; when running, reads the log file to update log and agents."""
    if job_id not in job_progress:
        raise HTTPException(status_code=404, detail="Job not found")
    info = job_progress[job_id]
    if info.get("status") == "running" and info.get("log_file"):
        log_path = Path(info["log_file"])
        if log_path.exists():
            try:
                with open(log_path, "r", encoding="utf-8", errors="replace") as f:
                    log_lines = [line.rstrip("\n\r") for line in f]
                info["log"] = log_lines[-500:]
                for line in log_lines:
                    agent = parse_agent_progress(line)
                    if agent:
                        info["agents"][agent] = "done"
            except Exception:
                pass
    return info


@app.post("/api/run/{job_id}")
def run_evaluation(job_id: str, background_tasks: BackgroundTasks):
    """Start reproducibility evaluation for the given workspace (job_id)."""
    workspace_dir = WORKSPACES_DIR / job_id
    if not workspace_dir.exists():
        raise HTTPException(status_code=404, detail="Workspace not found")
    if job_id not in job_progress:
        job_progress[job_id] = {
            "status": "idle",
            "agents": {"setup": "pending", "execution": "pending", "scoring": "pending", "summary": "pending"},
            "error": None,
            "report_path": None,
            "report_type": None,
        }
    if job_progress[job_id]["status"] == "running":
        raise HTTPException(status_code=409, detail="Run already in progress")
    env_overrides = {}
    if ENV_FILE.exists():
        with open(ENV_FILE, "r", encoding="utf-8") as f:
            for line in f:
                line = line.strip()
                if line and not line.startswith("#") and "=" in line:
                    k, _, v = line.partition("=")
                    env_overrides[k.strip()] = v.strip().strip('"').strip("'")
    background_tasks.add_task(run_evaluation_sync, job_id, str(workspace_dir), env_overrides)
    return {"job_id": job_id, "status": "started"}


@app.get("/api/run/{job_id}/report")
def download_report(job_id: str):
    """Download the reproducibility report (PDF or MD) for the job."""
    if job_id not in job_progress:
        raise HTTPException(status_code=404, detail="Job not found")
    info = job_progress[job_id]
    path = info.get("report_path")
    if not path or not os.path.exists(path):
        raise HTTPException(status_code=404, detail="Report not ready or not found")
    filename = "reproducibility_report.pdf" if info.get("report_type") == "pdf" else "reproducibility_report.md"
    return FileResponse(path, filename=filename, media_type="application/pdf" if info.get("report_type") == "pdf" else "text/markdown")


@app.get("/", response_class=HTMLResponse)
def index():
    """Serve the single-page UI."""
    index_file = static_dir / "index.html"
    if index_file.exists():
        return HTMLResponse(content=index_file.read_text(encoding="utf-8"))
    return HTMLResponse(content="<p>PaperRepro Web</p><p>Place index.html in web/static/</p>", status_code=200)
