import 'package:carzen_flutter/models/marketplace_models.dart';
import 'package:carzen_flutter/services/api_client.dart';

/// The seller's contact preferences (`/v1/contact*`).
class ContactService {
  ContactService({ApiClient? client}) : _client = client ?? ApiClient();
  final ApiClient _client;

  Future<List<SellerContact>> list() async {
    final json = await _client.get('/contact');
    return (json as List<dynamic>).map((e) => SellerContact.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<SellerContact> create({
    required int addressId,
    String? whatsapp,
    required PreferredContactMethod method,
    required ContactVisibility visibility,
    bool isVisible = true,
  }) async {
    final json = await _client.post('/contact-add', body: {
      'address_id': addressId,
      'whatsapp_number': (whatsapp == null || whatsapp.trim().isEmpty) ? null : whatsapp.trim(),
      'preferred_contact_method': method.apiValue,
      'contact_visibility': visibility.apiValue,
      'is_visible': isVisible,
    });
    return SellerContact.fromJson(json as Map<String, dynamic>);
  }

  Future<SellerContact> update(int id, Map<String, dynamic> fields) async {
    final json = await _client.patch('/contact/$id', body: fields);
    return SellerContact.fromJson(json as Map<String, dynamic>);
  }

  Future<void> delete(int id) => _client.delete('/contact/$id');
}
