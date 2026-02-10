"""
Reproducibility evaluation workflow.
"""
import os
import json
from typing import Dict, List, Optional, Union
from research_agent.inno.workflow.flowcache import FlowModule, AgentModule
from research_agent.inno.agents.inno_agent.setup_agent import get_setup_agent
from research_agent.inno.agents.inno_agent.execution_agent import get_execution_agent
from research_agent.inno.agents.inno_agent.scoring_agent import get_scoring_agent
from research_agent.inno.agents.inno_agent.summary_report_agent import get_summary_report_agent
from research_agent.inno.environment.docker_env import DockerEnv
from research_agent.inno.environment.local_env import LocalEnv
from research_agent.inno.environment.markdown_browser import RequestsMarkdownBrowser
from research_agent.constant import CHEEP_MODEL, COMPLETION_MODEL


class ReproducibilityFlow(FlowModule):
    """
    Workflow for evaluating reproducibility of social science papers.
    
    The workflow consists of four agents:
    1. Setup Agent: Identifies files to run and configures environment
    2. Execution Agent: Executes code and fixes issues
    3. Scoring Agent: Compares results and assigns reproducibility score
    4. Summary Report Agent: Generates comprehensive markdown summary report
    """
    
    def __init__(
        self,
        cache_path: str,
        log_path: Union[str, None] = None,
        model: str = COMPLETION_MODEL,
        code_env: Union[DockerEnv, LocalEnv] = None,
        file_env: RequestsMarkdownBrowser = None,
        # Optional per‑agent model overrides (LLM names)
        setup_model: str | None = None,
        execution_model: str | None = None,
        scoring_model: str | None = None,
        summary_model: str | None = None,
    ):
        """
        Args:
            cache_path: Cache directory
            log_path: Optional log file path
            model: Default model used for the FlowModule client itself
            code_env: Code execution environment
            file_env: File browsing environment
            setup_model: Optional LLM model name for the Setup Agent
            execution_model: Optional LLM model name for the Execution Agent
            scoring_model: Optional LLM model name for the Scoring Agent
            summary_model: Optional LLM model name for the Summary Report Agent

        Model selection priority for each agent:
        1. Explicit argument (e.g., setup_model)
        2. Environment variable:
           - SETUP_AGENT_MODEL
           - EXECUTION_AGENT_MODEL
           - SCORING_AGENT_MODEL
           - SUMMARY_AGENT_MODEL
        3. Default constants (CHEEP_MODEL / COMPLETION_MODEL)
        """
        super().__init__(cache_path, log_path, model)

        # Resolve models for each agent (arguments > env vars > defaults)
        setup_model = (
            setup_model
            or os.getenv("SETUP_AGENT_MODEL")
            or CHEEP_MODEL
        )
        execution_model = (
            execution_model
            or os.getenv("EXECUTION_AGENT_MODEL")
            or CHEEP_MODEL
        )
        scoring_model = (
            scoring_model
            or os.getenv("SCORING_AGENT_MODEL")
            or COMPLETION_MODEL
        )
        summary_model = (
            summary_model
            or os.getenv("SUMMARY_AGENT_MODEL")
            or COMPLETION_MODEL
        )

        # Save environment references
        self.code_env = code_env
        self.file_env = file_env

        # Initialize agents
        self.setup_agent = AgentModule(
            get_setup_agent(model=setup_model, code_env=code_env, file_env=file_env),
            self.client,
            cache_path
        )

        self.execution_agent = AgentModule(
            get_execution_agent(model=execution_model, code_env=code_env, file_env=file_env),
            self.client,
            cache_path
        )

        self.scoring_agent = AgentModule(
            get_scoring_agent(
                model=scoring_model,
                code_env=code_env,
                file_env=file_env,
                execution_agent=self.execution_agent
            ),
            self.client,
            cache_path
        )

        self.summary_report_agent = AgentModule(
            get_summary_report_agent(
                model=summary_model,
                code_env=code_env,
                file_env=file_env
            ),
            self.client,
            cache_path
        )
    
    async def forward(
        self,
        workspace_dir: str,
        figures: List[str] = None,
        tables: List[str] = None,
        claims: List[str] = None,
        replication_package: str = "replication_package",
        paper_path: str = "paper.pdf",
        agents_to_run: List[str] = None,
        *args,
        **kwargs
    ):
        """
        Execute the reproducibility evaluation workflow.
        
        Args:
            workspace_dir: Main directory containing paper.pdf and replication_package
            figures: List of figure identifiers to reproduce (e.g., ["Figure 1", "Figure 2"])
            tables: List of table identifiers to reproduce (e.g., ["Table 1", "Table 2"])
            claims: List of text claims to verify (e.g., ["Claim 1: ...", "Claim 2: ..."])
            replication_package: Name of replication package directory (default: "replication_package")
            paper_path: Path to paper PDF (default: "paper.pdf")
            agents_to_run: List of agent names to execute. Valid values: "setup", "execution", "scoring", "summary".
                          If None or empty, all agents will run. Agents are executed in order, but you can skip any.
                          Example: ["setup", "execution"] to run only setup and execution agents.
        """
        if figures is None:
            figures = []
        if tables is None:
            tables = []
        if claims is None:
            claims = []
        
        # Convert relative paths to absolute paths relative to workspace_dir
        workspace_dir = os.path.abspath(workspace_dir)
        if not os.path.isabs(paper_path):
            paper_path = os.path.join(workspace_dir, paper_path)
        if not os.path.isabs(replication_package):
            replication_package = os.path.join(workspace_dir, replication_package)
        
        # Prepare context variables for all agents
        base_context = {
            "workspace_dir": workspace_dir,
            "replication_package": replication_package,
            "paper_path": paper_path,
            "figures": figures,
            "tables": tables,
            "claims": claims
        }
        
        print("=" * 80)
        print("REPRODUCIBILITY EVALUATION WORKFLOW")
        print("=" * 80)
        print(f"Workspace: {workspace_dir}")
        print(f"Paper: {paper_path}")
        print(f"Replication Package: {replication_package}")
        print(f"Figures to reproduce: {figures}")
        print(f"Tables to reproduce: {tables}")
        print(f"Claims to verify: {claims}")
        print("=" * 80)
        
        # Determine which agents to run
        valid_agents = {"setup", "execution", "scoring", "summary"}
        if agents_to_run is None:
            agents_to_run = ["setup", "execution", "scoring", "summary"]
        else:
            # Validate agent names
            invalid_agents = set(agents_to_run) - valid_agents
            if invalid_agents:
                raise ValueError(f"Invalid agent names: {invalid_agents}. Valid names are: {valid_agents}")
            agents_to_run = list(agents_to_run)  # Convert to list if it's not
        
        print(f"Agents to run: {agents_to_run}")
        print("=" * 80)
        
        # Helper function to get directory tree
        def get_directory_tree_str(dir_path: str) -> str:
            """Get directory tree structure as string."""
            try:
                lines = []
                dir_path = os.path.abspath(dir_path)  # Ensure absolute path
                first = True
                for root, dirs, files in os.walk(dir_path):
                    level = root.replace(dir_path, '').count(os.sep)
                    indent = ' ' * 2 * level
                    if first:
                        # First line shows the full absolute path
                        lines.append(f'{dir_path}/')
                        first = False
                    else:
                        # Subsequent lines show relative directory names
                        lines.append(f'{indent}{os.path.basename(root)}/')
                    subindent = ' ' * 2 * (level + 1)
                    for f in files:
                        lines.append(f'{subindent}{f}')
                return '\n'.join(lines)
            except Exception as e:
                return f"Error generating directory tree: {e}"
        
        # Get directory tree for workspace
        workspace_tree = get_directory_tree_str(workspace_dir)
        
        # Step 1: Setup Agent
        setup_result = None
        setup_context = {}
        
        # Build the items to reproduce list (needed for all agents)
        items_to_reproduce = []
        if figures:
            items_to_reproduce.extend([f"Figure {f}" if not f.startswith("Figure") else f for f in figures])
        if tables:
            items_to_reproduce.extend([f"Table {t}" if not t.startswith("Table") else t for t in tables])
        if claims:
            items_to_reproduce.extend([f"Claim: {c}" if not c.startswith("Claim") else c for c in claims])
        
        items_list = "\n".join([f"- {item}" for item in items_to_reproduce]) if items_to_reproduce else "None"
        
        # Generate JSON structure example for setup_summary.json
        setup_json_example = {}
        for item in items_to_reproduce[:1]:
            setup_json_example[item] = {
                "related_files": ["absolute/path/to/file1.R", "absolute/path/to/file2.py"],
                "execution_steps": ["Run the script absolute/path/to/file1.R", "Run the script absolute/path/to/file2.py"]
            }
        
        setup_query = f"""Identify files to run and configure environment.

Items to reproduce:
{items_list}

Directory structure:
{workspace_tree}

Tasks:
1. Read README/docs, then use `read_file` to read code files
2. Identify required packages from code, then install using `execute_python_code`. The environment already includes R, Stata, and Python, so you don't need to check and install them.
3. Create `setup_summary.json` at `{workspace_dir}` with the following structure (use absolute paths):

{json.dumps(setup_json_example, indent=2, ensure_ascii=False)}

The JSON structure should be:
- Each key is an item to reproduce (Figure X, Table Y, or Claim: Z)
- Each value contains:
  - `related_files`: List of absolute file paths needed to reproduce this item
  - `execution_steps`: List of execution step descriptions (e.g., ["Run the script absolute/path/to/file1.R", "Run the script absolute/path/to/file2.py"]). Each step should ONLY describe the execution order - what file to run or what action to take. DO NOT mention output file paths or where results are saved. Focus only on the execution sequence. If only one file needs to be executed, use a single step like ["Run the script absolute/path/to/file1.R"]. If multiple files are needed, list them in order as separate steps.

CRITICAL REQUIREMENT:
- The final `setup_summary.json` MUST include EVERY item listed in "Items to reproduce".
- No item may be omitted for any reason.
- If an item fails to run or produce outputs, it MUST still appear as a key in the JSON, with empty `related_files` and an explanation in `execution_steps`.
- Missing any reproduction item is considered an incorrect and incomplete result.
"""
        
        if "setup" in agents_to_run:
            print("\n[STEP 1] Setup Agent: Identifying files and configuring environment...")
            setup_messages = [{"role": "user", "content": setup_query}]
            setup_result, setup_context = await self.setup_agent(setup_messages, base_context)
            print(f"\nSetup Agent completed")
        else:
            print("\n[STEP 1] Setup Agent: SKIPPED (not in agents_to_run)")
        
        # Note: Setup agent no longer generates a score
        
        # Read setup summary
        setup_summary_path = os.path.join(workspace_dir, "setup_summary.json")
        if os.path.exists(setup_summary_path):
            with open(setup_summary_path, "r", encoding="utf-8") as f:
                setup_summary = json.load(f)
            
            # Convert relative paths to absolute paths if needed
            def to_absolute_path(file_path: str) -> str:
                if os.path.isabs(file_path):
                    return file_path
                # Try relative to workspace_dir first
                abs_path = os.path.join(workspace_dir, file_path)
                if os.path.exists(abs_path):
                    return os.path.abspath(abs_path)
                # Try relative to replication_package
                abs_path = os.path.join(replication_package, file_path)
                if os.path.exists(abs_path):
                    return os.path.abspath(abs_path)
                # Return as-is if not found (let execution agent handle it)
                return os.path.abspath(os.path.join(workspace_dir, file_path))
            
            # New format: item keys with related_files and execution_steps
            # Extract all unique files from all items
            all_files = set()
            for item_data in setup_summary.values():
                if isinstance(item_data, dict):
                    related_files = item_data.get("related_files", [])
                    all_files.update(related_files)
            files_to_run = list(all_files)
            # For execution_order, we use all unique files (execution_steps are item-specific)
            execution_order = files_to_run
            
            files_to_run = [to_absolute_path(f) for f in files_to_run]
            execution_order = [to_absolute_path(f) for f in execution_order]
        else:
            print("Warning: setup_summary.json not found, proceeding with defaults")
            files_to_run = []
            execution_order = []
        
        # Step 2: Execution Agent
        execution_result = None
        exec_context = {}
        
        if "execution" in agents_to_run:
            print("\n[STEP 2] Execution Agent: Executing code and fixing issues...")
        # Read setup_summary to pass reproduction_mapping to execution agent
        setup_summary_for_execution = None
        if os.path.exists(setup_summary_path):
            try:
                with open(setup_summary_path, "r", encoding="utf-8") as f:
                    setup_summary_for_execution = json.load(f)
            except:
                pass
        
        execution_context = {
            **base_context,
            "files_to_run": files_to_run,
            "execution_order": execution_order,
            "setup_summary": setup_summary_for_execution
        }
        
        # Note: Setup agent does not provide a score
        
        # Generate JSON structure example for execution_summary.json
        execution_json_example = {}
        for item in items_to_reproduce[:1]:
            execution_json_example[item] = {
                "original_files": ["absolute/path/to/original.R"],
                "modified_files": ["absolute/path/to/original_modified.R"],
                "modifications": ["Changed data path from relative to absolute", "Fixed package import"],
                "output_files": ["absolute/path/to/figure1.png"],
                # "log_files": ["absolute/path/to/original_modified.log"]
            }
        
        # Format setup_summary for display in query
        setup_summary_full_str = "Not available"
        if setup_summary_for_execution:
            setup_summary_full_str = json.dumps(setup_summary_for_execution, indent=2, ensure_ascii=False)
        
        execution_query = f"""Execute files and reproduce results.

Items to reproduce:
{items_list}

**Previous Agent (Setup Agent) Summary**:
{setup_summary_full_str}

Directory structure:
{workspace_tree}

Tasks:
1. Read code files to be run and analyze input/output paths for data files
2. Create modified files (file_modified.ext) ensuring paths for data loading and saving outputs as files matching items to reproduce
3. Execute modified files and fix any errors that occur
4. Verify that output files for items to reproduce actually exist
5. Create `execution_summary.json` at {workspace_dir} with the following structure (use absolute paths):

{json.dumps(execution_json_example, indent=2)}

The JSON structure should be:
- Each key is an item to reproduce (Figure X, Table Y, or Claim: Z)
- Each value contains:
  - `original_files`: List of absolute paths to original code files used
  - `modified_files`: List of absolute paths to modified code files (if any modifications were made, otherwise can be empty or same as original_files)
  - `modifications`: List of descriptions of what modifications were made (e.g., "Changed data path from relative to absolute", "Fixed package import issue")
  - `output_files`: List of absolute paths to generated output files (figures, tables, data files, etc.) that correspond to this item
  
Focus on the items to reproduce - organize everything around them, not around the files.

CRITICAL REQUIREMENT:
- The final `execution_summary.json` MUST include EVERY item listed in "Items to reproduce".
- No item may be omitted for any reason.
- If an item fails to run or produce outputs, it MUST still appear as a key in the JSON, with empty `output_files` and an explanation in `modifications`. The `modifications` section details why it failed.
- Missing any reproduction item is considered an incorrect and incomplete result.

"""
        
        if "execution" in agents_to_run:
            execution_messages = [{"role": "user", "content": execution_query}]
            execution_result, exec_context = await self.execution_agent(execution_messages, execution_context)
            print(f"\nExecution Agent completed")
        else:
            print("\n[STEP 2] Execution Agent: SKIPPED (not in agents_to_run)")
        
        # Read execution score from file (always try to read, even if agent was skipped)
        execution_score = None
        execution_score_path = os.path.join(workspace_dir, "execution_score.json")
        if os.path.exists(execution_score_path):
            try:
                with open(execution_score_path, "r", encoding="utf-8") as f:
                    execution_score = json.load(f)
            except:
                pass
        
        # Read execution summary if it exists
        execution_summary_path = os.path.join(workspace_dir, "execution_summary.json")
        execution_summary = None
        if os.path.exists(execution_summary_path):
            try:
                with open(execution_summary_path, "r", encoding="utf-8") as f:
                    execution_summary = json.load(f)
                print(f"\nExecution summary loaded from {execution_summary_path}")
            except Exception as e:
                print(f"\nWarning: Failed to read execution_summary.json: {e}")
        else:
            print(f"\nWarning: execution_summary.json not found at {execution_summary_path}")
        
        # Get execution agent code quality assessment info
        execution_score_info = ""
        if execution_score:
            assessment = execution_score.get('code_quality_assessment', 'N/A')
            reason = execution_score.get('reason', 'N/A')
            execution_score_info = f"""
**Previous Agent (Execution Agent) Code Quality Assessment**:
- Code Quality Assessment: {assessment}
- Reason: {reason}

**IMPORTANT**: This assessment evaluates CODE QUALITY based on logical analysis of the code, NOT based on whether outputs were successfully reproduced. The assessment reflects whether the code contains logical errors, not whether it runs successfully in a specific environment.
"""
        else:
            execution_score_info = "**Previous Agent (Execution Agent) Code Quality Assessment**: Not available"
        
        # Step 3: Scoring Agent
        scoring_result = None
        scoring_context_final = {}
        
        # Step 3: Scoring Agent
        if "scoring" in agents_to_run:
            print("\n[STEP 3] Scoring Agent: Comparing results and assigning score...")
        
        scoring_context = {
            **base_context,
            "execution_summary": execution_summary,
            "execution_summary_path": execution_summary_path  # Keep path for reference, but summary is in context
        }
        
        # Format execution_summary for display in query
        execution_summary_str = "Not available"
        if execution_summary:
            execution_summary_str = json.dumps(execution_summary, indent=2, ensure_ascii=False)
        
        # Generate JSON structure example for scoring_summary.json
        scoring_json_example = {}
        for item in items_to_reproduce[:1]:
            scoring_json_example[item] = {
                "output_paths": ["absolute/path/to/output.png", "absolute/path/to/output.csv"],
                "evaluation": "Description of comparison result and reproducibility assessment",
                "original_item_content": "Original item content or output path (e.g., path to extracted figure/table from PDF, or text content for claims)"
            }
        
        scoring_query = f"""Compare reproduced results with paper findings and assign score (1-4).

Items to reproduce:
{items_list}

**Previous Agent (Execution Agent) Summary**:
{execution_summary_str}

{execution_score_info}

Directory structure:
{workspace_tree}

Tasks:
1. FIRST STEP: Use `pdf_extract_figures_tables` to extract figures and tables from the paper PDF and save them to {workspace_dir}/elements folder
2. Compare each item to reproduce with its reproduced outputs
3. Create `scoring_summary.json` at `{workspace_dir}` with the following structure (use absolute paths):

{json.dumps(scoring_json_example, indent=2, ensure_ascii=False)}

The JSON structure should be:
- Each key is an item to reproduce (Figure X, Table Y, or Claim: Z)
- Each value contains:
  - `output_paths`: List of absolute paths to reproduced output files for this item (from execution_summary output_files)
  - `evaluation`: Text description of the comparison result and reproducibility assessment for this item
  - `original_item_content`: The original item content or output that needs to be reproduced. For figures/tables, this should be the absolute path to the extracted figure/table from the PDF (saved in {workspace_dir}/elements). For claims, this should be the text content of the claim from the paper.
"""
        
        if "scoring" in agents_to_run:
            scoring_messages = [{"role": "user", "content": scoring_query}]
            scoring_result, scoring_context_final = await self.scoring_agent(scoring_messages, scoring_context)
            print(f"\nScoring Agent completed")
        else:
            print("\n[STEP 3] Scoring Agent: SKIPPED (not in agents_to_run)")
        
        # Read final score (always try to read, even if scoring agent was skipped)
        score_path = os.path.join(workspace_dir, "reproducibility_score.json")
        final_score = "Unknown"
        if os.path.exists(score_path):
            try:
                with open(score_path, "r", encoding="utf-8") as f:
                    score_data = json.load(f)
                final_score = score_data.get("score", score_data.get("reproducibility_score", "Unknown"))
                if isinstance(final_score, (int, float)):
                    final_score = str(final_score)
            except:
                pass
        
        if final_score != "Unknown":
            print("\n" + "=" * 80)
            print(f"FINAL REPRODUCIBILITY SCORE: {final_score}")
            print("=" * 80)
        else:
            print("\nWarning: reproducibility_score.json not found or score not available")
        
        # Step 4: Summary Report Agent
        summary_report_result = None
        summary_report_context_final = {}
        
        # Step 4: Summary Report Agent
        if "summary" in agents_to_run:
            print("\n[STEP 4] Summary Report Agent: Generating comprehensive markdown report...")
        
        # Read all summary files (always read, even if summary agent is skipped)
        setup_summary = {}
        execution_summary = {}
        scoring_summary = {}
        
        setup_summary_path = os.path.join(workspace_dir, "setup_summary.json")
        execution_summary_path = os.path.join(workspace_dir, "execution_summary.json")
        scoring_summary_path = os.path.join(workspace_dir, "scoring_summary.json")
        
        if os.path.exists(setup_summary_path):
            try:
                with open(setup_summary_path, "r", encoding="utf-8") as f:
                    setup_summary = json.load(f)
            except:
                pass
        
        if os.path.exists(execution_summary_path):
            try:
                with open(execution_summary_path, "r", encoding="utf-8") as f:
                    execution_summary = json.load(f)
            except:
                pass
        
        if os.path.exists(scoring_summary_path):
            try:
                with open(scoring_summary_path, "r", encoding="utf-8") as f:
                    scoring_summary = json.load(f)
            except:
                pass
        
        summary_report_context = {
            **base_context
        }
        
        # Create query with all summary information
        summary_report_query = f"""Create a comprehensive markdown summary report based on the following information:

**Setup Summary**:
{json.dumps(setup_summary, indent=2, ensure_ascii=False)}

**Execution Summary**:
{json.dumps(execution_summary, indent=2, ensure_ascii=False)}

**Scoring Summary**:
{json.dumps(scoring_summary, indent=2, ensure_ascii=False)}

**Final Score**: {final_score}

Please create the markdown report and save it to: {os.path.join(workspace_dir, "reproducibility_report.md")}
"""
        
        if "summary" in agents_to_run:
            summary_report_messages = [{"role": "user", "content": summary_report_query}]
            summary_report_result, summary_report_context_final = await self.summary_report_agent(summary_report_messages, summary_report_context)
            print(f"\nSummary Report Agent completed")
            
            # Convert markdown to PDF using Python
            markdown_path = os.path.join(workspace_dir, "reproducibility_report.md")
            pdf_path = os.path.join(workspace_dir, "reproducibility_report.pdf")
            
            if os.path.exists(markdown_path):
                print("\nConverting markdown report to PDF using Python...")
            try:
                # Read markdown content
                with open(markdown_path, "r", encoding="utf-8") as f:
                    md_content = f.read()
                
                # Convert to PDF using Python
                pdf_created = False
                
                # Try using markdown + weasyprint
                try:
                    import markdown  # type: ignore
                    from weasyprint import HTML  # type: ignore
                    html_content = markdown.markdown(md_content, extensions=['tables', 'fenced_code'])
                    HTML(string=html_content).write_pdf(pdf_path)
                    print(f"[SUCCESS] PDF report created at: {pdf_path}")
                    pdf_created = True
                except ImportError:
                    pass
                except Exception as e:
                    print(f"[WARNING] Error with markdown+weasyprint: {str(e)}")
                
                if not pdf_created:
                    # Fallback: try using markdown2 + pdfkit
                    try:
                        import markdown2  # type: ignore
                        import pdfkit  # type: ignore
                        html_content = markdown2.markdown(md_content, extras=['tables', 'fenced-code-blocks'])
                        pdfkit.from_string(html_content, pdf_path)
                        print(f"[SUCCESS] PDF report created at: {pdf_path}")
                        pdf_created = True
                    except ImportError:
                        pass
                    except Exception as e:
                        print(f"[WARNING] Error with markdown2+pdfkit: {str(e)}")
                
                if not pdf_created:
                    # Fallback: try using pypandoc
                    try:
                        import pypandoc  # type: ignore
                        pypandoc.convert_file(markdown_path, 'pdf', outputfile=pdf_path)
                        print(f"[SUCCESS] PDF report created at: {pdf_path}")
                        pdf_created = True
                    except ImportError:
                        pass
                    except Exception as e:
                        print(f"[WARNING] Error with pypandoc: {str(e)}")
                
                if not pdf_created:
                    print("[WARNING] No PDF conversion library available. Install one of: markdown+weasyprint, markdown2+pdfkit, or pypandoc")
            except Exception as e:
                print(f"[WARNING] Error during PDF conversion: {str(e)}")
        else:
            print("\n[STEP 4] Summary Report Agent: SKIPPED (not in agents_to_run)")
        
        return {
            "setup_result": setup_result,
            "execution_result": execution_result,
            "scoring_result": scoring_result,
            "summary_report_result": summary_report_result,
            "final_score": final_score if final_score != "Unknown" else None
        }

