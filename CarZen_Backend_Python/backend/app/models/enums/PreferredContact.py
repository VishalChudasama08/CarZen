from enum import Enum


class PreferredContactMethod(str, Enum):
    PHONE = "phone"
    EMAIL = "email"
    WHATSAPP = "whatsapp"

    @classmethod
    def _missing_(cls, value):
        if isinstance(value, str):
            val = value.lower()
            for member in cls:
                if member.value == val or member.name.lower() == val:
                    return member
        return None