import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/school_models.dart';
import '../../data/repositories/school_repository.dart';

// ── School (single) ───────────────────────────────────────────────────────────

class SchoolNotifier extends StateNotifier<AsyncValue<SchoolModel?>> {
  final SchoolRepository _repo;

  SchoolNotifier(this._repo) : super(const AsyncValue.loading()) {
    load();
  }

  Future<void> load() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repo.getSchool());
  }

  Future<String?> update(Map<String, dynamic> data) async {
    try {
      await _repo.updateSchool(data);
      await load();
      return null;
    } catch (e) {
      return e.toString();
    }
  }
}

final schoolProvider =
    StateNotifierProvider<SchoolNotifier, AsyncValue<SchoolModel?>>(
        (ref) => SchoolNotifier(ref.read(schoolRepositoryProvider)));

// ── Academic Years ────────────────────────────────────────────────────────────

class AcademicYearNotifier
    extends StateNotifier<AsyncValue<List<AcademicYearModel>>> {
  final SchoolRepository _repo;

  AcademicYearNotifier(this._repo) : super(const AsyncValue.loading()) {
    load();
  }

  Future<void> load() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repo.getAcademicYears());
  }

  Future<String?> create(Map<String, dynamic> data) async {
    try {
      await _repo.createAcademicYear(data);
      await load();
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> activate(String yearId) async {
    try {
      await _repo.activateYear(yearId);
      await load();
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> delete(String yearId) async {
    try {
      await _repo.deleteYear(yearId);
      await load();
      return null;
    } catch (e) {
      return e.toString();
    }
  }
}

final academicYearProvider =
    StateNotifierProvider<AcademicYearNotifier, AsyncValue<List<AcademicYearModel>>>(
  (ref) => AcademicYearNotifier(ref.read(schoolRepositoryProvider)),
);

// ── Classrooms ────────────────────────────────────────────────────────────────

class ClassRoomNotifier
    extends StateNotifier<AsyncValue<List<ClassRoomModel>>> {
  final SchoolRepository _repo;
  String? selectedYearId;

  ClassRoomNotifier(this._repo) : super(const AsyncValue.loading()) {
    load();
  }

  Future<void> load({String? academicYearId}) async {
    selectedYearId = academicYearId ?? selectedYearId;
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
        () => _repo.getClassrooms(academicYearId: selectedYearId));
  }

  Future<String?> create(Map<String, dynamic> data) async {
    try {
      await _repo.createClassroom(data);
      await load();
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> update(String classId, Map<String, dynamic> data) async {
    try {
      await _repo.updateClassroom(classId, data);
      await load();
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> delete(String classId) async {
    try {
      await _repo.deleteClassroom(classId);
      await load();
      return null;
    } catch (e) {
      return e.toString();
    }
  }
}

final classRoomProvider =
    StateNotifierProvider<ClassRoomNotifier, AsyncValue<List<ClassRoomModel>>>(
  (ref) => ClassRoomNotifier(ref.read(schoolRepositoryProvider)),
);

// ── Sections ──────────────────────────────────────────────────────────────────

class SectionNotifier
    extends StateNotifier<AsyncValue<List<SectionModel>>> {
  final SchoolRepository _repo;
  final String classId;

  SectionNotifier(this._repo, this.classId) : super(const AsyncValue.loading()) {
    load();
  }

  Future<void> load() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repo.getSections(classId));
  }

  Future<String?> create(Map<String, dynamic> data) async {
    try {
      await _repo.createSection(classId, data);
      await load();
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> delete(String sectionId) async {
    try {
      await _repo.deleteSection(classId, sectionId);
      await load();
      return null;
    } catch (e) {
      return e.toString();
    }
  }
}

// Key: classId
final sectionProvider = StateNotifierProvider.family<SectionNotifier,
    AsyncValue<List<SectionModel>>, String>(
  (ref, classId) =>
      SectionNotifier(ref.read(schoolRepositoryProvider), classId),
);
