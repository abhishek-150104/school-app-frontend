import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/timetable_models.dart';

class TimetableRepository {
  final DioClient _dio;
  TimetableRepository(this._dio);

  Future<List<TimetableEntryModel>> getSectionTimetable(String sectionId) async {
    final res = await _dio.get(ApiConstants.sectionTimetable(sectionId));
    return (res.data['data'] as List).map((e) => TimetableEntryModel.fromJson(e)).toList();
  }

  Future<List<TimetableEntryModel>> getMyTimetable() async {
    final res = await _dio.get(ApiConstants.myTimetable);
    return (res.data['data'] as List).map((e) => TimetableEntryModel.fromJson(e)).toList();
  }

  Future<TimetableEntryModel> addEntry(Map<String, dynamic> data) async {
    final res = await _dio.post(ApiConstants.timetable, data: data);
    return TimetableEntryModel.fromJson(res.data['data']);
  }

  Future<void> deleteEntry(String entryId) async {
    await _dio.delete('${ApiConstants.timetable}/$entryId');
  }
}

final timetableRepositoryProvider = Provider<TimetableRepository>(
    (ref) => TimetableRepository(ref.read(dioClientProvider)));
