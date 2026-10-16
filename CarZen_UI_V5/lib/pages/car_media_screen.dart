import 'package:carzen_flutter/config/api_config.dart';
import 'package:carzen_flutter/models/car_models.dart';
import 'package:carzen_flutter/models/enums.dart';
import 'package:carzen_flutter/routes/app_routes.dart';
import 'package:carzen_flutter/services/api_exception.dart';
import 'package:carzen_flutter/services/car_service.dart';
import 'package:carzen_flutter/theme/app_theme.dart';
import 'package:carzen_flutter/widgets/carzen_nav_bar.dart';
import 'package:carzen_flutter/widgets/content_width.dart';
import 'package:carzen_flutter/widgets/network_photo.dart';
import 'package:carzen_flutter/widgets/state_views.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

/// Manages one car's media — `GET/POST /v1/cars/{id}/media`,
/// `PATCH /v1/cars/{id}/media/{mediaId}/primary`, `DELETE /v1/cars/{id}/media/{mediaId}`.
class CarMediaScreen extends StatefulWidget {
  final int carId;
  const CarMediaScreen({super.key, required this.carId});

  @override
  State<CarMediaScreen> createState() => _CarMediaScreenState();
}

class _CarMediaScreenState extends State<CarMediaScreen> {
  final _carService = CarService();
  final _picker = ImagePicker();

  late Future<List<CarMedia>> _future;
  bool _uploading = false;
  String _uploadStatus = 'Uploading...';

  @override
  void initState() {
    super.initState();
    _future = _carService.listMedia(widget.carId);
  }

  void _refresh() => setState(() => _future = _carService.listMedia(widget.carId));

  Future<void> _handleUpload() async {
    List<XFile> pickedFiles = [];
    try {
      pickedFiles = await _picker.pickMultiImage(imageQuality: 85);
    } catch (_) {
      // Fallback to single image picker if multi-select fails or isn't supported
      final single = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
      if (single != null) pickedFiles = [single];
    }

    if (pickedFiles.isEmpty) {
      final single = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
      if (single != null) pickedFiles = [single];
    }

    if (pickedFiles.isEmpty) return;

    setState(() {
      _uploading = true;
      _uploadStatus = 'Uploading 1 of ${pickedFiles.length}...';
    });

    try {
      // Check if existing car has any primary photo
      List<CarMedia> existing = [];
      try {
        existing = await _future;
      } catch (_) {}
      bool hasPrimary = existing.any((m) => m.isPrimary);

      for (int i = 0; i < pickedFiles.length; i++) {
        if (!mounted) return;
        setState(() {
          _uploadStatus = 'Uploading ${i + 1} of ${pickedFiles.length}...';
        });

        final file = pickedFiles[i];
        final bytes = await file.readAsBytes();
        final makePrimary = !hasPrimary && i == 0;

        await _carService.uploadMedia(
          widget.carId,
          fileBytes: bytes,
          fileName: file.name,
          mediaType: MediaType.image,
          isPrimary: makePrimary,
        );

        if (makePrimary) {
          hasPrimary = true;
        }
      }

      if (!mounted) return;
      _refresh();
      showAppSnack(context, '${pickedFiles.length} photo${pickedFiles.length == 1 ? '' : 's'} uploaded.');
    } on ApiException catch (e) {
      if (!mounted) return;
      showAppSnack(context, e.message, error: true);
    } catch (e) {
      if (!mounted) return;
      showAppSnack(context, 'Failed to upload photo: $e', error: true);
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  Future<void> _handleSetPrimary(int mediaId) async {
    try {
      await _carService.setPrimaryMedia(widget.carId, mediaId);
      // Re-fetch media list from server to reflect true persisted state
      _refresh();
      if (!mounted) return;
      showAppSnack(context, 'Set as primary photo.');
    } on ApiException catch (e) {
      if (!mounted) return;
      showAppSnack(context, e.message, error: true);
    }
  }

  Future<void> _handleDelete(int mediaId) async {
    try {
      await _carService.deleteMedia(widget.carId, mediaId);
      _refresh();
      if (!mounted) return;
      showAppSnack(context, 'Photo deleted.');
    } on ApiException catch (e) {
      if (!mounted) return;
      showAppSnack(context, e.message, error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CarZenNavBar(
        current: NavSection.sell,
        title: 'Photos & Media',
        fallbackRoute: AppRoutes.sell,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _uploading ? null : _handleUpload,
        icon: _uploading
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2.2, color: AppColors.primary),
              )
            : const Icon(Icons.add_a_photo_outlined),
        label: Text(_uploading ? _uploadStatus : 'Add Photos'),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.divider)),
        ),
        child: SafeArea(
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _uploading ? null : _handleUpload,
                  icon: const Icon(Icons.add_photo_alternate_outlined, size: 18),
                  label: const Text('Add Photos'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: FilledButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                    showAppSnack(context, 'Photos saved.');
                  },
                  icon: const Icon(Icons.check_rounded, size: 18),
                  label: const Text('Save / Done'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: ContentWidth(
        maxWidth: 900,
        child: SafeArea(
          child: FutureBuilder<List<CarMedia>>(
            future: _future,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const LoadingView(label: 'Loading media...');
              }
              if (snapshot.hasError) {
                final message =
                    snapshot.error is ApiException ? (snapshot.error as ApiException).message : 'Could not load media.';
                return ErrorStateView(message: message, onRetry: _refresh);
              }
              final media = snapshot.data!;
              if (media.isEmpty) {
                return const EmptyStateView(
                  icon: Icons.photo_library_outlined,
                  title: 'No photos yet',
                  message: 'Add at least one photo so buyers can see your car.',
                );
              }
              return GridView.builder(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.85,
                ),
                itemCount: media.length,
                itemBuilder: (context, index) {
                  final item = media[index];
                  return _MediaTile(
                    media: item,
                    onSetPrimary: () => _handleSetPrimary(item.id),
                    onDelete: () => _handleDelete(item.id),
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

class _MediaTile extends StatelessWidget {
  final CarMedia media;
  final VoidCallback onSetPrimary;
  final VoidCallback onDelete;

  const _MediaTile({required this.media, required this.onSetPrimary, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Stack(
        fit: StackFit.expand,
        children: [
          NetworkPhoto(url: media.thumbnailAbsoluteUrl(ApiConfig.baseUrl), cacheWidth: 600),
          if (media.isPrimary)
            Positioned(
              left: 8,
              top: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: AppColors.secondary, borderRadius: BorderRadius.circular(8)),
                child: const Text('Primary', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.white)),
              ),
            ),
          Positioned(
            right: 4,
            top: 4,
            child: PopupMenuButton<String>(
              icon: const CircleAvatar(
                radius: 14,
                backgroundColor: Colors.black45,
                child: Icon(Icons.more_vert, size: 16, color: Colors.white),
              ),
              onSelected: (value) {
                if (value == 'primary') onSetPrimary();
                if (value == 'delete') onDelete();
              },
              itemBuilder: (context) => [
                if (!media.isPrimary)
                  const PopupMenuItem(value: 'primary', child: Text('Set as primary'))
                else
                  const PopupMenuItem(enabled: false, value: 'primary_current', child: Text('Already primary')),
                const PopupMenuItem(value: 'delete', child: Text('Delete')),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
