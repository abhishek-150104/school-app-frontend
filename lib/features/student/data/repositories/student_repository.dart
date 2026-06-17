import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/student_models.dart';

final studentRepositoryProvider = Provider<StudentRepository>((ref) {
  return StudentRepository(ref.read(dioClientProvider));
});

class StudentRepository {
  final DioClient _dio;
  StudentRepository(this._dio);

  Future<List<StudentModel>> getStudents(String schoolId,
      {String? classRoomId, String? sectionId}) async {
    Map<String, dynamic>? params;
    if (sectionId != null) {
      params = {'sectionId': sectionId};
    } else if (classRoomId != null) {
      params = {'classRoomId': classRoomId};
    }
    final res =
        await _dio.get(ApiConstants.students(schoolId), params: params);
    return (res.data['data'] as List)
        .map((e) => StudentModel.fromJson(e))
        .toList();
  }

  Future<List<StudentModel>> searchStudents(
      String schoolId, String query) async {
    final res = await _dio.get(ApiConstants.studentSearch(schoolId),
        params: {'q': query});
    return (res.data['data'] as List)
        .map((e) => StudentModel.fromJson(e))
        .toList();
  }

  Future<StudentModel> getStudent(String schoolId, String studentId) async {
    final res =
        await _dio.get(ApiConstants.student(schoolId, studentId));
    return StudentModel.fromJson(res.data['data']);
  }

  Future<StudentModel> enrollStudent(
      String schoolId, Map<String, dynamic> data) async {
    final res =
        await _dio.post(ApiConstants.students(schoolId), data: data);
    return StudentModel.fromJson(res.data['data']);
  }

  Future<StudentModel> updateStudent(String schoolId, String studentId,
      Map<String, dynamic> data) async {
    final res = await _dio.put(ApiConstants.student(schoolId, studentId),
        data: data);
    return StudentModel.fromJson(res.data['data']);
  }

  Future<void> deactivateStudent(String schoolId, String studentId) =>
      _dio.delete(ApiConstants.student(schoolId, studentId));

  Future<StudentModel> linkParent(
      String schoolId, String studentId, String parentId) async {
    final res = await _dio.post(
        ApiConstants.linkParent(schoolId, studentId),
        data: {'parentId': parentId});
    return StudentModel.fromJson(res.data['data']);
  }

  Future<StudentModel> transferStudent(String schoolId, String studentId,
      Map<String, dynamic> data) async {
    final res = await _dio.post(
        ApiConstants.transferStudent(schoolId, studentId),
        data: data);
    return StudentModel.fromJson(res.data['data']);
  }

  Future<List<StudentModel>> getMyChildren() async {
    final res = await _dio.get(ApiConstants.myChildren);
    return (res.data['data'] as List)
        .map((e) => StudentModel.fromJson(e))
        .toList();
  }
}
