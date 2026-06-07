import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:promofy/l10n/app_localizations.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/establishment_model.dart';
import '../../../data/models/establishment_photo_model.dart';
import '../../../data/repositories/photos_repository.dart';

// ─── Sección principal ────────────────────────────────────────────────────────

class PhotosSection extends StatefulWidget {
  final EstablishmentModel establishment;
  const PhotosSection({super.key, required this.establishment});

  @override
  State<PhotosSection> createState() => _PhotosSectionState();
}

class _PhotosSectionState extends State<PhotosSection> {
  final _repo   = PhotosRepository();
  final _picker = ImagePicker();

  List<EstablishmentPhotoModel> _photos        = [];
  String?  _logoUrl;
  bool     _loadingPhotos  = true;
  bool     _uploadingLogo  = false;
  String?  _uploadingCat;   // clave de categoría siendo subida
  String?  _deletingId;     // id de foto siendo eliminada

  static const _categories = <(String, int)>[
    ('establishment', 2),
    ('children_area', 2),
    ('menu',          3),
  ];

  String _categoryLabel(BuildContext context, String key) {
    final l10n = AppLocalizations.of(context);
    switch (key) {
      case 'establishment':
        return l10n.photosCategoryEstablishment;
      case 'children_area':
        return l10n.photosCategoryChildrenArea;
      case 'menu':
        return l10n.photosCategoryMenu;
      default:
        return key;
    }
  }

  @override
  void initState() {
    super.initState();
    _logoUrl = widget.establishment.logoUrl;
    _loadPhotos();
  }

  // ── Carga ─────────────────────────────────────────────────────────────────

  Future<void> _loadPhotos() async {
    try {
      final photos = await _repo.getPhotos(widget.establishment.id);
      if (mounted) setState(() { _photos = photos; _loadingPhotos = false; });
    } catch (_) {
      if (mounted) setState(() => _loadingPhotos = false);
    }
  }

  // ── Logo ──────────────────────────────────────────────────────────────────

  Future<void> _pickLogo() async {
    final file = await _picker.pickImage(
      source:       ImageSource.gallery,
      maxWidth:     800,
      maxHeight:    800,
      imageQuality: 85,
    );
    if (file == null || !mounted) return;

    setState(() => _uploadingLogo = true);
    try {
      final url = await _repo.uploadLogo(widget.establishment.id, file);
      if (mounted) setState(() { _logoUrl = url; _uploadingLogo = false; });
    } catch (_) {
      if (mounted) {
        setState(() => _uploadingLogo = false);
        _snack(AppLocalizations.of(context).photosErrorUploadLogo);
      }
    }
  }

  // ── Fotos ─────────────────────────────────────────────────────────────────

  Future<void> _pickPhoto(String category) async {
    final file = await _picker.pickImage(
      source:       ImageSource.gallery,
      maxWidth:     1200,
      maxHeight:    1200,
      imageQuality: 80,
    );
    if (file == null || !mounted) return;

    setState(() => _uploadingCat = category);
    try {
      final photo = await _repo.uploadPhoto(
          widget.establishment.id, category, file);
      if (mounted) {
        setState(() {
          _photos       = [..._photos, photo];
          _uploadingCat = null;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _uploadingCat = null);
        _snack(AppLocalizations.of(context).photosErrorUploadPhoto);
      }
    }
  }

  Future<void> _confirmDelete(EstablishmentPhotoModel photo) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title:   Text(AppLocalizations.of(context).photosDeleteTitle),
        content: Text(AppLocalizations.of(context).photosDeleteConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(false),
            child: Text(AppLocalizations.of(context).photosCancel),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () => Navigator.of(dialogCtx).pop(true),
            child: Text(AppLocalizations.of(context).photosDelete),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;

    setState(() => _deletingId = photo.id);
    try {
      await _repo.deletePhoto(photo);
      if (mounted) {
        setState(() {
          _photos     = _photos.where((p) => p.id != photo.id).toList();
          _deletingId = null;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _deletingId = null);
        _snack(AppLocalizations.of(context).photosErrorDeletePhoto);
      }
    }
  }

  void _snack(String msg) => ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating),
  );

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:        Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color:      Colors.black.withAlpha(13),
            blurRadius: 8,
            offset:     const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Encabezado ───────────────────────────────────────────────────
          Row(
            children: [
              const Icon(Icons.photo_library_outlined,
                  size: 20, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                AppLocalizations.of(context).photosSectionTitle,
                style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // ── Logo ─────────────────────────────────────────────────────────
          _LogoRow(
            logoUrl:   _logoUrl,
            uploading: _uploadingLogo,
            onTap:     _pickLogo,
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 16),

          // ── Fotos por categoría ───────────────────────────────────────────
          if (_loadingPhotos)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: CircularProgressIndicator(strokeWidth: 2.5),
              ),
            )
          else
            for (final (key, maxCount) in _categories) ...[
              _PhotoCategorySection(
                label:      _categoryLabel(context, key),
                photos:     _photos.where((p) => p.category == key).toList(),
                maxCount:   maxCount,
                uploading:  _uploadingCat == key,
                deletingId: _deletingId,
                onAdd:      () => _pickPhoto(key),
                onDelete:   _confirmDelete,
              ),
              const SizedBox(height: 16),
            ],
        ],
      ),
    );
  }
}

// ─── Logo row ─────────────────────────────────────────────────────────────────

class _LogoRow extends StatelessWidget {
  final String?    logoUrl;
  final bool       uploading;
  final VoidCallback onTap;

