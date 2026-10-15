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


class BodyType(CaseInsensitiveEnum):
    HATCHBACK = "hatchback"
    SEDAN = "sedan"
    SUV = "suv"
    MUV = "muv"
    MPV = "mpv"
    COUPE = "coupe"
    CONVERTIBLE = "convertible"
    PICKUP = "pickup"
    MINIVAN = "minivan"
    OTHER = "other"


class FuelType(CaseInsensitiveEnum):
    PETROL = "petrol"
    DIESEL = "diesel"
    CNG = "cng"
    ELECTRIC = "electric"
    HYBRID = "hybrid"


class TransmissionType(CaseInsensitiveEnum):
    MANUAL = "manual"
    AUTOMATIC = "automatic"
    AMT = "amt"
    CVT = "cvt"
    DCT = "dct"


class OwnershipType(CaseInsensitiveEnum):
    FIRST_OWNER = "first_owner"
    SECOND_OWNER = "second_owner"
    THIRD_OWNER = "third_owner"
    FOURTH_OR_MORE = "fourth_or_more"


class CarCondition(CaseInsensitiveEnum):
    EXCELLENT = "excellent"
    GOOD = "good"
    FAIR = "fair"
    POOR = "poor"
    NEW  = "new"
    OLD = "oldCar"

    @classmethod
    def _missing_(cls, value):
        if isinstance(value, str):
            val = value.lower()
            if val in ("old", "oldcar", "old_car"):
                return cls.OLD
            for member in cls:
                if member.value.lower() == val or member.name.lower() == val:
                    return member
        return None


class CarApprovalStatus(CaseInsensitiveEnum):
    DRAFT = "draft"
    PENDING_APPROVAL = "pending_approval"
    APPROVED = "approved"
    REJECTED = "rejected"
    PUBLISHED = "published"
    SOLD = "sold"
    INACTIVE = "inactive"


class MediaType(CaseInsensitiveEnum):
    IMAGE = "image"
    VIDEO = "video"
