import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/school_models.dart';

final schoolRepositoryProvider = Provider<SchoolRepository>((ref) {
  return SchoolRepository(ref.read(dioClientProvider));
});

class SchoolRepository {
  final DioClient _dio;
  SchoolRepository(this._dio);

  // ── School (single) ───────────────────────────────────────────────────────

  Future<SchoolModel> getSchool() async {
    final res = await _dio.get(ApiConstants.school);
    return SchoolModel.fromJson(res.data['data']);
  }

  Future<SchoolModel> updateSchool(Map<String, dynamic> data) async {
    final res = await _dio.put(ApiConstants.school, data: data);
    return SchoolModel.fromJson(res.data['data']);
  }

  // ── Academic Years ────────────────────────────────────────────────────────

  Future<List<AcademicYearModel>> getAcademicYears() async {
    final res = await _dio.get(ApiConstants.academicYears);
    return (res.data['data'] as List)
        .map((e) => AcademicYearModel.fromJson(e))
        .toList();
  }

  Future<AcademicYearModel> createAcademicYear(Map<String, dynamic> data) async {
    final res = await _dio.post(ApiConstants.academicYears, data: data);
    return AcademicYearModel.fromJson(res.data['data']);
  }

  Future<void> activateYear(String yearId) =>
      _dio.post(ApiConstants.activateYear(yearId));

  Future<void> deleteYear(String yearId) =>
      _dio.delete(ApiConstants.academicYear(yearId));

  // ── Classrooms ────────────────────────────────────────────────────────────

  Future<List<ClassRoomModel>> getClassrooms({String? academicYearId}) async {
    final res = await _dio.get(ApiConstants.classrooms,
        params: academicYearId != null ? {'academicYearId': academicYearId} : null);
    return (res.data['data'] as List)
        .map((e) => ClassRoomModel.fromJson(e))
        .toList();
  }

  Future<ClassRoomModel> createClassroom(Map<String, dynamic> data) async {
    final res = await _dio.post(ApiConstants.classrooms, data: data);
    return ClassRoomModel.fromJson(res.data['data']);
  }

  Future<ClassRoomModel> updateClassroom(
      String classId, Map<String, dynamic> data) async {
    final res = await _dio.put(ApiConstants.classroom(classId), data: data);
    return ClassRoomModel.fromJson(res.data['data']);
  }

  Future<void> deleteClassroom(String classId) =>
      _dio.delete(ApiConstants.classroom(classId));

  // ── Sections ──────────────────────────────────────────────────────────────

  Future<List<SectionModel>> getSections(String classId) async {
    final res = await _dio.get(ApiConstants.sections(classId));
    return (res.data['data'] as List)
        .map((e) => SectionModel.fromJson(e))
        .toList();
  }

  Future<SectionModel> createSection(
      String classId, Map<String, dynamic> data) async {
    final res = await _dio.post(ApiConstants.sections(classId), data: data);
    return SectionModel.fromJson(res.data['data']);
  }

  Future<SectionModel> assignTeacher(
      String classId, String sectionId, String teacherId) async {
    final res = await _dio.post(
        ApiConstants.assignTeacher(classId, sectionId),
        data: {'teacherId': teacherId});
    return SectionModel.fromJson(res.data['data']);
  }

  Future<void> deleteSection(String classId, String sectionId) =>
      _dio.delete(ApiConstants.section(classId, sectionId));
}
