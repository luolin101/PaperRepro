"""
Summary Report Agent for reproducibility evaluation workflow.
Generates a comprehensive markdown summary report from the three summary JSON files.
"""
import os
import re
from research_agent.inno.types import Agent, Result
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
        
        return f"""You are a Summary Report Agent. Your task is to create a comprehensive markdown summary report.

**Context**:
- Workspace: {workspace_dir}

**IMPORTANT**: Always explicitly state your thinking and reasoning steps before calling any tool.

**Report Format**:

The markdown report should include the following sections:

1. **Overall Score**
   - Display the final reproducibility score (1-4)
   - Explain what the score means

2. **Scoring Criteria**
   - Explain the scoring system:
     • 1: Major findings in the paper are irreproducible
     • 2: There are minor inconsistencies and/or errors in the provided data and/or code
     • 3: There are rounding errors or equivalent issues in the major findings
     • 4: Major findings of the paper are fully reproducible

3. **Overall Explanation**
   - Provide a comprehensive explanation of why this score was given
   - Summarize the overall reproduction attempt
   - Highlight key successes and challenges

4. **Item-by-Item Analysis**
   - For each item to reproduce (figures, tables, claims), provide:
     - Item identifier (e.g., "Figure 1", "Table 1")
     - **How it was reproduced**: Describe the execution steps and files used
     - **Modifications made**: List any changes made to original files
     - **Output generated**: List the output files produced
     - **Comparison result**: Describe how the reproduced result compares with the original
     - **Reproducibility assessment**: State whether this item was successfully reproduced

**Writing Guidelines**:
- Use clear, professional language
- Use proper markdown formatting (headers, lists, code blocks where appropriate)
- Be thorough but concise
- Make the report easy to read and understand

**Tasks**:
1. Read the provided summaries and score information from the user query
2. Create the markdown report based on the report format above
3. Write the report to `{workspace_dir}/reproducibility_report.md` using `write_markdown` tool (this tool will validate the markdown format)
4. Call `case_resolved` when complete

**Tools**:
- `read_file`: Read files if needed
- `write_markdown`: Write and validate the markdown report file
- `case_resolved`: Report completion
"""

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