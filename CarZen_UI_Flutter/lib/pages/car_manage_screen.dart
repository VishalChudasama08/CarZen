import 'package:carzen_flutter/config/api_config.dart';
import 'package:carzen_flutter/models/car_models.dart';
import 'package:carzen_flutter/models/enums.dart';
import 'package:carzen_flutter/models/listing_models.dart';
import 'package:carzen_flutter/pages/add_edit_car_screen.dart';
import 'package:carzen_flutter/routes/app_routes.dart';
import 'package:carzen_flutter/services/api_exception.dart';
import 'package:carzen_flutter/services/car_service.dart';
import 'package:carzen_flutter/services/marketplace_service.dart';
import 'package:carzen_flutter/theme/app_theme.dart';
import 'package:carzen_flutter/utils/breakpoints.dart';
import 'package:carzen_flutter/utils/formatters.dart';
import 'package:carzen_flutter/utils/validators.dart';
import 'package:carzen_flutter/widgets/app_shell.dart';
import 'package:carzen_flutter/widgets/auth_text_field.dart';
import 'package:carzen_flutter/widgets/form_widgets.dart';
import 'package:carzen_flutter/widgets/network_photo.dart';
import 'package:carzen_flutter/widgets/page_container.dart';
import 'package:carzen_flutter/widgets/state_views.dart';
import 'package:carzen_flutter/widgets/status_pill.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

StatusTone approvalTone(CarApprovalStatus s) => switch (s) {
      CarApprovalStatus.published => StatusTone.success,
      CarApprovalStatus.approved => StatusTone.info,
      CarApprovalStatus.pendingApproval => StatusTone.warning,
      CarApprovalStatus.rejected => StatusTone.danger,
      CarApprovalStatus.sold => StatusTone.highlight,
      _ => StatusTone.neutral,
    };

StatusTone listingTone(ListingStatus s) => switch (s) {
      ListingStatus.active => StatusTone.success,
      ListingStatus.reserved => StatusTone.highlight,
      ListingStatus.sold => StatusTone.highlight,
      ListingStatus.pendingReview => StatusTone.warning,
      ListingStatus.rejected || ListingStatus.suspended || ListingStatus.removed => StatusTone.danger,
      _ => StatusTone.neutral,
    };

/// Everything about one of the seller's cars on one page: where it is in
/// the process, photos, features and the marketplace listing.
class CarManageScreen extends StatefulWidget {
  final int carId;
  const CarManageScreen({super.key, required this.carId});

  @override
  State<CarManageScreen> createState() => _CarManageScreenState();
}

class _CarManageScreenState extends State<CarManageScreen> {
  final _cars = CarService();
  final _market = MarketplaceService();

