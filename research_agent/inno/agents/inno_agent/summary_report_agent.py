"""
Summary Report Agent for reproducibility evaluation workflow.
Generates a comprehensive markdown summary report from the three summary JSON files.
"""
import os
import re
from research_agent.inno.types import Agent, Result
from research_agent.inno.prompt_loader import render_prompt
from research_agent.inno.tools.terminal_tools import read_file
from research_agent.inno.registry import register_agent, register_tool
from research_agent.inno.environment.docker_env import DockerEnv, with_env
from research_agent.inno.environment.local_env import LocalEnv
from inspect import signature

__CTX_VARS_NAME__ = "context_variables"


@register_tool("write_markdown")
def write_markdown(
    markdown_content: str,
    output_path: str,
    context_variables: dict = None
):
    """
    Write a markdown file with format validation.
    
    Args:
        markdown_content: The markdown content to write
        output_path: Path where the markdown file should be saved (absolute path)
        context_variables: Context variables containing workspace_dir
    """
    if context_variables is None:
        context_variables = {}
    
    workspace_dir = context_variables.get("workspace_dir", ".")
    
    # Ensure output_path is absolute
    if not os.path.isabs(output_path):
        output_path = os.path.join(workspace_dir, output_path)
    
    # Create directory if it doesn't exist
    output_dir = os.path.dirname(output_path)
    if output_dir:
        os.makedirs(output_dir, exist_ok=True)
    
    # Validate markdown format
    validation_errors = []
    validation_warnings = []
    
    # Check 1: Has at least one header
    if not re.search(r'^#+\s+', markdown_content, re.MULTILINE):
        validation_warnings.append("No headers found in markdown")
    
    # Check 2: Check for unmatched markdown syntax
    # Check for unmatched code blocks
    code_block_count = markdown_content.count('```')
    if code_block_count % 2 != 0:
        validation_errors.append("Unmatched code block markers (```)")
    
    # Check for unmatched bold/italic
    bold_stars = markdown_content.count('**')
    bold_underscores = markdown_content.count('__')
    if bold_stars % 2 != 0:
        validation_warnings.append("Possible unmatched bold markers (**)")
    if bold_underscores % 2 != 0:
        validation_warnings.append("Possible unmatched bold markers (__)")
    
    # Check 3: Try to parse with markdown library if available
    try:
        import markdown  # type: ignore
        md = markdown.Markdown(extensions=['tables', 'fenced_code', 'codehilite'])
        html_content = md.convert(markdown_content)
        # If conversion succeeds without exception, markdown is valid
        if not html_content.strip():
            validation_warnings.append("Markdown parsed but produced empty HTML")
    except ImportError:
        # markdown library not available, skip this check
        pass
    except Exception as e:
        validation_warnings.append(f"Markdown parsing warning: {str(e)}")
    
    # Write the markdown file
    try:
        with open(output_path, 'w', encoding='utf-8') as f:
            f.write(markdown_content)
    except Exception as e:
        return Result(
            value=f"Error writing markdown file: {str(e)}",
            context_variables=context_variables
        )
    
    # Prepare validation message
    validation_msg = f"Markdown file written to: {output_path}"
    if validation_errors:
        validation_msg += f"\n❌ Validation errors: {', '.join(validation_errors)}"
    if validation_warnings:
        validation_msg += f"\n⚠️  Validation warnings: {', '.join(validation_warnings)}"
    if not validation_errors and not validation_warnings:
        validation_msg += "\n✅ Markdown validation passed"
    
    return Result(
        value=validation_msg,
        context_variables=context_variables
    )


@register_tool("case_resolved")
def case_resolved(task_response: str, context_variables: dict = None):
    """
    Called when markdown report generation is completed.
    
    Args:
        task_response: Description of what was accomplished in the report generation task.
    """
    if context_variables is None:
        context_variables = {}
    
    return Result(value=f"Case resolved. {task_response}", context_variables=context_variables)


@register_agent("get_summary_report_agent")
def get_summary_report_agent(model: str, **kwargs):
    code_env = kwargs.get("code_env", None)
    file_env = kwargs.get("file_env", None)
    
    def instructions(context_variables):
        workspace_dir = context_variables.get("workspace_dir", ".")

        return render_prompt(
            "summary_report_agent_prompt.txt",
            workspace_dir=workspace_dir,
        )

    tools = [
        read_file, write_markdown, case_resolved
    ]
    
    if code_env:
        tools = [
            with_env(code_env)(tool) if 'env' in signature(tool).parameters else tool
            for tool in tools
        ]
    
    return Agent(
        name="Summary Report Agent",
        model=model,
        instructions=instructions,
        functions=tools,
        tool_choice="required",
        parallel_tool_calls=False
    )
