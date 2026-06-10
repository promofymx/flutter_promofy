import '../datasources/supabase/reports_datasource.dart';

/// Reportes de contenido para moderación (promociones / establecimientos).
class ReportsRepository {
  final ReportsDatasource _ds;

  ReportsRepository({ReportsDatasource? datasource})
      : _ds = datasource ?? ReportsDatasource();

  Future<void> submitReport({
    required String contentType,
    required String contentId,
    required String reason,
    String? note,
  }) =>
      _ds.submitReport(
        contentType: contentType,
        contentId:   contentId,
        reason:      reason,
        note:        note,
      );
}
