import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/report_provider.dart';
import '../../data/models/report_models.dart';

class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Reports & Analytics'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Dashboard'),
              Tab(text: 'Fees'),
              Tab(text: 'Attendance'),
              Tab(text: 'Exams'),
            ],
          ),
        ),
        body: TabBarView(children: [
          _ReportTab(provider: dashboardReportProvider),
          _ReportTab(provider: feeReportProvider),
          _ReportTab(provider: attendanceReportProvider),
          _ReportTab(provider: examReportProvider),
        ]),
      ),
    );
  }
}

class _ReportTab extends ConsumerWidget {
  final ProviderListenable<AsyncValue<ReportModel>> provider;
  const _ReportTab({required this.provider});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportAsync = ref.watch(provider);
    return reportAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (report) => _ReportData(report: report),
    );
  }
}

class _ReportData extends StatelessWidget {
  final ReportModel report;
  const _ReportData({required this.report});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                report.reportType.replaceAll('_', ' '),
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                report.generatedAt.length > 10 ? report.generatedAt.substring(0, 10) : report.generatedAt,
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...report.data.entries.map((e) => _StatCard(
                label: _formatKey(e.key),
                value: e.value.toString(),
              )),
        ],
      ),
    );
  }

  String _formatKey(String key) {
    return key
        .replaceAllMapped(RegExp(r'([A-Z])'), (m) => ' ${m[0]}')
        .trim()
        .split(' ')
        .map((w) => w.isEmpty ? '' : '${w[0].toUpperCase()}${w.substring(1)}')
        .join(' ');
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  const _StatCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        title: Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.blue,
            ),
          ),
        ),
      ),
    );
  }
}
