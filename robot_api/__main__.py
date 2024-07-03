from __future__ import annotations

from .api import app


if __name__ == "__main__":
    import uvicorn

    uvicorn.run(app)
