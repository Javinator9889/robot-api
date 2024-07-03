from __future__ import annotations

from enum import StrEnum


class Status(StrEnum):
    IDLE = "idle"
    WORKING = "working"
    BROKEN = "broken"
    LOST = "lost"
    CHARGING = "charging"
    SLEEPING = "sleeping"
    CLEANING = "cleaning"
    ERROR = "error"
    UNKNOWN = "unknown"


__all__ = ["Status"]
