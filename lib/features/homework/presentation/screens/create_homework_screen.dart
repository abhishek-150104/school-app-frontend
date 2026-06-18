import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/homework_provider.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../core/utils/validators.dart';

class CreateHomeworkScreen extends ConsumerStatefulWidget {
  final String sectionId;
  final String sectionName;

  const CreateHomeworkScreen({
    super.key,
    required this.sectionId,
    required this.sectionName,
  });

  @override
  ConsumerState<CreateHomeworkScreen> createState() =>
      _CreateHomeworkScreenState();
}

class _CreateHomeworkScreenState extends ConsumerState<CreateHomeworkScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  String? _selectedSubject;
  DateTime? _dueDate;
  bool _isLoading = false;

  final _subjects = [
    'Mathematics',
    'Science',
    'English',
    'Hindi',
    'Social Studies',
    'Computer Science',
    'History',
    'Geography',
    'Physics',
    'Chemistry',
    'Biology',
    'Economics',
    'Other',
  ];

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDueDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(days: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _dueDate = picked);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedSubject == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a subject')));
      return;
    }
    if (_dueDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a due date')));
      return;
    }

    setState(() => _isLoading = true);

    final dueDateStr =
        '${_dueDate!.year}-${_dueDate!.month.toString().padLeft(2, '0')}-${_dueDate!.day.toString().padLeft(2, '0')}';

    final data = {
      'sectionId': widget.sectionId,
      'title': _titleCtrl.text.trim(),
      'description': _descCtrl.text.trim(),
      'subject': _selectedSubject,
      'dueDate': dueDateStr,
    };

    final err = await ref
        .read(homeworkProvider(widget.sectionId).notifier)
        .create(data);

    setState(() => _isLoading = false);

    if (!mounted) return;
    if (err == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Homework created'),
              backgroundColor: Colors.green));
      context.pop();
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(err)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Homework — ${widget.sectionName}')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppTextField(
                label: 'Title',
                controller: _titleCtrl,
                prefixIcon: Icons.title,
                validator: (v) => Validators.required(v, 'Title'),
              ),
              const SizedBox(height: 12),
              // Subject dropdown
              DropdownButtonFormField<String>(
                value: _selectedSubject,
                decoration: const InputDecoration(
                  labelText: 'Subject',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.subject),
                ),
                items: _subjects
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                onChanged: (v) => setState(() => _selectedSubject = v),
                validator: (v) => v == null ? 'Please select a subject' : null,
              ),
              const SizedBox(height: 12),
              AppTextField(
                label: 'Description',
                controller: _descCtrl,
                prefixIcon: Icons.description_outlined,
                maxLines: 4,
                validator: (v) => Validators.required(v, 'Description'),
              ),
              const SizedBox(height: 12),
              // Due date picker
              InkWell(
                onTap: _pickDueDate,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Due Date',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.calendar_today_outlined),
                  ),
                  child: Text(
                    _dueDate != null
                        ? '${_dueDate!.year}-${_dueDate!.month.toString().padLeft(2, '0')}-${_dueDate!.day.toString().padLeft(2, '0')}'
                        : 'Select due date',
                    style: TextStyle(
                      color: _dueDate != null ? null : Colors.grey,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              AppButton(
                label: 'Create Homework',
                isLoading: _isLoading,
                onPressed: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
