import 'package:carzen_flutter/models/service_models.dart';
import 'api_client.dart';

/// Saved addresses (`addresses.py`). A service request needs one: the backend
/// looks the address up when the request is created.
class AddressService {
  AddressService({ApiClient? client}) : _client = client ?? ApiClient();
  final ApiClient _client;

  /// `GET /v1/address` — a plain list, default address first.
  Future<List<AddressRecord>> list() async {
    final json = await _client.get('/address');
    return (json as List<dynamic>).map((e) => AddressRecord.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// `POST /v1/address-add` (`AddressCreate`).
  Future<AddressRecord> create({
    required String addressLine1,
    String? addressLine2,
    String? landmark,
    required String city,
    required String state,
    required String postalCode,
    bool isDefault = false,
  }) async {
    final json = await _client.post('/address-add', body: {
      'address_line_1': addressLine1,
      if (addressLine2 != null && addressLine2.isNotEmpty) 'address_line_2': addressLine2,
      if (landmark != null && landmark.isNotEmpty) 'landmark': landmark,
      'city': city,
      'state': state,
      'country': 'India',
      'postal_code': postalCode,
      'is_default': isDefault,
    });
    return AddressRecord.fromJson(json as Map<String, dynamic>);
  }
}
