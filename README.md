# PaperRepro: Automated Computational Reproducibility Assessment for Social Science Papers

This repository provides an automated system for assessing the computational reproducibility of social science papers. The system uses AI agents to understand replication packages, execute code, and evaluate reproducibility scores.

## Installation

### Using uv (Recommended)

We recommend using [uv](https://docs.astral.sh/uv/) for fast and reliable package management:

```bash
# Install uv
curl -LsSf https://astral.sh/uv/install.sh | sh
source ~/.bashrc  # or restart your terminal

# Clone the repository
git clone https://github.com/luolin101/PaperRepro.git
cd PaperRepro

# Create and activate virtual environment
uv venv --python 3.11
source ./.venv/bin/activate  # On Windows: .\.venv\Scripts\activate

# Install dependencies
uv pip install -e .
```

## Configuration

Create a `.env` file in the project root directory with your configuration. Here's an example:

```bash
# Required: LLM API Configuration
OPENAI_API_BASE=http://your-api-server.com/v1/
OPENAI_API_KEY=sk-your-key-here

# Optional: Agent Models (uses default if not set)
SETUP_AGENT_MODEL=gpt-5
EXECUTION_AGENT_MODEL=gpt-5
SCORING_AGENT_MODEL=gpt-5
SUMMARY_AGENT_MODEL=gpt-5

# Optional: Stata Configuration (if using Stata)
STATA_PATH=Stata Path
STATA_EDITION=mp

# Optional: Cache Configuration
SKIP_CACHE=0
```

**Required variables**: `OPENAI_API_BASE` and `OPENAI_API_KEY` must be set. Other variables are optional:
- Agent models: Specify different models for each agent (defaults used if not set)
- Stata: Required only if you need to execute Stata code (`STATA_PATH` and `STATA_EDITION`)
- MATLAB: Automatically detected from system PATH if installed
- Cache: Set `SKIP_CACHE=1` to disable caching

## Usage

### Basic Usage

Run the reproducibility evaluation workflow:

```bash
cd research_agent
python examples/run_reproducibility_evaluation.py <workspace_dir>
```

### Workspace Directory Structure

The `workspace_dir` must contain the following files and directories:

```
workspace_dir/
├── paper.pdf                    # The paper PDF to evaluate
├── should_reproduce.txt         # List of items to reproduce (one per line, e.g., "Figure 1", "Table 2", "Claim 1")
└── replication_package/         # Directory containing source code and data
    ├── README.md                # (Optional) Documentation for the replication package
    ├── main.R                   # Example: R scripts
    └── ... 
```

### Agent Selection

Control which agents run using the `AGENTS_TO_RUN` environment variable (4-digit string: Setup, Execution, Scoring, Summary):

```bash
# Run all agents (default: 1111)
export AGENTS_TO_RUN=1111
python examples/run_reproducibility_evaluation.py workspace_dir

# Run only Setup and Execution agents
export AGENTS_TO_RUN=1100
python examples/run_reproducibility_evaluation.py workspace_dir
```

## Output

After running the evaluation, the following files will be generated in the workspace directory:

- `setup_summary.json`: Summary of setup analysis and execution plan
- `execution_summary.json`: Summary of code execution results
- `scoring_summary.json`: Summary of scoring analysis
- `reproducibility_score.json`: Reproducibility score
- `cache_reproducibility/`: Cached agent outputs (if caching is enabled)

## Workflow Overview

The system uses multiple AI agents in sequence:

1. **Setup Agent**: Analyzes the replication package, identifies dependencies, and creates an execution plan.
2. **Execution Agent**: Reads code files, modifies paths if needed, executes scripts, and generates output files.
3. **Scoring Agent**: Compares generated outputs with paper figures/tables and assigns reproducibility scores.
4. **Summary Agent**: Generates a final summary report.

## Supported Languages

The system supports code execution in:

- **R**: Via `Rscript` command
- **Python**: Via Python interpreter
- **Stata**: Via `pystata` (requires Stata installation and configuration)
- **MATLAB**: Via MATLAB command line (requires MATLAB in system PATH)

## Troubleshooting

### API Configuration Errors

If you see errors about missing API configuration:

```
Error: OPENAI_API_BASE environment variable is not set.
```

Make sure you have set `OPENAI_API_BASE` and `OPENAI_API_KEY` in your `.env` file or environment variables.

### Stata Configuration

If you encounter Stata-related errors:

1. Ensure Stata is installed
2. Install `pystata`: `pip install pystata`
3. Set `STATA_PATH` in your `.env` file to point to your Stata installation directory
4. Set `STATA_EDITION` to match your Stata license (mp, se, or be)

### MATLAB Configuration

If MATLAB execution fails:

1. Ensure MATLAB is installed
2. Verify MATLAB is in your system PATH by running `matlab` from command line
3. The system will automatically detect and use MATLAB if available

### Encoding Issues (Windows)

If you encounter Unicode encoding errors on Windows:

- The system includes automatic handling for GBK encoding issues
- If problems persist, try setting your terminal encoding to UTF-8

## Benchmark Evaluation

For benchmark evaluation, you can use the REPRO-Bench dataset. Refer to [REPRO-Bench](https://github.com/uiuc-kang-lab/REPRO-Bench) for more details.

### Preparing the Dataset

The REPRO-Bench dataset is hosted on Hugging Face:

```bash
git clone https://huggingface.co/datasets/chuxuan/REPRO-Bench
cd REPRO-Bench
git lfs pull
```

After downloading, note the directory path. Each task instance in the dataset contains a `paper.pdf`, `should_reproduce.txt`, and `replication_package/` directory.

### Running Evaluation

For each task instance, use the following command:

```bash
cd research_agent
python examples/run_reproducibility_evaluation.py <workspace_dir>
```

Where `<workspace_dir>` is the path to the task instance directory (containing `paper.pdf`, `should_reproduce.txt`, and `replication_package/`).

For REPRO-Bench-S evaluation, refer to the [benchmark-s README](benchmark/README.md) for detailed instructions.

## Citation

If you use this tool in your research, please cite:

```bibtex
@misc{paperrepro2025,
  title={PaperRepro: Automated Computational Reproducibility Assessment for Social Science Papers},
  author={Your Name},
  year={2025},
  url={https://github.com/your-org/AI-Researcher}
}
```

## Acknowledgement 

* [AI-Researcher](https://github.com/HKUDS/AI-Researcher)
* [LiteLLM](https://github.com/BerriAI/litellm)