  CarRecordDetail? _car;
  Listing? _listing;
  Object? _error;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load({bool silent = false}) async {
    if (!silent) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }
    try {
      final car = await _cars.getCar(widget.carId);
      Listing? listing;
      try {
        listing = await _market.getOwnedListing(widget.carId);
      } on ApiException catch (e) {
        if (e.statusCode != 404) rethrow;
      }
      if (!mounted) return;
      setState(() {
        _car = car;
        _listing = listing;
        _loading = false;
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e;
        _loading = false;
      });
    }
  }

  Future<void> _edit() async {
    final saved = await Navigator.of(context).push<bool>(MaterialPageRoute(
      settings: RouteSettings(name: '/sell/cars/${widget.carId}/edit'),
      builder: (_) => AddEditCarScreen(existingCar: _car),
    ));
    if (saved == true) _load(silent: true);
  }

  Future<void> _deleteCar() async {
    final ok = await confirmAction(
      context,
      title: 'Delete this car?',
      message: 'The car, its photos and its listing will be removed. This cannot be undone.',
      confirmLabel: 'Delete car',
      destructive: true,
    );
    if (!ok) return;
    try {
      await _cars.deleteCar(widget.carId);
      if (!mounted) return;
      showAppSnack(context, 'Car deleted');
      Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.sell, (r) => false);
    } on ApiException catch (e) {
      if (mounted) showAppSnack(context, e.message, error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final car = _car;
    return AppScaffold(
      section: NavSection.sell,
      title: car == null ? 'Your car' : car.displayName,
      fallbackRoute: AppRoutes.sell,
      showBackButton: true,
      body: _body(context),
    );
  }

  Widget _body(BuildContext context) {
    if (_loading && _car == null) return const LoadingView(label: 'Loading your car...');
    if (_error != null && _car == null) return ApiErrorView(error: _error!, onRetry: _load, fallback: 'This car could not be loaded.');
    final car = _car!;
    final wide = Breakpoints.widthOf(context) >= Breakpoints.expanded;
    final compact = Breakpoints.isCompact(context);

    final header = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Semantics(header: true, child: Text(car.displayName, style: AppText.heading(compact ? 23 : 28))),
              const SizedBox(height: 4),
              Text('${car.variantName}, ${car.manufacturingYear}, ${car.city}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 15)),
            ],
          ),
        ),
        PopupMenuButton<String>(
          tooltip: 'More actions',
          onSelected: (v) => v == 'edit' ? _edit() : _deleteCar(),
          itemBuilder: (_) => const [
            PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit_outlined, size: 20), SizedBox(width: 12), Text('Edit details')])),
            PopupMenuItem(
              value: 'delete',
              child: Row(children: [
                Icon(Icons.delete_outline, size: 20, color: AppColors.danger),
                SizedBox(width: 12),
                Text('Delete car', style: TextStyle(color: AppColors.danger)),
              ]),
            ),
          ],
          icon: const Icon(Icons.more_vert),
        ),
      ],
    );

    final progress = _ProgressPanel(car: car, listing: _listing, onEdit: _edit);
    final photos = _PhotosPanel(car: car, onChanged: () => _load(silent: true));
    final features = _FeaturesPanel(car: car, onChanged: () => _load(silent: true));
    final listing = _ListingPanel(car: car, listing: _listing, onChanged: () => _load(silent: true));
    final details = _DetailsPanel(car: car, onEdit: _edit);

    return RefreshIndicator(
      onRefresh: () => _load(silent: true),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: PageContainer(
          verticalPadding: compact ? 18 : 28,
          child: wide
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    header,
                    const SizedBox(height: 24),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                            photos,
                            const SizedBox(height: 16),
                            listing,
                            const SizedBox(height: 16),
                            features,
                          ]),
                        ),
                        const SizedBox(width: 24),
                        SizedBox(
                          width: 360,
                          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [progress, const SizedBox(height: 16), details]),
                        ),
                      ],
                    ),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    header,
                    const SizedBox(height: 18),
                    progress,
                    const SizedBox(height: 16),
                    photos,
                    const SizedBox(height: 16),
                    listing,
                    const SizedBox(height: 16),
                    features,
                    const SizedBox(height: 16),
                    details,
                  ],
                ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Progress: details -> photos -> review -> listing -> live
// ---------------------------------------------------------------------------

