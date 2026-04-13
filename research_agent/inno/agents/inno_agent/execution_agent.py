"""
Execution Agent for reproducibility evaluation workflow.
Executes code files and fixes issues if needed.
"""
import os
import json
from research_agent.inno.types import Agent
from research_agent.inno.prompt_loader import render_prompt
from research_agent.inno.tools import (
    write_file, execute_command, run_python,
    terminal_page_down, terminal_page_up, terminal_page_to
)
from research_agent.inno.tools.file_surfer_tool import open_local_file
from research_agent.inno.tools.terminal_tools import read_file
from research_agent.inno.tools.local_execution_tools import (
    run_local_stata,
    run_local_matlab,
    run_local_r,
    grep_file,
    replace_in_file,
    copy_file,
)
from research_agent.inno.registry import register_agent, register_tool
from research_agent.inno.environment.docker_env import DockerEnv, with_env
from research_agent.inno.environment.local_env import LocalEnv
from inspect import signature

__CTX_VARS_NAME__ = "context_variables"


@register_tool("case_resolved")
def case_resolved(task_response: str, code_quality_assessment: str, reason: str, context_variables: dict = None):
    """
    Called when execution is completed. Provide code quality assessment and reason.
    
    Args:
        task_response: Description of what was accomplished in the execution task.
        code_quality_assessment: Code quality assessment, must be one of: "major_errors", "minor_errors", "no_errors", "cannot_determine"
        reason: Detailed explanation of the code quality assessment, including specific examples 
                of errors found (if any) and code logic analysis.
    """
    if context_variables is None:
        context_variables = {}
    workspace_dir = context_variables.get("workspace_dir", ".")
    
    # Validate assessment value
    valid_assessments = ["major_errors", "minor_errors", "no_errors", "cannot_determine"]
    if code_quality_assessment not in valid_assessments:
        raise ValueError(f"code_quality_assessment must be one of {valid_assessments}, got: {code_quality_assessment}")
    
    score_data = {
        "agent": "execution_agent",
        "code_quality_assessment": code_quality_assessment,
        "reason": reason,
    }
    score_path = os.path.join(workspace_dir, "execution_score.json")
    try:
        with open(score_path, "w", encoding="utf-8") as f:
            json.dump(score_data, f, indent=2, ensure_ascii=False)
    except:
        pass
    
    # Store score in context_variables
    context_variables["execution_score"] = score_data
    
    from research_agent.inno.types import Result
    return Result(value=f"Case resolved. {task_response}", context_variables=context_variables)




@register_agent("get_execution_agent")
def get_execution_agent(model: str, **kwargs):
    code_env = kwargs.get("code_env", None)
    file_env = kwargs.get("file_env", None)
    
    def instructions(context_variables):
        workspace_dir = context_variables.get("workspace_dir", ".")
        replication_package = context_variables.get("replication_package", "replication_package")
        paper_path = context_variables.get("paper_path", "paper.pdf")

        return render_prompt(
            "execution_agent_prompt.txt",
            workspace_dir=workspace_dir,
            paper_path=paper_path,
            replication_package=replication_package,
        )

    from research_agent.inno.tools.terminal_tools import get_directory_tree
    tools = [
        read_file,
        open_local_file,
        write_file,
        execute_command,
        get_directory_tree,
        run_local_stata,
        run_local_matlab,
        run_local_r,
        copy_file,
        grep_file,
        replace_in_file,
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
        name="Execution Agent",
        model=model,
        instructions=instructions,
        functions=tools,
        tool_choice="required",
        parallel_tool_calls=False
    )
