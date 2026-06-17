import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/attendance_provider.dart';
import '../../../student/presentation/providers/student_provider.dart';
import '../../data/models/attendance_models.dart';

class MarkAttendanceScreen extends ConsumerStatefulWidget {
  final String schoolId;
  final String sectionId;
  final String sectionName;
  final String classRoomName;

  const MarkAttendanceScreen({
    super.key,
    required this.schoolId,
    required this.sectionId,
    required this.sectionName,
    required this.classRoomName,
  });

  @override
  ConsumerState<MarkAttendanceScreen> createState() =>
      _MarkAttendanceScreenState();
}

class _MarkAttendanceScreenState extends ConsumerState<MarkAttendanceScreen> {
  late DateTime _selectedDate;
  bool _initialized = false;

  String get _providerKey =>
      '${widget.schoolId}:${widget.sectionId}';

  String get _dateStr => DateFormat('yyyy-MM-dd').format(_selectedDate);

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadStudents());
  }

  Future<void> _loadStudents() async {
    final notifier = ref.read(studentListProvider(widget.schoolId).notifier);
    await notifier.load(sectionId: widget.sectionId);
    final students = ref.read(studentListProvider(widget.schoolId)).value ?? [];
    final activeStudents = students.where((s) => s.active).toList();

    final markNotifier = ref.read(markAttendanceProvider(_providerKey).notifier);
    markNotifier.initEntries(activeStudents.map((s) => s.id).toList());
    await markNotifier.loadExisting(_dateStr);
    setState(() => _initialized = true);
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 90)),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _initialized = false;
      });
      await ref
          .read(markAttendanceProvider(_providerKey).notifier)
          .loadExisting(_dateStr);
      setState(() => _initialized = true);
    }
  }

  Future<void> _submit() async {
    final success = await ref
        .read(markAttendanceProvider(_providerKey).notifier)
        .submit(_dateStr);
    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Attendance saved'),
              backgroundColor: Colors.green),
        );
      } else {
        final err =
            ref.read(markAttendanceProvider(_providerKey)).error ?? 'Error';
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(err)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final markState = ref.watch(markAttendanceProvider(_providerKey));
    final studentsAsync = ref.watch(studentListProvider(widget.schoolId));

    return Scaffold(
      appBar: AppBar(
        title: Text(
            '${widget.classRoomName} – Section ${widget.sectionName}'),
        actions: [
          TextButton.icon(
            onPressed: markState.isLoading ? null : _submit,
            icon: const Icon(Icons.save, color: Colors.white),
            label: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: Column(
        children: [
          // Date selector bar
          Container(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.08),
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                const Icon(Icons.calendar_today, size: 18),
                const SizedBox(width: 8),
                Text(
                  DateFormat('EEEE, d MMM yyyy').format(_selectedDate),
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const Spacer(),
                TextButton(
                  onPressed: _pickDate,
                  child: const Text('Change'),
                ),
              ],
            ),
          ),

          if (!_initialized || markState.isLoading)
            const Expanded(
                child: Center(child: CircularProgressIndicator()))
          else
            studentsAsync.when(
              loading: () => const Expanded(
                  child: Center(child: CircularProgressIndicator())),
              error: (e, _) =>
                  Expanded(child: Center(child: Text('Error: $e'))),
              data: (students) {
                final active = students.where((s) => s.active).toList();
                if (active.isEmpty) {
                  return const Expanded(
                    child: Center(
                        child: Text('No active students in this section.')),
                  );
                }

                return Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: active.length,
                    separatorBuilder: (_, __) =>
                        const Divider(height: 1),
                    itemBuilder: (context, i) {
                      final student = active[i];
                      final entry = markState.entries[student.id];
                      final status =
                          entry?.status ?? AttendanceStatus.present;

                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 4),
                        leading: CircleAvatar(
                          backgroundColor: _statusColor(status)
                              .withOpacity(0.15),
                          child: Text(
                            student.fullName[0].toUpperCase(),
                            style: TextStyle(
                                color: _statusColor(status),
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        title: Text(student.fullName,
                            style: const TextStyle(
                                fontWeight: FontWeight.w600)),
                        subtitle: Text(student.admissionNumber,
                            style: const TextStyle(fontSize: 12)),
                        trailing: _StatusToggle(
                          status: status,
                          onChanged: (s) => ref
                              .read(markAttendanceProvider(_providerKey)
                                  .notifier)
                              .setStatus(student.id, s),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Color _statusColor(AttendanceStatus s) {
    switch (s) {
      case AttendanceStatus.present:
        return Colors.green;
      case AttendanceStatus.absent:
        return Colors.red;
      case AttendanceStatus.late:
        return Colors.orange;
      case AttendanceStatus.excused:
        return Colors.blue;
    }
  }
}

class _StatusToggle extends StatelessWidget {
  final AttendanceStatus status;
  final ValueChanged<AttendanceStatus> onChanged;

  const _StatusToggle(
      {required this.status, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: AttendanceStatus.values.map((s) {
        final selected = s == status;
        return Padding(
          padding: const EdgeInsets.only(left: 4),
          child: GestureDetector(
            onTap: () => onChanged(s),
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: selected
                    ? _color(s)
                    : _color(s).withOpacity(0.08),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                    color: selected
                        ? _color(s)
                        : _color(s).withOpacity(0.3)),
              ),
              child: Text(
                _label(s),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: selected ? Colors.white : _color(s),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Color _color(AttendanceStatus s) {
    switch (s) {
      case AttendanceStatus.present:
        return Colors.green;
      case AttendanceStatus.absent:
        return Colors.red;
      case AttendanceStatus.late:
        return Colors.orange;
      case AttendanceStatus.excused:
        return Colors.blue;
    }
  }

  String _label(AttendanceStatus s) {
    switch (s) {
      case AttendanceStatus.present:
        return 'P';
      case AttendanceStatus.absent:
        return 'A';
      case AttendanceStatus.late:
        return 'L';
      case AttendanceStatus.excused:
        return 'E';
    }
  }
}
