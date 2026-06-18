import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/timetable_provider.dart';

class TimetableScreen extends ConsumerWidget {
  final String sectionId;
  final String sectionName;
  const TimetableScreen({super.key, required this.sectionId, required this.sectionName});

  static const _days = ['MONDAY', 'TUESDAY', 'WEDNESDAY', 'THURSDAY', 'FRIDAY'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entriesAsync = ref.watch(sectionTimetableProvider(sectionId));

    return Scaffold(
      appBar: AppBar(title: Text('Timetable — $sectionName')),
      body: entriesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (entries) {
          if (entries.isEmpty) {
            return const Center(child: Text('No timetable entries yet'));
          }
          return RefreshIndicator(
            onRefresh: () => ref.read(sectionTimetableProvider(sectionId).notifier).load(),
            child: ListView(
              children: _days.map((day) {
                final dayEntries = entries
                    .where((e) => e.dayOfWeek == day)
                    .toList()
                  ..sort((a, b) => a.periodNumber.compareTo(b.periodNumber));
                if (dayEntries.isEmpty) return const SizedBox.shrink();
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                      child: Text(day,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    ),
                    ...dayEntries.map((e) => Card(
                          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.indigo.withAlpha(30),
                              child: Text('P${e.periodNumber}',
                                  style: const TextStyle(color: Colors.indigo, fontSize: 12)),
                            ),
                            title: Text(e.subjectName,
                                style: const TextStyle(fontWeight: FontWeight.w600)),
                            subtitle: Text('${e.teacherName} • ${e.startTime}–${e.endTime}'),
                          ),
                        )),
                  ],
                );
              }).toList(),
            ),
          );
        },
      ),
    );
  }
}
