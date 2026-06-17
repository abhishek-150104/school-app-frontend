import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/attendance_models.dart';
import '../../data/repositories/attendance_repository.dart';

// ── Mark-attendance state (keyed by sectionId) ───────────────────────────────

class MarkAttendanceState {
  final bool isLoading;
  final String? error;
  final List<AttendanceModel> saved;
  final Map<String, AttendanceEntry> entries;

  const MarkAttendanceState({
    this.isLoading = false,
    this.error,
    this.saved = const [],
    this.entries = const {},
  });

  MarkAttendanceState copyWith({
    bool? isLoading,
    String? error,
    List<AttendanceModel>? saved,
    Map<String, AttendanceEntry>? entries,
  }) {
    return MarkAttendanceState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      saved: saved ?? this.saved,
      entries: entries ?? this.entries,
    );
  }
}

class MarkAttendanceNotifier extends StateNotifier<MarkAttendanceState> {
  final AttendanceRepository _repo;
  final String sectionId;

  MarkAttendanceNotifier(this._repo, this.sectionId)
      : super(const MarkAttendanceState());

  void initEntries(List<String> studentIds) {
    final map = {
      for (final id in studentIds)
        id: AttendanceEntry(studentId: id, status: AttendanceStatus.present)
    };
    state = state.copyWith(entries: map);
  }

  void setStatus(String studentId, AttendanceStatus status) {
    final updated = Map<String, AttendanceEntry>.from(state.entries);
    final existing = updated[studentId];
    if (existing != null) {
      existing.status = status;
      state = state.copyWith(entries: updated);
    }
  }

  void setRemarks(String studentId, String remarks) {
    final updated = Map<String, AttendanceEntry>.from(state.entries);
    final existing = updated[studentId];
    if (existing != null) {
      existing.remarks = remarks.isEmpty ? null : remarks;
      state = state.copyWith(entries: updated);
    }
  }

  Future<bool> submit(String date) async {
    state = state.copyWith(isLoading: true);
    try {
      final saved =
          await _repo.markBulk(sectionId, date, state.entries.values.toList());
      state = state.copyWith(isLoading: false, saved: saved);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<void> loadExisting(String date) async {
    state = state.copyWith(isLoading: true);
    try {
      final records = await _repo.getBySection(sectionId, date);
      final map = Map<String, AttendanceEntry>.from(state.entries);
      for (final r in records) {
        map[r.studentId] = AttendanceEntry(
          studentId: r.studentId,
          status: r.status,
          remarks: r.remarks,
        );
      }
      state = state.copyWith(isLoading: false, entries: map, saved: records);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

// Key: sectionId
final markAttendanceProvider = StateNotifierProvider.family<
    MarkAttendanceNotifier, MarkAttendanceState, String>(
  (ref, sectionId) =>
      MarkAttendanceNotifier(ref.read(attendanceRepositoryProvider), sectionId),
);

// ── Attendance summary (keyed by sectionId) ───────────────────────────────────

class AttendanceSummaryNotifier
    extends StateNotifier<AsyncValue<AttendanceSummaryModel>> {
  final AttendanceRepository _repo;
  final String sectionId;

  AttendanceSummaryNotifier(this._repo, this.sectionId)
      : super(const AsyncValue.loading());

  Future<void> load(String from, String to) async {
    state = const AsyncValue.loading();
    try {
      final data = await _repo.getSummary(sectionId, from, to);
      state = AsyncValue.data(data);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

// Key: sectionId
final attendanceSummaryProvider = StateNotifierProvider.family<
    AttendanceSummaryNotifier,
    AsyncValue<AttendanceSummaryModel>,
    String>(
  (ref, sectionId) => AttendanceSummaryNotifier(
      ref.read(attendanceRepositoryProvider), sectionId),
);

// ── Student attendance history ────────────────────────────────────────────────

class StudentAttendanceNotifier
    extends StateNotifier<AsyncValue<List<AttendanceModel>>> {
  final AttendanceRepository _repo;

  StudentAttendanceNotifier(this._repo) : super(const AsyncValue.loading());

  Future<void> loadForStudent(String studentId, String from, String to) async {
    state = const AsyncValue.loading();
    try {
      final data = await _repo.getByStudent(studentId, from, to);
      state = AsyncValue.data(data);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> loadForChild(String studentId, String from, String to) async {
    state = const AsyncValue.loading();
    try {
      final data = await _repo.getMyChildAttendance(studentId, from, to);
      state = AsyncValue.data(data);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final studentAttendanceProvider = StateNotifierProvider.family<
    StudentAttendanceNotifier,
    AsyncValue<List<AttendanceModel>>,
    String>(
  (ref, studentId) =>
      StudentAttendanceNotifier(ref.read(attendanceRepositoryProvider)),
);
