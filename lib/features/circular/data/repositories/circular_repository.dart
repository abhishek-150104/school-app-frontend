import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/circular_models.dart';

class CircularRepository {
  final DioClient _dio;
  CircularRepository(this._dio);

  Future<List<CircularModel>> getCirculars() async {
    final res = await _dio.get(ApiConstants.circulars);
    return (res.data['data'] as List).map((e) => CircularModel.fromJson(e)).toList();
  }

  Future<CircularModel> getCircular(String id) async {
    final res = await _dio.get(ApiConstants.circular(id));
    return CircularModel.fromJson(res.data['data']);
  }

  Future<CircularModel> createCircular(Map<String, dynamic> data) async {
    final res = await _dio.post(ApiConstants.circulars, data: data);
    return CircularModel.fromJson(res.data['data']);
  }

  Future<CircularModel> updateCircular(String id, Map<String, dynamic> data) async {
    final res = await _dio.put(ApiConstants.circular(id), data: data);
    return CircularModel.fromJson(res.data['data']);
  }

  Future<void> deleteCircular(String id) async {
    await _dio.delete(ApiConstants.circular(id));
  }

  Future<void> markRead(String id) async {
    await _dio.post(ApiConstants.markCircularRead(id));
  }

  Future<int> getUnreadCount() async {
    final res = await _dio.get(ApiConstants.circularUnreadCount);
    return (res.data['data'] as num).toInt();
  }
}

final circularRepositoryProvider = Provider<CircularRepository>(
    (ref) => CircularRepository(ref.read(dioClientProvider)));
