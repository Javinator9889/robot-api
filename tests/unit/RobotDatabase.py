from robot_api.database import Database


class RobotDatabase(Database):
    def __init__(self, path="test_db") -> None:
        super().__init__(path)

    def commit(self):
        return self.connection.commit()
