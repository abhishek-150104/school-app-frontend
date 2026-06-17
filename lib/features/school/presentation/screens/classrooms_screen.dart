import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/school_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../core/utils/validators.dart';

class ClassRoomsScreen extends ConsumerStatefulWidget {
  final String schoolId;
  final String schoolName;

  const ClassRoomsScreen(
      {super.key, required this.schoolId, required this.schoolName});

  @override
  ConsumerState<ClassRoomsScreen> createState() => _ClassRoomsScreenState();
}

class _ClassRoomsScreenState extends ConsumerState<ClassRoomsScreen> {
  String? _selectedYearId;

  @override
  Widget build(BuildContext context) {
    final classesAsync = ref.watch(classRoomProvider(widget.schoolId));
    final yearsAsync = ref.watch(academicYearProvider(widget.schoolId));
    final user = ref.watch(authProvider).user;
    final canEdit =
        user?.isSuperAdmin == true || user?.isSchoolAdmin == true;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Classrooms', style: TextStyle(fontSize: 16)),
            Text(widget.schoolName,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal)),
          ],
        ),
      ),
      floatingActionButton: canEdit
          ? FloatingActionButton.extended(
              icon: const Icon(Icons.add),
              label: const Text('Add Class'),
              onPressed: () => _showCreateClassDialog(context),
            )
          : null,
      body: Column(
        children: [
          // Year filter chip row
          yearsAsync.whenOrNull(
                data: (years) => years.isEmpty
                    ? const SizedBox.shrink()
                    : SizedBox(
                        height: 52,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          children: [
                            ChoiceChip(
                              label: const Text('All Years'),
                              selected: _selectedYearId == null,
                              onSelected: (_) {
                                setState(() => _selectedYearId = null);
                                ref
                                    .read(classRoomProvider(widget.schoolId)
                                        .notifier)
                                    .load();
                              },
                            ),
                            const SizedBox(width: 8),
                            ...years.map((y) => Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: ChoiceChip(
                                    label: Text(y.label),
                                    selected: _selectedYearId == y.id,
                                    onSelected: (_) {
                                      setState(
                                          () => _selectedYearId = y.id);
                                      ref
                                          .read(classRoomProvider(
                                                  widget.schoolId)
                                              .notifier)
                                          .load(academicYearId: y.id);
                                    },
                                  ),
                                )),
                          ],
                        ),
                      ),
              ) ??
              const SizedBox.shrink(),

          // Class list
          Expanded(
            child: classesAsync.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (classes) {
                if (classes.isEmpty) {
                  return EmptyState(
                    icon: Icons.class_outlined,
                    title: 'No classes yet',
                    subtitle: 'Add classes for this school',
                    actionLabel: canEdit ? 'Add Class' : null,
                    onAction: canEdit
                        ? () => _showCreateClassDialog(context)
                        : null,
                  );
                }
                return RefreshIndicator(
                  onRefresh: () => ref
                      .read(classRoomProvider(widget.schoolId).notifier)
                      .load(academicYearId: _selectedYearId),
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: classes.length,
                    itemBuilder: (_, i) {
                      final cls = classes[i];
                      return Card(
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Theme.of(context)
                                .colorScheme
                                .primary
                                .withOpacity(0.1),
                            child: Text(
                              cls.displayOrder?.toString() ??
                                  cls.name.substring(0, 1),
                              style: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          title: Text(cls.name,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600)),
                          subtitle: Text(cls.academicYearLabel),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => context.push(
                              '/schools/${widget.schoolId}/classrooms/${cls.id}/sections',
                              extra: {'className': cls.name, 'schoolName': widget.schoolName}),
                          onLongPress: canEdit
                              ? () =>
                                  _showClassOptions(context, cls.id, cls.name)
                              : null,
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showCreateClassDialog(BuildContext context) {
    final yearsAsync = ref.read(academicYearProvider(widget.schoolId));
    final years = yearsAsync.valueOrNull ?? [];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => _CreateClassSheet(
        schoolId: widget.schoolId,
        years: years,
        ref: ref,
      ),
    );
  }

  void _showClassOptions(
      BuildContext context, String classId, String className) {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.delete_outline,
                  color: Colors.red.shade700),
              title: Text('Delete $className',
                  style: TextStyle(color: Colors.red.shade700)),
              onTap: () async {
                Navigator.pop(context);
                final err = await ref
                    .read(classRoomProvider(widget.schoolId).notifier)
                    .delete(classId);
                if (err != null && context.mounted) {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text(err)));
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _CreateClassSheet extends StatefulWidget {
  final String schoolId;
  final List years;
  final WidgetRef ref;
  const _CreateClassSheet(
      {required this.schoolId, required this.years, required this.ref});

  @override
  State<_CreateClassSheet> createState() => _CreateClassSheetState();
}

class _CreateClassSheetState extends State<_CreateClassSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _orderCtrl = TextEditingController();
  String? _selectedYearId;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.years.isNotEmpty) _selectedYearId = widget.years.first.id;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _orderCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedYearId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select an academic year')));
      return;
    }
    setState(() => _isLoading = true);
    final err = await widget.ref
        .read(classRoomProvider(widget.schoolId).notifier)
        .create({
      'name': _nameCtrl.text.trim(),
      'academicYearId': _selectedYearId,
      if (_orderCtrl.text.trim().isNotEmpty)
        'displayOrder': int.tryParse(_orderCtrl.text.trim()),
    });
    setState(() => _isLoading = false);
    if (!mounted) return;
    if (err == null) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Class created'), backgroundColor: Colors.green));
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
            Text('Add Class',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            if (widget.years.isNotEmpty) ...[
              DropdownButtonFormField<String>(
                value: _selectedYearId,
                decoration: InputDecoration(
                  labelText: 'Academic Year',
                  prefixIcon: const Icon(Icons.calendar_today_outlined),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
                items: widget.years
                    .map((y) => DropdownMenuItem(
                        value: y.id as String, child: Text(y.label as String)))
                    .toList(),
                onChanged: (v) => setState(() => _selectedYearId = v),
              ),
              const SizedBox(height: 12),
            ],
            AppTextField(
              label: 'Class Name (e.g. Class 5)',
              controller: _nameCtrl,
              prefixIcon: Icons.class_outlined,
              validator: (v) => Validators.required(v, 'Class name'),
            ),
            const SizedBox(height: 12),
            AppTextField(
              label: 'Display Order (optional)',
              controller: _orderCtrl,
              prefixIcon: Icons.sort_outlined,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 24),
            AppButton(
                label: 'Create Class',
                isLoading: _isLoading,
                onPressed: _submit),
          ],
        ),
      ),
    );
  }
}
