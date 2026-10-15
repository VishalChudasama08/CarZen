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


class ListingType(CaseInsensitiveEnum):
    SALE = "sale"
    RESALE = "resale"


class ListingStatus(CaseInsensitiveEnum):
    DRAFT = "draft"
    PENDING_REVIEW = "pending_review"
    APPROVED = "approved"
    REJECTED = "rejected"
    ACTIVE = "active"
    RESERVED = "reserved"
    SOLD = "sold"
    EXPIRED = "expired"
    CANCELLED = "cancelled"
    REMOVED = "removed"
    SUSPENDED = "suspended"


class ListingSort(CaseInsensitiveEnum):
    NEWEST = "newest"
    PRICE_LOW_TO_HIGH = "price_low_to_high"
    PRICE_HIGH_TO_LOW = "price_high_to_low"
    YEAR_NEWEST = "year_newest"
    MILEAGE_LOW_TO_HIGH = "mileage_low_to_high"
