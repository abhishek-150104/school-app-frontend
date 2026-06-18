import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/library_models.dart';

class LibraryRepository {
  final DioClient _dio;
  LibraryRepository(this._dio);

  Future<List<LibraryBookModel>> getBooks() async {
    final res = await _dio.get(ApiConstants.libraryBooks);
    final data = res.data['data'] as List;
    return data.map((e) => LibraryBookModel.fromJson(e)).toList();
  }

  Future<List<LibraryIssueModel>> getActiveIssues() async {
    final res = await _dio.get(ApiConstants.activeIssues);
    final data = res.data['data'] as List;
    return data.map((e) => LibraryIssueModel.fromJson(e)).toList();
  }

  Future<List<LibraryIssueModel>> getMemberIssues(String memberId) async {
    final res = await _dio.get(ApiConstants.memberIssues(memberId));
    final data = res.data['data'] as List;
    return data.map((e) => LibraryIssueModel.fromJson(e)).toList();
  }

  Future<LibraryIssueModel> issueBook({
    required String bookId,
    required String memberId,
    required String memberRole,
    required String dueDate,
  }) async {
    final res = await _dio.post(ApiConstants.libraryIssues, data: {
      'bookId': bookId,
      'memberId': memberId,
      'memberRole': memberRole,
      'dueDate': dueDate,
    });
    return LibraryIssueModel.fromJson(res.data['data']);
  }

  Future<LibraryIssueModel> returnBook(String issueId) async {
    final res = await _dio.post(ApiConstants.returnBook(issueId));
    return LibraryIssueModel.fromJson(res.data['data']);
  }
}

final libraryRepositoryProvider = Provider((ref) {
  return LibraryRepository(ref.read(dioClientProvider));
});
