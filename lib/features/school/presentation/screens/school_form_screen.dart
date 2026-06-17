import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/school_provider.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../core/utils/validators.dart';

class SchoolFormSheet extends StatefulWidget {
  final Map<String, dynamic>? existing;
  final WidgetRef ref;

  const SchoolFormSheet({super.key, this.existing, required this.ref});

  @override
  State<SchoolFormSheet> createState() => _SchoolFormSheetState();
}

class _SchoolFormSheetState extends State<SchoolFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _email;
  late final TextEditingController _phone;
  late final TextEditingController _city;
  late final TextEditingController _state;
  late final TextEditingController _affiliation;
  bool _isLoading = false;

  bool get _isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final e = widget.existing ?? {};
    _name = TextEditingController(text: e['name'] ?? '');
    _email = TextEditingController(text: e['email'] ?? '');
    _phone = TextEditingController(text: e['phone'] ?? '');
    _city = TextEditingController(text: e['city'] ?? '');
    _state = TextEditingController(text: e['state'] ?? '');
    _affiliation = TextEditingController(text: e['affiliationNumber'] ?? '');
  }

  @override
  void dispose() {
    _name.dispose(); _email.dispose(); _phone.dispose();
    _city.dispose(); _state.dispose(); _affiliation.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final data = {
      'name': _name.text.trim(),
      if (_email.text.trim().isNotEmpty) 'email': _email.text.trim(),
      if (_phone.text.trim().isNotEmpty) 'phone': _phone.text.trim(),
      if (_city.text.trim().isNotEmpty) 'city': _city.text.trim(),
      if (_state.text.trim().isNotEmpty) 'state': _state.text.trim(),
      if (_affiliation.text.trim().isNotEmpty)
        'affiliationNumber': _affiliation.text.trim(),
    };

    String? err;
    if (_isEdit) {
      err = await widget.ref
          .read(schoolListProvider.notifier)
          .update(widget.existing!['id'], data);
    } else {
      err = await widget.ref.read(schoolListProvider.notifier).create(data);
    }

    setState(() => _isLoading = false);
    if (!mounted) return;

    if (err == null) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(_isEdit ? 'School updated' : 'School created'),
        backgroundColor: Colors.green,
      ));
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(err)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(context).viewInsets.bottom + 24),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_isEdit ? 'Edit School' : 'Add School',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              AppTextField(
                label: 'School Name',
                controller: _name,
                prefixIcon: Icons.business_outlined,
                validator: (v) => Validators.required(v, 'School name'),
              ),
              const SizedBox(height: 12),
              AppTextField(
                label: 'Email',
                controller: _email,
                prefixIcon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                validator: (v) =>
                    v != null && v.isNotEmpty ? Validators.email(v) : null,
              ),
              const SizedBox(height: 12),
              AppTextField(
                label: 'Phone',
                controller: _phone,
                prefixIcon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                validator: (v) =>
                    v != null && v.isNotEmpty ? Validators.phone(v) : null,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: AppTextField(
                      label: 'City',
                      controller: _city,
                      prefixIcon: Icons.location_city_outlined,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppTextField(
                      label: 'State',
                      controller: _state,
                      prefixIcon: Icons.map_outlined,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              AppTextField(
                label: 'Affiliation Number',
                controller: _affiliation,
                prefixIcon: Icons.numbers_outlined,
              ),
              const SizedBox(height: 24),
              AppButton(
                label: _isEdit ? 'Update School' : 'Create School',
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
