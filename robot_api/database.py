from __future__ import annotations

from sqlite3 import Connection, Cursor, connect


class Database:
    def __init__(self, path: str) -> None:
        self.path = path
        self.connection = connect(path)
        self.cursor = self.connection.cursor()

    def __enter__(self) -> tuple[Connection, Cursor]:
        return self.connection, self.cursor

    def __exit__(self, exc_type, exc_val, exc_tb) -> None:
        self.connection.commit()
        self.connection.close()

    def create_table(self) -> None:
        self.cursor.execute(
            """
            CREATE TABLE IF NOT EXISTS robots (
                id INTEGER PRIMARY KEY,
                name TEXT NOT NULL,
                status TEXT NOT NULL
            )
            """
        )

    def insert_robot(self, name: str, status: str) -> None:
        self.cursor.execute(
            "INSERT INTO robots (name, status) VALUES (?, ?)", (name, status)
        )

    def get_robot(self, name: str) -> tuple[int, str, str]:
        self.cursor.execute("SELECT * FROM robots WHERE name = ?", (name,))
        return self.cursor.fetchone()

    def update_robot(self, name: str, status: str) -> None:
        self.cursor.execute(
            "UPDATE robots SET status = ? WHERE name = ?", (status, name)
        )

    def delete_robot(self, name: str) -> None:
        self.cursor.execute("DELETE FROM robots WHERE name = ?", (name,))

    def robot_exists(self, name: str) -> bool:
        self.cursor.execute("SELECT EXISTS(SELECT 1 FROM robots WHERE name = ? LIMIT 1)", (name,))
        return bool(self.cursor.fetchone())
