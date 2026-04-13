"""Utilities for loading externalized agent prompt templates."""
from pathlib import Path


PROMPTS_DIR = Path(__file__).resolve().parents[2] / "prompts"


class _PromptVariables(dict):
    def __missing__(self, key):
        return "{" + key + "}"


def render_prompt(prompt_name: str, **variables) -> str:
    """Load a prompt template from the repository prompts directory."""
    prompt_path = PROMPTS_DIR / prompt_name
    template = prompt_path.read_text(encoding="utf-8")
    return template.format_map(_PromptVariables(variables))
