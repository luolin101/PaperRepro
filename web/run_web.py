"""
Convenience script to start the PaperRepro Web UI.
Usage: python web/run_web.py   or   uv run python web/run_web.py
"""
import uvicorn

if __name__ == "__main__":
    uvicorn.run(
        "web.main:app",
        host="0.0.0.0",
        port=8000,
        reload=True,
    )