class _ProgressPanel extends StatelessWidget {
  final CarRecordDetail car;
  final Listing? listing;
  final VoidCallback onEdit;
  const _ProgressPanel({required this.car, required this.listing, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    final photos = car.media.where((m) => m.mediaType == MediaType.image).length;
    final status = car.approvalStatus;
    final approved = status == CarApprovalStatus.approved || status == CarApprovalStatus.published || status == CarApprovalStatus.sold;
    final live = listing?.listingStatus == ListingStatus.active || listing?.listingStatus == ListingStatus.reserved;
    final sold = status == CarApprovalStatus.sold || listing?.listingStatus == ListingStatus.sold;

    final steps = <(String, String, bool)>[
      ('Car details added', 'Saved on ${formatDate(car.createdAtDate)}', true),
      ('Photos', photos == 0 ? 'Add at least one photo' : '$photos ${photos == 1 ? 'photo' : 'photos'}', photos > 0),
      (
        'CarZen review',
        switch (status) {
          CarApprovalStatus.pendingApproval => 'Waiting for our team',
          CarApprovalStatus.rejected => 'Changes needed',
          _ when approved => 'Approved',
          _ => status.label,
        },
        approved,
      ),
      ('Listing', listing == null ? 'Set your price' : 'Price ${formatLakh(listing!.askingPrice)}', listing != null),
      ('Live for buyers', sold ? 'Sold' : (live ? 'Buyers can see it' : 'Publish when ready'), live || sold),
    ];

    String? next;
    if (status == CarApprovalStatus.rejected) {
      next = null;
    } else if (photos == 0) {
      next = 'Add photos. Cars with clear photos get approved faster.';
    } else if (status == CarApprovalStatus.pendingApproval) {
      next = 'Our team is reviewing your car. Meanwhile, set your price below.';
    } else if (listing == null) {
      next = 'Create your listing to set an asking price.';
    } else if (approved && !live && !sold) {
      next = 'Everything is ready. Publish your listing so buyers can find it.';
    }

    return FormPanel(
      title: 'Progress',
      trailing: StatusPill(label: status.label, tone: approvalTone(status)),
      children: [
        if (status == CarApprovalStatus.rejected) ...[
          Callout(
            tone: CalloutTone.danger,
            icon: Icons.report_outlined,
            title: 'Our team asked for changes',
            message: car.rejectionReason ?? 'Please check the car details and photos.',
            action: TextButton(onPressed: onEdit, child: const Text('Edit details and resubmit')),
          ),
          const SizedBox(height: 16),
        ],
        for (var i = 0; i < steps.length; i++)
          _ProgressRow(title: steps[i].$1, detail: steps[i].$2, done: steps[i].$3, last: i == steps.length - 1),
        if (next != null) ...[
          const SizedBox(height: 8),
          Callout(icon: Icons.lightbulb_outline, message: next),
        ],
      ],
    );
  }
}

class _ProgressRow extends StatelessWidget {
  final String title;
  final String detail;
  final bool done;
  final bool last;
  const _ProgressRow({required this.title, required this.detail, required this.done, required this.last});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$title: $detail${done ? ', done' : ''}',
      excludeSemantics: true,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Column(
              children: [
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: done ? AppColors.success : AppColors.surface,
                    shape: BoxShape.circle,
                    border: Border.all(color: done ? AppColors.success : AppColors.lineStrong, width: 2),
                  ),
                  child: done ? const Icon(Icons.check, size: 14, color: Colors.white) : null,
                ),
                if (!last) Expanded(child: Container(width: 2, color: done ? AppColors.success : AppColors.divider)),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14.5, color: done ? AppColors.ink : AppColors.textSecondary)),
                    Text(detail, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Photos
// ---------------------------------------------------------------------------

class _PhotosPanel extends StatefulWidget {
  final CarRecordDetail car;
  final VoidCallback onChanged;
  const _PhotosPanel({required this.car, required this.onChanged});

  @override
  State<_PhotosPanel> createState() => _PhotosPanelState();
}

class _PhotosPanelState extends State<_PhotosPanel> {
  static const _maxPhotos = 20;
  final _cars = CarService();
  final _picker = ImagePicker();
  bool _busy = false;
  String? _status;

  List<CarMedia> get _photos => widget.car.media.where((m) => m.mediaType == MediaType.image).toList().inDisplayOrder;

  Future<void> _upload() async {
    final remaining = _maxPhotos - _photos.length;
    if (remaining <= 0) {
      showAppSnack(context, 'You can add up to $_maxPhotos photos. Delete one to add another.', error: true);
      return;
    }
    List<XFile> files = [];
    try {
      files = await _picker.pickMultiImage(imageQuality: 85, maxWidth: 2400);
    } catch (_) {
      final single = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 85, maxWidth: 2400);
      if (single != null) files = [single];
    }
    if (files.isEmpty || !mounted) return;
    if (files.length > remaining) {
      files = files.take(remaining).toList();
      showAppSnack(context, 'Only the first $remaining photos will be added (limit $_maxPhotos).');
    }
    setState(() => _busy = true);
    var hasPrimary = _photos.any((m) => m.isPrimary);
    var nextOrder = _photos.isEmpty ? 0 : _photos.map((m) => m.sortOrder).reduce((a, b) => a > b ? a : b) + 1;
    var uploaded = 0;
    try {
      for (var i = 0; i < files.length; i++) {
        if (!mounted) return;
        setState(() => _status = 'Uploading ${i + 1} of ${files.length}...');
        final file = files[i];
        final bytes = await file.readAsBytes();
        final name = file.name.contains('.') ? file.name : '${file.name}.jpg';
        await _cars.uploadMedia(
          widget.car.id,
          fileBytes: bytes,
          fileName: name,
          mediaType: MediaType.image,
          sortOrder: nextOrder++,
          isPrimary: !hasPrimary,
        );
        hasPrimary = true;
        uploaded++;
      }
      if (mounted) showAppSnack(context, '$uploaded ${uploaded == 1 ? 'photo' : 'photos'} added');
    } on ApiException catch (e) {
      if (mounted) showAppSnack(context, uploaded > 0 ? '$uploaded added. ${e.message}' : e.message, error: true);
    } catch (_) {
      if (mounted) showAppSnack(context, 'That photo could not be read. Try a JPG, PNG or WebP image.', error: true);
    } finally {
      if (mounted) {
        setState(() {
          _busy = false;
          _status = null;
        });
      }
      widget.onChanged();
    }
  }

  Future<void> _run(Future<void> Function() action, String done) async {
    setState(() => _busy = true);
    try {
      await action();
      if (mounted) showAppSnack(context, done);
      widget.onChanged();
    } on ApiException catch (e) {
      if (mounted) showAppSnack(context, e.message, error: true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _move(CarMedia m, int delta) {
    final list = [..._photos];
    final i = list.indexOf(m);
    final j = i + delta;
    if (j < 0 || j >= list.length) return;
    list.removeAt(i);
    list.insert(j, m);
    _run(() => _cars.reorderMedia(widget.car.id, [for (var k = 0; k < list.length; k++) MapEntry(list[k].id, k)]), 'Order updated');
  }

  Future<void> _delete(CarMedia m) async {
    final ok = await confirmAction(context, title: 'Delete this photo?', message: 'It will be removed from your car and listing.', confirmLabel: 'Delete', destructive: true);
    if (ok) _run(() => _cars.deleteMedia(widget.car.id, m.id), 'Photo deleted');
  }

  @override
  Widget build(BuildContext context) {
    final photos = _photos;
    return FormPanel(
      title: 'Photos',
      subtitle: photos.isEmpty
          ? 'Clear daylight photos of the front, back, sides, interior and odometer work best.'
          : 'The first photo is the cover buyers see. ${photos.length} of $_maxPhotos.',
      trailing: photos.isEmpty
          ? null
          : OutlinedButton.icon(
              onPressed: _busy ? null : _upload,
              icon: const Icon(Icons.add_photo_alternate_outlined, size: 19),
              label: const Text('Add'),
            ),
      children: [
        if (_status != null) ...[
          Semantics(liveRegion: true, child: Text(_status!, style: const TextStyle(fontWeight: FontWeight.w600))),
          const SizedBox(height: 8),
          const LinearProgressIndicator(),
          const SizedBox(height: 12),
        ],
        if (photos.isEmpty)
          InkWell(
            onTap: _busy ? null : _upload,
            borderRadius: BorderRadius.circular(AppRadii.md),
            child: Container(
              height: 160,
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(AppRadii.md),
                border: Border.all(color: AppColors.lineStrong),
              ),
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add_photo_alternate_outlined, size: 36, color: AppColors.chrome),
                    SizedBox(height: 8),
                    Text('Add photos', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                    SizedBox(height: 2),
                    Text('JPG, PNG or WebP', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                  ],
                ),
              ),
            ),
          )
        else
          LayoutBuilder(builder: (context, c) {
            final cols = c.maxWidth >= 640 ? 4 : (c.maxWidth >= 400 ? 3 : 2);
            const gap = 10.0;
            final w = (c.maxWidth - gap * (cols - 1)) / cols;
            return Wrap(
              spacing: gap,
              runSpacing: gap,
              children: [
                for (var i = 0; i < photos.length; i++)
                  SizedBox(
                    width: w,
                    child: _PhotoTile(
                      media: photos[i],
                      cover: i == 0,
                      busy: _busy,
                      canMoveLeft: i > 0,
                      canMoveRight: i < photos.length - 1,
                      onCover: () => _run(() => _cars.setPrimaryMedia(widget.car.id, photos[i].id), 'Cover photo updated'),
                      onLeft: () => _move(photos[i], -1),
                      onRight: () => _move(photos[i], 1),
                      onDelete: () => _delete(photos[i]),
                    ),
                  ),
              ],
            );
          }),
      ],
    );
  }
}

