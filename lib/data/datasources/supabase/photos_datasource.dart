import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show FileOptions;
import '../../../main.dart';
import '../../models/establishment_photo_model.dart';

class PhotosDatasource {
  static const _bucket = 'establishments';

  // ── Consulta ──────────────────────────────────────────────────────────────

  Future<List<EstablishmentPhotoModel>> getPhotos(String establishmentId) async {
    final response = await supabase
        .from('establishment_photos')
        .select()
        .eq('establishment_id', establishmentId)
        .order('sort_order');
    return (response as List)
        .map((e) => EstablishmentPhotoModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // ── Logo ──────────────────────────────────────────────────────────────────

  /// Sube (o reemplaza) el logo y actualiza logo_url en establishments.
  Future<String> uploadLogo(String establishmentId, XFile file) async {
    final bytes = await file.readAsBytes();
    final ext   = _safeExt(file.path);
    // Timestamp en el path para forzar bust de caché en CachedNetworkImage
    final ts    = DateTime.now().millisecondsSinceEpoch;
    final path  = '$establishmentId/logo_$ts.$ext';

    await supabase.storage.from(_bucket).uploadBinary(
      path, bytes,
      fileOptions: FileOptions(contentType: _contentType(ext), upsert: false),
    );

    final url = supabase.storage.from(_bucket).getPublicUrl(path);

    await supabase
        .from('establishments')
        .update({'logo_url': url})
        .eq('id', establishmentId);

    return url;
  }

  // ── Fotos ─────────────────────────────────────────────────────────────────

  Future<EstablishmentPhotoModel> uploadPhoto(
    String establishmentId,
    String category,
    XFile  file,
  ) async {
    final bytes = await file.readAsBytes();
    final ext   = _safeExt(file.path);
    final ts    = DateTime.now().millisecondsSinceEpoch;
    final path  = '$establishmentId/$category/$ts.$ext';

    await supabase.storage.from(_bucket).uploadBinary(
      path, bytes,
      fileOptions: FileOptions(contentType: _contentType(ext), upsert: false),
    );

    final url = supabase.storage.from(_bucket).getPublicUrl(path);

    final response = await supabase
        .from('establishment_photos')
        .insert({
          'establishment_id': establishmentId,
          'category':         category,
          'url':              url,
          'sort_order':       ts,
        })
        .select()
        .single();

    return EstablishmentPhotoModel.fromJson(response);
  }

  Future<void> deletePhoto(EstablishmentPhotoModel photo) async {
    // Elimina de Storage (best-effort: si el archivo ya no existe, continúa)
    final storagePath = _pathFromUrl(photo.url);
    if (storagePath.isNotEmpty) {
      try {
        await supabase.storage.from(_bucket).remove([storagePath]);
      } catch (_) {}
    }
    // Elimina de la tabla
    await supabase
        .from('establishment_photos')
        .delete()
        .eq('id', photo.id);
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  String _safeExt(String filePath) {
    final raw = filePath.split('.').last.toLowerCase();
    if (raw == 'png')  return 'png';
    if (raw == 'webp') return 'webp';
    return 'jpg'; // cubre jpg, jpeg, heic (image_picker comprime a JPEG)
  }

  String _contentType(String ext) {
    if (ext == 'png')  return 'image/png';
    if (ext == 'webp') return 'image/webp';
    return 'image/jpeg';
  }

  /// Extrae el path de Storage a partir de la URL pública.
  /// URL pública: .../storage/v1/object/public/establishments/{path}
  String _pathFromUrl(String url) {
    const marker = '/object/public/$_bucket/';
    final idx    = url.indexOf(marker);
    return idx == -1 ? '' : url.substring(idx + marker.length);
  }
}
