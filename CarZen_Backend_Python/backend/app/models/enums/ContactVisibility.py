from enum import Enum

class ContactVisibility(str, Enum):
    PUBLIC = "public"
    BUYERS_ONLY = "buyers_only"
    PRIVATE = "private"

    @classmethod
    def _missing_(cls, value):
        if isinstance(value, str):
            val = value.lower()
            for member in cls:
                if member.value == val or member.name.lower() == val:
                    return member
        return None