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


class PaymentMethod(CaseInsensitiveEnum):
    CASH = "cash"
    UPI = "upi"
    CARD = "card"
    BANK_TRANSFER = "bank_transfer"
    FINANCE = "finance"
    OTHER = "other"


class PaymentStatus(CaseInsensitiveEnum):
    PENDING = "pending"
    PARTIAL = "partial"
    PAID = "paid"
    FAILED = "failed"
    REFUNDED = "refunded"
    UNPAID = "unpaid"


class TransactionStatus(CaseInsensitiveEnum):
    INITIATED = "initiated"
    COMPLETED = "completed"
    CANCELLED = "cancelled"
    FAILED = "failed"


class GatewayPaymentStatus(CaseInsensitiveEnum):
    """Lifecycle states for an individual gateway payment attempt."""

    PENDING = "pending"
    PROCESSING = "processing"
    SUCCESS = "success"
    FAILED = "failed"
    CANCELLED = "cancelled"
    REFUNDED = "refunded"
