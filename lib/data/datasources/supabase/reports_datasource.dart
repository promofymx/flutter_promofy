import '../../../main.dart';

/// Inserta reportes de contenido (moderación) en la tabla content_reports.
class ReportsDatasource {
  Future<void> submitReport({
    required String contentType, // 'promotion' | 'establishment'
    required String contentId,
    required String reason,
    String? note,
  }) async {
    final uid = supabase.auth.currentUser?.id;
    await supabase.from('content_reports').insert({
      'reporter_id':  uid,
      'content_type': contentType,
      'content_id':   contentId,
      'reason':       reason,
      if (note != null && note.trim().isNotEmpty) 'note': note.trim(),
    });
  }
}
