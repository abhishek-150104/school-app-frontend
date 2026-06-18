import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/circular_provider.dart';

class CreateCircularScreen extends ConsumerStatefulWidget {
  const CreateCircularScreen({super.key});
  @override
  ConsumerState<CreateCircularScreen> createState() => _CreateCircularScreenState();
}

class _CreateCircularScreenState extends ConsumerState<CreateCircularScreen> {
  final _form = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _content = TextEditingController();
  String _targetType = 'ALL';
  final _classId = TextEditingController();
  final _sectionId = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _title.dispose(); _content.dispose();
    _classId.dispose(); _sectionId.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await ref.read(circularProvider.notifier).create({
        'title': _title.text.trim(),
        'content': _content.text.trim(),
        'targetType': _targetType,
        if (_targetType == 'CLASS' && _classId.text.isNotEmpty)
          'targetClassRoomId': _classId.text.trim(),
        if (_targetType == 'SECTION' && _sectionId.text.isNotEmpty)
          'targetSectionId': _sectionId.text.trim(),
      });
      if (mounted) context.pop();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Circular')),
      body: Form(
        key: _form,
        child: ListView(padding: const EdgeInsets.all(16), children: [
          TextFormField(controller: _title, decoration: const InputDecoration(labelText: 'Title'),
              validator: (v) => v == null || v.isEmpty ? 'Required' : null),
          const SizedBox(height: 12),
          TextFormField(controller: _content, decoration: const InputDecoration(labelText: 'Content'),
              maxLines: 6,
              validator: (v) => v == null || v.isEmpty ? 'Required' : null),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _targetType,
            decoration: const InputDecoration(labelText: 'Target'),
            items: ['ALL', 'CLASS', 'SECTION'].map((t) =>
                DropdownMenuItem(value: t, child: Text(t))).toList(),
            onChanged: (v) => setState(() => _targetType = v!),
          ),
          if (_targetType == 'CLASS') ...[
            const SizedBox(height: 12),
            TextFormField(controller: _classId,
                decoration: const InputDecoration(labelText: 'Class Room ID')),
          ],
          if (_targetType == 'SECTION') ...[
            const SizedBox(height: 12),
            TextFormField(controller: _sectionId,
                decoration: const InputDecoration(labelText: 'Section ID')),
          ],
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _loading ? null : _submit,
            child: _loading ? const CircularProgressIndicator() : const Text('Publish'),
          ),
        ]),
      ),
    );
  }
}
