import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/exam_provider.dart';

class ExamsScreen extends ConsumerWidget {
  const ExamsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final examsAsync = ref.watch(examProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Exams')),
      body: examsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (exams) {
          if (exams.isEmpty) {
            return const Center(child: Text('No exams scheduled'));
          }
          return RefreshIndicator(
            onRefresh: () => ref.read(examProvider.notifier).load(),
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: exams.length,
              itemBuilder: (context, i) {
                final exam = exams[i];
                final statusColor = exam.status == 'COMPLETED'
                    ? Colors.grey
                    : exam.status == 'ONGOING' ? Colors.green : Colors.blue;
                return Card(
                  child: ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: statusColor.withAlpha(30),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.assignment_outlined, color: statusColor),
                    ),
                    title: Text(exam.title,
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text(
                        '${exam.classRoomName} • ${exam.startDate} – ${exam.endDate}',
                        style: const TextStyle(fontSize: 12)),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor.withAlpha(30),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: statusColor),
                      ),
                      child: Text(exam.status,
                          style: TextStyle(color: statusColor, fontSize: 10)),
                    ),
                    onTap: () => context.push('/exams/${exam.id}', extra: exam),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
