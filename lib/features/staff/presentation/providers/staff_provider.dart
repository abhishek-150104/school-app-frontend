import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/staff_models.dart';
import '../../data/repositories/staff_repository.dart';

// ── Staff list (by schoolId) ──────────────────────────────────────────────────

class StaffListNotifier
    extends StateNotifier<AsyncValue<List<StaffModel>>> {
  final StaffRepository _repo;
  final String schoolId;

  StaffListNotifier(this._repo, this.schoolId)
      : super(const AsyncValue.loading()) {
    load();
  }

  Future<void> load() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repo.getStaff(schoolId));
  }

  Future<void> search(String query) async {
    if (query.trim().isEmpty) {
      await load();
      return;
    }
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
        () => _repo.searchStaff(schoolId, query.trim()));
  }

  Future<String?> create(Map<String, dynamic> data) async {
    try {
      await _repo.createStaff(schoolId, data);
      await load();
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> update(String staffId, Map<String, dynamic> data) async {
    try {
      await _repo.updateStaff(schoolId, staffId, data);
      await load();
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> deactivate(String staffId) async {
    try {
      await _repo.deactivateStaff(schoolId, staffId);
      await load();
      return null;
    } catch (e) {
      return e.toString();
    }
  }
}

final staffListProvider = StateNotifierProvider.family<StaffListNotifier,
    AsyncValue<List<StaffModel>>, String>(
  (ref, schoolId) =>
      StaffListNotifier(ref.read(staffRepositoryProvider), schoolId),
);

// ── Teacher profile (self) ────────────────────────────────────────────────────

class TeacherProfileNotifier
    extends StateNotifier<AsyncValue<TeacherProfileModel>> {
  final StaffRepository _repo;

  TeacherProfileNotifier(this._repo) : super(const AsyncValue.loading()) {
    load();
  }

  Future<void> load() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repo.getTeacherProfile());
  }
}

final teacherProfileProvider = StateNotifierProvider<TeacherProfileNotifier,
    AsyncValue<TeacherProfileModel>>(
  (ref) => TeacherProfileNotifier(ref.read(staffRepositoryProvider)),
);
