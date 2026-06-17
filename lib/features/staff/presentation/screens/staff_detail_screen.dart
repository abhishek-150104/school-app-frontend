import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/staff_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/models/staff_models.dart';

class StaffDetailScreen extends ConsumerWidget {
  final StaffModel staff;

  const StaffDetailScreen({
    super.key,
    required this.staff,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;
    final canManage =
        user?.isSuperAdmin == true || user?.isSchoolAdmin == true;

    return Scaffold(
      appBar: AppBar(
        title: Text(staff.fullName),
        actions: [
          if (canManage)
            PopupMenuButton<String>(
              onSelected: (val) => _onMenuSelected(context, ref, val),
              itemBuilder: (_) => [
                const PopupMenuItem(
                    value: 'edit', child: Text('Edit Staff')),
                if (staff.active)
                  PopupMenuItem(
                    value: 'deactivate',
                    child: Text('Deactivate',
                        style: TextStyle(color: Colors.red.shade700)),
                  ),
              ],
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _profileHeader(context),
            const SizedBox(height: 16),
            _infoCard(context, 'Employment', [
              _row('Employee ID', staff.employeeId),
              if (staff.designation != null)
                _row('Designation', staff.designation!),
              if (staff.joiningDate != null)
                _row('Joining Date', staff.joiningDate!),
            ]),
            if (staff.subjects.isNotEmpty) ...[
              const SizedBox(height: 12),
              _subjectsCard(context),
            ],
            if (staff.qualification != null) ...[
              const SizedBox(height: 12),
              _infoCard(context, 'Qualification', [
                _row('Education', staff.qualification!),
              ]),
            ],
            if (staff.address != null) ...[
              const SizedBox(height: 12),
              _infoCard(context, 'Address', [
                if (staff.address!.street != null)
                  _row('Street', staff.address!.street!),
                if (staff.address!.city != null)
                  _row('City', staff.address!.city!),
                if (staff.address!.state != null)
                  _row('State', staff.address!.state!),
                if (staff.address!.pincode != null)
                  _row('Pincode', staff.address!.pincode!),
              ]),
            ],
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _profileHeader(BuildContext context) {
    final theme = Theme.of(context);
    final initials =
        staff.fullName.trim().split(' ').map((w) => w[0]).take(2).join();

    return Card(
      color: theme.colorScheme.secondary,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: Colors.white24,
              child: Text(
                initials.toUpperCase(),
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    staff.fullName,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),
                  if (staff.designation != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      staff.designation!,
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.85),
                          fontSize: 13),
                    ),
                  ],
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: staff.active
                          ? Colors.green.shade400
                          : Colors.red.shade400,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      staff.active ? 'Active' : 'Inactive',
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
    );
  }

  Widget _subjectsCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Subjects',
                style: TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 15)),
            const Divider(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: staff.subjects
                  .map((s) => Chip(
                        label: Text(s),
                        visualDensity: VisualDensity.compact,
                      ))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoCard(
      BuildContext context, String title, List<Widget> children) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 15)),
            const Divider(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(label,
                style: const TextStyle(color: Colors.grey, fontSize: 13)),
          ),
          Expanded(
            child: Text(value,
                style: const TextStyle(fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }

  void _onMenuSelected(
      BuildContext context, WidgetRef ref, String action) {
    if (action == 'edit') {
      _showEditSheet(context, ref);
    } else if (action == 'deactivate') {
      _confirmDeactivate(context, ref);
    }
  }

  void _showEditSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => _EditStaffSheet(
        staff: staff,
        onSaved: () => context.pop(),
      ),
    );
  }

  void _confirmDeactivate(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Deactivate Staff'),
        content: Text(
            'Deactivate ${staff.fullName}? They will lose access to school resources.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          FilledButton(
            style:
                FilledButton.styleFrom(backgroundColor: Colors.red.shade700),
            onPressed: () async {
              Navigator.pop(context);
              final err = await ref
                  .read(staffListProvider.notifier)
                  .deactivate(staff.id);
              if (err != null && context.mounted) {
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text(err)));
              } else if (context.mounted) {
                context.pop();
              }
            },
            child: const Text('Deactivate'),
          ),
        ],
      ),
    );
  }
}

// ── Edit Staff Sheet ──────────────────────────────────────────────────────────

class _EditStaffSheet extends ConsumerStatefulWidget {
  final StaffModel staff;
  final VoidCallback onSaved;

  const _EditStaffSheet({
    required this.staff,
    required this.onSaved,
  });

  @override
  ConsumerState<_EditStaffSheet> createState() => _EditStaffSheetState();
}

class _EditStaffSheetState extends ConsumerState<_EditStaffSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _firstName;
  late final TextEditingController _lastName;
  late final TextEditingController _designation;
  late final TextEditingController _qualification;
  late final TextEditingController _subjectsCtrl;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _firstName = TextEditingController(text: widget.staff.firstName);
    _lastName = TextEditingController(text: widget.staff.lastName);
    _designation =
        TextEditingController(text: widget.staff.designation ?? '');
    _qualification =
        TextEditingController(text: widget.staff.qualification ?? '');
    _subjectsCtrl = TextEditingController(
        text: widget.staff.subjects.join(', '));
  }

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _designation.dispose();
    _qualification.dispose();
    _subjectsCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    final data = <String, dynamic>{};
    if (_firstName.text.trim() != widget.staff.firstName)
      data['firstName'] = _firstName.text.trim();
    if (_lastName.text.trim() != widget.staff.lastName)
      data['lastName'] = _lastName.text.trim();
    if (_designation.text.trim().isNotEmpty)
      data['designation'] = _designation.text.trim();
    if (_qualification.text.trim().isNotEmpty)
      data['qualification'] = _qualification.text.trim();
    if (_subjectsCtrl.text.trim().isNotEmpty) {
      data['subjects'] = _subjectsCtrl.text
          .split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();
    }

    final err = await ref
        .read(staffListProvider.notifier)
        .update(widget.staff.id, data);

    setState(() => _loading = false);
    if (err != null && mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(err)));
    } else if (mounted) {
      Navigator.pop(context);
      widget.onSaved();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16, right: 16, top: 16),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Edit Staff',
                style:
                    TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _firstName,
                    decoration:
                        const InputDecoration(labelText: 'First Name'),
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? 'Required' : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _lastName,
                    decoration:
                        const InputDecoration(labelText: 'Last Name'),
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? 'Required' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _designation,
              decoration:
                  const InputDecoration(labelText: 'Designation'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _subjectsCtrl,
              decoration: const InputDecoration(
                labelText: 'Subjects',
                hintText: 'e.g. Mathematics, Science',
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _qualification,
              decoration:
                  const InputDecoration(labelText: 'Qualification'),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _loading ? null : _save,
                child: _loading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : const Text('Save Changes'),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
