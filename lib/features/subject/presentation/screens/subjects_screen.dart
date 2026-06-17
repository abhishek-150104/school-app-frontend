import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/subject_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../core/utils/validators.dart';

class SubjectsScreen extends ConsumerStatefulWidget {
  final String classId;
  final String className;

  const SubjectsScreen({
    super.key,
    required this.classId,
    required this.className,
  });

  @override
  ConsumerState<SubjectsScreen> createState() => _SubjectsScreenState();
}

class _SubjectsScreenState extends ConsumerState<SubjectsScreen> {
  @override
  Widget build(BuildContext context) {
    final subjectsAsync = ref.watch(subjectProvider(widget.classId));
    final user = ref.watch(authProvider).user;
    final canEdit = user?.isSuperAdmin == true || user?.isSchoolAdmin == true;

    return Scaffold(
      appBar: AppBar(
        title: Text('Subjects — ${widget.className}',
            style: const TextStyle(fontSize: 15)),
      ),
      floatingActionButton: canEdit
          ? FloatingActionButton.extended(
              icon: const Icon(Icons.add),
              label: const Text('Add Subject'),
              onPressed: () => _showAddSubjectSheet(context),
            )
          : null,
      body: subjectsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (subjects) {
          if (subjects.isEmpty) {
            return EmptyState(
              icon: Icons.menu_book_outlined,
              title: 'No subjects yet',
              subtitle: canEdit
                  ? 'Add subjects for ${widget.className}'
                  : 'No subjects have been added for ${widget.className}',
              actionLabel: canEdit ? 'Add Subject' : null,
              onAction: canEdit ? () => _showAddSubjectSheet(context) : null,
            );
          }
          return RefreshIndicator(
            onRefresh: () =>
                ref.read(subjectProvider(widget.classId).notifier).load(),
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: subjects.length,
              itemBuilder: (_, i) {
                final subject = subjects[i];
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor:
                          Theme.of(context).colorScheme.primary.withOpacity(0.1),
                      child: Text(
                        subject.name.substring(0, 1).toUpperCase(),
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(subject.name,
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: subject.code != null && subject.code!.isNotEmpty
                        ? Text('Code: ${subject.code}')
                        : null,
                    trailing: canEdit
                        ? IconButton(
                            icon: Icon(Icons.delete_outline,
                                color: Colors.red.shade400),
                            onPressed: () =>
                                _confirmDelete(context, subject.id, subject.name),
                          )
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

  void _showAddSubjectSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => _AddSubjectSheet(
        classId: widget.classId,
        ref: ref,
      ),
    );
  }

  void _confirmDelete(BuildContext context, String subjectId, String name) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Subject'),
        content: Text('Delete "$name"? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(context);
              final err = await ref
                  .read(subjectProvider(widget.classId).notifier)
                  .delete(subjectId);
              if (err != null && context.mounted) {
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text(err)));
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _AddSubjectSheet extends StatefulWidget {
  final String classId;
  final WidgetRef ref;
  const _AddSubjectSheet({required this.classId, required this.ref});

  @override
  State<_AddSubjectSheet> createState() => _AddSubjectSheetState();
}

class _AddSubjectSheetState extends State<_AddSubjectSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _codeCtrl = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _codeCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final data = {
      'name': _nameCtrl.text.trim(),
      if (_codeCtrl.text.trim().isNotEmpty) 'code': _codeCtrl.text.trim(),
    };

    final err =
        await widget.ref.read(subjectProvider(widget.classId).notifier).create(data);
    setState(() => _isLoading = false);
    if (!mounted) return;
    if (err == null) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Subject added'), backgroundColor: Colors.green));
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(err)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
          24, 24, 24, MediaQuery.of(context).viewInsets.bottom + 24),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Add Subject',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            AppTextField(
              label: 'Subject Name (e.g. Mathematics)',
              controller: _nameCtrl,
              prefixIcon: Icons.menu_book_outlined,
              validator: (v) => Validators.required(v, 'Subject name'),
            ),
            const SizedBox(height: 12),
            AppTextField(
              label: 'Subject Code (optional, e.g. MATH)',
              controller: _codeCtrl,
              prefixIcon: Icons.tag_outlined,
            ),
            const SizedBox(height: 24),
            AppButton(
                label: 'Add Subject',
                isLoading: _isLoading,
                onPressed: _submit),
          ],
        ),
      ),
    );
  }
}
