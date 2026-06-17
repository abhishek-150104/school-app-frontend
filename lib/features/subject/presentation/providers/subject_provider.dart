import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/subject_models.dart';
import '../../data/repositories/subject_repository.dart';

class SubjectNotifier extends StateNotifier<AsyncValue<List<SubjectModel>>> {
  final SubjectRepository _repo;
  final String classId;

  SubjectNotifier(this._repo, this.classId) : super(const AsyncValue.loading()) {
    load();
  }

  Future<void> load() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repo.getSubjects(classId));
  }

  Future<String?> create(Map<String, dynamic> data) async {
    try {
      await _repo.createSubject(classId, data);
      await load();
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> delete(String subjectId) async {
    try {
      await _repo.deleteSubject(classId, subjectId);
      await load();
      return null;
    } catch (e) {
      return e.toString();
    }
  }
}

// Key: classId
final subjectProvider = StateNotifierProvider.family<SubjectNotifier,
    AsyncValue<List<SubjectModel>>, String>(
  (ref, classId) =>
      SubjectNotifier(ref.read(subjectRepositoryProvider), classId),
);
