"""
Setup Agent for reproducibility evaluation workflow.
Identifies files to run and configures the environment.
"""
import os
import json
from research_agent.inno.types import Agent
from research_agent.inno.prompt_loader import render_prompt
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

        return render_prompt(
            "setup_agent_prompt.txt",
            workspace_dir=workspace_dir,
            paper_path=paper_path,
            replication_package=replication_package,
        )

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
