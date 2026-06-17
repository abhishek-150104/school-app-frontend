import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/staff_models.dart';

final staffRepositoryProvider = Provider<StaffRepository>((ref) {
  return StaffRepository(ref.read(dioClientProvider));
});

class StaffRepository {
  final DioClient _dio;
  StaffRepository(this._dio);

  Future<List<StaffModel>> getStaff(String schoolId) async {
    final res = await _dio.get(ApiConstants.staff(schoolId));
    return (res.data['data'] as List)
        .map((e) => StaffModel.fromJson(e))
        .toList();
  }

  Future<List<StaffModel>> searchStaff(
      String schoolId, String query) async {
    final res = await _dio.get(ApiConstants.staffSearch(schoolId),
        params: {'q': query});
    return (res.data['data'] as List)
        .map((e) => StaffModel.fromJson(e))
        .toList();
  }

  Future<StaffModel> getStaffMember(
      String schoolId, String staffId) async {
    final res =
        await _dio.get(ApiConstants.staffMember(schoolId, staffId));
    return StaffModel.fromJson(res.data['data']);
  }

  Future<StaffModel> createStaff(
      String schoolId, Map<String, dynamic> data) async {
    final res = await _dio.post(ApiConstants.staff(schoolId), data: data);
    return StaffModel.fromJson(res.data['data']);
  }

  Future<StaffModel> updateStaff(String schoolId, String staffId,
      Map<String, dynamic> data) async {
    final res = await _dio.put(
        ApiConstants.staffMember(schoolId, staffId),
        data: data);
    return StaffModel.fromJson(res.data['data']);
  }

  Future<void> deactivateStaff(String schoolId, String staffId) =>
      _dio.delete(ApiConstants.staffMember(schoolId, staffId));

  Future<TeacherProfileModel> getTeacherProfile() async {
    final res = await _dio.get(ApiConstants.teacherMyProfile);
    return TeacherProfileModel.fromJson(res.data['data']);
  }
}
