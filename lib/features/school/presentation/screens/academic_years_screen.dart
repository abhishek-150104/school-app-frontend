import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/school_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../core/utils/validators.dart';

class AcademicYearsScreen extends ConsumerWidget {
  const AcademicYearsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final yearsAsync = ref.watch(academicYearProvider);
    final user = ref.watch(authProvider).user;
    final canEdit =
        user?.isSuperAdmin == true || user?.isSchoolAdmin == true;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Academic Years', style: TextStyle(fontSize: 16)),
        actions: [
          IconButton(
            icon: const Icon(Icons.class_outlined),
            tooltip: 'Classrooms',
            onPressed: () => context.push('/classrooms'),
          ),
        ],
      ),
      floatingActionButton: canEdit
          ? FloatingActionButton.extended(
              icon: const Icon(Icons.add),
              label: const Text('Add Year'),
              onPressed: () =>
                  _showCreateYearDialog(context, ref),
            )
          : null,
      body: yearsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (years) {
          if (years.isEmpty) {
            return EmptyState(
              icon: Icons.calendar_today_outlined,
              title: 'No academic years',
              subtitle: 'Create an academic year to start managing classes',
              actionLabel: canEdit ? 'Add Year' : null,
              onAction: canEdit ? () => _showCreateYearDialog(context, ref) : null,
            );
          }
          return RefreshIndicator(
            onRefresh: () =>
                ref.read(academicYearProvider.notifier).load(),
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: years.length,
              itemBuilder: (_, i) {
                final year = years[i];
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: year.active
                          ? Colors.green.shade50
                          : Colors.grey.shade100,
                      child: Icon(Icons.calendar_today,
                          color:
                              year.active ? Colors.green : Colors.grey),
                    ),
                    title: Text(year.label,
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle:
                        Text('${year.startYear} – ${year.endYear}'),
                    trailing: year.active
                        ? Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text('Active',
                                style: TextStyle(
                                    color: Colors.green.shade700,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600)),
                          )
                        : canEdit
                            ? TextButton(
                                onPressed: () async {
                                  final err = await ref
                                      .read(academicYearProvider
                                          .notifier)
                                      .activate(year.id);
                                  if (err != null && context.mounted) {
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(
                                            SnackBar(content: Text(err)));
                                  }
                                },
                                child: const Text('Activate'),
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

  void _showCreateYearDialog(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => _CreateYearSheet(ref: ref),
    );
  }
}

class _CreateYearSheet extends StatefulWidget {
  final WidgetRef ref;
  const _CreateYearSheet({required this.ref});

  @override
  State<_CreateYearSheet> createState() => _CreateYearSheetState();
}

class _CreateYearSheetState extends State<_CreateYearSheet> {
  final _formKey = GlobalKey<FormState>();
  final _labelCtrl = TextEditingController();
  final _startCtrl = TextEditingController();
  final _endCtrl = TextEditingController();
  bool _isActive = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _labelCtrl.dispose();
    _startCtrl.dispose();
    _endCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    final err = await widget.ref
        .read(academicYearProvider.notifier)
        .create({
      'label': _labelCtrl.text.trim(),
      'startYear': int.parse(_startCtrl.text.trim()),
      'endYear': int.parse(_endCtrl.text.trim()),
      'active': _isActive,
    });
    setState(() => _isLoading = false);
    if (!mounted) return;
    if (err == null) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Academic year created'), backgroundColor: Colors.green));
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
            Text('New Academic Year',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            AppTextField(
              label: 'Label (e.g. 2024-25)',
              controller: _labelCtrl,
              prefixIcon: Icons.label_outline,
              validator: (v) => Validators.required(v, 'Label'),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: AppTextField(
                    label: 'Start Year',
                    controller: _startCtrl,
                    keyboardType: TextInputType.number,
                    prefixIcon: Icons.calendar_today_outlined,
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Required';
                      if (int.tryParse(v) == null) return 'Invalid year';
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppTextField(
                    label: 'End Year',
                    controller: _endCtrl,
                    keyboardType: TextInputType.number,
                    prefixIcon: Icons.calendar_today_outlined,
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Required';
                      if (int.tryParse(v) == null) return 'Invalid year';
                      return null;
                    },
                  ),
                ),
              ],
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Set as active year'),
              value: _isActive,
              onChanged: (v) => setState(() => _isActive = v),
            ),
            const SizedBox(height: 8),
            AppButton(
                label: 'Create Year',
                isLoading: _isLoading,
                onPressed: _submit),
          ],
        ),
      ),
    );
  }
}
