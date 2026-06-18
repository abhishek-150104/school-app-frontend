import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/exam_models.dart';
import '../../data/repositories/exam_repository.dart';

class ExamNotifier extends StateNotifier<AsyncValue<List<ExamModel>>> {
  final ExamRepository _repo;
  ExamNotifier(this._repo) : super(const AsyncValue.loading()) {
    load();
  }

  Future<void> load() async {
    try {
      state = const AsyncValue.loading();
      state = AsyncValue.data(await _repo.getExams());
    } catch (e, s) {
      state = AsyncValue.error(e, s);
    }
  }
}

final examProvider =
    StateNotifierProvider<ExamNotifier, AsyncValue<List<ExamModel>>>(
        (ref) => ExamNotifier(ref.read(examRepositoryProvider)));
