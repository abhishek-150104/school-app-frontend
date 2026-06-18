import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/fee_models.dart';
import '../../data/repositories/fee_repository.dart';

class FeeInvoiceNotifier extends StateNotifier<AsyncValue<List<FeeInvoiceModel>>> {
  final FeeRepository _repo;
  FeeInvoiceNotifier(this._repo) : super(const AsyncValue.loading()) {
    load();
  }

  Future<void> load() async {
    try {
      state = const AsyncValue.loading();
      state = AsyncValue.data(await _repo.getInvoices());
    } catch (e, s) {
      state = AsyncValue.error(e, s);
    }
  }

  Future<void> create(Map<String, dynamic> data) async {
    await _repo.createInvoice(data);
    await load();
  }
}

final feeInvoiceProvider =
    StateNotifierProvider<FeeInvoiceNotifier, AsyncValue<List<FeeInvoiceModel>>>(
        (ref) => FeeInvoiceNotifier(ref.read(feeRepositoryProvider)));

class FeeStructureNotifier extends StateNotifier<AsyncValue<List<FeeStructureModel>>> {
  final FeeRepository _repo;
  FeeStructureNotifier(this._repo) : super(const AsyncValue.loading()) {
    load();
  }

  Future<void> load() async {
    try {
      state = const AsyncValue.loading();
      state = AsyncValue.data(await _repo.getStructures());
    } catch (e, s) {
      state = AsyncValue.error(e, s);
    }
  }

  Future<void> create(Map<String, dynamic> data) async {
    await _repo.createStructure(data);
    await load();
  }
}

final feeStructureProvider =
    StateNotifierProvider<FeeStructureNotifier, AsyncValue<List<FeeStructureModel>>>(
        (ref) => FeeStructureNotifier(ref.read(feeRepositoryProvider)));
