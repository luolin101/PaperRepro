"""
Scoring Agent for reproducibility evaluation workflow.
Compares reproduced results with paper findings and assigns scores.
"""
import os
import json
from research_agent.inno.types import Agent, Result
from research_agent.inno.prompt_loader import render_prompt
from research_agent.inno.tools import (
    list_files, pdf_extract_figures_tables, save_reproducibility_score,
    write_file, execute_command,
    terminal_page_down, terminal_page_up, terminal_page_to
)
from research_agent.inno.tools.file_surfer_tool import open_local_file
from research_agent.inno.tools.terminal_tools import read_file
from research_agent.inno.tools.reproducibility_tools import add_image_to_context
from research_agent.inno.tools.local_execution_tools import pdf_to_images, pdf_page_to_image, xlsx_to_images, convert_image_to_png
from research_agent.inno.registry import register_agent, register_tool
from research_agent.inno.environment.docker_env import DockerEnv, with_env
from research_agent.inno.environment.local_env import LocalEnv
from inspect import signature
from research_agent.inno.tools.terminal_tools import get_directory_tree

__CTX_VARS_NAME__ = "context_variables"


@register_tool("case_resolved")
def case_resolved(task_response: str, score: int, reason: str, context_variables: dict = None):
    """
    Called when scoring is completed. Provide score (1-4) and reason.
    
    Args:
        task_response: Description of what was accomplished in the scoring task.
        score: Score from 1-4 based on reproducibility evaluation standards.
        reason: Explanation for the score, describing the comparison results and why this score.
    
    Scoring criteria (based on reproducibility evaluation standards):
    • 1: Major findings are irreproducible - Cannot reproduce main results, critical errors
    • 2: Minor inconsistencies/errors in code - Results are close but have minor differences (e.g., "We do not find any major coding errors. One minor point is inconsistency in how NA values are coded for the gender variable.")
    • 3: Minor issues at display/reporting level - Results match closely with minor numerical differences (e.g., rounding errors in tables)
    • 4: Major findings are fully reproducible - All major findings match exactly, perfect reproduction
    """
    if context_variables is None:
        context_variables = {}
    workspace_dir = context_variables.get("workspace_dir", ".")
    
    score_data = {
        "score": score,
        "reason": reason
    }
    score_path = os.path.join(workspace_dir, "reproducibility_score.json")
    try:
        with open(score_path, "w", encoding="utf-8") as f:
            json.dump({"score": score}, f, indent=2, ensure_ascii=False)
    except:
        pass
    
    # Store score in context_variables
    context_variables["reproducibility_score"] = score_data
    
    return Result(value=f"Case resolved. {task_response}", context_variables=context_variables)




@register_agent("get_scoring_agent")
def get_scoring_agent(model: str, **kwargs):
    code_env = kwargs.get("code_env", None)
    file_env = kwargs.get("file_env", None)
    
    def instructions(context_variables):
        workspace_dir = context_variables.get("workspace_dir", ".")
        paper_path = context_variables.get("paper_path", "paper.pdf")
        replication_package = context_variables.get("replication_package", "replication_package")

        return render_prompt(
            "scoring_agent_prompt.txt",
            workspace_dir=workspace_dir,
            paper_path=paper_path,
            replication_package=replication_package,
        )

    tools = [
        pdf_extract_figures_tables, read_file, open_local_file, write_file, execute_command, get_directory_tree,
        add_image_to_context, pdf_to_images, pdf_page_to_image, xlsx_to_images, convert_image_to_png,
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
            with_env(code_env)(tool) if 'env' in signature(tool).parameters else tool
            for tool in tools
        ]
    
    return Agent(
        name="Scoring Agent",
        model=model,
        instructions=instructions,
        functions=tools,
        tool_choice="required",
        parallel_tool_calls=False
    )
