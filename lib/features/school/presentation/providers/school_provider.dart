import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/school_models.dart';
import '../../data/repositories/school_repository.dart';

// ── Schools ───────────────────────────────────────────────────────────────────

class SchoolListNotifier
    extends StateNotifier<AsyncValue<List<SchoolModel>>> {
  final SchoolRepository _repo;

  SchoolListNotifier(this._repo) : super(const AsyncValue.loading()) {
    load();
  }

  Future<void> load() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repo.getSchools());
  }

  Future<String?> create(Map<String, dynamic> data) async {
    try {
      await _repo.createSchool(data);
      await load();
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> update(String id, Map<String, dynamic> data) async {
    try {
      await _repo.updateSchool(id, data);
      await load();
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> delete(String id) async {
    try {
      await _repo.deleteSchool(id);
      await load();
      return null;
    } catch (e) {
      return e.toString();
    }
  }
}

final schoolListProvider =
    StateNotifierProvider<SchoolListNotifier, AsyncValue<List<SchoolModel>>>(
        (ref) => SchoolListNotifier(ref.read(schoolRepositoryProvider)));

// ── Academic Years ────────────────────────────────────────────────────────────

class AcademicYearNotifier
    extends StateNotifier<AsyncValue<List<AcademicYearModel>>> {
  final SchoolRepository _repo;
  final String schoolId;

  AcademicYearNotifier(this._repo, this.schoolId)
      : super(const AsyncValue.loading()) {
    load();
  }

  Future<void> load() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repo.getAcademicYears(schoolId));
  }

  Future<String?> create(Map<String, dynamic> data) async {
    try {
      await _repo.createAcademicYear(schoolId, data);
      await load();
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> activate(String yearId) async {
    try {
      await _repo.activateYear(schoolId, yearId);
      await load();
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> delete(String yearId) async {
    try {
      await _repo.deleteYear(schoolId, yearId);
      await load();
      return null;
    } catch (e) {
      return e.toString();
    }
  }
}

final academicYearProvider = StateNotifierProvider.family<AcademicYearNotifier,
    AsyncValue<List<AcademicYearModel>>, String>(
  (ref, schoolId) =>
      AcademicYearNotifier(ref.read(schoolRepositoryProvider), schoolId),
);

// ── Classrooms ────────────────────────────────────────────────────────────────

class ClassRoomNotifier
    extends StateNotifier<AsyncValue<List<ClassRoomModel>>> {
  final SchoolRepository _repo;
  final String schoolId;
  String? selectedYearId;

  ClassRoomNotifier(this._repo, this.schoolId)
      : super(const AsyncValue.loading()) {
    load();
  }

  Future<void> load({String? academicYearId}) async {
    selectedYearId = academicYearId ?? selectedYearId;
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
        () => _repo.getClassrooms(schoolId, academicYearId: selectedYearId));
  }

  Future<String?> create(Map<String, dynamic> data) async {
    try {
      await _repo.createClassroom(schoolId, data);
      await load();
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> update(String classId, Map<String, dynamic> data) async {
    try {
      await _repo.updateClassroom(schoolId, classId, data);
      await load();
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> delete(String classId) async {
    try {
      await _repo.deleteClassroom(schoolId, classId);
      await load();
      return null;
    } catch (e) {
      return e.toString();
    }
  }
}

final classRoomProvider = StateNotifierProvider.family<ClassRoomNotifier,
    AsyncValue<List<ClassRoomModel>>, String>(
  (ref, schoolId) =>
      ClassRoomNotifier(ref.read(schoolRepositoryProvider), schoolId),
);

// ── Sections ──────────────────────────────────────────────────────────────────

class SectionNotifier
    extends StateNotifier<AsyncValue<List<SectionModel>>> {
  final SchoolRepository _repo;
  final String schoolId;
  final String classId;

  SectionNotifier(this._repo, this.schoolId, this.classId)
      : super(const AsyncValue.loading()) {
    load();
  }

  Future<void> load() async {
    state = const AsyncValue.loading();
    state =
        await AsyncValue.guard(() => _repo.getSections(schoolId, classId));
  }

  Future<String?> create(Map<String, dynamic> data) async {
    try {
      await _repo.createSection(schoolId, classId, data);
      await load();
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> delete(String sectionId) async {
    try {
      await _repo.deleteSection(schoolId, classId, sectionId);
      await load();
      return null;
    } catch (e) {
      return e.toString();
    }
  }
}

// Key: 'schoolId:classId'
final sectionProvider = StateNotifierProvider.family<SectionNotifier,
    AsyncValue<List<SectionModel>>, String>(
  (ref, key) {
    final parts = key.split(':');
    return SectionNotifier(
        ref.read(schoolRepositoryProvider), parts[0], parts[1]);
  },
);
