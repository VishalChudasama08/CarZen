import 'package:carzen_flutter/widgets/content_width.dart';
import 'package:flutter/material.dart';
import 'package:carzen_flutter/models/enums.dart';
import 'package:carzen_flutter/models/listing_models.dart';
import 'package:carzen_flutter/services/api_exception.dart';
import 'package:carzen_flutter/services/marketplace_service.dart';
import 'package:carzen_flutter/theme/app_theme.dart';
import 'package:carzen_flutter/widgets/auth_error_banner.dart';
import 'package:carzen_flutter/widgets/auth_text_field.dart';
import 'package:carzen_flutter/widgets/primary_button.dart';
import 'package:carzen_flutter/widgets/state_views.dart';

/// Manages the marketplace listing for one owned car —
/// `POST/GET/PATCH/DELETE /v1/cars/{id}/listing` plus publish/unpublish.
class CarListingScreen extends StatefulWidget {
  final int carId;
  const CarListingScreen({super.key, required this.carId});

  @override
  State<CarListingScreen> createState() => _CarListingScreenState();
}

class _CarListingScreenState extends State<CarListingScreen> {
  final _marketplaceService = MarketplaceService();
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  bool _negotiable = true;
  ListingType _listingType = ListingType.sale;

  Listing? _listing;
  bool _loading = true;
  bool _saving = false;
  bool _hasNoListing = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });
    try {
      final listing = await _marketplaceService.getOwnedListing(widget.carId);
      if (!mounted) return;
      setState(() {
        _listing = listing;
        _hasNoListing = false;
        _titleController.text = listing.title;
        _descriptionController.text = listing.description ?? '';
        _priceController.text = listing.askingPrice.toString();
        _negotiable = listing.negotiable;
        _listingType = listing.listingType;
        _loading = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        // A 404 here just means "no listing created yet" — not a real error.
        _hasNoListing = e.statusCode == 404;
        _errorMessage = e.statusCode == 404 ? null : e.message;
      });
    }
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _saving = true;
      _errorMessage = null;
    });
    try {
      if (_listing == null) {
        await _marketplaceService.createListing(
          widget.carId,
          listingType: _listingType,
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          askingPrice: num.parse(_priceController.text.trim()),
          negotiable: _negotiable,
        );
      } else {
        await _marketplaceService.updateListing(widget.carId, {
          'title': _titleController.text.trim(),
          'description': _descriptionController.text.trim(),
          'asking_price': num.parse(_priceController.text.trim()),
          'negotiable': _negotiable,
        });
      }
      if (!mounted) return;
      await _load();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Listing saved.')));
    } on ApiException catch (e) {
      setState(() => _errorMessage = e.message);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _togglePublish() async {
    if (_listing == null) return;
    setState(() => _saving = true);
    try {
      if (_listing!.listingStatus == ListingStatus.active) {
        await _marketplaceService.unpublishListing(widget.carId);
      } else {
        await _marketplaceService.publishListing(widget.carId);
      }
      await _load();
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _handleDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove this listing?'),
        content: const Text('The car itself will not be deleted — only its marketplace listing.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Remove', style: TextStyle(color: AppColors.favorite))),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await _marketplaceService.deleteListing(widget.carId);
      if (!mounted) return;
      setState(() {
        _listing = null;
        _hasNoListing = true;
        _titleController.clear();
        _descriptionController.clear();
        _priceController.clear();
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Listing'),
        backgroundColor: AppColors.background,
        actions: [
          if (_listing != null)
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded, color: AppColors.favorite),
              onPressed: _handleDelete,
            ),
        ],
      ),
      body: ContentWidth(
        maxWidth: 720,
        child: SafeArea(
        child: _loading
            ? const LoadingView(label: 'Loading listing...')
            : SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_errorMessage != null) AuthErrorBanner(message: _errorMessage!),
                      if (_hasNoListing)
                        const Padding(
                          padding: EdgeInsets.only(bottom: 16),
                          child: Text(
                            'This car has no listing yet. Fill in the details below to publish it for sale.',
                            style: TextStyle(color: AppColors.textSecondary),
                          ),
                        ),
                      if (_listing != null) ...[
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: (_listing!.listingStatus == ListingStatus.active
                                        ? AppColors.success
                                        : AppColors.secondary)
                                    .withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                _listing!.listingStatus.label,
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                  color: _listing!.listingStatus == ListingStatus.active
                                      ? AppColors.success
                                      : AppColors.secondary,
                                ),
                              ),
                            ),
                            const Spacer(),
                            TextButton.icon(
                              onPressed: _saving ? null : _togglePublish,
                              icon: Icon(_listing!.listingStatus == ListingStatus.active
                                  ? Icons.visibility_off_outlined
                                  : Icons.publish_outlined),
                              label: Text(_listing!.listingStatus == ListingStatus.active ? 'Unpublish' : 'Publish'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                      ],
                      DropdownButtonFormField<ListingType>(
                        value: _listingType,
                        items: ListingType.values
                            .map((t) => DropdownMenuItem(value: t, child: Text(t.label)))
                            .toList(),
                        onChanged: (v) => setState(() => _listingType = v!),
                        decoration: const InputDecoration(labelText: 'Listing Type'),
                      ),
                      const SizedBox(height: 12),
                      AuthTextField(
                        controller: _titleController,
                        label: 'Title',
                        hint: 'e.g. Well-maintained Swift VXI, single owner',
                        icon: Icons.title_rounded,
                        validator: (v) => v == null || v.trim().isEmpty ? 'Title is required' : null,
                      ),
                      AuthTextField(
                        controller: _priceController,
                        label: 'Asking Price',
                        hint: 'e.g. 650000',
                        icon: Icons.sell_outlined,
                        keyboardType: TextInputType.number,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return 'Asking price is required';
                          if (num.tryParse(v.trim()) == null) return 'Enter a valid number';
                          return null;
                        },
                      ),
                      AuthTextField(
                        controller: _descriptionController,
                        label: 'Description (optional)',
                        hint: 'Highlight what makes this car a great buy',
                        icon: Icons.notes_outlined,
                        textInputAction: TextInputAction.done,
                      ),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Price negotiable'),
                        value: _negotiable,
                        activeColor: AppColors.secondary,
                        onChanged: (v) => setState(() => _negotiable = v),
                      ),
                      const SizedBox(height: 10),
                      PrimaryButton(
                        label: _listing == null ? 'Create Listing' : 'Save Changes',
                        onPressed: _handleSave,
                        isLoading: _saving,
                      ),
                    ],
                  ),
                ),
              ),
      ),
      ),
    );
  }
}
