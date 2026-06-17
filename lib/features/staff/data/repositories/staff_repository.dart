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

  Future<List<StaffModel>> getStaff() async {
    final res = await _dio.get(ApiConstants.staff);
    return (res.data['data'] as List)
        .map((e) => StaffModel.fromJson(e))
        .toList();
  }

  Future<List<StaffModel>> searchStaff(String query) async {
    final res = await _dio.get(ApiConstants.staffSearch, params: {'q': query});
    return (res.data['data'] as List)
        .map((e) => StaffModel.fromJson(e))
        .toList();
  }

  Future<StaffModel> getStaffMember(String staffId) async {
    final res = await _dio.get(ApiConstants.staffMember(staffId));
    return StaffModel.fromJson(res.data['data']);
  }

  Future<Map<String, dynamic>> createStaff(Map<String, dynamic> data) async {
    final res = await _dio.post(ApiConstants.staff, data: data);
    return res.data['data'] as Map<String, dynamic>;
  }

  Future<StaffModel> updateStaff(String staffId, Map<String, dynamic> data) async {
    final res = await _dio.put(ApiConstants.staffMember(staffId), data: data);
    return StaffModel.fromJson(res.data['data']);
  }

  Future<void> deactivateStaff(String staffId) =>
      _dio.delete(ApiConstants.staffMember(staffId));

  Future<TeacherProfileModel> getTeacherProfile() async {
    final res = await _dio.get(ApiConstants.teacherMyProfile);
    return TeacherProfileModel.fromJson(res.data['data']);
  }
}
