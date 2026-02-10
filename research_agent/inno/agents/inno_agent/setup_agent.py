"""
Setup Agent for reproducibility evaluation workflow.
Identifies files to run and configures the environment.
"""
import os
import json
from research_agent.inno.types import Agent
from research_agent.inno.tools import (
    write_file, execute_command,
    terminal_page_down, terminal_page_up, terminal_page_to
)
from research_agent.inno.tools.file_surfer_tool import open_local_file
from research_agent.inno.tools.local_execution_tools import execute_python_code
from research_agent.inno.tools.terminal_tools import read_file
from research_agent.inno.registry import register_agent, register_tool
from research_agent.inno.environment.docker_env import DockerEnv, with_env
from research_agent.inno.environment.local_env import LocalEnv
from inspect import signature

__CTX_VARS_NAME__ = "context_variables"


@register_tool("case_resolved")
def case_resolved(task_response: str, context_variables: dict = None):
    """
    Called when setup is completed. Setup agent does not provide a score.
    
    Args:
        task_response: Description of what was accomplished in the setup task.
    """
    if context_variables is None:
        context_variables = {}
    
    from research_agent.inno.types import Result
    return Result(value=f"Case resolved. {task_response}", context_variables=context_variables)




@register_agent("get_setup_agent")
def get_setup_agent(model: str, **kwargs):
    code_env = kwargs.get("code_env", None)
    file_env = kwargs.get("file_env", None)
    
    def instructions(context_variables):
        workspace_dir = context_variables.get("workspace_dir", ".")
        replication_package = context_variables.get("replication_package", "replication_package")
        paper_path = context_variables.get("paper_path", "paper.pdf")
        
        return f"""You are a Setup Agent. Given a paper and its corresponding code repository, along with items specified by the user that need to be reproduced, your task is to configure the environment and create a step-by-step plan to reproduce each item.

**Context**:
- Workspace: {workspace_dir}
- Paper: {paper_path}
- Code Repository: {replication_package}

**IMPORTANT**: Always explicitly state your thinking and reasoning steps before calling any tool.

**Note on master/main files**: Some repositories have master files (e.g., `master.do`, `main.do`, `run_all.do`, `main.R`, `run_all.py`, `master.py`) that orchestrate the entire replication by calling other scripts in order. If you find such files using `get_directory_tree` and confirm they handle the full replication, you can use them as the primary entry point in `execution_steps` instead of analyzing individual files separately.

Your task:
1. Read README/docs, then use `read_file` to read code files (e.g., .R, .py, .do files)
2. **Check for output directories**: While reading code, identify if results are likely to be saved to folders that may not exist (e.g., `results/`, `tables/`, `graphs/`, `figures/`, `output/`, `data/`, etc.). If you find such output paths, proactively create these directories in the workspace using `execute_command` (e.g., `mkdir results` on Windows PowerShell, or `New-Item -ItemType Directory -Path results`) to prevent folder errors during execution.
3. Identify required packages from the code you read, then install using `execute_python_code`
4. Create `setup_summary.json` at `{workspace_dir}` following the JSON structure specified in the user query

Critical note on related files:
- When a script loads/calls other scripts or data, you MUST include those as related files for the corresponding reproduction item.
  Examples: R `source("x.R")`, `read.csv("data.csv")`; Python `import ...` / `from ... import ...` + reading files; Stata `do "x.do"`, `include`, `use`, `import delimited`, `insheet`, etc.
- In `setup_summary.json`, list these dependent scripts/data/config files under the item’s related/involved files.

IMPORTANT: Use `read_file` to read code files and identify dependencies, then install packages.
Note: The environment already includes R, Stata, matlab, and Python, so you don't need to install them.

**Windows Environment**: When using command-line tools:
- Use PowerShell commands, NOT bash commands
- Use `Get-ChildItem` instead of `ls`
- Use `Get-ChildItem -Recurse` for directory trees
- Use PowerShell syntax for paths and commands

Workflow:
1. Read README/docs, then use `read_file` to read code files (e.g., `main.R`, `analysis.py`)
2. While reading code, collect ALL dependent scripts/data/config files referenced via source/import/do/include/file reads, and treat them as related files for the relevant reproduction item
3. **Check for output directories**: While analyzing code, identify if results are likely to be saved to folders that may not exist (e.g., `results/`, `tables/`, `graphs/`, `figures/`, `output/`, `data/`, etc.). If you find such output paths in the code, proactively create these directories in the workspace using `execute_command` (e.g., `mkdir results` on Windows PowerShell, or `New-Item -ItemType Directory -Path results`). This prevents folder errors during execution.
4. Then identify required packages from the code content
5. Install packages using `execute_python_code`:
   
   For R packages (ensure R is installed, e.g., via conda):
   ```python
   import subprocess
   subprocess.run(['Rscript', '-e', 'install.packages(c("dplyr", "ggplot2", "tidyr"), repos="https://cran.rstudio.com/")'], check=True)
   ```
   
   For Python packages:
   ```python
   import subprocess
   # Install from requirements.txt
   subprocess.run(['pip', 'install', '-r', 'requirements.txt'], check=True)
   # Or install specific packages
   subprocess.run(['pip', 'install', 'pandas', 'numpy', 'matplotlib'], check=True)
   ```
   
   For conda environments (if environment.yml exists):
   ```python
   import subprocess
   subprocess.run(['conda', 'env', 'update', '-f', 'environment.yml'], check=True)
   ```

Tools:
- `read_file`: Read code/text files (simple, like cat - use for .R, .py, .do, .txt files, using absolute path)
- `open_local_file`: Open document files (PDF, DOCX, etc.) in browser for viewing
- `execute_python_code`: Execute Python code string directly (use this for installing packages)
- `execute_command`: Run commands (use PowerShell commands on Windows)
- `get_directory_tree`: Get directory tree structure (Windows uses PowerShell, Linux uses tree)
- `write_file`: Create setup_summary.json
- `case_resolved(task_response)`: Report completion (no score needed for setup agent)

Remember: Use execute_python_code for all Python operations. Create setup_summary.json manually with absolute paths.
"""

    from research_agent.inno.tools.terminal_tools import get_directory_tree
    tools = [
        read_file, open_local_file, write_file, execute_python_code, execute_command, get_directory_tree,
        terminal_page_down, terminal_page_up, terminal_page_to,
        case_resolved
    ]
    
    if file_env:
        from research_agent.inno.tools.file_surfer_tool import with_env as with_file_env
        tools = [
            with_file_env(file_env)(tool) if tool == open_local_file else tool
            for tool in tools
        ]
    
    if code_env:
        tools = [
            with_env(code_env)(tool) if 'env' in signature(tool).parameters and tool != open_local_file else tool
            for tool in tools
        ]
    
    return Agent(
        name="Setup Agent",
        model=model,
        instructions=instructions,
        functions=tools,
        tool_choice="required",
        parallel_tool_calls=False
    )
