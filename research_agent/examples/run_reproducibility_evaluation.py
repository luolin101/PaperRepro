"""
Script to run reproducibility evaluation workflow.

Usage:
    python run_reproducibility_evaluation.py <workspace_dir>

The workspace_dir should contain:
    - paper.pdf: The paper to evaluate
    - replication_package/: Directory with source code and data
    - should_reproduce.txt: List of items to reproduce (one per line)
        Format: Figure 1, Table 1, Claim 1, etc.
"""
import asyncio
import os
import sys
import builtins
from pathlib import Path
from research_agent.inno.workflow.reproducibility_flow import ReproducibilityFlow
from research_agent.inno.environment.local_env import LocalEnv, LocalEnvConfig
from research_agent.inno.environment.markdown_browser import RequestsMarkdownBrowser

# 保存原始内置 print，避免 safe_print 递归调用自己
_ORIGINAL_PRINT = builtins.print


def safe_print(*args, **kwargs):
    """
    Print wrapper that avoids UnicodeEncodeError on GBK consoles by
    replacing characters that cannot be encoded.
    """
    try:
        _ORIGINAL_PRINT(*args, **kwargs)
    except UnicodeEncodeError:
        encoding = getattr(sys.stdout, "encoding", None) or "utf-8"
        safe_args = []
        for a in args:
            s = str(a)
            try:
                s = s.encode(encoding, errors="replace").decode(encoding, errors="replace")
            except Exception:
                s = s.encode("ascii", errors="replace").decode("ascii", errors="replace")
            safe_args.append(s)
        _ORIGINAL_PRINT(*safe_args, **kwargs)

# 全局替换内置 print，避免在 workflow/agent 代码里的普通 print
# 因 GBK 编码问题导致整个流程中断。
builtins.print = safe_print

# Load environment variables from .env file if it exists
from dotenv import load_dotenv
load_dotenv()

# Read API configuration from environment variables (required)
# Users must set these in their .env file or environment
OPENAI_API_BASE = os.getenv("OPENAI_API_BASE")
OPENAI_API_KEY = os.getenv("OPENAI_API_KEY")

if not OPENAI_API_BASE:
    safe_print("Error: OPENAI_API_BASE environment variable is not set.")
    safe_print("Please set it in your .env file or environment variables.")
    sys.exit(1)

if not OPENAI_API_KEY:
    safe_print("Error: OPENAI_API_KEY environment variable is not set.")
    safe_print("Please set it in your .env file or environment variables.")
    sys.exit(1)

os.environ["OPENAI_API_BASE"] = OPENAI_API_BASE
os.environ["OPENAI_API_KEY"] = OPENAI_API_KEY

# SKIP_CACHE is optional (defaults to not skipping if not set)
if os.getenv("SKIP_CACHE", "").lower() in ("1", "true", "yes"):
    os.environ["SKIP_CACHE"] = "1"
def parse_should_reproduce(should_reproduce_path: str):
    """
    Parse should_reproduce.txt file to extract figures, tables, and claims.
    
    Args:
        should_reproduce_path: Path to should_reproduce.txt file
    
    Returns:
        Tuple of (figures, tables, claims) lists
    """
    with open(should_reproduce_path, 'r', encoding='utf-8') as file:
        reproduction_list = [line.strip() for line in file.readlines() if len(line.strip()) > 0]
    
    figures = [item for item in reproduction_list if item.startswith('Figure')]
    tables = [item for item in reproduction_list if item.startswith('Table')]
    claims = [item for item in reproduction_list if item.startswith('Claim')]
    
    return figures, tables, claims


def parse_agents_to_run(agents_str: str) -> list:
    """
    Convert agent string format to list format.
    
    Args:
        agents_str: String of 4 digits, each representing an agent (1=run, 0=skip)
                   Format: "SESC" where:
                   - S = Setup (position 0)
                   - E = Execution (position 1)  
                   - S = Scoring (position 2)
                   - C = Summary (position 3)
                   Examples:
                   - "0001" = only summary
                   - "0010" = only scoring
                   - "0100" = only execution
                   - "1000" = only setup
                   - "1111" = all agents
                   - "1100" = setup and execution
    
    Returns:
        List of agent names to run
    """
    agent_names = ["setup", "execution", "scoring", "summary"]
    
    if len(agents_str) != 4:
        raise ValueError(f"agents_str must be exactly 4 characters, got: {agents_str}")
    
    agents_to_run = []
    for i, char in enumerate(agents_str):
        if char not in ['0', '1']:
            raise ValueError(f"Each character in agents_str must be '0' or '1', got: {char}")
        if char == '1':
            agents_to_run.append(agent_names[i])
    
    return agents_to_run


