from enum import Enum


class CaseInsensitiveEnum(str, Enum):
    @classmethod
    def _missing_(cls, value):
        if isinstance(value, str):
            val = value.lower()
            for member in cls:
                if member.value.lower() == val or member.name.lower() == val:
                    return member
        return None


class PredictionStatus(CaseInsensitiveEnum):
    REQUESTED = "requested"
    COMPLETED = "completed"
    FAILED = "failed"


class AdminRole(CaseInsensitiveEnum):
    SUPER_ADMIN = "super_admin"
    ADMIN = "admin"
    MODERATOR = "moderator"