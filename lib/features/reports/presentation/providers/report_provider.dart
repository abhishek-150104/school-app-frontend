import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/report_models.dart';
import '../../data/repositories/report_repository.dart';

final dashboardReportProvider = FutureProvider<ReportModel>((ref) {
  return ref.read(reportRepositoryProvider).getDashboardReport();
});

final feeReportProvider = FutureProvider<ReportModel>((ref) {
  return ref.read(reportRepositoryProvider).getFeeReport();
});

final attendanceReportProvider = FutureProvider<ReportModel>((ref) {
  return ref.read(reportRepositoryProvider).getAttendanceReport();
});

final examReportProvider = FutureProvider<ReportModel>((ref) {
  return ref.read(reportRepositoryProvider).getExamReport();
});