  const _LogoRow({
    required this.logoUrl,
    required this.uploading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Avatar cuadrado
        GestureDetector(
          onTap: uploading ? null : onTap,
          child: Container(
            width:  72,
            height: 72,
            decoration: BoxDecoration(
              color:        AppColors.primary.withAlpha(20),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.primary.withAlpha(80),
                width: 1.5,
              ),
            ),
            child: uploading
                ? const Center(
                    child: SizedBox(
                      width: 24, height: 24,
                      child: CircularProgressIndicator(
                          strokeWidth: 2.5, color: AppColors.primary),
                    ),
                  )
                : logoUrl != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: CachedNetworkImage(
                          imageUrl:    logoUrl!,
                          fit:         BoxFit.cover,
                          errorWidget: (_, __, ___) => const Icon(
                            Icons.store,
                            color: AppColors.primary,
                            size: 32,
                          ),
                        ),
                      )
                    : const Icon(
                        Icons.add_photo_alternate_outlined,
                        color: AppColors.primary,
                        size: 32,
                      ),
          ),
        ),
        const SizedBox(width: 16),
        // Texto + botón
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.of(context).photosLogoTitle,
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark),
              ),
              const SizedBox(height: 4),
              Text(
                AppLocalizations.of(context).photosLogoHint,
                style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
              ),
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: uploading ? null : onTap,
                icon:  Icon(
                  logoUrl != null
                      ? Icons.refresh_outlined
                      : Icons.upload_outlined,
                  size: 16,
                ),
                label: Text(
                  logoUrl != null
                      ? AppLocalizations.of(context).photosChangeLogo
                      : AppLocalizations.of(context).photosUploadLogo,
                  style: const TextStyle(fontSize: 13),
                ),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 6),
                  minimumSize:   Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Sección de fotos por categoría ──────────────────────────────────────────

class _PhotoCategorySection extends StatelessWidget {
  final String                        label;
  final List<EstablishmentPhotoModel> photos;
  final int                           maxCount;
  final bool                          uploading;
  final String?                       deletingId;
  final VoidCallback                  onAdd;
  final void Function(EstablishmentPhotoModel) onDelete;

  const _PhotoCategorySection({
    required this.label,
    required this.photos,
    required this.maxCount,
    required this.uploading,
    required this.deletingId,
    required this.onAdd,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final canAdd    = photos.length < maxCount;
    final showAdd   = canAdd || uploading;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Encabezado de categoría
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark),
              ),
            ),
            Text(
              '${photos.length}/$maxCount',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Scroll horizontal de fotos
        SizedBox(
          height: 90,
          child: photos.isEmpty && !showAdd
              ? Center(
                  child: Text(
                    AppLocalizations.of(context).photosEmpty,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade400),
                  ),
                )
              : SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      for (int i = 0; i < photos.length; i++) ...[
                        if (i > 0) const SizedBox(width: 8),
                        _PhotoThumb(
                          photo:      photos[i],
                          isDeleting: deletingId == photos[i].id,
                          onDelete:   () => onDelete(photos[i]),
                        ),
                      ],
                      if (showAdd) ...[
                        if (photos.isNotEmpty) const SizedBox(width: 8),
                        _AddPhotoButton(
                          uploading: uploading,
                          onTap:     canAdd ? onAdd : null,
                        ),
                      ],
                    ],
                  ),
                ),
        ),
      ],
    );
  }
}

// ─── Miniatura de foto ────────────────────────────────────────────────────────

class _PhotoThumb extends StatelessWidget {
  final EstablishmentPhotoModel photo;
  final bool         isDeleting;
  final VoidCallback onDelete;

  const _PhotoThumb({
    required this.photo,
    required this.isDeleting,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width:  90,
      height: 90,
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: CachedNetworkImage(
              imageUrl: photo.url,
              width:    90,
              height:   90,
              fit:      BoxFit.cover,
              placeholder: (_, __) => Container(
                color: Colors.grey.shade200,
                child: const Center(
                  child: SizedBox(
                    width:  20, height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              ),
              errorWidget: (_, __, ___) => Container(
                color: Colors.grey.shade200,
                child: const Icon(
                    Icons.broken_image_outlined, color: Colors.grey),
              ),
            ),
          ),
          // Overlay cuando se está eliminando
          if (isDeleting)
            Container(
              width:  90, height: 90,
              decoration: BoxDecoration(
                color:        Colors.black.withAlpha(120),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Center(
                child: SizedBox(
                  width: 22, height: 22,
                  child: CircularProgressIndicator(
                      strokeWidth: 2.5, color: Colors.white),
                ),
              ),
            )
          else
            // Botón eliminar
            Positioned(
              top: 4, right: 4,
              child: GestureDetector(
                onTap: onDelete,
                child: Container(
                  width:  22, height: 22,
                  decoration: BoxDecoration(
                    color: Colors.black.withAlpha(150),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close,
                    size:  14,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─── Botón agregar foto ───────────────────────────────────────────────────────

class _AddPhotoButton extends StatelessWidget {
  final bool          uploading;
  final VoidCallback? onTap;

  const _AddPhotoButton({required this.uploading, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (uploading || onTap == null) ? null : onTap,
      child: Container(
        width:  90,
        height: 90,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: AppColors.primary.withAlpha(100),
            width: 1.5,
          ),
          color: AppColors.primary.withAlpha(12),
        ),
        child: uploading
            ? const Center(
                child: SizedBox(
                  width: 22, height: 22,
                  child: CircularProgressIndicator(
                      strokeWidth: 2.5, color: AppColors.primary),
                ),
              )
            : Icon(
                Icons.add_photo_alternate_outlined,
                color: AppColors.primary.withAlpha(180),
                size:  32,
              ),
      ),
    );
  }
}
