# REPRO-Bench-S Evaluation Guide

This guide explains how to evaluate your system on the REPRO-Bench-S dataset.

## Dataset Preparation

First, download the original REPRO-Bench dataset from Hugging Face:

```bash
git clone https://huggingface.co/datasets/chuxuan/REPRO-Bench
cd REPRO-Bench
git lfs pull
```

## Dataset Structure

The `benchmark` directory contains:

- **Corrected `should_reproduce.txt` files**: Each instance directory (e.g., `106/`, `15/`, `7/`) contains a corrected `should_reproduce.txt` file that should replace the original file in the REPRO-Bench dataset.

- **`ground_truth.json`**: Contains the ground truth labels and difficulty levels for each instance:
  - `instance`: Instance ID
  - `label`: Reproducibility score (1-4)
  - `level`: Difficulty level (1-3, where 1=easy, 2=medium, 3=hard)

## Evaluation Steps

1. **Prepare the workspace**: For each instance you want to evaluate, copy the corrected `should_reproduce.txt` from `benchmark/<instance_id>/should_reproduce.txt` to the corresponding instance directory in the REPRO-Bench dataset.

2. **Run evaluation**: Use the following command for each instance:

```bash
cd research_agent
python examples/run_reproducibility_evaluation.py <workspace_dir>
```

Where `<workspace_dir>` is the path to the instance directory in REPRO-Bench (containing `paper.pdf`, `should_reproduce.txt`, and `replication_package/`).

3. **Compare results**: After evaluation, compare the generated `reproducibility_score.json` with the ground truth labels in `ground_truth.json` to compute accuracy metrics.
