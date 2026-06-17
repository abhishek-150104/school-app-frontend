import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../models/attendance_models.dart';

class AttendanceRepository {
  final DioClient _dio;
  AttendanceRepository(this._dio);

  Future<List<AttendanceModel>> getBySection(String sectionId, String date) async {
    final res = await _dio.get(
      ApiConstants.sectionAttendance(sectionId),
      params: {'date': date},
    );
    return (res.data['data'] as List)
        .map((e) => AttendanceModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<AttendanceModel>> markBulk(
      String sectionId, String date, List<AttendanceEntry> entries) async {
    final res = await _dio.post(
      ApiConstants.sectionAttendance(sectionId),
      data: {
        'date': date,
        'records': entries.map((e) => e.toJson()).toList(),
      },
    );
    return (res.data['data'] as List)
        .map((e) => AttendanceModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<AttendanceSummaryModel> getSummary(
      String sectionId, String from, String to) async {
    final res = await _dio.get(
      ApiConstants.attendanceSummary(sectionId),
      params: {'from': from, 'to': to},
    );
    return AttendanceSummaryModel.fromJson(
        res.data['data'] as Map<String, dynamic>);
  }

  Future<List<AttendanceModel>> getByStudent(
      String studentId, String from, String to) async {
    final res = await _dio.get(
      ApiConstants.studentAttendance(studentId),
      params: {'from': from, 'to': to},
    );
    return (res.data['data'] as List)
        .map((e) => AttendanceModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<AttendanceModel>> getMyChildAttendance(
      String studentId, String from, String to) async {
    final res = await _dio.get(
      ApiConstants.myChildAttendance(studentId),
      params: {'from': from, 'to': to},
    );
    return (res.data['data'] as List)
        .map((e) => AttendanceModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<AttendanceModel> updateRecord(
      String attendanceId, AttendanceStatus status, {String? remarks}) async {
    final res = await _dio.put(
      ApiConstants.attendanceRecord(attendanceId),
      data: {
        'status': status.apiValue,
        if (remarks != null) 'remarks': remarks,
      },
    );
    return AttendanceModel.fromJson(res.data['data'] as Map<String, dynamic>);
  }
}

final attendanceRepositoryProvider = Provider<AttendanceRepository>(
    (ref) => AttendanceRepository(ref.read(dioClientProvider)));
