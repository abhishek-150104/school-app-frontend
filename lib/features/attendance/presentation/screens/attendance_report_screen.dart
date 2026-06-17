import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/attendance_provider.dart';
import '../../data/models/attendance_models.dart';

class AttendanceReportScreen extends ConsumerStatefulWidget {
  final String schoolId;
  final String sectionId;
  final String sectionName;
  final String classRoomName;

  const AttendanceReportScreen({
    super.key,
    required this.schoolId,
    required this.sectionId,
    required this.sectionName,
    required this.classRoomName,
  });

  @override
  ConsumerState<AttendanceReportScreen> createState() =>
      _AttendanceReportScreenState();
}

class _AttendanceReportScreenState
    extends ConsumerState<AttendanceReportScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DateTime _from = DateTime.now().subtract(const Duration(days: 29));
  DateTime _to = DateTime.now();

  String get _fromStr => DateFormat('yyyy-MM-dd').format(_from);
  String get _toStr => DateFormat('yyyy-MM-dd').format(_to);
  String get _providerKey => '${widget.schoolId}:${widget.sectionId}';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadSummary());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadSummary() {
    ref
        .read(attendanceSummaryProvider(_providerKey).notifier)
        .load(_fromStr, _toStr);
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
      _loadSummary();
    }
  }

  @override
  Widget build(BuildContext context) {
    final summaryAsync =
        ref.watch(attendanceSummaryProvider(_providerKey));

    return Scaffold(
      appBar: AppBar(
        title:
            Text('${widget.classRoomName} – Section ${widget.sectionName}'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Summary'),
            Tab(text: 'Date View'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Date range bar
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
                  child: const Text('Change'),
                ),
              ],
            ),
          ),

          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Tab 1: Summary
                summaryAsync.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) =>
                      Center(child: Text('Error: $e')),
                  data: (summary) => _SummaryTab(summary: summary),
                ),

                // Tab 2: Date view — single day
                _DateViewTab(
                  schoolId: widget.schoolId,
                  sectionId: widget.sectionId,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryTab extends StatelessWidget {
  final AttendanceSummaryModel summary;
  const _SummaryTab({required this.summary});

  @override
  Widget build(BuildContext context) {
    if (summary.students.isEmpty) {
      return const Center(child: Text('No attendance data for this period.'));
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Text('${summary.totalDays} school days',
                  style: TextStyle(
                      color: Colors.grey.shade600, fontSize: 13)),
              const Spacer(),
              Text('${summary.students.length} students',
                  style: TextStyle(
                      color: Colors.grey.shade600, fontSize: 13)),
            ],
          ),
        ),
        // Header row
        Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color:
              Theme.of(context).colorScheme.primary.withOpacity(0.06),
          child: Row(
            children: [
              const Expanded(
                  flex: 3,
                  child:
                      Text('Student', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
              for (final label in ['P', 'A', 'L', 'E', '%'])
                Expanded(
                  child: Text(label,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 12)),
                ),
            ],
          ),
        ),
        Expanded(
          child: ListView.separated(
            itemCount: summary.students.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final stat = summary.students[i];
              final pct = stat.percentage;
              final pctColor = pct >= 75
                  ? Colors.green
                  : pct >= 60
                      ? Colors.orange
                      : Colors.red;

              return Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(stat.fullName,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis),
                          Text(stat.admissionNumber,
                              style: TextStyle(
                                  color: Colors.grey.shade500,
                                  fontSize: 11)),
                        ],
                      ),
                    ),
                    _cell('${stat.present}', Colors.green),
                    _cell('${stat.absent}', Colors.red),
                    _cell('${stat.late}', Colors.orange),
                    _cell('${stat.excused}', Colors.blue),
                    Expanded(
                      child: Text(
                        '${pct.toStringAsFixed(0)}%',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: pctColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 12),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _cell(String text, Color color) {
    return Expanded(
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
            color: color, fontWeight: FontWeight.w600, fontSize: 12),
      ),
    );
  }
}

class _DateViewTab extends ConsumerStatefulWidget {
  final String schoolId;
  final String sectionId;

  const _DateViewTab(
      {required this.schoolId, required this.sectionId});

  @override
  ConsumerState<_DateViewTab> createState() => _DateViewTabState();
}

class _DateViewTabState extends ConsumerState<_DateViewTab> {
  DateTime _date = DateTime.now();
  List<AttendanceModel>? _records;
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final repo = ref.read(attendanceRepositoryProvider);
      final records = await repo.getBySection(
        widget.schoolId,
        widget.sectionId,
        DateFormat('yyyy-MM-dd').format(_date),
      );
      setState(() {
        _records = records;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _date = picked);
      _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              Text(DateFormat('EEEE, d MMM yyyy').format(_date),
                  style: const TextStyle(fontWeight: FontWeight.w600)),
              const Spacer(),
              TextButton(
                  onPressed: _pickDate, child: const Text('Change')),
            ],
          ),
        ),
        if (_loading)
          const Expanded(
              child: Center(child: CircularProgressIndicator()))
        else if (_error != null)
          Expanded(child: Center(child: Text('Error: $_error')))
        else if (_records == null || _records!.isEmpty)
          const Expanded(
              child:
                  Center(child: Text('No attendance recorded for this date.')))
        else
          Expanded(
            child: ListView.separated(
              itemCount: _records!.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, i) {
                final r = _records![i];
                final color = _statusColor(r.status);
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: color.withOpacity(0.12),
                    child: Text(r.studentFullName[0],
                        style: TextStyle(
                            color: color,
                            fontWeight: FontWeight.bold)),
                  ),
                  title: Text(r.studentFullName,
                      style:
                          const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text(r.admissionNumber,
                      style: const TextStyle(fontSize: 12)),
                  trailing: Chip(
                    label: Text(r.status.displayName,
                        style: const TextStyle(
                            color: Colors.white, fontSize: 12)),
                    backgroundColor: color,
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                  ),
                );
              },
            ),
          ),
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
}
