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


class OrderStatus(CaseInsensitiveEnum):
    PENDING = "pending"
    CONFIRMED = "confirmed"
    PROCESSING = "processing"
    COMPLETED = "completed"
    CANCELLED = "cancelled"
    REJECTED = "rejected"


class NotificationType(CaseInsensitiveEnum):
    ORDER = "order"
    PAYMENT = "payment"
    LISTING = "listing"
    INQUIRY = "inquiry"
    FAVORITE = "favorite"
    SYSTEM = "system"
    ADMIN = "admin"
