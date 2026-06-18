import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/notification_models.dart';
import '../../data/repositories/notification_repository.dart';

final notificationsProvider = FutureProvider<List<NotificationModel>>((ref) {
  return ref.read(notificationRepositoryProvider).getMyNotifications();
});

final unreadCountProvider = FutureProvider<int>((ref) {
  return ref.read(notificationRepositoryProvider).getUnreadCount();
});

class NotificationsNotifier extends StateNotifier<AsyncValue<List<NotificationModel>>> {
  final NotificationRepository _repo;
  NotificationsNotifier(this._repo) : super(const AsyncValue.loading()) {
    _load();
  }

  Future<void> _load() async {
    state = await AsyncValue.guard(() => _repo.getMyNotifications());
  }

  Future<void> markAsRead(String notificationId) async {
    await _repo.markAsRead(notificationId);
    state.whenData((list) => state = AsyncValue.data(
      list.map((n) => n.id == notificationId
          ? NotificationModel(
              id: n.id, schoolId: n.schoolId, recipientId: n.recipientId,
              title: n.title, body: n.body, type: n.type,
              referenceId: n.referenceId, referenceType: n.referenceType,
              read: true, createdAt: n.createdAt)
          : n).toList(),
    ));
  }

  Future<void> markAllAsRead() async {
    await _repo.markAllAsRead();
    await _load();
  }
}

final notificationsNotifierProvider =
    StateNotifierProvider<NotificationsNotifier, AsyncValue<List<NotificationModel>>>((ref) {
  return NotificationsNotifier(ref.read(notificationRepositoryProvider));
});
