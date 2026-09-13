/// Every enum here mirrors a `str, Enum` class in the backend exactly
/// (`app/models/enums/*.py`). Values are the literal strings the API
/// sends/expects — do not rename them without checking the backend first.

enum FuelType { petrol, diesel, cng, electric, hybrid }

enum TransmissionType { manual, automatic, amt, cvt, dct }

enum OwnershipType { firstOwner, secondOwner, thirdOwner, fourthOrMore }

/// NOTE: `old` maps to the backend's literal value `"oldCar"` — that odd
/// casing comes straight from `CarEnums.py` (`OLD = "oldCar"`), not a typo
/// here. Flagged to Ayush; kept as-is so requests actually match.
enum CarCondition { excellent, good, fair, poor, newCar, old }

enum CarApprovalStatus { draft, pendingApproval, approved, rejected, published, sold, inactive }

enum MediaType { image, video, document }

enum BodyType { hatchback, sedan, suv, muv, coupe, convertible, pickup, minivan, other }

enum ListingType { sale, resale }

enum ListingStatus { draft, active, reserved, sold, expired, cancelled, removed }

extension FuelTypeX on FuelType {
  String get apiValue => name;
  String get label => name[0].toUpperCase() + name.substring(1);
  static FuelType fromApi(String value) => FuelType.values.firstWhere((e) => e.apiValue == value);
}

extension TransmissionTypeX on TransmissionType {
  String get apiValue => name;
  String get label => name.toUpperCase();
  static TransmissionType fromApi(String value) =>
      TransmissionType.values.firstWhere((e) => e.name == value);
}

const Map<OwnershipType, String> _ownershipApi = {
  OwnershipType.firstOwner: 'first_owner',
  OwnershipType.secondOwner: 'second_owner',
  OwnershipType.thirdOwner: 'third_owner',
  OwnershipType.fourthOrMore: 'fourth_or_more',
};
const Map<OwnershipType, String> _ownershipLabel = {
  OwnershipType.firstOwner: '1st Owner',
  OwnershipType.secondOwner: '2nd Owner',
  OwnershipType.thirdOwner: '3rd Owner',
  OwnershipType.fourthOrMore: '4th Owner or more',
};
extension OwnershipTypeX on OwnershipType {
  String get apiValue => _ownershipApi[this]!;
  String get label => _ownershipLabel[this]!;
  static OwnershipType fromApi(String value) =>
      _ownershipApi.entries.firstWhere((e) => e.value == value).key;
}

const Map<CarCondition, String> _conditionApi = {
  CarCondition.excellent: 'excellent',
  CarCondition.good: 'good',
  CarCondition.fair: 'fair',
  CarCondition.poor: 'poor',
  CarCondition.newCar: 'new',
  CarCondition.old: 'oldCar',
};
extension CarConditionX on CarCondition {
  String get apiValue => _conditionApi[this]!;
  String get label => this == CarCondition.newCar
      ? 'New'
      : this == CarCondition.old
          ? 'Old'
          : apiValue[0].toUpperCase() + apiValue.substring(1);
  static CarCondition fromApi(String value) =>
      _conditionApi.entries.firstWhere((e) => e.value == value).key;
}

const Map<CarApprovalStatus, String> _approvalApi = {
  CarApprovalStatus.draft: 'draft',
  CarApprovalStatus.pendingApproval: 'pending_approval',
  CarApprovalStatus.approved: 'approved',
  CarApprovalStatus.rejected: 'rejected',
  CarApprovalStatus.published: 'published',
  CarApprovalStatus.sold: 'sold',
  CarApprovalStatus.inactive: 'inactive',
};
extension CarApprovalStatusX on CarApprovalStatus {
  String get apiValue => _approvalApi[this]!;
  String get label => apiValue.replaceAll('_', ' ');
  static CarApprovalStatus fromApi(String value) =>
      _approvalApi.entries.firstWhere((e) => e.value == value).key;
}

extension MediaTypeX on MediaType {
  String get apiValue => name;
  static MediaType fromApi(String value) => MediaType.values.firstWhere((e) => e.apiValue == value);
}

extension BodyTypeX on BodyType {
  String get apiValue => name;
  String get label => name[0].toUpperCase() + name.substring(1);
  static BodyType fromApi(String value) => BodyType.values.firstWhere((e) => e.apiValue == value);
}

extension ListingTypeX on ListingType {
  String get apiValue => name;
  String get label => name[0].toUpperCase() + name.substring(1);
  static ListingType fromApi(String value) => ListingType.values.firstWhere((e) => e.apiValue == value);
}

extension ListingStatusX on ListingStatus {
  String get apiValue => name;
  String get label => name[0].toUpperCase() + name.substring(1);
  static ListingStatus fromApi(String value) =>
      ListingStatus.values.firstWhere((e) => e.apiValue == value);
}
