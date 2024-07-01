from __future__ import annotations

from typing import TYPE_CHECKING

from fastapi import FastAPI, HTTPException
from starlette.status import (
    HTTP_201_CREATED,
    HTTP_204_NO_CONTENT,
    HTTP_400_BAD_REQUEST,
)

from .database import Database
from .models import Status

if TYPE_CHECKING:
    from collections.abc import Awaitable, Callable

    from fastapi import Request, Response

MY_ROBOT = "Bender"
DATABASE = r"robots.db"

app = FastAPI()
db = Database(DATABASE)

@app.middleware("http")
async def db_session_middleware(request: Request, call_next: Callable[[Request], Awaitable[Response]]) -> Response:
    """Middleware to create a database session per request. Not every
    request needs a database session, but this is a simple example
    that will simplify the code slightly a bit.

    Args:
        request (:obj:`Request`): Request object as received from the HTTP session.
            Given by :obj:`FastAPI`.
        call_next (Awaitable[Request]): Next call to await to. Given by
            :obj:`FastAPI`.

    Returns:
        :obj:`Response`: The HTTP response of the request.
    """
    with db:
        db.create_table()
        response = await call_next(request)
    return response

@app.get("/")
async def root() -> str:
    """The demo that verifies our application. Say hello to Bender! :)

    Returns:
        :obj:`str`: The robot name.
    """
    return MY_ROBOT

@app.get("/{status}")
async def echo_status(status: Status) -> str:
    """Sets an aribtrary status for Bender.

    Args:
        status (:obj:`Status`): The accepted status

    Returns:
        :obj:`str`: What's the robot status?
    """
    return f"{MY_ROBOT} is {status}"

@app.get("/robot/{name}")
async def get_robot(name: str) -> tuple[int, str, str]:
    robot = db.get_robot(name)

    return {"id": robot[0], "name": robot[1], "status": robot[2]}

@app.post("/robot/{name}/{status}", status_code=HTTP_201_CREATED)
async def new_robot(name: str, status: Status) -> None:
    if db.robot_exists(name):
        raise HTTPException(status_code=HTTP_400_BAD_REQUEST, detail="Robot already exists")

    db.insert_robot(name, status)

@app.put("/robot/{name}/{status}", status_code=HTTP_204_NO_CONTENT)
async def update_robot(name: str, status: Status) -> None:
    if not db.robot_exists(name):
        raise HTTPException(status_code=HTTP_400_BAD_REQUEST, detail="Robot not found")

    db.update_robot(name, status)

@app.delete("/robot/{name}")
async def delete_robot(name: str) -> None:
    if not db.robot_exists(name):
        raise HTTPException(status_code=HTTP_400_BAD_REQUEST, detail="Robot not found")

    db.delete_robot(name)
