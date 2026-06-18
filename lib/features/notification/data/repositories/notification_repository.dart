import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/notification_models.dart';

class NotificationRepository {
  final DioClient _dio;
  NotificationRepository(this._dio);

  Future<List<NotificationModel>> getMyNotifications() async {
    final res = await _dio.get(ApiConstants.notifications);
    final data = res.data['data'] as List;
    return data.map((e) => NotificationModel.fromJson(e)).toList();
  }

  Future<int> getUnreadCount() async {
    final res = await _dio.get(ApiConstants.notificationUnreadCount);
    return res.data['data']['count'] as int;
  }

  Future<NotificationModel> markAsRead(String notificationId) async {
    final res = await _dio.patch(ApiConstants.markNotificationRead(notificationId));
    return NotificationModel.fromJson(res.data['data']);
  }

  Future<void> markAllAsRead() async {
    await _dio.patch(ApiConstants.markAllNotificationsRead);
  }
}

final notificationRepositoryProvider = Provider((ref) {
  return NotificationRepository(ref.read(dioClientProvider));
});
