import 'package:carzen_flutter/widgets/carzen_nav_bar.dart';
import 'package:carzen_flutter/widgets/content_width.dart';
import 'package:flutter/material.dart';
import 'package:carzen_flutter/models/car_models.dart';
import 'package:carzen_flutter/services/api_exception.dart';
import 'package:carzen_flutter/services/car_service.dart';
import 'package:carzen_flutter/theme/app_theme.dart';
import 'package:carzen_flutter/widgets/state_views.dart';

/// Manages one car's features — `GET/POST /v1/cars/{id}/features`,
/// `PATCH`/`DELETE .package:carzen_flutter/features/{featureId}`.
class CarFeaturesScreen extends StatefulWidget {
  final int carId;
  const CarFeaturesScreen({super.key, required this.carId});

  @override
  State<CarFeaturesScreen> createState() => _CarFeaturesScreenState();
}

class _CarFeaturesScreenState extends State<CarFeaturesScreen> {
  final _carService = CarService();
  late Future<List<CarFeature>> _future;

  @override
  void initState() {
    super.initState();
    _future = _carService.listFeatures(widget.carId);
  }

  void _refresh() => setState(() => _future = _carService.listFeatures(widget.carId));

  Future<void> _openFeatureDialog({CarFeature? existing}) async {
    final nameController = TextEditingController(text: existing?.featureName ?? '');
    final valueController = TextEditingController(text: existing?.featureValue ?? '');

    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(existing == null ? 'Add Feature' : 'Edit Feature'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Feature name')),
            const SizedBox(height: 10),
            TextField(controller: valueController, decoration: const InputDecoration(labelText: 'Value (optional)')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Save')),
        ],
      ),
    );

    if (saved != true || nameController.text.trim().isEmpty) return;

    try {
      if (existing == null) {
        await _carService.addFeature(widget.carId, nameController.text.trim(), valueController.text.trim());
      } else {
        await _carService.updateFeature(widget.carId, existing.id,
            name: nameController.text.trim(), value: valueController.text.trim());
      }
      _refresh();
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  Future<void> _handleDelete(CarFeature feature) async {
    try {
      await _carService.deleteFeature(widget.carId, feature.id);
      _refresh();
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CarZenNavBar(current: NavSection.sell, title: 'Features'),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.secondary,
        foregroundColor: AppColors.primary,
        onPressed: () => _openFeatureDialog(),
        child: const Icon(Icons.add),
      ),
      body: ContentWidth(
        maxWidth: 720,
        child: SafeArea(
        child: FutureBuilder<List<CarFeature>>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const LoadingView(label: 'Loading features...');
            }
            if (snapshot.hasError) {
              final message = snapshot.error is ApiException
                  ? (snapshot.error as ApiException).message
                  : 'Could not load features.';
              return ErrorStateView(message: message, onRetry: _refresh);
            }
            final features = snapshot.data!;
            if (features.isEmpty) {
              return const EmptyStateView(
                icon: Icons.checklist_rtl_outlined,
                title: 'No features added',
                message: 'Add features like Sunroof, ABS, or Alloy Wheels to attract buyers.',
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
              itemCount: features.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final feature = features[index];
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: ListTile(
                    title: Text(feature.featureName, style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: feature.featureValue == null ? null : Text(feature.featureValue!),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit_outlined, size: 20),
                          onPressed: () => _openFeatureDialog(existing: feature),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline_rounded, size: 20, color: AppColors.favorite),
                          onPressed: () => _handleDelete(feature),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
      ),
    );
  }
}
