import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/student_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../school/presentation/providers/school_provider.dart';
import '../../data/models/student_models.dart';

class StudentDetailScreen extends ConsumerWidget {
  final String schoolId;
  final StudentModel student;

  const StudentDetailScreen({
    super.key,
    required this.schoolId,
    required this.student,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;
    final canManage =
        user?.isSuperAdmin == true || user?.isSchoolAdmin == true;

    return Scaffold(
      appBar: AppBar(
        title: Text(student.fullName),
        actions: [
          PopupMenuButton<String>(
              onSelected: (val) =>
                  _onMenuSelected(context, ref, val),
              itemBuilder: (_) => [
                const PopupMenuItem(
                    value: 'attendance',
                    child: Text('View Attendance')),
                if (canManage) ...[
                  const PopupMenuItem(
                      value: 'edit', child: Text('Edit Student')),
                  const PopupMenuItem(
                      value: 'link_parent',
                      child: Text('Link Parent')),
                  const PopupMenuItem(
                      value: 'transfer',
                      child: Text('Transfer Class')),
                  if (student.active)
                    PopupMenuItem(
                      value: 'deactivate',
                      child: Text('Deactivate',
                          style:
                              TextStyle(color: Colors.red.shade700)),
                    ),
                ],
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
            _infoCard(context, 'Class Placement', [
              _row('Academic Year', student.academicYearLabel),
              _row('Class', student.classRoomName),
              _row('Section', student.sectionName),
              _row('Roll Number', student.rollNumber.toString()),
            ]),
            const SizedBox(height: 12),
            _infoCard(context, 'Admission', [
              _row('Admission No.', student.admissionNumber),
              if (student.admissionDate != null)
                _row('Admission Date', student.admissionDate!),
            ]),
            const SizedBox(height: 12),
            _infoCard(context, 'Personal Info', [
              _row('Date of Birth', student.dateOfBirth ?? '—'),
              _row('Gender', student.displayGender),
              if (student.bloodGroup != null)
                _row('Blood Group', student.bloodGroup!),
              if (student.religion != null)
                _row('Religion', student.religion!),
              if (student.category != null)
                _row('Category', student.category!),
            ]),
            if (student.address != null) ...[
              const SizedBox(height: 12),
              _infoCard(context, 'Address', [
                if (student.address!.street != null)
                  _row('Street', student.address!.street!),
                if (student.address!.city != null)
                  _row('City', student.address!.city!),
                if (student.address!.state != null)
                  _row('State', student.address!.state!),
                if (student.address!.pincode != null)
                  _row('Pincode', student.address!.pincode!),
              ]),
            ],
            const SizedBox(height: 12),
            _infoCard(context, 'Parent / Guardian', [
              if (student.hasParent) ...[
                _row('Name', student.parentName ?? '—'),
                _row('Phone', student.parentPhone ?? '—'),
              ] else
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 4),
                  child: Text('No parent linked',
                      style: TextStyle(color: Colors.orange)),
                ),
            ]),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _profileHeader(BuildContext context) {
    final theme = Theme.of(context);
    final initials = student.fullName.trim().split(' ').map((w) => w[0]).take(2).join();

    return Card(
      color: theme.colorScheme.primary,
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
                    student.fullName,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    student.classSectionDisplay,
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.85), fontSize: 13),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: student.active ? Colors.green.shade400 : Colors.red.shade400,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      student.active ? 'Active' : 'Inactive',
                      style: const TextStyle(color: Colors.white, fontSize: 11),
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

  void _onMenuSelected(BuildContext context, WidgetRef ref, String action) {
    switch (action) {
      case 'attendance':
        context.push(
          '/schools/$schoolId/students/${student.id}/attendance',
          extra: student.fullName,
        );
        break;
      case 'edit':
        _showEditSheet(context, ref);
        break;
      case 'link_parent':
        _showLinkParentDialog(context, ref);
        break;
      case 'transfer':
        _showTransferSheet(context, ref);
        break;
      case 'deactivate':
        _confirmDeactivate(context, ref);
        break;
    }
  }

  void _showEditSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => _EditStudentSheet(
        schoolId: schoolId,
        student: student,
        onSaved: () => context.pop(),
      ),
    );
  }

  void _showLinkParentDialog(BuildContext context, WidgetRef ref) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Link Parent'),
        content: TextField(
          controller: ctrl,
          decoration: const InputDecoration(
            labelText: 'Parent User ID',
            hintText: 'Enter the parent account ID',
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          FilledButton(
            onPressed: () async {
              if (ctrl.text.trim().isEmpty) return;
              Navigator.pop(context);
              final err = await ref
                  .read(studentListProvider(schoolId).notifier)
                  .linkParent(student.id, ctrl.text.trim());
              if (err != null && context.mounted) {
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text(err)));
              } else if (context.mounted) {
                context.pop();
              }
            },
            child: const Text('Link'),
          ),
        ],
      ),
    );
  }

  void _showTransferSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => _TransferSheet(
        schoolId: schoolId,
        student: student,
        onTransferred: () => context.pop(),
      ),
    );
  }

  void _confirmDeactivate(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Deactivate Student'),
        content: Text(
            'Are you sure you want to deactivate ${student.fullName}? This action can be reversed.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(
                backgroundColor: Colors.red.shade700),
            onPressed: () async {
              Navigator.pop(context);
              final err = await ref
                  .read(studentListProvider(schoolId).notifier)
                  .deactivate(student.id);
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

// ── Edit Student Sheet ────────────────────────────────────────────────────────

class _EditStudentSheet extends ConsumerStatefulWidget {
  final String schoolId;
  final StudentModel student;
  final VoidCallback onSaved;

  const _EditStudentSheet({
    required this.schoolId,
    required this.student,
    required this.onSaved,
  });

  @override
  ConsumerState<_EditStudentSheet> createState() => _EditStudentSheetState();
}

class _EditStudentSheetState extends ConsumerState<_EditStudentSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _firstName;
  late final TextEditingController _lastName;
  late final TextEditingController _bloodGroup;
  late final TextEditingController _religion;
  late final TextEditingController _category;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _firstName = TextEditingController(text: widget.student.firstName);
    _lastName = TextEditingController(text: widget.student.lastName);
    _bloodGroup = TextEditingController(text: widget.student.bloodGroup ?? '');
    _religion = TextEditingController(text: widget.student.religion ?? '');
    _category = TextEditingController(text: widget.student.category ?? '');
  }

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _bloodGroup.dispose();
    _religion.dispose();
    _category.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    final data = <String, dynamic>{};
    if (_firstName.text.trim() != widget.student.firstName)
      data['firstName'] = _firstName.text.trim();
    if (_lastName.text.trim() != widget.student.lastName)
      data['lastName'] = _lastName.text.trim();
    if (_bloodGroup.text.trim().isNotEmpty)
      data['bloodGroup'] = _bloodGroup.text.trim();
    if (_religion.text.trim().isNotEmpty)
      data['religion'] = _religion.text.trim();
    if (_category.text.trim().isNotEmpty)
      data['category'] = _category.text.trim();

    final err = await ref
        .read(studentListProvider(widget.schoolId).notifier)
        .update(widget.student.id, data);

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
            const Text('Edit Student',
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
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _bloodGroup,
                    decoration:
                        const InputDecoration(labelText: 'Blood Group'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _category,
                    decoration:
                        const InputDecoration(labelText: 'Category'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _religion,
              decoration:
                  const InputDecoration(labelText: 'Religion'),
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

// ── Transfer Sheet ────────────────────────────────────────────────────────────

class _TransferSheet extends ConsumerStatefulWidget {
  final String schoolId;
  final StudentModel student;
  final VoidCallback onTransferred;

  const _TransferSheet({
    required this.schoolId,
    required this.student,
    required this.onTransferred,
  });

  @override
  ConsumerState<_TransferSheet> createState() => _TransferSheetState();
}

class _TransferSheetState extends ConsumerState<_TransferSheet> {
  final _formKey = GlobalKey<FormState>();
  final _rollCtrl = TextEditingController();
  String? _selectedClassId;
  String? _selectedSectionId;
  bool _loading = false;

  @override
  void dispose() {
    _rollCtrl.dispose();
    super.dispose();
  }

  Future<void> _transfer() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedClassId == null || _selectedSectionId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select class and section')));
      return;
    }
    setState(() => _loading = true);

    final data = {
      'classRoomId': _selectedClassId,
      'sectionId': _selectedSectionId,
      'rollNumber': int.parse(_rollCtrl.text.trim()),
    };

    final err = await ref
        .read(studentListProvider(widget.schoolId).notifier)
        .transfer(widget.student.id, data);

    setState(() => _loading = false);
    if (err != null && mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(err)));
    } else if (mounted) {
      Navigator.pop(context);
      widget.onTransferred();
    }
  }

  @override
  Widget build(BuildContext context) {
    final classesAsync =
        ref.watch(classRoomProvider(widget.schoolId));
    final sectionKey =
        '${widget.schoolId}:${_selectedClassId ?? ''}';
    final sectionsAsync = _selectedClassId != null
        ? ref.watch(sectionProvider(sectionKey))
        : null;

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
            const Text('Transfer Student',
                style:
                    TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(
              'Current: ${widget.student.classSectionDisplay}',
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),
            const SizedBox(height: 16),
            classesAsync.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) =>
                  Text('Failed to load classes: $e'),
              data: (classes) => DropdownButtonFormField<String>(
                value: _selectedClassId,
                decoration:
                    const InputDecoration(labelText: 'New Class'),
                items: classes
                    .map((c) => DropdownMenuItem(
                        value: c.id, child: Text(c.name)))
                    .toList(),
                onChanged: (v) =>
                    setState(() {
                      _selectedClassId = v;
                      _selectedSectionId = null;
                    }),
                validator: (v) =>
                    v == null ? 'Select a class' : null,
              ),
            ),
            const SizedBox(height: 12),
            if (sectionsAsync != null)
              sectionsAsync.when(
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (e, _) =>
                    Text('Failed to load sections: $e'),
                data: (sections) => DropdownButtonFormField<String>(
                  value: _selectedSectionId,
                  decoration:
                      const InputDecoration(labelText: 'New Section'),
                  items: sections
                      .map((s) => DropdownMenuItem(
                          value: s.id, child: Text(s.name)))
                      .toList(),
                  onChanged: (v) =>
                      setState(() => _selectedSectionId = v),
                  validator: (v) =>
                      v == null ? 'Select a section' : null,
                ),
              ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _rollCtrl,
              keyboardType: TextInputType.number,
              decoration:
                  const InputDecoration(labelText: 'New Roll Number'),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Required';
                if (int.tryParse(v.trim()) == null)
                  return 'Must be a number';
                return null;
              },
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _loading ? null : _transfer,
                child: _loading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : const Text('Transfer'),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
