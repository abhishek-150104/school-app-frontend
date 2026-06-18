import 'package:flutter/material.dart';
import '../../data/models/exam_models.dart';

class ExamDetailScreen extends StatelessWidget {
  final ExamModel exam;
  const ExamDetailScreen({super.key, required this.exam});

  @override
  Widget build(BuildContext context) {
    final statusColor = exam.status == 'COMPLETED'
        ? Colors.grey
        : exam.status == 'ONGOING' ? Colors.green : Colors.blue;

    return Scaffold(
      appBar: AppBar(title: Text(exam.title, overflow: TextOverflow.ellipsis)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _row('Class', exam.classRoomName),
          _row('Academic Year', exam.academicYearName),
          _row('Start Date', exam.startDate),
          _row('End Date', exam.endDate),
          if (exam.description != null && exam.description!.isNotEmpty)
            _row('Description', exam.description!),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: statusColor.withAlpha(30),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: statusColor),
            ),
            child: Text(exam.status,
                style: TextStyle(color: statusColor, fontWeight: FontWeight.bold)),
          ),
        ]),
      ),
    );
  }

  Widget _row(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            SizedBox(width: 120, child: Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13))),
            Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w500))),
          ],
        ),
      );
}
