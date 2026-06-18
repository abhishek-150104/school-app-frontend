import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/library_provider.dart';
import '../../data/models/library_models.dart';

class LibraryScreen extends ConsumerWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Library'),
          bottom: const TabBar(tabs: [
            Tab(text: 'Books'),
            Tab(text: 'Active Issues'),
          ]),
        ),
        body: TabBarView(children: [
          _BooksTab(),
          _ActiveIssuesTab(),
        ]),
      ),
    );
  }
}

class _BooksTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final booksAsync = ref.watch(libraryBooksProvider);
    return booksAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (books) => books.isEmpty
          ? const Center(child: Text('No books found'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: books.length,
              itemBuilder: (_, i) => _BookCard(book: books[i]),
            ),
    );
  }
}

class _BookCard extends StatelessWidget {
  final LibraryBookModel book;
  const _BookCard({required this.book});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.indigo,
          child: Text(
            book.title.isNotEmpty ? book.title[0] : 'B',
            style: const TextStyle(color: Colors.white),
          ),
        ),
        title: Text(book.title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('${book.author} • ISBN: ${book.isbn}'),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('${book.availableCopies}/${book.totalCopies}',
                style: const TextStyle(fontWeight: FontWeight.bold)),
            Text('available', style: TextStyle(fontSize: 10, color: Colors.grey[600])),
          ],
        ),
      ),
    );
  }
}

class _ActiveIssuesTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final issuesAsync = ref.watch(activeIssuesProvider);
    return issuesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (issues) => issues.isEmpty
          ? const Center(child: Text('No active issues'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: issues.length,
              itemBuilder: (_, i) => _IssueCard(issue: issues[i], ref: ref),
            ),
    );
  }
}

class _IssueCard extends StatelessWidget {
  final LibraryIssueModel issue;
  final WidgetRef ref;
  const _IssueCard({required this.issue, required this.ref});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        title: Text(issue.bookTitle, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('Member: ${issue.memberId} • Due: ${issue.dueDate}'),
        trailing: TextButton(
          onPressed: () async {
            await ref.read(libraryIssueNotifierProvider.notifier).returnBook(issue.id);
            ref.invalidate(activeIssuesProvider);
          },
          child: const Text('Return'),
        ),
      ),
    );
  }
}
