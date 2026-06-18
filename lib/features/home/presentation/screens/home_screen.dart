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
            ..._menuItems(context, user.role).map((item) => _MenuCard(item: item)),
          ],
        ),
      ),
    );
  }

  List<_MenuItem> _menuItems(BuildContext context, String role) {
    final isSuperAdmin = role == 'SUPER_ADMIN';
    final isAdmin = role == 'SUPER_ADMIN' || role == 'SCHOOL_ADMIN';
    final isTeacherOrAbove = isAdmin || role == 'TEACHER';

    final items = <_MenuItem>[];

    if (isAdmin) {
      items.add(_MenuItem(
        icon: Icons.school_outlined,
        title: 'School Info',
        subtitle: 'View and update school details',
        color: Colors.blue,
        onTap: () => context.push('/school-info'),
      ));
    }

    if (isSuperAdmin) {
      items.add(_MenuItem(
        icon: Icons.manage_accounts_outlined,
        title: 'Admin Accounts',
        subtitle: 'Create and manage school admins',
        color: Colors.deepOrange,
        onTap: () => context.push('/admins'),
      ));
    }

    if (isAdmin) {
      items.add(_MenuItem(
        icon: Icons.calendar_today_outlined,
        title: 'Academic Years',
        subtitle: 'Manage academic year settings',
        color: Colors.teal,
        onTap: () => context.push('/academic-years'),
      ));
    }

    if (isTeacherOrAbove) {
      items.add(_MenuItem(
        icon: Icons.class_outlined,
        title: 'Classrooms',
        subtitle: 'Manage classes and sections',
        color: Colors.indigo,
        onTap: () => context.push('/classrooms'),
      ));
    }

    if (isAdmin) {
      items.add(_MenuItem(
        icon: Icons.people_outline,
        title: 'Students',
        subtitle: 'Enroll and manage students',
        color: Colors.green,
        onTap: () => context.push('/students'),
      ));
      items.add(_MenuItem(
        icon: Icons.badge_outlined,
        title: 'Staff',
        subtitle: 'Manage teachers and staff',
        color: Colors.purple,
        onTap: () => context.push('/staff'),
      ));
    }

    if (role == 'TEACHER') {
      items.add(_MenuItem(
        icon: Icons.person_pin_outlined,
        title: 'My Profile',
        subtitle: 'View your profile and assigned sections',
        color: Colors.deepPurple,
        onTap: () => context.push('/teacher/my-profile'),
      ));
      items.add(_MenuItem(
        icon: Icons.people_outline,
        title: 'Students',
        subtitle: 'View students',
        color: Colors.orange,
        onTap: () => context.push('/students'),
      ));
    }

    if (role == 'PARENT') {
      items.add(_MenuItem(
        icon: Icons.child_care_outlined,
        title: 'My Children',
        subtitle: "View your children's profile",
        color: Colors.pink,
        onTap: () => context.push('/my-children'),
      ));
      items.add(_MenuItem(
        icon: Icons.assignment_outlined,
        title: 'My Child Homework',
        subtitle: "View your child's homework",
        color: Colors.orange,
        onTap: () => context.push('/my-children'),
      ));
    }

    if (isTeacherOrAbove) {
      items.add(_MenuItem(
        icon: Icons.assignment_outlined,
        title: 'Homework',
        subtitle: 'Manage homework assignments',
        color: Colors.orange,
        onTap: () => context.push('/classrooms'),
      ));
    }

    if (role == 'STUDENT') {
      items.add(_MenuItem(
        icon: Icons.person_outline,
        title: 'My Profile',
        subtitle: 'View your student profile',
        color: Colors.indigo,
        onTap: () => context.push('/profile'),
      ));
    }

    items.add(_MenuItem(
      icon: Icons.campaign_outlined,
      title: 'Circulars',
      subtitle: 'View school announcements',
      color: Colors.teal,
      onTap: () => context.push('/circulars'),
    ));

    if (isAdmin) {
      items.add(_MenuItem(
        icon: Icons.receipt_long_outlined,
        title: 'Fee Management',
        subtitle: 'Invoices, payments and fee structures',
        color: Colors.indigo,
        onTap: () => context.push('/fees/invoices'),
      ));
    }

    items.add(_MenuItem(
      icon: Icons.assignment_outlined,
      title: 'Exams',
      subtitle: 'View scheduled exams and results',
      color: Colors.deepOrange,
      onTap: () => context.push('/exams'),
    ));

    items.add(_MenuItem(
      icon: Icons.library_books_outlined,
      title: 'Library',
      subtitle: 'Books and issue management',
      color: Colors.teal,
      onTap: () => context.push('/library'),
    ));

    items.add(_MenuItem(
      icon: Icons.chat_outlined,
      title: 'Messages',
      subtitle: 'Chat with staff and groups',
      color: Colors.indigo,
      onTap: () => context.push('/chat'),
    ));

    items.add(_MenuItem(
      icon: Icons.notifications_outlined,
      title: 'Notifications',
      subtitle: 'View your notifications',
      color: Colors.amber,
      onTap: () => context.push('/notifications'),
    ));

    return items;
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
        title:
            Text(item.title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(item.subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: item.onTap,
      ),
    );
  }
}
