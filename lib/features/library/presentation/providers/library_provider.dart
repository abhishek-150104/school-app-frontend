import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/library_models.dart';
import '../../data/repositories/library_repository.dart';

final libraryBooksProvider = FutureProvider<List<LibraryBookModel>>((ref) {
  return ref.read(libraryRepositoryProvider).getBooks();
});

final activeIssuesProvider = FutureProvider<List<LibraryIssueModel>>((ref) {
  return ref.read(libraryRepositoryProvider).getActiveIssues();
});

final memberIssuesProvider = FutureProvider.family<List<LibraryIssueModel>, String>((ref, memberId) {
  return ref.read(libraryRepositoryProvider).getMemberIssues(memberId);
});

class LibraryIssueNotifier extends StateNotifier<AsyncValue<void>> {
  final LibraryRepository _repo;
  LibraryIssueNotifier(this._repo) : super(const AsyncValue.data(null));

  Future<void> returnBook(String issueId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repo.returnBook(issueId));
  }
}

final libraryIssueNotifierProvider = StateNotifierProvider<LibraryIssueNotifier, AsyncValue<void>>((ref) {
  return LibraryIssueNotifier(ref.read(libraryRepositoryProvider));
});
