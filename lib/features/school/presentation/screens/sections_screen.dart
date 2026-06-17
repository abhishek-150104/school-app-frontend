import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/school_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../core/utils/validators.dart';

class SectionsScreen extends ConsumerWidget {
  final String schoolId;
  final String classId;
  final String className;
  final String schoolName;

  const SectionsScreen({
    super.key,
    required this.schoolId,
    required this.classId,
    required this.className,
    required this.schoolName,
  });

  String get _key => '$schoolId:$classId';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sectionsAsync = ref.watch(sectionProvider(_key));
    final user = ref.watch(authProvider).user;
    final canEdit =
        user?.isSuperAdmin == true || user?.isSchoolAdmin == true;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(className, style: const TextStyle(fontSize: 16)),
            Text(schoolName,
                style: const TextStyle(
                    fontSize: 12, fontWeight: FontWeight.normal)),
          ],
        ),
      ),
      floatingActionButton: canEdit
          ? FloatingActionButton.extended(
              icon: const Icon(Icons.add),
              label: const Text('Add Section'),
              onPressed: () => _showCreateSectionSheet(context, ref),
            )
          : null,
      body: sectionsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (sections) {
          if (sections.isEmpty) {
            return EmptyState(
              icon: Icons.group_outlined,
              title: 'No sections yet',
              subtitle: 'Add sections like A, B, C for this class',
              actionLabel: canEdit ? 'Add Section' : null,
              onAction:
                  canEdit ? () => _showCreateSectionSheet(context, ref) : null,
            );
          }
          return RefreshIndicator(
            onRefresh: () =>
                ref.read(sectionProvider(_key).notifier).load(),
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: sections.length,
              itemBuilder: (_, i) {
                final section = sections[i];
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Theme.of(context)
                          .colorScheme
                          .secondary
                          .withOpacity(0.12),
                      child: Text(
                        section.name,
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.secondary,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    title: Text('Section ${section.name}',
                        style:
                            const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Capacity: ${section.capacity} students'),
                        if (section.classTeacherName != null)
                          Text(
                            'Class Teacher: ${section.classTeacherName}',
                            style: TextStyle(
                                color:
                                    Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.w500),
                          )
                        else
                          Text(
                            'No class teacher assigned',
                            style: TextStyle(color: Colors.orange.shade700),
                          ),
                      ],
                    ),
                    isThreeLine: true,
                    trailing: canEdit
                        ? IconButton(
                            icon: Icon(Icons.delete_outline,
                                color: Colors.red.shade300),
                            onPressed: () => _confirmDelete(
                                context, ref, section.id, section.name),
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

  void _showCreateSectionSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => _CreateSectionSheet(
        sectionKey: _key,
        ref: ref,
      ),
    );
  }

  void _confirmDelete(
      BuildContext context, WidgetRef ref, String sectionId, String name) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Delete Section $name?'),
        content: const Text('This will permanently delete the section.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final err = await ref
                  .read(sectionProvider(_key).notifier)
                  .delete(sectionId);
              if (err != null && context.mounted) {
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text(err)));
              }
            },
            child: Text('Delete',
                style: TextStyle(color: Colors.red.shade700)),
          ),
        ],
      ),
    );
  }
}

class _CreateSectionSheet extends StatefulWidget {
  final String sectionKey;
  final WidgetRef ref;
  const _CreateSectionSheet(
      {required this.sectionKey, required this.ref});

  @override
  State<_CreateSectionSheet> createState() => _CreateSectionSheetState();
}

class _CreateSectionSheetState extends State<_CreateSectionSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _capacityCtrl = TextEditingController(text: '40');
  bool _isLoading = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _capacityCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    final err = await widget.ref
        .read(sectionProvider(widget.sectionKey).notifier)
        .create({
      'name': _nameCtrl.text.trim(),
      'capacity': int.tryParse(_capacityCtrl.text.trim()) ?? 40,
    });
    setState(() => _isLoading = false);
    if (!mounted) return;
    if (err == null) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Section created'),
          backgroundColor: Colors.green));
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
            Text('Add Section',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            AppTextField(
              label: 'Section Name (e.g. A, B, C)',
              controller: _nameCtrl,
              prefixIcon: Icons.group_outlined,
              validator: (v) => Validators.required(v, 'Section name'),
            ),
            const SizedBox(height: 12),
            AppTextField(
              label: 'Capacity',
              controller: _capacityCtrl,
              prefixIcon: Icons.people_outline,
              keyboardType: TextInputType.number,
              validator: (v) {
                if (v == null || v.isEmpty) return 'Required';
                final n = int.tryParse(v);
                if (n == null || n < 1) return 'Enter a valid capacity';
                return null;
              },
            ),
            const SizedBox(height: 24),
            AppButton(
                label: 'Create Section',
                isLoading: _isLoading,
                onPressed: _submit),
          ],
        ),
      ),
    );
  }
}
