import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/student_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../data/models/student_models.dart';

class StudentsScreen extends ConsumerStatefulWidget {
  final String schoolId;
  final String schoolName;

  const StudentsScreen({
    super.key,
    required this.schoolId,
    required this.schoolName,
  });

  @override
  ConsumerState<StudentsScreen> createState() => _StudentsScreenState();
}

class _StudentsScreenState extends ConsumerState<StudentsScreen> {
  bool _searching = false;
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    ref.read(studentListProvider(widget.schoolId).notifier).search(value);
  }

  void _clearSearch() {
    _searchCtrl.clear();
    ref.read(studentListProvider(widget.schoolId).notifier).load();
    setState(() => _searching = false);
  }

  @override
  Widget build(BuildContext context) {
    final studentsAsync = ref.watch(studentListProvider(widget.schoolId));
    final user = ref.watch(authProvider).user;
    final canManage =
        user?.isSuperAdmin == true || user?.isSchoolAdmin == true;

    return Scaffold(
      appBar: AppBar(
        title: _searching
            ? TextField(
                controller: _searchCtrl,
                autofocus: true,
                onChanged: _onSearchChanged,
                decoration: const InputDecoration(
                  hintText: 'Search by name or admission no.',
                  border: InputBorder.none,
                ),
                style: const TextStyle(fontSize: 16),
              )
            : Text(widget.schoolName.isEmpty
                ? 'Students'
                : '${widget.schoolName} — Students'),
        actions: [
          if (_searching)
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: _clearSearch,
            )
          else
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () => setState(() => _searching = true),
            ),
        ],
      ),
      floatingActionButton: canManage
          ? FloatingActionButton.extended(
              icon: const Icon(Icons.person_add_outlined),
              label: const Text('Enroll Student'),
              onPressed: () => context.push(
                '/schools/${widget.schoolId}/students/enroll',
                extra: widget.schoolName,
              ),
            )
          : null,
      body: studentsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Failed to load students',
                  style: TextStyle(color: Colors.red.shade700)),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => ref
                    .read(studentListProvider(widget.schoolId).notifier)
                    .load(),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (students) {
          if (students.isEmpty) {
            return EmptyState(
              icon: Icons.people_outline,
              title: 'No students found',
              subtitle: canManage
                  ? 'Enroll the first student to get started'
                  : 'No students are available right now',
              actionLabel: canManage ? 'Enroll Student' : null,
              onAction: canManage
                  ? () => context.push(
                        '/schools/${widget.schoolId}/students/enroll',
                        extra: widget.schoolName,
                      )
                  : null,
            );
          }
          return RefreshIndicator(
            onRefresh: () => ref
                .read(studentListProvider(widget.schoolId).notifier)
                .load(),
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: students.length,
              itemBuilder: (_, i) => _StudentCard(
                student: students[i],
                schoolId: widget.schoolId,
                canManage: canManage,
                onDeactivated: () => ref
                    .read(studentListProvider(widget.schoolId).notifier)
                    .load(),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _StudentCard extends ConsumerWidget {
  final StudentModel student;
  final String schoolId;
  final bool canManage;
  final VoidCallback onDeactivated;

  const _StudentCard({
    required this.student,
    required this.schoolId,
    required this.canManage,
    required this.onDeactivated,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final initials = student.fullName.isNotEmpty
        ? student.fullName.trim().split(' ').map((w) => w[0]).take(2).join()
        : '?';

    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: student.active
              ? theme.colorScheme.primary.withOpacity(0.15)
              : Colors.grey.shade200,
          child: Text(
            initials.toUpperCase(),
            style: TextStyle(
              color: student.active
                  ? theme.colorScheme.primary
                  : Colors.grey,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                student.fullName,
                style: const TextStyle(fontWeight: FontWeight.w600),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (!student.active)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text('Inactive',
                    style: TextStyle(
                        color: Colors.red.shade700, fontSize: 10)),
              ),
          ],
        ),
        subtitle: Text(
          'Roll ${student.rollNumber} · ${student.classSectionDisplay} · ${student.admissionNumber}',
          overflow: TextOverflow.ellipsis,
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => context.push(
          '/schools/$schoolId/students/${student.id}',
          extra: student,
        ),
      ),
    );
  }
}
