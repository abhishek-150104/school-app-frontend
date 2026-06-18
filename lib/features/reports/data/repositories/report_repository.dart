import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/report_models.dart';

class ReportRepository {
  final DioClient _dio;
  ReportRepository(this._dio);

  Future<ReportModel> getDashboardReport() async {
    final res = await _dio.get(ApiConstants.reportDashboard);
    return ReportModel.fromJson(res.data['data']);
  }

  Future<ReportModel> getFeeReport() async {
    final res = await _dio.get(ApiConstants.reportFees);
    return ReportModel.fromJson(res.data['data']);
  }

  Future<ReportModel> getAttendanceReport() async {
    final res = await _dio.get(ApiConstants.reportAttendance);
    return ReportModel.fromJson(res.data['data']);
  }

  Future<ReportModel> getExamReport() async {
    final res = await _dio.get(ApiConstants.reportExams);
    return ReportModel.fromJson(res.data['data']);
  }
}

final reportRepositoryProvider = Provider((ref) {
  return ReportRepository(ref.read(dioClientProvider));
});
