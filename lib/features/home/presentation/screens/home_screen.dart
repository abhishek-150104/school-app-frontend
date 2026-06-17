import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;
    final theme = Theme.of(context);

    if (user == null) return const SizedBox.shrink();

    return Scaffold(
      appBar: AppBar(
        title: const Text('School App'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () => context.push('/profile'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome card
            Card(
              color: theme.colorScheme.primary,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.white24,
                      radius: 28,
                      child: Text(
                        user.fullName[0].toUpperCase(),
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Welcome back,',
                              style: TextStyle(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: 13)),
                          Text(user.fullName,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold),
                              overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.white24,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              user.role.replaceAll('_', ' '),
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 11),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text('Quick Access',
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            // Role-based menu items (will expand in Part 2 and 3)
            ..._menuItems(context, user.role).map((item) => _MenuCard(item: item)),
          ],
        ),
      ),
    );
  }

  List<_MenuItem> _menuItems(BuildContext context, String role) {
    switch (role) {
      case 'SUPER_ADMIN':
        return [
          _MenuItem(
            icon: Icons.business_outlined,
            title: 'Schools',
            subtitle: 'Create and manage schools',
            color: Colors.blue,
            onTap: () => context.push('/schools'),
          ),
        ];
      case 'SCHOOL_ADMIN':
        return [
          _MenuItem(
            icon: Icons.business_outlined,
            title: 'Schools',
            subtitle: 'View and manage your school',
            color: Colors.blue,
            onTap: () => context.push('/schools'),
          ),
          _MenuItem(
            icon: Icons.people_outline,
            title: 'Students',
            subtitle: 'Manage student enrollment',
            color: Colors.teal,
            onTap: () => context.push('/schools'),
          ),
        ];
      case 'TEACHER':
        return [
          _MenuItem(
            icon: Icons.people_outline,
            title: 'Students',
            subtitle: 'View students in your school',
            color: Colors.orange,
            onTap: () => context.push('/schools'),
          ),
        ];
      case 'PARENT':
        return [
          _MenuItem(
            icon: Icons.child_care_outlined,
            title: 'My Children',
            subtitle: 'View your children\'s profile',
            color: Colors.pink,
            onTap: () => context.push('/my-children'),
          ),
        ];
      default:
        return [];
    }
  }
}

class _MenuItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  _MenuItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });
}

class _MenuCard extends StatelessWidget {
  final _MenuItem item;
  const _MenuCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: item.color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(item.icon, color: item.color),
        ),
        title: Text(item.title,
            style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(item.subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: item.onTap,
      ),
    );
  }
}
