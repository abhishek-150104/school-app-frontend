import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/homework_models.dart';
import '../../data/repositories/homework_repository.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/homework_provider.dart';

class HomeworkDetailScreen extends ConsumerStatefulWidget {
  final HomeworkModel homework;

  const HomeworkDetailScreen({super.key, required this.homework});

  @override
  ConsumerState<HomeworkDetailScreen> createState() =>
      _HomeworkDetailScreenState();
}

class _HomeworkDetailScreenState extends ConsumerState<HomeworkDetailScreen> {
  List<HomeworkSubmissionModel>? _submissions;
  bool _loadingSubmissions = false;

  @override
  void initState() {
    super.initState();
    _loadSubmissions();
  }

  Future<void> _loadSubmissions() async {
    final user = ref.read(authProvider).user;
    if (user == null) return;
    if (user.isTeacher || user.isSchoolAdmin || user.isSuperAdmin) {
      setState(() => _loadingSubmissions = true);
      try {
        final repo = ref.read(homeworkRepositoryProvider);
        final subs = await repo.getSubmissions(widget.homework.id);
        if (mounted) setState(() => _submissions = subs);
      } catch (e) {
        // ignore
      } finally {
        if (mounted) setState(() => _loadingSubmissions = false);
      }
    }
  }

  Future<void> _markSubmitted() async {
    final studentIdCtrl = TextEditingController();
    final admNoCtrl = TextEditingController();
    final nameCtrl = TextEditingController();
    final remarksCtrl = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Mark Submitted'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                  controller: studentIdCtrl,
                  decoration:
                      const InputDecoration(labelText: 'Student ID')),
              TextField(
                  controller: admNoCtrl,
                  decoration:
                      const InputDecoration(labelText: 'Admission Number')),
              TextField(
                  controller: nameCtrl,
                  decoration:
                      const InputDecoration(labelText: 'Student Full Name')),
              TextField(
                  controller: remarksCtrl,
                  decoration:
                      const InputDecoration(labelText: 'Remarks (optional)')),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Submit')),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final repo = ref.read(homeworkRepositoryProvider);
      await repo.markSubmitted(widget.homework.id, {
        'studentId': studentIdCtrl.text.trim(),
        'admissionNumber': admNoCtrl.text.trim(),
        'studentFullName': nameCtrl.text.trim(),
        if (remarksCtrl.text.trim().isNotEmpty)
          'remarks': remarksCtrl.text.trim(),
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Submission recorded')));
        await _loadSubmissions();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final hw = widget.homework;
    final user = ref.watch(authProvider).user;
    final canManage = user?.isSchoolAdmin == true || user?.isSuperAdmin == true;
    final canViewSubmissions =
        user?.role == 'TEACHER' || canManage;

    return Scaffold(
      appBar: AppBar(title: const Text('Homework Detail')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(hw.title,
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    _InfoRow(icon: Icons.subject, label: hw.subject),
                    _InfoRow(icon: Icons.class_outlined, label: hw.classRoomName),
                    _InfoRow(icon: Icons.group_outlined, label: hw.sectionName),
                    _InfoRow(
                        icon: Icons.calendar_today_outlined,
                        label: 'Due: ${hw.dueDate}'),
                    _InfoRow(
                        icon: Icons.person_outline,
                        label: 'By: ${hw.assignedByName}'),
                    const SizedBox(height: 12),
                    Text('Description',
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(hw.description),
                  ],
                ),
              ),
            ),
            if (canViewSubmissions) ...[
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Submissions',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold)),
                  if (canManage)
                    TextButton.icon(
                      icon: const Icon(Icons.add),
                      label: const Text('Mark Submitted'),
                      onPressed: _markSubmitted,
                    ),
                ],
              ),
              const SizedBox(height: 8),
              if (_loadingSubmissions)
                const Center(child: CircularProgressIndicator())
              else if (_submissions == null || _submissions!.isEmpty)
                const Text('No submissions yet.')
              else
                ...(_submissions!.map((s) => Card(
                      child: ListTile(
                        leading: const Icon(Icons.check_circle_outline,
                            color: Colors.green),
                        title: Text(s.studentFullName),
                        subtitle: Text(s.admissionNumber),
                        trailing: s.submittedAt != null
                            ? Text(s.submittedAt!.substring(0, 10),
                                style: const TextStyle(fontSize: 12))
                            : null,
                      ),
                    ))),
            ],
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  const _InfoRow({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey),
          const SizedBox(width: 8),
          Text(label),
        ],
      ),
    );
  }
}
