import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/fee_models.dart';

class FeeRepository {
  final DioClient _dio;
  FeeRepository(this._dio);

  Future<List<FeeStructureModel>> getStructures() async {
    final res = await _dio.get(ApiConstants.feeStructures);
    return (res.data['data'] as List).map((e) => FeeStructureModel.fromJson(e)).toList();
  }

  Future<FeeStructureModel> createStructure(Map<String, dynamic> data) async {
    final res = await _dio.post(ApiConstants.feeStructures, data: data);
    return FeeStructureModel.fromJson(res.data['data']);
  }

  Future<List<FeeInvoiceModel>> getInvoices() async {
    final res = await _dio.get(ApiConstants.feeInvoices);
    return (res.data['data'] as List).map((e) => FeeInvoiceModel.fromJson(e)).toList();
  }

  Future<List<FeeInvoiceModel>> getStudentInvoices(String studentId) async {
    final res = await _dio.get(ApiConstants.studentFeeInvoices(studentId));
    return (res.data['data'] as List).map((e) => FeeInvoiceModel.fromJson(e)).toList();
  }

  Future<FeeInvoiceModel> createInvoice(Map<String, dynamic> data) async {
    final res = await _dio.post(ApiConstants.feeInvoices, data: data);
    return FeeInvoiceModel.fromJson(res.data['data']);
  }

  Future<FeePaymentModel> recordPayment(Map<String, dynamic> data) async {
    final res = await _dio.post(ApiConstants.feePayments, data: data);
    return FeePaymentModel.fromJson(res.data['data']);
  }

  Future<List<FeePaymentModel>> getInvoicePayments(String invoiceId) async {
    final res = await _dio.get(ApiConstants.invoicePayments(invoiceId));
    return (res.data['data'] as List).map((e) => FeePaymentModel.fromJson(e)).toList();
  }
}

final feeRepositoryProvider = Provider<FeeRepository>(
    (ref) => FeeRepository(ref.read(dioClientProvider)));
