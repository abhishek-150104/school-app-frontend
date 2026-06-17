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

  // ── Schools ───────────────────────────────────────────────────────────────

  Future<List<SchoolModel>> getSchools() async {
    final res = await _dio.get(ApiConstants.schools);
    return (res.data['data'] as List)
        .map((e) => SchoolModel.fromJson(e))
        .toList();
  }

  Future<SchoolModel> createSchool(Map<String, dynamic> data) async {
    final res = await _dio.post(ApiConstants.schools, data: data);
    return SchoolModel.fromJson(res.data['data']);
  }

  Future<SchoolModel> updateSchool(String id, Map<String, dynamic> data) async {
    final res = await _dio.put(ApiConstants.school(id), data: data);
    return SchoolModel.fromJson(res.data['data']);
  }

  Future<void> deleteSchool(String id) =>
      _dio.delete(ApiConstants.school(id));

  // ── Academic Years ────────────────────────────────────────────────────────

  Future<List<AcademicYearModel>> getAcademicYears(String schoolId) async {
    final res = await _dio.get(ApiConstants.academicYears(schoolId));
    return (res.data['data'] as List)
        .map((e) => AcademicYearModel.fromJson(e))
        .toList();
  }

  Future<AcademicYearModel> createAcademicYear(
      String schoolId, Map<String, dynamic> data) async {
    final res =
        await _dio.post(ApiConstants.academicYears(schoolId), data: data);
    return AcademicYearModel.fromJson(res.data['data']);
  }

  Future<void> activateYear(String schoolId, String yearId) =>
      _dio.post(ApiConstants.activateYear(schoolId, yearId));

  Future<void> deleteYear(String schoolId, String yearId) =>
      _dio.delete(ApiConstants.academicYear(schoolId, yearId));

  // ── Classrooms ────────────────────────────────────────────────────────────

  Future<List<ClassRoomModel>> getClassrooms(String schoolId,
      {String? academicYearId}) async {
    final res = await _dio.get(ApiConstants.classrooms(schoolId),
        params: academicYearId != null
            ? {'academicYearId': academicYearId}
            : null);
    return (res.data['data'] as List)
        .map((e) => ClassRoomModel.fromJson(e))
        .toList();
  }

  Future<ClassRoomModel> createClassroom(
      String schoolId, Map<String, dynamic> data) async {
    final res =
        await _dio.post(ApiConstants.classrooms(schoolId), data: data);
    return ClassRoomModel.fromJson(res.data['data']);
  }

  Future<ClassRoomModel> updateClassroom(
      String schoolId, String classId, Map<String, dynamic> data) async {
    final res = await _dio.put(ApiConstants.classroom(schoolId, classId),
        data: data);
    return ClassRoomModel.fromJson(res.data['data']);
  }

  Future<void> deleteClassroom(String schoolId, String classId) =>
      _dio.delete(ApiConstants.classroom(schoolId, classId));

  // ── Sections ──────────────────────────────────────────────────────────────

  Future<List<SectionModel>> getSections(
      String schoolId, String classId) async {
    final res =
        await _dio.get(ApiConstants.sections(schoolId, classId));
    return (res.data['data'] as List)
        .map((e) => SectionModel.fromJson(e))
        .toList();
  }

  Future<SectionModel> createSection(
      String schoolId, String classId, Map<String, dynamic> data) async {
    final res =
        await _dio.post(ApiConstants.sections(schoolId, classId), data: data);
    return SectionModel.fromJson(res.data['data']);
  }

  Future<SectionModel> assignTeacher(String schoolId, String classId,
      String sectionId, String teacherId) async {
    final res = await _dio.post(
        ApiConstants.assignTeacher(schoolId, classId, sectionId),
        data: {'teacherId': teacherId});
    return SectionModel.fromJson(res.data['data']);
  }

  Future<void> deleteSection(
          String schoolId, String classId, String sectionId) =>
      _dio.delete(ApiConstants.section(schoolId, classId, sectionId));
}
