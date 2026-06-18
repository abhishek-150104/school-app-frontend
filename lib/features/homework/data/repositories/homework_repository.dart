import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/homework_models.dart';

class HomeworkRepository {
  final DioClient _dio;
  HomeworkRepository(this._dio);

  Future<HomeworkModel> createHomework(
      String sectionId, Map<String, dynamic> data) async {
    final response = await _dio.post(
      ApiConstants.sectionHomework(sectionId),
      data: data,
    );
    return HomeworkModel.fromJson(response.data['data']);
  }

  Future<List<HomeworkModel>> getBySection(String sectionId,
      {String? from, String? to}) async {
    final params = <String, dynamic>{};
    if (from != null) params['from'] = from;
    if (to != null) params['to'] = to;
    final response = await _dio.get(
      ApiConstants.sectionHomework(sectionId),
      params: params.isNotEmpty ? params : null,
    );
    final data = response.data['data'] as List;
    return data.map((e) => HomeworkModel.fromJson(e)).toList();
  }

  Future<HomeworkModel> getById(String homeworkId) async {
    final response = await _dio.get(ApiConstants.homework(homeworkId));
    return HomeworkModel.fromJson(response.data['data']);
  }

  Future<HomeworkModel> updateHomework(
      String homeworkId, Map<String, dynamic> data) async {
    final response = await _dio.put(
      ApiConstants.homework(homeworkId),
      data: data,
    );
    return HomeworkModel.fromJson(response.data['data']);
  }

  Future<void> deleteHomework(String homeworkId) async {
    await _dio.delete(ApiConstants.homework(homeworkId));
  }

  Future<HomeworkSubmissionModel> markSubmitted(
      String homeworkId, Map<String, dynamic> data) async {
    final response = await _dio.post(
      ApiConstants.homeworkSubmissions(homeworkId),
      data: data,
    );
    return HomeworkSubmissionModel.fromJson(response.data['data']);
  }

  Future<List<HomeworkSubmissionModel>> getSubmissions(String homeworkId) async {
    final response =
        await _dio.get(ApiConstants.homeworkSubmissions(homeworkId));
    final data = response.data['data'] as List;
    return data.map((e) => HomeworkSubmissionModel.fromJson(e)).toList();
  }

  Future<List<HomeworkModel>> getMyChildHomework(String studentId,
      {String? from, String? to}) async {
    final params = <String, dynamic>{};
    if (from != null) params['from'] = from;
    if (to != null) params['to'] = to;
    final response = await _dio.get(
      ApiConstants.myChildHomework(studentId),
      params: params.isNotEmpty ? params : null,
    );
    final data = response.data['data'] as List;
    return data.map((e) => HomeworkModel.fromJson(e)).toList();
  }
}

final homeworkRepositoryProvider = Provider<HomeworkRepository>(
    (ref) => HomeworkRepository(ref.read(dioClientProvider)));
