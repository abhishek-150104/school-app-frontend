import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/fee_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class FeeInvoicesScreen extends ConsumerWidget {
  const FeeInvoicesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final invoicesAsync = ref.watch(feeInvoiceProvider);
    final user = ref.watch(authProvider).user;
    final isAdmin = user?.isSuperAdmin == true || user?.isSchoolAdmin == true;

    return Scaffold(
      appBar: AppBar(title: const Text('Fee Invoices')),
      floatingActionButton: isAdmin
          ? FloatingActionButton.extended(
              icon: const Icon(Icons.add),
              label: const Text('New Invoice'),
              onPressed: () => context.push('/fees/invoices/create'),
            )
          : null,
      body: invoicesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (invoices) {
          if (invoices.isEmpty) {
            return const Center(child: Text('No invoices yet'));
          }
          return RefreshIndicator(
            onRefresh: () => ref.read(feeInvoiceProvider.notifier).load(),
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: invoices.length,
              itemBuilder: (context, i) {
                final inv = invoices[i];
                final color = inv.status == 'PAID'
                    ? Colors.green
                    : inv.status == 'PARTIAL'
                        ? Colors.orange
                        : Colors.red;
                return Card(
                  child: ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: color.withAlpha(30),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.receipt_long_outlined, color: color),
                    ),
                    title: Text(inv.studentFullName,
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text(
                        '${inv.classRoomName} • ${inv.academicYearName}',
                        style: const TextStyle(fontSize: 12)),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('₹${inv.dueAmount.toStringAsFixed(0)} due',
                            style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: color.withAlpha(30),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: color),
                          ),
                          child: Text(inv.status, style: TextStyle(color: color, fontSize: 10)),
                        ),
                      ],
                    ),
                    onTap: () => context.push('/fees/invoices/${inv.id}', extra: inv),
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
