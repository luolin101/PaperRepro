"""
Scoring Agent for reproducibility evaluation workflow.
Compares reproduced results with paper findings and assigns scores.
"""
import os
import json
from research_agent.inno.types import Agent, Result
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
        execution_summary = context_variables.get("execution_summary", None)
        
        execution_summary_str = json.dumps(execution_summary, indent=2, ensure_ascii=False) if execution_summary else "Not available"
        
        return f"""You are a Scoring Agent. Your task is to compare the reproduced results with the original items from the paper and evaluate whether the reproduction was successful.

**Context**:
- Workspace: {workspace_dir}
- Paper: {paper_path}
- Code Repository: {replication_package}

**IMPORTANT**: Always explicitly state your thinking and reasoning steps before calling any tool.

Scoring Explanation:
• 1: Major findings irreproducible
• 2: Minor inconsistencies/errors in code
• 3: Minor issues at display/reporting level (only numerical differences, e.g., rounding errors in tables). **IMPORTANT**: Score 3 should ONLY be used for minor numerical differences. Visual differences such as colors, fonts, or styling should NOT affect the score - these are not considered issues.
• 4: Major findings fully reproducible

**Important Note on Standard Errors**: Differences in standard errors between the paper and reproduced results are generally acceptable and should NOT be considered minor issues (score 2) or even minor display issues (score 3). Standard errors can vary due to random seed differences, numerical precision, or different computational implementations, and these variations are expected in statistical reproducibility. Only assess as score 2 or 3 if there are differences in the main coefficient estimates or other substantive findings beyond standard errors.

**IMPORTANT**: execution_summary.json may sometimes miss or not perfectly list all reproduced output files. When you cannot find expected output files:
- **FIRST**: Manually inspect the workspace (e.g., using directory tree) to locate the true output files before scoring. Always prioritize checking for actual output files (figures, tables, data files) over log files.
- **ONLY IF output files cannot be found**: Then check log files (e.g., `.log` files from script execution). Log files may contain printed output, table data, or execution details as a fallback when separate output files are missing. **Do NOT prioritize log files over actual output files.**

**IMPORTANT**: For R projects, check for `Rplots.pdf` files in the workspace. R scripts that generate plots without explicitly saving them (e.g., using `plot()` without `png()`/`pdf()` wrapper) will save figures to `Rplots.pdf` by default. This file may contain reproduced figures that were not explicitly saved to named output files. Use `pdf_page_to_image` or `pdf_to_images` to extract figures from `Rplots.pdf` if it exists, then compare them with paper figures using `add_image_to_context`.

Tasks:
1. FIRST STEP: Use `pdf_extract_figures_tables` to extract figures and tables from the paper PDF and save the outputs under `{workspace_dir}/elements` so you have local copies of every item to reproduce (figures, tables, claims)
   **IMPORTANT**: The file names extracted by `pdf_extract_figures_tables` may not always correspond correctly to the actual content. For example, a file named "figure2.png" might not actually contain Figure 2's content - it could be mislabeled or contain Figure 1's content instead. When you notice obvious mismatches (e.g., the content clearly doesn't match what you expect for that item), you should examine other extracted files to find the correct match. Don't rely solely on file names - verify the actual content when comparing with reproduced outputs.
   **VERIFYING FIGURE/TABLE NUMBERS USING CAPTIONS**: When you use `add_image_to_context` to view extracted figures or tables, pay attention to any captions in the images (text labels like "Figure 1:", "Table 2:", etc.). Compare the caption number with the filename to identify mismatches. For example, if you see "figure2.png" but the caption in the image says "Figure 1", you should recognize that this file is mislabeled and contains Figure 1's content, not Figure 2.
2. Use `read_file` to read:
   - Tables/text data to reproduce (from execution_summary or paper PDF extracted tables)
   - Reproduced output files (CSV, text files from execution_summary output_files)
3. Use `add_image_to_context` to read:
   - Images to reproduce (extracted from paper PDF using pdf_extract_figures_tables)
   - Reproduced output images (from execution_summary output_files, or from Rplots.pdf if found)
   - **Note**: If output charts/figures are in PDF format (including Rplots.pdf):
     - Use `pdf_page_to_image` when you only need a single page (recommended for scoring)
     - Use `pdf_to_images` when you need all pages
     Then load the generated images with `add_image_to_context`.
   - **Note**: If outputs are in Excel (.xlsx) with many sheets/tabs, you can use `xlsx_to_images` to export each sheet to an image, then load the relevant sheet images with `add_image_to_context`.
   - **Note**: If output images are in unusual formats (e.g., .eps, .svg, .tiff, .bmp), use `convert_image_to_png` to convert them to PNG format first, then load the converted PNG images with `add_image_to_context`.
4. Compare results between paper findings (to reproduce) and reproduced outputs
   **Note on Standard Errors**: Differences in standard errors are acceptable and should not be considered as issues. Focus on comparing the main coefficient estimates, effect sizes, and substantive findings rather than standard errors.
   **Note on Visual Differences**: Color differences, font differences, or styling differences in figures should NOT affect the score. Score 3 should ONLY be used for minor numerical differences (e.g., rounding errors), not for visual differences.
5. Assign score (1-4) based on comparison results
6. Create `scoring_summary.json` at `{workspace_dir}` with each item to reproduce as key, and value containing output paths and evaluation
7. Save score using `case_resolved(score, reason)`

Windows: Use PowerShell commands

Tools:
- `pdf_extract_figures_tables`: Use this to extract figures and tables from PDF. **Note**: The extracted file names may not always accurately match their content (e.g., "figure2.png" might not actually contain Figure 2, it could be Figure 1). When you use `add_image_to_context` to view the extracted images, pay attention to any captions visible in the images (like "Figure 1:", "Table 2:", etc.) to verify the figure/table number matches the filename.
- `read_file`: Read text files (simple, like cat - use for CSV, text output files, including code files, documents (RTF, LaTeX, csv) )
- `open_local_file`: Open document files (PDF, DOCX) in browser for viewing
- `add_image_to_context`: Add images for comparison (used to read image)
- `pdf_to_images`: Convert a PDF into per-page images for visual comparison
- `pdf_page_to_image`: Convert a single PDF page to one image (recommended when only one figure/page is needed)
- `xlsx_to_images`: Convert an .xlsx workbook (each sheet/tab) into images for visual comparison
- `convert_image_to_png`: Convert unusual image formats (e.g., EPS, SVG, TIFF, BMP) to PNG format. Useful when reproduced outputs are in formats that cannot be directly loaded by `add_image_to_context`.
- `execute_command`: Run commands (use PowerShell on Windows)
- `terminal_page_down`, `terminal_page_up`, `terminal_page_to`: Scroll terminal output when using execute_command
- `write_file`: Create scoring_summary.json
- `get_directory_tree`: Get directory structure
- `case_resolved(score, reason)`: Report completion
"""

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
