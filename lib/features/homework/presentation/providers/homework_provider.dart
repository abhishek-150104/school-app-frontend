import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/homework_models.dart';
import '../../data/repositories/homework_repository.dart';

class HomeworkNotifier
    extends StateNotifier<AsyncValue<List<HomeworkModel>>> {
  final HomeworkRepository _repo;
  final String sectionId;

  HomeworkNotifier(this._repo, this.sectionId)
      : super(const AsyncValue.loading()) {
    load();
  }

  Future<void> load({String? from, String? to}) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
        () => _repo.getBySection(sectionId, from: from, to: to));
  }

  Future<String?> create(Map<String, dynamic> data) async {
    try {
      await _repo.createHomework(sectionId, data);
      await load();
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> delete(String homeworkId) async {
    try {
      await _repo.deleteHomework(homeworkId);
      await load();
      return null;
    } catch (e) {
      return e.toString();
    }
  }
}

final homeworkProvider = StateNotifierProvider.family<HomeworkNotifier,
    AsyncValue<List<HomeworkModel>>, String>(
  (ref, sectionId) =>
      HomeworkNotifier(ref.read(homeworkRepositoryProvider), sectionId),
);

// For PARENT view
class MyChildHomeworkNotifier
    extends StateNotifier<AsyncValue<List<HomeworkModel>>> {
  final HomeworkRepository _repo;
  final String studentId;

  MyChildHomeworkNotifier(this._repo, this.studentId)
      : super(const AsyncValue.loading()) {
    load();
  }

  Future<void> load({String? from, String? to}) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
        () => _repo.getMyChildHomework(studentId, from: from, to: to));
  }
}

final myChildHomeworkProvider = StateNotifierProvider.family<
    MyChildHomeworkNotifier, AsyncValue<List<HomeworkModel>>, String>(
  (ref, studentId) =>
      MyChildHomeworkNotifier(ref.read(homeworkRepositoryProvider), studentId),
);
