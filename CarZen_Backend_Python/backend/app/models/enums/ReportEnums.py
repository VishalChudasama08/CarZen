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


class ReportReason(CaseInsensitiveEnum):
    FAKE_LISTING = "fake_listing"
    WRONG_INFORMATION = "wrong_information"
    FRAUD = "fraud"
    DUPLICATE_LISTING = "duplicate_listing"
    SUSPICIOUS_SELLER = "suspicious_seller"
    INAPPROPRIATE_CONTENT = "inappropriate_content"
    OTHER = "other"


class ReportStatus(CaseInsensitiveEnum):
    PENDING = "pending"
    UNDER_REVIEW = "under_review"
    RESOLVED = "resolved"
    REJECTED = "rejected"