class _PhotoTile extends StatelessWidget {
  final CarMedia media;
  final bool cover;
  final bool busy;
  final bool canMoveLeft;
  final bool canMoveRight;
  final VoidCallback onCover;
  final VoidCallback onLeft;
  final VoidCallback onRight;
  final VoidCallback onDelete;

  const _PhotoTile({
    required this.media,
    required this.cover,
    required this.busy,
    required this.canMoveLeft,
    required this.canMoveRight,
    required this.onCover,
    required this.onLeft,
    required this.onRight,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadii.sm),
      child: AspectRatio(
        aspectRatio: 4 / 3,
        child: Stack(
          fit: StackFit.expand,
          children: [
            NetworkPhoto(url: media.thumbnailAbsoluteUrl(ApiConfig.baseUrl), cacheWidth: 300),
            if (cover)
              Positioned(
                left: 6,
                top: 6,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(color: AppColors.plate, borderRadius: BorderRadius.circular(AppRadii.xs)),
                  child: const Text('Cover', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: AppColors.ink)),
                ),
              ),
            Positioned(
              right: 4,
              top: 4,
              child: Material(
                color: Colors.white,
                shape: const CircleBorder(),
                child: PopupMenuButton<String>(
                  tooltip: 'Photo actions',
                  enabled: !busy,
                  padding: EdgeInsets.zero,
                  iconSize: 20,
                  icon: const Icon(Icons.more_horiz, color: AppColors.ink),
                  onSelected: (v) => switch (v) {
                    'cover' => onCover(),
                    'left' => onLeft(),
                    'right' => onRight(),
                    _ => onDelete(),
                  },
                  itemBuilder: (_) => [
                    if (!cover) const PopupMenuItem(value: 'cover', child: Text('Use as cover')),
                    if (canMoveLeft) const PopupMenuItem(value: 'left', child: Text('Move earlier')),
                    if (canMoveRight) const PopupMenuItem(value: 'right', child: Text('Move later')),
                    const PopupMenuItem(value: 'delete', child: Text('Delete photo', style: TextStyle(color: AppColors.danger))),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Features
// ---------------------------------------------------------------------------

class _FeaturesPanel extends StatefulWidget {
  final CarRecordDetail car;
  final VoidCallback onChanged;
  const _FeaturesPanel({required this.car, required this.onChanged});

  @override
  State<_FeaturesPanel> createState() => _FeaturesPanelState();
}

class _FeaturesPanelState extends State<_FeaturesPanel> {
  static const _suggestions = [
    'Sunroof',
    'Airbags',
    'Rear camera',
    'Parking sensors',
    'Cruise control',
    'Touchscreen',
    'Android Auto / Apple CarPlay',
    'Alloy wheels',
    'Keyless entry',
    'Automatic climate control',
    'Ventilated seats',
    'Wireless charging',
  ];

  final _cars = CarService();
  final _name = TextEditingController();
  final _value = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _name.dispose();
    _value.dispose();
    super.dispose();
  }

  Future<void> _add([String? preset]) async {
    final name = (preset ?? _name.text).trim();
    if (name.isEmpty || _busy) return;
    if (widget.car.features.any((f) => f.featureName.toLowerCase() == name.toLowerCase())) {
      showAppSnack(context, '$name is already listed');
      return;
    }
    setState(() => _busy = true);
    try {
      await _cars.addFeature(widget.car.id, name, preset == null ? _value.text.trim() : null);
      _name.clear();
      _value.clear();
      widget.onChanged();
    } on ApiException catch (e) {
      if (mounted) showAppSnack(context, e.message, error: true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _remove(CarFeature f) async {
    setState(() => _busy = true);
    try {
      await _cars.deleteFeature(widget.car.id, f.id);
      widget.onChanged();
    } on ApiException catch (e) {
      if (mounted) showAppSnack(context, e.message, error: true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final features = widget.car.features;
    final existing = features.map((f) => f.featureName.toLowerCase()).toSet();
    final suggestions = _suggestions.where((s) => !existing.contains(s.toLowerCase())).take(8).toList();
    return FormPanel(
      title: 'Features',
      subtitle: 'Shown on your listing. Add what makes the car worth a look.',
      children: [
        if (features.isNotEmpty) ...[
          LayoutBuilder(
            builder: (context, c) => Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final f in features)
                  ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: c.maxWidth),
                    child: InputChip(
                      label: Text(f.featureValue == null || f.featureValue!.isEmpty ? f.featureName : '${f.featureName}: ${f.featureValue}'),
                      onDeleted: _busy ? null : () => _remove(f),
                      deleteButtonTooltipMessage: 'Remove ${f.featureName}',
                      deleteIcon: const Icon(Icons.close, size: 16),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
        if (suggestions.isNotEmpty) ...[
          const Text('Quick add', style: TextStyle(fontSize: 13, color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final s in suggestions)
                ActionChip(
                  avatar: const Icon(Icons.add, size: 16),
                  label: Text(s),
                  onPressed: _busy ? null : () => _add(s),
                ),
            ],
          ),
          const SizedBox(height: 16),
        ],
        FieldPair(
          AuthTextField(controller: _name, label: 'Feature', hint: 'e.g. Sunroof', textInputAction: TextInputAction.next, maxLength: 150),
          AuthTextField(controller: _value, label: 'Detail (optional)', hint: 'e.g. Panoramic', onSubmitted: (_) => _add(), maxLength: 255),
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: OutlinedButton.icon(onPressed: _busy ? null : () => _add(), icon: const Icon(Icons.add, size: 18), label: const Text('Add feature')),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Listing
// ---------------------------------------------------------------------------

class _ListingPanel extends StatefulWidget {
  final CarRecordDetail car;
  final Listing? listing;
  final VoidCallback onChanged;
  const _ListingPanel({required this.car, required this.listing, required this.onChanged});

  @override
  State<_ListingPanel> createState() => _ListingPanelState();
}

class _ListingPanelState extends State<_ListingPanel> {
  final _market = MarketplaceService();
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _price = TextEditingController();
  final _description = TextEditingController();
  bool _negotiable = true;
  bool _busy = false;
  bool _editing = false;

  @override
  void initState() {
    super.initState();
    _fill();
  }

  @override
  void didUpdateWidget(covariant _ListingPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.listing, widget.listing) && !_editing) _fill();
  }

  @override
  void dispose() {
    _title.dispose();
    _price.dispose();
    _description.dispose();
    super.dispose();
  }

  void _fill() {
    final l = widget.listing;
    final car = widget.car;
    if (l != null) {
      _title.text = l.title;
      _price.text = l.askingPrice.round().toString();
      _description.text = l.description ?? '';
      _negotiable = l.negotiable;
    } else {
      _title.text = car.fullTitle;
      final expected = car.expectedMarketPrice;
      _price.text = expected == null || expected <= 0 ? '' : expected.round().toString();
      _description.text = '';
    }
  }

  num? get _priceValue => num.tryParse(_price.text.replaceAll(',', '').trim());

  Future<void> _save() async {
    if (!_formKey.currentState!.validate() || _busy) return;
    setState(() => _busy = true);
    try {
      if (widget.listing == null) {
        await _market.createListing(
          widget.car.id,
          listingType: widget.car.condition == CarCondition.newCar ? ListingType.sale : ListingType.resale,
          title: _title.text.trim(),
          description: _description.text.trim(),
          askingPrice: _priceValue!,
          negotiable: _negotiable,
        );
        if (mounted) showAppSnack(context, 'Listing created');
      } else {
        await _market.updateListing(widget.car.id, {
          'title': _title.text.trim(),
          'description': _description.text.trim().isEmpty ? null : _description.text.trim(),
          'asking_price': _priceValue,
          'negotiable': _negotiable,
        });
        if (mounted) showAppSnack(context, 'Listing updated');
      }
      _editing = false;
      widget.onChanged();
    } on ApiException catch (e) {
      if (mounted) showAppSnack(context, e.message, error: true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _publish(bool publish) async {
    if (!publish) {
      final ok = await confirmAction(
        context,
        title: 'Take the listing down?',
        message: 'Buyers won\'t see it until you publish it again. People who saved it are told it is unavailable.',
        confirmLabel: 'Take down',
      );
      if (!ok) return;
    }
    setState(() => _busy = true);
    try {
      if (publish) {
        await _market.publishListing(widget.car.id);
      } else {
        await _market.unpublishListing(widget.car.id);
      }
      if (mounted) showAppSnack(context, publish ? 'Published. Buyers can now find your car.' : 'Listing taken down');
      widget.onChanged();
    } on ApiException catch (e) {
      if (mounted) showAppSnack(context, e.message, error: true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _delete() async {
    final ok = await confirmAction(
      context,
      title: 'Delete the listing?',
      message: 'Your car stays in your account; only the listing and its price are removed.',
      confirmLabel: 'Delete listing',
      destructive: true,
    );
    if (!ok) return;
    setState(() => _busy = true);
    try {
      await _market.deleteListing(widget.car.id);
      if (mounted) showAppSnack(context, 'Listing deleted');
      widget.onChanged();
    } on ApiException catch (e) {
      if (mounted) showAppSnack(context, e.message, error: true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = widget.listing;
    final car = widget.car;
    final approved = car.isVerified &&
        (car.approvalStatus == CarApprovalStatus.approved || car.approvalStatus == CarApprovalStatus.published);
    final live = l?.listingStatus == ListingStatus.active;
    final locked = l != null && (l.listingStatus == ListingStatus.reserved || l.listingStatus == ListingStatus.sold);

    if (l != null && !_editing) {
      return FormPanel(
        title: 'Listing',
        trailing: StatusPill(label: l.listingStatus.label, tone: listingTone(l.listingStatus)),
        children: [
          Text(l.title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
          const SizedBox(height: 6),
          Wrap(crossAxisAlignment: WrapCrossAlignment.center, spacing: 10, children: [
            Text(formatInr(l.askingPrice), style: AppText.price(22)),
            Text(l.negotiable ? 'Negotiable' : 'Fixed price', style: const TextStyle(color: AppColors.textSecondary)),
          ]),
          if ((l.description ?? '').isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(l.description!, style: const TextStyle(height: 1.5)),
          ],
          if (l.viewsCount != null) ...[
            const SizedBox(height: 10),
            Text('${formatCount(l.viewsCount!)} views so far', style: const TextStyle(color: AppColors.textSecondary, fontSize: 13.5)),
          ],
          const SizedBox(height: 16),
          if (locked)
            Callout(
              tone: CalloutTone.warning,
              message: l.listingStatus == ListingStatus.sold
                  ? 'This car is sold. The listing can no longer be changed.'
                  : 'You accepted a buyer\'s request, so the car is reserved. Manage the sale from Orders.',
              action: TextButton(onPressed: () => Navigator.of(context).pushNamed(AppRoutes.sales), child: const Text('Go to orders')),
            )
          else if (!approved && !live)
            const Callout(message: 'You can publish once our team approves the car. We\'ll notify you.'),
          if (!locked) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                if (live)
                  OutlinedButton(onPressed: _busy ? null : () => _publish(false), child: const Text('Take down'))
                else
                  ElevatedButton(onPressed: _busy || !approved ? null : () => _publish(true), child: const Text('Publish listing')),
                OutlinedButton(onPressed: _busy ? null : () => setState(() => _editing = true), child: const Text('Edit')),
                if (live)
                  TextButton(
                    onPressed: () => Navigator.of(context).pushNamed(AppRoutes.carDetails(l.id, l.title)),
                    child: const Text('View as buyer'),
                  ),
                TextButton(
                  onPressed: _busy ? null : _delete,
                  style: TextButton.styleFrom(foregroundColor: AppColors.danger),
                  child: const Text('Delete listing'),
                ),
              ],
            ),
          ],
        ],
      );
    }

    return Form(
      key: _formKey,
      child: FormPanel(
        title: l == null ? 'Create your listing' : 'Edit listing',
        subtitle: l == null ? 'Set the price and how the car appears to buyers. You can publish after approval.' : null,
        children: [
          AuthTextField(
            controller: _title,
            label: 'Listing title',
            required: true,
            maxLength: 255,
            validator: (v) => Validators.required(v, message: 'Enter a title'),
          ),
          AuthTextField(
            controller: _price,
            label: 'Asking price (₹)',
            required: true,
            keyboardType: TextInputType.number,
            helper: _priceValue == null ? 'Full amount in rupees, e.g. 650000' : formatInr(_priceValue!),
            onChanged: (_) => setState(() {}),
            validator: (v) {
              final err = Validators.positiveNumber(v, field: 'Price');
              if (err != null) return err;
              return (_priceValue ?? 0) <= 0 ? 'Enter a price above zero' : null;
            },
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            value: _negotiable,
            onChanged: (v) => setState(() => _negotiable = v),
            title: const Text('Open to offers'),
            subtitle: const Text('Shows "Negotiable" next to your price'),
          ),
          const SizedBox(height: 8),
          AuthTextField(controller: _description, label: 'Listing description', maxLines: 4, maxLength: 2000),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              FilledButton(
                onPressed: _busy ? null : _save,
                child: _busy
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2.4, color: Colors.white))
                    : Text(l == null ? 'Create listing' : 'Save listing'),
              ),
              if (l != null)
                TextButton(
                  onPressed: _busy
                      ? null
                      : () => setState(() {
                            _editing = false;
                            _fill();
                          }),
                  child: const Text('Cancel'),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Details summary
// ---------------------------------------------------------------------------

class _DetailsPanel extends StatelessWidget {
  final CarRecordDetail car;
  final VoidCallback onEdit;
  const _DetailsPanel({required this.car, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    final rows = <(String, String)>[
      ('Variant', car.variantName),
      ('Manufactured', '${car.manufacturingYear}'),
      ('Driven', formatKm(car.mileageKm)),
      ('Fuel and gearbox', '${car.fuelType.label}, ${car.transmission.label}'),
      ('Condition', car.condition.label),
      if (car.ownershipType != null) ('Ownership', car.ownershipType!.label),
      if (car.registrationNumber != null) ('Registration', car.registrationNumber!),
      if (car.color != null) ('Colour', car.color!),
      ('Location', '${car.city}, ${car.state}'),
    ];
    return FormPanel(
      title: 'Car details',
      trailing: TextButton(onPressed: onEdit, child: const Text('Edit')),
      children: [
        for (final r in rows)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: Text(r.$1, style: const TextStyle(color: AppColors.textSecondary, fontSize: 14))),
                const SizedBox(width: 12),
                Expanded(child: Text(r.$2, textAlign: TextAlign.right, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14))),
              ],
            ),
          ),
      ],
    );
  }
}
