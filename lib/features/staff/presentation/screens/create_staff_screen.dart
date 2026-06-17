import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/staff_provider.dart';

class CreateStaffScreen extends ConsumerStatefulWidget {
  const CreateStaffScreen({super.key});

  @override
  ConsumerState<CreateStaffScreen> createState() =>
      _CreateStaffScreenState();
}

class _CreateStaffScreenState extends ConsumerState<CreateStaffScreen> {
  final _formKey = GlobalKey<FormState>();
  final _userId = TextEditingController();
  final _employeeId = TextEditingController();
  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _designation = TextEditingController();
  final _subjectsCtrl = TextEditingController();
  final _qualification = TextEditingController();
  DateTime? _joiningDate;
  bool _loading = false;

  @override
  void dispose() {
    _userId.dispose();
    _employeeId.dispose();
    _firstName.dispose();
    _lastName.dispose();
    _designation.dispose();
    _subjectsCtrl.dispose();
    _qualification.dispose();
    super.dispose();
  }

  Future<void> _pickJoiningDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _joiningDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _joiningDate = picked);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    final data = <String, dynamic>{
      'userId': _userId.text.trim(),
      'employeeId': _employeeId.text.trim(),
      'firstName': _firstName.text.trim(),
      'lastName': _lastName.text.trim(),
    };

    if (_designation.text.trim().isNotEmpty) {
      data['designation'] = _designation.text.trim();
    }
    if (_subjectsCtrl.text.trim().isNotEmpty) {
      data['subjects'] = _subjectsCtrl.text
          .split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();
    }
    if (_qualification.text.trim().isNotEmpty) {
      data['qualification'] = _qualification.text.trim();
    }
    if (_joiningDate != null) {
      data['joiningDate'] =
          DateFormat('yyyy-MM-dd').format(_joiningDate!);
    }

    final err =
        await ref.read(staffListProvider.notifier).create(data);

    setState(() => _loading = false);

    if (err != null && mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(err)));
    } else if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Staff Member')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionHeader('Link User Account'),
              TextFormField(
                controller: _userId,
                decoration: const InputDecoration(
                  labelText: 'User ID *',
                  hintText: 'MongoDB ID of the TEACHER user account',
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 24),
              _sectionHeader('Basic Info'),
              TextFormField(
                controller: _employeeId,
                decoration: const InputDecoration(
                    labelText: 'Employee ID *'),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _firstName,
                      decoration: const InputDecoration(
                          labelText: 'First Name *'),
                      textCapitalization: TextCapitalization.words,
                      validator: (v) =>
                          v == null || v.trim().isEmpty ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _lastName,
                      decoration: const InputDecoration(
                          labelText: 'Last Name *'),
                      textCapitalization: TextCapitalization.words,
                      validator: (v) =>
                          v == null || v.trim().isEmpty ? 'Required' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _sectionHeader('Role & Expertise (optional)'),
              TextFormField(
                controller: _designation,
                decoration: const InputDecoration(
                  labelText: 'Designation',
                  hintText: 'e.g. Class Teacher, HOD Science',
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _subjectsCtrl,
                decoration: const InputDecoration(
                  labelText: 'Subjects',
                  hintText: 'Comma-separated: Mathematics, Physics',
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _qualification,
                decoration: const InputDecoration(
                  labelText: 'Qualification',
                  hintText: 'e.g. B.Ed, M.Sc Mathematics',
                ),
              ),
              const SizedBox(height: 12),
              InkWell(
                onTap: _pickJoiningDate,
                borderRadius: BorderRadius.circular(12),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Joining Date',
                    suffixIcon:
                        Icon(Icons.calendar_today_outlined, size: 18),
                  ),
                  child: Text(
                    _joiningDate != null
                        ? DateFormat('dd MMM yyyy').format(_joiningDate!)
                        : 'Select date',
                    style: TextStyle(
                        color: _joiningDate != null
                            ? null
                            : Colors.grey.shade500),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _loading ? null : _submit,
                  child: _loading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : const Text('Add Staff Member'),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionHeader(String title) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Text(title,
            style: const TextStyle(
                fontWeight: FontWeight.bold, fontSize: 15)),
      );
}
