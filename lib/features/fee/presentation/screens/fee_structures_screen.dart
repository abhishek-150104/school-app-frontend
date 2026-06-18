import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/fee_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class FeeStructuresScreen extends ConsumerWidget {
  const FeeStructuresScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final structuresAsync = ref.watch(feeStructureProvider);
    final user = ref.watch(authProvider).user;
    final isAdmin = user?.isSuperAdmin == true || user?.isSchoolAdmin == true;

    return Scaffold(
      appBar: AppBar(title: const Text('Fee Structures')),
      floatingActionButton: isAdmin
          ? FloatingActionButton.extended(
              icon: const Icon(Icons.add),
              label: const Text('New Structure'),
              onPressed: () => context.push('/fees/structures/create'),
            )
          : null,
      body: structuresAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (structures) {
          if (structures.isEmpty) {
            return const Center(child: Text('No fee structures yet'));
          }
          return RefreshIndicator(
            onRefresh: () => ref.read(feeStructureProvider.notifier).load(),
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: structures.length,
              itemBuilder: (context, i) {
                final s = structures[i];
                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.account_balance_wallet_outlined, size: 36, color: Colors.indigo),
                    title: Text('${s.classRoomName} — ${s.academicYearName}',
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text('Total: ₹${s.totalFee.toStringAsFixed(0)}'),
                    trailing: const Icon(Icons.chevron_right),
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
