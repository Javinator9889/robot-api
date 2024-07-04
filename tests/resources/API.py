from __future__ import annotations

import requests


class API:
    def __init__(self, url: str) -> None:
        self.url = url

    def Python_API_GET(self, path: str, expected_status: int = 200) -> dict:
        response = requests.get(f"{self.url}/{path}")
        assert response.status_code == expected_status
        return response.json()

    def Python_API_POST(
        self, path: str, data: dict | None = None, expected_status: int = 200
    ) -> dict:
        response = requests.post(f"{self.url}/{path}", json=data)
        assert response.status_code == expected_status
        return response.json()
