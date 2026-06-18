import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/chat_models.dart';
import '../../data/repositories/chat_repository.dart';

final myChannelsProvider = FutureProvider<List<ChatChannelModel>>((ref) {
  return ref.read(chatRepositoryProvider).getMyChannels();
});

final channelMessagesProvider = FutureProvider.family<List<ChatMessageModel>, String>((ref, channelId) {
  return ref.read(chatRepositoryProvider).getChannelMessages(channelId);
});

class ChatMessagesNotifier extends StateNotifier<AsyncValue<List<ChatMessageModel>>> {
  final ChatRepository _repo;
  final String channelId;

  ChatMessagesNotifier(this._repo, this.channelId) : super(const AsyncValue.loading()) {
    _load();
  }

  Future<void> _load() async {
    state = await AsyncValue.guard(() => _repo.getChannelMessages(channelId));
  }

  Future<void> sendMessage(String content) async {
    final msg = await _repo.sendMessage(channelId: channelId, content: content);
    state.whenData((msgs) => state = AsyncValue.data([...msgs, msg]));
  }
}

final chatMessagesNotifierProvider = StateNotifierProvider.family<ChatMessagesNotifier, AsyncValue<List<ChatMessageModel>>, String>((ref, channelId) {
  return ChatMessagesNotifier(ref.read(chatRepositoryProvider), channelId);
});
