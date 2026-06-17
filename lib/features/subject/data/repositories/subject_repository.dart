import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/subject_models.dart';

class SubjectRepository {
  final DioClient _dio;
  SubjectRepository(this._dio);

  Future<List<SubjectModel>> getSubjects(String classId) async {
    final response = await _dio.get(ApiConstants.subjects(classId));
    final data = response.data['data'] as List;
    return data.map((e) => SubjectModel.fromJson(e)).toList();
  }

  Future<SubjectModel> createSubject(
      String classId, Map<String, dynamic> data) async {
    final response = await _dio.post(
      ApiConstants.subjects(classId),
      data: data,
    );
    return SubjectModel.fromJson(response.data['data']);
  }

  Future<void> deleteSubject(String classId, String subjectId) async {
    await _dio.delete(ApiConstants.subject(classId, subjectId));
  }
}

final subjectRepositoryProvider = Provider<SubjectRepository>(
    (ref) => SubjectRepository(ref.read(dioClientProvider)));
