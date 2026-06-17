import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/school_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../shared/widgets/empty_state.dart';
import 'school_form_screen.dart';

class SchoolsScreen extends ConsumerWidget {
  const SchoolsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final schoolsAsync = ref.watch(schoolListProvider);
    final user = ref.watch(authProvider).user;
    final isSuperAdmin = user?.isSuperAdmin ?? false;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Schools'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () => context.push('/profile'),
          ),
        ],
      ),
      floatingActionButton: isSuperAdmin
          ? FloatingActionButton.extended(
              icon: const Icon(Icons.add),
              label: const Text('Add School'),
              onPressed: () => _showSchoolForm(context, ref),
            )
          : null,
      body: schoolsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Failed to load schools',
                  style: TextStyle(color: Colors.red.shade700)),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () =>
                    ref.read(schoolListProvider.notifier).load(),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (schools) {
          if (schools.isEmpty) {
            return EmptyState(
              icon: Icons.business_outlined,
              title: 'No schools yet',
              subtitle: 'Add your first school to get started',
              actionLabel: isSuperAdmin ? 'Add School' : null,
              onAction: isSuperAdmin
                  ? () => _showSchoolForm(context, ref)
                  : null,
            );
          }
          return RefreshIndicator(
            onRefresh: () =>
                ref.read(schoolListProvider.notifier).load(),
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: schools.length,
              itemBuilder: (_, i) {
                final school = schools[i];
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: school.active
                          ? Theme.of(context)
                              .colorScheme
                              .primary
                              .withOpacity(0.12)
                          : Colors.grey.shade200,
                      child: Icon(Icons.business,
                          color: school.active
                              ? Theme.of(context).colorScheme.primary
                              : Colors.grey),
                    ),
                    title: Text(school.name,
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text(
                      [
                        if (school.city != null) school.city!,
                        if (school.state != null) school.state!,
                      ].join(', '),
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (!school.active)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text('Inactive',
                                style: TextStyle(
                                    color: Colors.red.shade700, fontSize: 11)),
                          ),
                        const Icon(Icons.chevron_right),
                      ],
                    ),
                    onTap: () => _showSchoolMenu(context, school.id, school.name),
                    onLongPress: isSuperAdmin
                        ? () => _showSchoolOptions(context, ref, school.id,
                            school.name, school)
                        : null,
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  void _showSchoolMenu(
      BuildContext context, String schoolId, String schoolName) {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Text(schoolName,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16)),
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.people_outline),
              title: const Text('Students'),
              onTap: () {
                Navigator.pop(context);
                context.push('/schools/$schoolId/students', extra: schoolName);
              },
            ),
            ListTile(
              leading: const Icon(Icons.calendar_today_outlined),
              title: const Text('Academic Years'),
              onTap: () {
                Navigator.pop(context);
                context.push('/schools/$schoolId/academic-years',
                    extra: schoolName);
              },
            ),
            ListTile(
              leading: const Icon(Icons.class_outlined),
              title: const Text('Classrooms'),
              onTap: () {
                Navigator.pop(context);
                context.push('/schools/$schoolId/classrooms', extra: schoolName);
              },
            ),
            ListTile(
              leading: const Icon(Icons.badge_outlined),
              title: const Text('Staff'),
              onTap: () {
                Navigator.pop(context);
                context.push('/schools/$schoolId/staff', extra: schoolName);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showSchoolForm(BuildContext context, WidgetRef ref,
      [Map<String, dynamic>? existing]) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => SchoolFormSheet(existing: existing, ref: ref),
    );
  }

  void _showSchoolOptions(BuildContext context, WidgetRef ref, String id,
      String name, dynamic school) {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: const Text('Edit School'),
              onTap: () {
                Navigator.pop(context);
                _showSchoolForm(context, ref, {
                  'id': id,
                  'name': school.name,
                  'email': school.email ?? '',
                  'phone': school.phone ?? '',
                  'city': school.city ?? '',
                  'state': school.state ?? '',
                });
              },
            ),
            ListTile(
              leading: Icon(Icons.delete_outline, color: Colors.red.shade700),
              title: Text('Deactivate School',
                  style: TextStyle(color: Colors.red.shade700)),
              onTap: () async {
                Navigator.pop(context);
                final err =
                    await ref.read(schoolListProvider.notifier).delete(id);
                if (err != null && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(err)));
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
