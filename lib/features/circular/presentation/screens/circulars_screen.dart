import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/circular_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class CircularsScreen extends ConsumerWidget {
  const CircularsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final circularsAsync = ref.watch(circularProvider);
    final user = ref.watch(authProvider).user;
    final canCreate = user?.isSuperAdmin == true || user?.isSchoolAdmin == true ||
        user?.role == 'TEACHER';

    return Scaffold(
      appBar: AppBar(title: const Text('Circulars')),
      floatingActionButton: canCreate
          ? FloatingActionButton.extended(
              icon: const Icon(Icons.add),
              label: const Text('New'),
              onPressed: () => context.push('/circulars/create'),
            )
          : null,
      body: circularsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (circulars) {
          if (circulars.isEmpty) {
            return const Center(child: Text('No circulars yet'));
          }
          return RefreshIndicator(
            onRefresh: () => ref.read(circularProvider.notifier).load(),
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: circulars.length,
              itemBuilder: (context, i) {
                final c = circulars[i];
                return Card(
                  child: ListTile(
                    leading: Stack(children: [
                      const Icon(Icons.campaign, size: 36),
                      if (!c.read)
                        Positioned(right: 0, top: 0,
                          child: Container(width: 10, height: 10,
                            decoration: const BoxDecoration(
                              color: Colors.blue, shape: BoxShape.circle))),
                    ]),
                    title: Text(c.title,
                        style: TextStyle(
                            fontWeight: c.read ? FontWeight.normal : FontWeight.bold)),
                    subtitle: Text(
                        '${c.targetType} • ${c.publishedByName}',
                        style: const TextStyle(fontSize: 12)),
                    trailing: _targetBadge(c.targetType),
                    onTap: () => context.push('/circulars/${c.id}', extra: c),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _targetBadge(String type) {
    final color = type == 'ALL' ? Colors.green : type == 'CLASS' ? Colors.orange : Colors.purple;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color.withAlpha(30),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color)),
      child: Text(type, style: TextStyle(color: color, fontSize: 11)),
    );
  }
}
