import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/fee_provider.dart';
import '../../data/models/fee_models.dart';
import '../../data/repositories/fee_repository.dart';

class FeeInvoiceDetailScreen extends ConsumerStatefulWidget {
  final FeeInvoiceModel invoice;
  const FeeInvoiceDetailScreen({super.key, required this.invoice});

  @override
  ConsumerState<FeeInvoiceDetailScreen> createState() => _FeeInvoiceDetailScreenState();
}

class _FeeInvoiceDetailScreenState extends ConsumerState<FeeInvoiceDetailScreen> {
  final _amountCtrl = TextEditingController();
  String _paymentMode = 'CASH';
  final _txnCtrl = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _amountCtrl.dispose();
    _txnCtrl.dispose();
    super.dispose();
  }

  Future<void> _recordPayment() async {
    if (_amountCtrl.text.isEmpty) return;
    setState(() => _loading = true);
    try {
      final repo = ref.read(feeRepositoryProvider);
      await repo.recordPayment({
        'invoiceId': widget.invoice.id,
        'amount': double.parse(_amountCtrl.text),
        'paymentMode': _paymentMode,
        if (_txnCtrl.text.isNotEmpty) 'transactionId': _txnCtrl.text,
      });
      if (mounted) {
        ref.read(feeInvoiceProvider.notifier).load();
        context.pop();
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final inv = widget.invoice;
    final statusColor = inv.status == 'PAID'
        ? Colors.green
        : inv.status == 'PARTIAL' ? Colors.orange : Colors.red;

    return Scaffold(
      appBar: AppBar(title: Text(inv.studentFullName, overflow: TextOverflow.ellipsis)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _infoRow('Student', inv.studentFullName),
          _infoRow('Admission No', inv.admissionNumber),
          _infoRow('Class', '${inv.classRoomName} - ${inv.sectionName}'),
          _infoRow('Academic Year', inv.academicYearName),
          if (inv.dueDate != null) _infoRow('Due Date', inv.dueDate!),
          const Divider(height: 24),
          _amountRow('Total', inv.totalAmount, Colors.black87),
          _amountRow('Paid', inv.paidAmount, Colors.green),
          _amountRow('Due', inv.dueAmount, statusColor),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withAlpha(30),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: statusColor),
            ),
            child: Text(inv.status, style: TextStyle(color: statusColor, fontWeight: FontWeight.bold)),
          ),
          if (inv.status != 'PAID') ...[
            const SizedBox(height: 24),
            Text('Record Payment', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            TextFormField(
              controller: _amountCtrl,
              decoration: const InputDecoration(labelText: 'Amount', prefixText: '₹ '),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _paymentMode,
              decoration: const InputDecoration(labelText: 'Payment Mode'),
              items: ['CASH', 'ONLINE', 'CHEQUE', 'DD']
                  .map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
              onChanged: (v) => setState(() => _paymentMode = v!),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _txnCtrl,
              decoration: const InputDecoration(labelText: 'Transaction ID (optional)'),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : _recordPayment,
                child: _loading ? const CircularProgressIndicator() : const Text('Record Payment'),
              ),
            ),
          ],
        ]),
      ),
    );
  }

  Widget _infoRow(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            SizedBox(width: 120, child: Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13))),
            Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w500))),
          ],
        ),
      );

  Widget _amountRow(String label, double amount, Color color) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label),
            Text('₹${amount.toStringAsFixed(2)}', style: TextStyle(color: color, fontWeight: FontWeight.bold)),
          ],
        ),
      );
}
