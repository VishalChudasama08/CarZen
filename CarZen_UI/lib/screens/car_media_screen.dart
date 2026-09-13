import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../config/api_config.dart';
import '../models/car_models.dart';
import '../models/enums.dart';
import '../services/api_exception.dart';
import '../services/car_service.dart';
import '../theme/app_theme.dart';
import '../widgets/state_views.dart';

/// Manages one car's media — `GET/POST /v1/cars/{id}/media`,
/// `PATCH .../media/{mediaId}/primary`, `DELETE .../media/{mediaId}`.
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

  @override
  void initState() {
    super.initState();
    _future = _carService.listMedia(widget.carId);
  }

  void _refresh() => setState(() => _future = _carService.listMedia(widget.carId));

  Future<void> _handleUpload() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (picked == null) return;

    setState(() => _uploading = true);
    try {
      final bytes = await picked.readAsBytes();
      await _carService.uploadMedia(
        widget.carId,
        fileBytes: bytes,
        fileName: picked.name,
        mediaType: MediaType.image,
      );
      if (!mounted) return;
      _refresh();
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  Future<void> _handleSetPrimary(int mediaId) async {
    try {
      await _carService.setPrimaryMedia(widget.carId, mediaId);
      _refresh();
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  Future<void> _handleDelete(int mediaId) async {
    try {
      await _carService.deleteMedia(widget.carId, mediaId);
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
      appBar: AppBar(title: const Text('Photos & Media'), backgroundColor: AppColors.background),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.secondary,
        foregroundColor: AppColors.primary,
        onPressed: _uploading ? null : _handleUpload,
        icon: _uploading
            ? const SizedBox(
                width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2.2, color: AppColors.primary))
            : const Icon(Icons.add_a_photo_outlined),
        label: Text(_uploading ? 'Uploading...' : 'Add Photo'),
      ),
      body: SafeArea(
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
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
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
          Image.network(
            media.absoluteUrl(ApiConfig.baseUrl),
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(color: AppColors.divider, child: const Icon(Icons.broken_image_outlined)),
          ),
          if (media.isPrimary)
            Positioned(
              left: 8,
              top: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: AppColors.secondary, borderRadius: BorderRadius.circular(8)),
                child: const Text('Primary', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700)),
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
                if (!media.isPrimary) const PopupMenuItem(value: 'primary', child: Text('Set as primary')),
                const PopupMenuItem(value: 'delete', child: Text('Delete')),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
