import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/student_provider.dart';
import '../../../../shared/widgets/empty_state.dart';

class MyChildrenScreen extends ConsumerWidget {
  const MyChildrenScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final childrenAsync = ref.watch(myChildrenProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Children'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () => context.push('/profile'),
          ),
        ],
      ),
      body: childrenAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Failed to load children',
                  style: TextStyle(color: Colors.red.shade700)),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () =>
                    ref.read(myChildrenProvider.notifier).load(),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (children) {
          if (children.isEmpty) {
            return const EmptyState(
              icon: Icons.child_care_outlined,
              title: 'No children linked',
              subtitle:
                  'Ask the school admin to link your account to your child\'s profile',
            );
          }
          return RefreshIndicator(
            onRefresh: () => ref.read(myChildrenProvider.notifier).load(),
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: children.length,
              itemBuilder: (_, i) {
                final child = children[i];
                final initials = child.fullName.trim().split(' ').map((w) => w[0]).take(2).join();

                return Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor:
                          Theme.of(context).colorScheme.primary.withOpacity(0.12),
                      child: Text(
                        initials.toUpperCase(),
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(
                      child.fullName,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      '${child.classSectionDisplay} · Roll ${child.rollNumber}',
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: child.active
                                ? Colors.green.shade50
                                : Colors.red.shade50,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            child.active ? 'Active' : 'Inactive',
                            style: TextStyle(
                              color: child.active
                                  ? Colors.green.shade700
                                  : Colors.red.shade700,
                              fontSize: 11,
                            ),
                          ),
                        ),
                        const Icon(Icons.chevron_right),
                      ],
                    ),
                    onTap: () => context.push(
                      '/students/${child.id}',
                      extra: child,
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
