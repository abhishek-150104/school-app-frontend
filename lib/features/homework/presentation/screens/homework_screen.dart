import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/homework_provider.dart';
import '../../data/models/homework_models.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../shared/widgets/empty_state.dart';

class HomeworkScreen extends ConsumerWidget {
  final String sectionId;
  final String sectionName;

  const HomeworkScreen({
    super.key,
    required this.sectionId,
    required this.sectionName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeworkAsync = ref.watch(homeworkProvider(sectionId));
    final user = ref.watch(authProvider).user;
    final canCreate =
        user?.isTeacher == true || user?.isSchoolAdmin == true || user?.isSuperAdmin == true;

    return Scaffold(
      appBar: AppBar(
        title: Text('Homework — $sectionName',
            style: const TextStyle(fontSize: 15)),
      ),
      floatingActionButton: canCreate
          ? FloatingActionButton.extended(
              icon: const Icon(Icons.add),
              label: const Text('Add Homework'),
              onPressed: () => context.push(
                '/sections/$sectionId/homework/create',
                extra: sectionName,
              ),
            )
          : null,
      body: homeworkAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (homeworkList) {
          if (homeworkList.isEmpty) {
            return EmptyState(
              icon: Icons.assignment_outlined,
              title: 'No homework yet',
              subtitle: canCreate
                  ? 'Add homework for $sectionName'
                  : 'No homework has been assigned',
              actionLabel: canCreate ? 'Add Homework' : null,
              onAction: canCreate
                  ? () => context.push(
                        '/sections/$sectionId/homework/create',
                        extra: sectionName,
                      )
                  : null,
            );
          }

          // Group by due date
          final grouped = <String, List<HomeworkModel>>{};
          for (final hw in homeworkList) {
            grouped.putIfAbsent(hw.dueDate, () => []).add(hw);
          }

          return RefreshIndicator(
            onRefresh: () =>
                ref.read(homeworkProvider(sectionId).notifier).load(),
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: grouped.length,
              itemBuilder: (_, i) {
                final date = grouped.keys.elementAt(i);
                final items = grouped[date]!;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                      child: Text(
                        'Due: $date',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                    ...items.map((hw) => Card(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 4),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.orange.withOpacity(0.15),
                              child: const Icon(Icons.assignment_outlined,
                                  color: Colors.orange),
                            ),
                            title: Text(hw.title,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600)),
                            subtitle: Text(hw.subject),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () => context.push(
                              '/homework/${hw.id}',
                              extra: hw,
                            ),
                          ),
                        )),
                  ],
                );
              },
            ),
          );
        },
      ),
    );
  }
}
