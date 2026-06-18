import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/circular_models.dart';
import '../../data/repositories/circular_repository.dart';

class CircularNotifier extends StateNotifier<AsyncValue<List<CircularModel>>> {
  final CircularRepository _repo;
  CircularNotifier(this._repo) : super(const AsyncValue.loading()) {
    load();
  }

  Future<void> load() async {
    try {
      state = const AsyncValue.loading();
      final list = await _repo.getCirculars();
      state = AsyncValue.data(list);
    } catch (e, s) {
      state = AsyncValue.error(e, s);
    }
  }

  Future<void> markRead(String id) async {
    await _repo.markRead(id);
    state.whenData((list) {
      state = AsyncValue.data(
          list.map((c) => c.id == id ? c.copyWith(read: true) : c).toList());
    });
  }

  Future<void> create(Map<String, dynamic> data) async {
    await _repo.createCircular(data);
    await load();
  }

  Future<void> delete(String id) async {
    await _repo.deleteCircular(id);
    state.whenData((list) {
      state = AsyncValue.data(list.where((c) => c.id != id).toList());
    });
  }
}

final circularProvider =
    StateNotifierProvider<CircularNotifier, AsyncValue<List<CircularModel>>>(
        (ref) => CircularNotifier(ref.read(circularRepositoryProvider)));

final unreadCircularCountProvider = FutureProvider<int>(
    (ref) => ref.read(circularRepositoryProvider).getUnreadCount());
