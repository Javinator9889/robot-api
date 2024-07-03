from __future__ import annotations

from typing import TYPE_CHECKING

from fastapi import FastAPI, HTTPException
from starlette.status import (
    HTTP_201_CREATED,
    HTTP_204_NO_CONTENT,
    HTTP_400_BAD_REQUEST,
    HTTP_404_NOT_FOUND,
)

from .database import Database
from .models import Status

if TYPE_CHECKING:
    from collections.abc import Awaitable, Callable
    from typing import TypedDict

    from fastapi import Request, Response

    class Robot(TypedDict):
        id: int
        name: str
        status: str


MY_ROBOT = "Bender"
DATABASE = r"robots.db"

app = FastAPI()
db = Database(DATABASE)


@app.middleware("http")
async def db_session_middleware(
    request: Request, call_next: Callable[[Request], Awaitable[Response]]
) -> Response:
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


@app.get("/robot/{id}")
async def get_robot(id: int) -> Robot:
    """Gets the robot information.

    Args:
        id (:obj:`int`): Robot ID.

    Returns:
        dict[str, Any]: Robot information. See :obj:`Robot`.
    """
    robot = db.get_robot(id)

    return {"id": robot[0], "name": robot[1], "status": robot[2]}


@app.post("/robot/{name}/{status}", status_code=HTTP_201_CREATED)
async def new_robot(name: str, status: Status) -> Robot:
    """Creates a new robot. Returns code `201` if the robot is created.

    Args:
        name (:obj:`str`): The robot name.
        status (:obj:`Status`): The robot status.

    Returns:
        dict[str, Any]: Robot information. See :obj:`Robot`.

    Raises:
        HTTPException: Error `400` if the robot already exists.
    """
    if db.robot_exists(name):
        raise HTTPException(
            status_code=HTTP_400_BAD_REQUEST, detail=f'Robot "{name}" already exists'
        )

    id = db.insert_robot(name, status)
    return {"id": id, "name": name, "status": status}


@app.put("/robot/{id}", status_code=HTTP_204_NO_CONTENT)
async def update_robot(
    id: int, name: str | None = None, status: Status | None = None
) -> None:
    """Updates an existing robot information. Optionally, you can update the robot
    name and status, or just one of them. Returns code `204` if the robot is updated.

    Args:
        id (:obj:`int`): The robot ID.
        name (:obj:`str`): The name of the robot to update. Optional.
        status (:obj:`Status`): The status of the robot to update. Optional.

    Raises:
        HTTPException: Error `400` if there are no changes to update.
        HTTPException: Error `404` if the robot does not exist.
    """
    if not db.robot_exists(id):
        raise HTTPException(
            status_code=HTTP_404_NOT_FOUND, detail=f'Robot "{id}" not found'
        )

    try:
        db.update_robot(id, name, status)
    except ValueError as e:
        raise HTTPException(status_code=HTTP_400_BAD_REQUEST, detail=str(e)) from e


@app.delete("/robot/{id}")
async def delete_robot(id: int) -> None:
    """Deletes a robot by ID. It checks if the robot exists before deleting it.

    Args:
        id (:obj:`int`): The robot ID.

    Raises:
        HTTPException: Error `404` if the robot does not exist.
    """
    if not db.robot_exists(id):
        raise HTTPException(
            status_code=HTTP_404_NOT_FOUND, detail=f'Robot "{id}" not found'
        )

    db.delete_robot(id)
