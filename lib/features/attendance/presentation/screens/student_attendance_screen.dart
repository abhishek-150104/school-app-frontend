import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/attendance_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/models/attendance_models.dart';

class StudentAttendanceScreen extends ConsumerStatefulWidget {
  final String schoolId;
  final String studentId;
  final String studentName;

  const StudentAttendanceScreen({
    super.key,
    required this.schoolId,
    required this.studentId,
    required this.studentName,
  });

  @override
  ConsumerState<StudentAttendanceScreen> createState() =>
      _StudentAttendanceScreenState();
}

class _StudentAttendanceScreenState
    extends ConsumerState<StudentAttendanceScreen> {
  DateTime _from = DateTime.now().subtract(const Duration(days: 29));
  DateTime _to = DateTime.now();
  bool _isParent = false;

  String get _fromStr => DateFormat('yyyy-MM-dd').format(_from);
  String get _toStr => DateFormat('yyyy-MM-dd').format(_to);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  void _load() {
    final user = ref.read(authProvider).user;
    _isParent = user?.isParent == true;
    final notifier = ref.read(
        studentAttendanceProvider(widget.studentId).notifier);
    if (_isParent) {
      notifier.loadForChild(widget.studentId, _fromStr, _toStr);
    } else {
      notifier.loadForStudent(
          widget.schoolId, widget.studentId, _fromStr, _toStr);
    }
  }

  Future<void> _pickDateRange() async {
    final range = await showDateRangePicker(
      context: context,
      initialDateRange: DateTimeRange(start: _from, end: _to),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (range != null) {
      setState(() {
        _from = range.start;
        _to = range.end;
      });
      _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    final recordsAsync =
        ref.watch(studentAttendanceProvider(widget.studentId));

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.studentName),
        actions: [
          IconButton(
              icon: const Icon(Icons.refresh), onPressed: _load),
        ],
      ),
      body: Column(
        children: [
          // Date range selector
          Container(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.08),
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                const Icon(Icons.date_range, size: 18),
                const SizedBox(width: 8),
                Text(
                  '${DateFormat('d MMM').format(_from)} – ${DateFormat('d MMM yyyy').format(_to)}',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const Spacer(),
                TextButton(
                    onPressed: _pickDateRange,
                    child: const Text('Change')),
              ],
            ),
          ),

          recordsAsync.when(
            loading: () => const Expanded(
                child: Center(child: CircularProgressIndicator())),
            error: (e, _) =>
                Expanded(child: Center(child: Text('Error: $e'))),
            data: (records) {
              if (records.isEmpty) {
                return const Expanded(
                    child: Center(
                        child:
                            Text('No attendance records for this period.')));
              }

              // Summary chips at top
              final present =
                  records.where((r) => r.status == AttendanceStatus.present).length;
              final absent =
                  records.where((r) => r.status == AttendanceStatus.absent).length;
              final late =
                  records.where((r) => r.status == AttendanceStatus.late).length;
              final excused =
                  records.where((r) => r.status == AttendanceStatus.excused).length;
              final total = records.length;
              final pct = total > 0
                  ? ((present + late) * 100 / total).toStringAsFixed(1)
                  : '0.0';

              return Expanded(
                child: Column(
                  children: [
                    // Stats bar
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _statChip('Present', '$present', Colors.green),
                          _statChip('Absent', '$absent', Colors.red),
                          _statChip('Late', '$late', Colors.orange),
                          _statChip('Excused', '$excused', Colors.blue),
                          _statChip('Attend.', '$pct%',
                              _pctColor(double.parse(pct))),
                        ],
                      ),
                    ),
                    const Divider(height: 1),
                    Expanded(
                      child: ListView.separated(
                        itemCount: records.length,
                        separatorBuilder: (_, __) =>
                            const Divider(height: 1),
                        itemBuilder: (context, i) {
                          final r = records[i];
                          final color = _statusColor(r.status);
                          return ListTile(
                            leading: SizedBox(
                              width: 48,
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.center,
                                children: [
                                  Text(
                                    DateFormat('d').format(
                                        DateTime.parse(r.date)),
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16),
                                  ),
                                  Text(
                                    DateFormat('MMM').format(
                                        DateTime.parse(r.date)),
                                    style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey.shade500),
                                  ),
                                ],
                              ),
                            ),
                            title: Text(
                              '${r.classRoomName} – Section ${r.sectionName}',
                              style: const TextStyle(fontSize: 13),
                            ),
                            subtitle: r.remarks != null
                                ? Text(r.remarks!,
                                    style: const TextStyle(
                                        fontSize: 12))
                                : null,
                            trailing: Chip(
                              label: Text(r.status.displayName,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12)),
                              backgroundColor: color,
                              visualDensity: VisualDensity.compact,
                              padding: EdgeInsets.zero,
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _statChip(String label, String value, Color color) {
    return Column(
      children: [
        Text(value,
            style: TextStyle(
                fontWeight: FontWeight.bold,
                color: color,
                fontSize: 16)),
        Text(label,
            style: TextStyle(
                fontSize: 11, color: Colors.grey.shade500)),
      ],
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

  Color _pctColor(double pct) {
    if (pct >= 75) return Colors.green;
    if (pct >= 60) return Colors.orange;
    return Colors.red;
  }
}
