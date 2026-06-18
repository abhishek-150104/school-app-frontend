import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/chat_models.dart';

class ChatRepository {
  final DioClient _dio;
  ChatRepository(this._dio);

  Future<List<ChatChannelModel>> getMyChannels() async {
    final res = await _dio.get(ApiConstants.chatChannels);
    final data = res.data['data'] as List;
    return data.map((e) => ChatChannelModel.fromJson(e)).toList();
  }

  Future<List<ChatMessageModel>> getChannelMessages(String channelId) async {
    final res = await _dio.get(ApiConstants.channelMessages(channelId));
    final data = res.data['data'] as List;
    return data.map((e) => ChatMessageModel.fromJson(e)).toList();
  }

  Future<ChatMessageModel> sendMessage({
    required String channelId,
    required String content,
  }) async {
    final res = await _dio.post(ApiConstants.chatMessages, data: {
      'channelId': channelId,
      'content': content,
      'type': 'TEXT',
    });
    return ChatMessageModel.fromJson(res.data['data']);
  }

  Future<ChatChannelModel> createChannel({
    required String name,
    required String type,
    required List<String> memberIds,
    required List<String> memberNames,
  }) async {
    final res = await _dio.post(ApiConstants.chatChannels, data: {
      'name': name,
      'type': type,
      'memberIds': memberIds,
      'memberNames': memberNames,
    });
    return ChatChannelModel.fromJson(res.data['data']);
  }
}

final chatRepositoryProvider = Provider((ref) {
  return ChatRepository(ref.read(dioClientProvider));
});
