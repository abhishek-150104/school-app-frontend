import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/student_models.dart';
import '../../data/repositories/student_repository.dart';

// ── Student List (by schoolId) ────────────────────────────────────────────────

class StudentListNotifier
    extends StateNotifier<AsyncValue<List<StudentModel>>> {
  final StudentRepository _repo;
  final String schoolId;
  String? _classRoomId;
  String? _sectionId;

  StudentListNotifier(this._repo, this.schoolId)
      : super(const AsyncValue.loading()) {
    load();
  }

  Future<void> load({
    String? classRoomId,
    String? sectionId,
    bool clearFilters = false,
  }) async {
    if (clearFilters) {
      _classRoomId = null;
      _sectionId = null;
    } else {
      if (classRoomId != null) _classRoomId = classRoomId;
      if (sectionId != null) _sectionId = sectionId;
    }
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repo.getStudents(
          schoolId,
          classRoomId: _classRoomId,
          sectionId: _sectionId,
        ));
  }

  Future<void> search(String query) async {
    if (query.trim().isEmpty) {
      await load();
      return;
    }
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
        () => _repo.searchStudents(schoolId, query.trim()));
  }

  Future<String?> enroll(Map<String, dynamic> data) async {
    try {
      await _repo.enrollStudent(schoolId, data);
      await load();
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> update(String studentId, Map<String, dynamic> data) async {
    try {
      await _repo.updateStudent(schoolId, studentId, data);
      await load();
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> deactivate(String studentId) async {
    try {
      await _repo.deactivateStudent(schoolId, studentId);
      await load();
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> linkParent(String studentId, String parentId) async {
    try {
      await _repo.linkParent(schoolId, studentId, parentId);
      await load();
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> transfer(
      String studentId, Map<String, dynamic> data) async {
    try {
      await _repo.transferStudent(schoolId, studentId, data);
      await load();
      return null;
    } catch (e) {
      return e.toString();
    }
  }
}

final studentListProvider = StateNotifierProvider.family<StudentListNotifier,
    AsyncValue<List<StudentModel>>, String>(
  (ref, schoolId) =>
      StudentListNotifier(ref.read(studentRepositoryProvider), schoolId),
);

// ── My Children (PARENT role) ─────────────────────────────────────────────────

class MyChildrenNotifier
    extends StateNotifier<AsyncValue<List<StudentModel>>> {
  final StudentRepository _repo;

  MyChildrenNotifier(this._repo) : super(const AsyncValue.loading()) {
    load();
  }

  Future<void> load() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repo.getMyChildren());
  }
}

final myChildrenProvider = StateNotifierProvider<MyChildrenNotifier,
    AsyncValue<List<StudentModel>>>(
  (ref) => MyChildrenNotifier(ref.read(studentRepositoryProvider)),
);
