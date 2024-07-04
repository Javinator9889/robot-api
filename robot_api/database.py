from __future__ import annotations

from sqlite3 import Connection, Cursor, connect

from .models import Status


class Database:
    def __init__(self, path: str) -> None:
        self.path = path
        self.connection = connect(path)
        self.cursor = self.connection.cursor()

    def __enter__(self) -> tuple[Connection, Cursor]:
        return self.connection, self.cursor

    def __exit__(self, exc_type, exc_val, exc_tb) -> None:
        self.connection.commit()

    def create_table(self) -> None:
        self.cursor.execute(
            """
            CREATE TABLE IF NOT EXISTS robots (
                id INTEGER PRIMARY KEY,
                name TEXT NOT NULL UNIQUE,
                status TEXT NOT NULL
            )
            """
        )

    def insert_robot(self, name: str, status: Status) -> int:
        """
        Insert a new robot into the database. The robot name must be unique. It does
        not check for uniqueness, so it will raise an exception if the name is not unique.

        Args:
            name (str): The name of the robot.
            status (str): The status of the robot.

        Returns:
            :obj:`int`: The ID of the robot inserted.
        """
        c = self.cursor.execute(
            "INSERT INTO robots (name, status) VALUES (?, ?)", (name, str(status))
        )
        return c.execute("SELECT last_insert_rowid()").fetchone()[0]

    def get_robots(self) -> list[tuple[int, str, str]]:
        """Get all robots."""
        self.cursor.execute("SELECT * FROM robots")
        return self.cursor.fetchall()

    def get_robot(self, id: int) -> tuple[int, str, str]:
        """Get a robot by ID."""
        self.cursor.execute("SELECT * FROM robots WHERE id = ?", (id,))
        return self.cursor.fetchone()

    def update_robot(self, id: int, name: str | None, status: str | None) -> None:
        """Updates an existing robot information. Optionally, you can update the robot
        name and status, or just one of them.

        Args:
            id (:obj:`int`): The robot ID.
            name (str | None): The name of the robot to update. Optional.
            status (str | None): The status of the robot to update. Optional.

        Raises:
            :obj:`ValueError`: Error if there are no changes to update.
        """
        if not any((name, status)):
            raise ValueError("At least one of name or status must be provided.")

        params = []
        query = "UPDATE robots SET"
        if name:
            query += " name = ?,"
            params.append(name)
        if status:
            query += " status = ?,"
            params.append(status)
        params.append(id)
        query = query.rstrip(",")
        query += " WHERE id = ?"
        self.cursor.execute(query, params)

    def delete_robot(self, id: int) -> None:
        """Deletes a robot by ID."""
        self.cursor.execute("DELETE FROM robots WHERE id = ?", (id,))

    def robot_exists(self, id: str | int) -> bool:
        """Robots are unique by name. Checking for existence by name is enough. Support looking
        up by ID as well."""
        query = "SELECT EXISTS(SELECT 1 FROM robots WHERE"
        query += " name = ?" if isinstance(id, str) else " id = ?"
        query += " LIMIT 1)"
        self.cursor.execute(query, (id,))

        return bool(self.cursor.fetchone()[0])
