import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/timetable_models.dart';
import '../../data/repositories/timetable_repository.dart';

class TimetableNotifier extends StateNotifier<AsyncValue<List<TimetableEntryModel>>> {
  final TimetableRepository _repo;
  final String? sectionId;

  TimetableNotifier(this._repo, {this.sectionId}) : super(const AsyncValue.loading()) {
    load();
  }

  Future<void> load() async {
    try {
      state = const AsyncValue.loading();
      final entries = sectionId != null
          ? await _repo.getSectionTimetable(sectionId!)
          : await _repo.getMyTimetable();
      state = AsyncValue.data(entries);
    } catch (e, s) {
      state = AsyncValue.error(e, s);
    }
  }
}

final sectionTimetableProvider = StateNotifierProvider.family<
    TimetableNotifier, AsyncValue<List<TimetableEntryModel>>, String>(
  (ref, sectionId) => TimetableNotifier(ref.read(timetableRepositoryProvider), sectionId: sectionId),
);

final myTimetableProvider =
    StateNotifierProvider<TimetableNotifier, AsyncValue<List<TimetableEntryModel>>>(
        (ref) => TimetableNotifier(ref.read(timetableRepositoryProvider)));
