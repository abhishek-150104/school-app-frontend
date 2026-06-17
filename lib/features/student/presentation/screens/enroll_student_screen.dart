import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/student_provider.dart';
import '../../../school/presentation/providers/school_provider.dart';

class EnrollStudentScreen extends ConsumerStatefulWidget {
  final String schoolId;
  final String schoolName;

  const EnrollStudentScreen({
    super.key,
    required this.schoolId,
    required this.schoolName,
  });

  @override
  ConsumerState<EnrollStudentScreen> createState() =>
      _EnrollStudentScreenState();
}

class _EnrollStudentScreenState extends ConsumerState<EnrollStudentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _admissionNumber = TextEditingController();
  final _rollNumber = TextEditingController();
  final _bloodGroup = TextEditingController();
  final _religion = TextEditingController();
  final _category = TextEditingController();
  final _parentId = TextEditingController();

  String _gender = 'MALE';
  DateTime? _dateOfBirth;
  DateTime? _admissionDate;
  String? _selectedYearId;
  String? _selectedClassId;
  String? _selectedSectionId;
  bool _loading = false;

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _admissionNumber.dispose();
    _rollNumber.dispose();
    _bloodGroup.dispose();
    _religion.dispose();
    _category.dispose();
    _parentId.dispose();
    super.dispose();
  }

  Future<void> _pickDate(bool isDob) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isDob
          ? DateTime(2010)
          : (_admissionDate ?? DateTime.now()),
      firstDate: isDob ? DateTime(1990) : DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        if (isDob) {
          _dateOfBirth = picked;
        } else {
          _admissionDate = picked;
        }
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedYearId == null ||
        _selectedClassId == null ||
        _selectedSectionId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Please select academic year, class and section')));
      return;
    }
    if (_dateOfBirth == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select date of birth')));
      return;
    }

    setState(() => _loading = true);

    final data = <String, dynamic>{
      'firstName': _firstName.text.trim(),
      'lastName': _lastName.text.trim(),
      'admissionNumber': _admissionNumber.text.trim(),
      'rollNumber': int.parse(_rollNumber.text.trim()),
      'gender': _gender,
      'dateOfBirth': DateFormat('yyyy-MM-dd').format(_dateOfBirth!),
      'academicYearId': _selectedYearId,
      'classRoomId': _selectedClassId,
      'sectionId': _selectedSectionId,
    };

    if (_admissionDate != null) {
      data['admissionDate'] =
          DateFormat('yyyy-MM-dd').format(_admissionDate!);
    }
    if (_bloodGroup.text.trim().isNotEmpty) {
      data['bloodGroup'] = _bloodGroup.text.trim();
    }
    if (_religion.text.trim().isNotEmpty) {
      data['religion'] = _religion.text.trim();
    }
    if (_category.text.trim().isNotEmpty) {
      data['category'] = _category.text.trim();
    }
    if (_parentId.text.trim().isNotEmpty) {
      data['parentId'] = _parentId.text.trim();
    }

    final err = await ref
        .read(studentListProvider(widget.schoolId).notifier)
        .enroll(data);

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
    final yearsAsync =
        ref.watch(academicYearProvider(widget.schoolId));
    final classesAsync =
        ref.watch(classRoomProvider(widget.schoolId));
    final sectionKey = '${widget.schoolId}:${_selectedClassId ?? ''}';
    final sectionsAsync = _selectedClassId != null
        ? ref.watch(sectionProvider(sectionKey))
        : null;

    return Scaffold(
      appBar: AppBar(title: Text('Enroll — ${widget.schoolName}')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionHeader('Basic Info'),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _firstName,
                      decoration:
                          const InputDecoration(labelText: 'First Name *'),
                      textCapitalization: TextCapitalization.words,
                      validator: (v) =>
                          v == null || v.trim().isEmpty ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _lastName,
                      decoration:
                          const InputDecoration(labelText: 'Last Name *'),
                      textCapitalization: TextCapitalization.words,
                      validator: (v) =>
                          v == null || v.trim().isEmpty ? 'Required' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _gender,
                decoration: const InputDecoration(labelText: 'Gender *'),
                items: const [
                  DropdownMenuItem(value: 'MALE', child: Text('Male')),
                  DropdownMenuItem(value: 'FEMALE', child: Text('Female')),
                  DropdownMenuItem(value: 'OTHER', child: Text('Other')),
                ],
                onChanged: (v) => setState(() => _gender = v!),
              ),
              const SizedBox(height: 12),
              _datePicker(
                label: 'Date of Birth *',
                date: _dateOfBirth,
                onTap: () => _pickDate(true),
              ),
              const SizedBox(height: 24),
              _sectionHeader('Admission'),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _admissionNumber,
                      decoration:
                          const InputDecoration(labelText: 'Admission No. *'),
                      validator: (v) =>
                          v == null || v.trim().isEmpty ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _rollNumber,
                      keyboardType: TextInputType.number,
                      decoration:
                          const InputDecoration(labelText: 'Roll Number *'),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Required';
                        if (int.tryParse(v.trim()) == null) return 'Number only';
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _datePicker(
                label: 'Admission Date',
                date: _admissionDate,
                onTap: () => _pickDate(false),
              ),
              const SizedBox(height: 24),
              _sectionHeader('Class Placement'),
              yearsAsync.when(
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (e, _) => Text('Failed to load years: $e'),
                data: (years) => DropdownButtonFormField<String>(
                  value: _selectedYearId,
                  decoration:
                      const InputDecoration(labelText: 'Academic Year *'),
                  items: years
                      .map((y) => DropdownMenuItem(
                          value: y.id, child: Text(y.label)))
                      .toList(),
                  onChanged: (v) => setState(() => _selectedYearId = v),
                  validator: (v) =>
                      v == null ? 'Select an academic year' : null,
                ),
              ),
              const SizedBox(height: 12),
              classesAsync.when(
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (e, _) =>
                    Text('Failed to load classes: $e'),
                data: (classes) {
                  final filtered = _selectedYearId == null
                      ? classes
                      : classes
                          .where((c) => c.academicYearId == _selectedYearId)
                          .toList();
                  return DropdownButtonFormField<String>(
                    value: _selectedClassId,
                    decoration:
                        const InputDecoration(labelText: 'Class *'),
                    items: filtered
                        .map((c) => DropdownMenuItem(
                            value: c.id, child: Text(c.name)))
                        .toList(),
                    onChanged: (v) => setState(() {
                      _selectedClassId = v;
                      _selectedSectionId = null;
                    }),
                    validator: (v) =>
                        v == null ? 'Select a class' : null,
                  );
                },
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
                        const InputDecoration(labelText: 'Section *'),
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
              const SizedBox(height: 24),
              _sectionHeader('Additional Info (optional)'),
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
              const SizedBox(height: 12),
              TextFormField(
                controller: _parentId,
                decoration: const InputDecoration(
                  labelText: 'Parent ID (optional)',
                  hintText: 'Link parent account at enrollment',
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
                      : const Text('Enroll Student'),
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

  Widget _datePicker({
    required String label,
    required DateTime? date,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          suffixIcon: const Icon(Icons.calendar_today_outlined, size: 18),
        ),
        child: Text(
          date != null
              ? DateFormat('dd MMM yyyy').format(date)
              : 'Select date',
          style: TextStyle(
              color: date != null ? null : Colors.grey.shade500),
        ),
      ),
    );
  }
}
