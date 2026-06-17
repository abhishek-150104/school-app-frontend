import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/school_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

// Single-school info screen (replaces the old multi-school listing screen)
class SchoolInfoScreen extends ConsumerWidget {
  const SchoolInfoScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final schoolAsync = ref.watch(schoolProvider);
    final user = ref.watch(authProvider).user;
    final canEdit = user?.isSuperAdmin == true || user?.isSchoolAdmin == true;

    return Scaffold(
      appBar: AppBar(title: const Text('School Info')),
      body: schoolAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (school) {
          if (school == null) {
            return const Center(child: Text('School not found'));
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(school.name,
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(fontWeight: FontWeight.bold)),
                      if (school.address != null) ...[
                        const SizedBox(height: 8),
                        Text(school.address!,
                            style: Theme.of(context).textTheme.bodyMedium),
                      ],
                      if (school.city != null || school.state != null) ...[
                        const SizedBox(height: 4),
                        Text('${school.city ?? ''} ${school.state ?? ''}'.trim(),
                            style: Theme.of(context).textTheme.bodyMedium),
                      ],
                      if (school.phone != null) ...[
                        const SizedBox(height: 8),
                        Row(children: [
                          const Icon(Icons.phone_outlined, size: 16),
                          const SizedBox(width: 8),
                          Text(school.phone!),
                        ]),
                      ],
                      if (school.email != null) ...[
                        const SizedBox(height: 4),
                        Row(children: [
                          const Icon(Icons.email_outlined, size: 16),
                          const SizedBox(width: 8),
                          Text(school.email!),
                        ]),
                      ],
                      if (school.affiliationNumber != null) ...[
                        const SizedBox(height: 8),
                        Chip(label: Text('Affiliation: ${school.affiliationNumber!}')),
                      ],
                    ],
                  ),
                ),
              ),
              if (canEdit) ...[
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    // TODO: navigate to edit school form
                  },
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text('Edit School Info'),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

// Keep backward-compatible alias so any remaining imports don't break
typedef SchoolsScreen = SchoolInfoScreen;