async def main(workspace_dir: str):
    """
    Run reproducibility evaluation workflow.
    
    Args:
        workspace_dir: Main directory containing paper.pdf, replication_package/, and should_reproduce.txt
    """
    workspace_dir = os.path.abspath(workspace_dir)
    
    # Check if workspace directory exists
    if not os.path.exists(workspace_dir):
        safe_print(f"Error: Workspace directory does not exist: {workspace_dir}")
        sys.exit(1)
    
    # Check for required files
    paper_path = os.path.join(workspace_dir, "paper.pdf")
    should_reproduce_path = os.path.join(workspace_dir, "should_reproduce.txt")
    replication_package = os.path.join(workspace_dir, "replication_package")
    
    if not os.path.exists(paper_path):
        safe_print(f"Error: paper.pdf not found in {workspace_dir}")
        sys.exit(1)
    
    if not os.path.exists(should_reproduce_path):
        safe_print(f"Error: should_reproduce.txt not found in {workspace_dir}")
        sys.exit(1)
    
    if not os.path.exists(replication_package):
        safe_print(f"Warning: replication_package directory not found in {workspace_dir}")
        safe_print("Creating replication_package directory...")
        os.makedirs(replication_package, exist_ok=True)
    
    # Parse should_reproduce.txt
    safe_print(f"Reading {should_reproduce_path}...")
    figures, tables, claims = parse_should_reproduce(should_reproduce_path)
    
    safe_print(f"\nFound {len(figures)} figures, {len(tables)} tables, {len(claims)} claims to reproduce")
    if figures:
        safe_print(f"  Figures: {', '.join(figures)}")
    if tables:
        safe_print(f"  Tables: {', '.join(tables)}")
    if claims:
        safe_print(f"  Claims: {', '.join(claims)}")
    
    # Setup cache path
    cache_path = os.path.join(workspace_dir, "cache_reproducibility")
    os.makedirs(cache_path, exist_ok=True)
    
    # Setup local environment
    safe_print("\nSetting up local environment...")
    local_config = LocalEnvConfig(
        workplace_name="workplace",
        local_root=workspace_dir,
        create_workplace=False
    )
    code_env = LocalEnv(local_config)
    code_env.init_container()
    
    # Setup file browser environment
    file_env = RequestsMarkdownBrowser(
        local_root=workspace_dir,
        workplace_name="workplace",
        viewport_size=1024 * 4
    )
    
    # 读取 agent 运行配置（默认保持原有行为: 只跑 summary，但支持通过环境变量覆盖）
    agents_str = os.getenv("AGENTS_TO_RUN", "1110")  # 例如: 1111=全部, 0010=只 scoring
    agents_to_run = parse_agents_to_run(agents_str)

    # 可选：通过环境变量为四个 agent 单独指定模型（如果不设，就用默认）
    setup_model = os.getenv("SETUP_AGENT_MODEL") or None
    execution_model = os.getenv("EXECUTION_AGENT_MODEL") or None
    scoring_model = os.getenv("SCORING_AGENT_MODEL") or None
    summary_model = os.getenv("SUMMARY_AGENT_MODEL") or None

    # Initialize workflow
    safe_print("Initializing reproducibility evaluation workflow...")
    flow = ReproducibilityFlow(
        cache_path=cache_path,
        log_path=None,
        code_env=code_env,
        file_env=file_env,
        setup_model=setup_model,
        execution_model=execution_model,
        scoring_model=scoring_model,
        summary_model=summary_model,
    )
    
    # Run the workflow
    safe_print("\n" + "=" * 80)
    safe_print("Starting Reproducibility Evaluation Workflow")
    safe_print("=" * 80)
    safe_print(f"Agents_to_run (SESC): {agents_str} -> {agents_to_run}")
    
    result = await flow(
        workspace_dir=workspace_dir,
        figures=figures,
        tables=tables,
        claims=claims,
        replication_package="replication_package",
        paper_path="paper.pdf",
        agents_to_run=agents_to_run
    )
    
    # Print final results
    safe_print("\n" + "=" * 80)
    safe_print("WORKFLOW COMPLETED")
    safe_print("=" * 80)
    
    if result.get('final_score'):
        safe_print(f"\n[SUCCESS] Final Reproducibility Score: {result['final_score']}")
        safe_print(f"\nCheck the following files for details:")
        safe_print(f"  - {workspace_dir}/setup_summary.json")
        safe_print(f"  - {workspace_dir}/execution_summary.json")
        safe_print(f"  - {workspace_dir}/reproducibility_score.json")
    else:
        safe_print("\n[WARNING] Could not retrieve final score")
        safe_print("Check the log files for details.")


if __name__ == "__main__":
    if len(sys.argv) < 2:
        safe_print("Usage: python run_reproducibility_evaluation.py <workspace_dir>")
        safe_print("\nExample:")
        safe_print("  python run_reproducibility_evaluation.py C:/Project/reproducibility_test")
        sys.exit(1)
    
    workspace_dir = sys.argv[1]
    
    # In batch mode we want to be more tolerant: log errors but avoid
    # non‑zero exit codes for unexpected exceptions so the batch
    # controller can continue and just record NA.
    _batch_mode = os.getenv("BATCH_MODE", "").lower() in ("1", "true", "yes")
    
    try:
        asyncio.run(main(workspace_dir))
    except KeyboardInterrupt:
        safe_print("\n\nWorkflow interrupted by user.")
        # For Ctrl+C we still exit with non‑zero to indicate user abort,
        # regardless of batch/interactive mode.
        sys.exit(1)
    except Exception as e:
        safe_print(f"\n\nError: {e}")
        import traceback
        traceback.print_exc()
        # Only treat this as fatal in interactive mode. In batch mode,
        # keep exit code 0 so the caller can continue and mark score as NA.
        if not _batch_mode:
            sys.exit(1)

