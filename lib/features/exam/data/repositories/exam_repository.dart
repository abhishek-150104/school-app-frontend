import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/exam_models.dart';

class ExamRepository {
  final DioClient _dio;
  ExamRepository(this._dio);

  Future<List<ExamModel>> getExams() async {
    final res = await _dio.get(ApiConstants.exams);
    return (res.data['data'] as List).map((e) => ExamModel.fromJson(e)).toList();
  }

  Future<List<ExamResultModel>> getExamResults(String examId) async {
    final res = await _dio.get(ApiConstants.examResults(examId));
    return (res.data['data'] as List).map((e) => ExamResultModel.fromJson(e)).toList();
  }

  Future<List<ExamResultModel>> getStudentResults(String studentId) async {
    final res = await _dio.get(ApiConstants.studentResults(studentId));
    return (res.data['data'] as List).map((e) => ExamResultModel.fromJson(e)).toList();
  }
}

final examRepositoryProvider = Provider<ExamRepository>(
    (ref) => ExamRepository(ref.read(dioClientProvider)));
