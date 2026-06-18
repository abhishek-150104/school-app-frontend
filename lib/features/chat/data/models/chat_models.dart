class ChatChannelModel {
  final String id;
  final String schoolId;
  final String name;
  final String type;
  final List<String> members;
  final List<String> memberNames;
  final String createdByName;

  ChatChannelModel({
    required this.id,
    required this.schoolId,
    required this.name,
    required this.type,
    required this.members,
    required this.memberNames,
    required this.createdByName,
  });

  factory ChatChannelModel.fromJson(Map<String, dynamic> json) {
    return ChatChannelModel(
      id: json['id'] ?? '',
      schoolId: json['schoolId'] ?? '',
      name: json['name'] ?? '',
      type: json['type'] ?? '',
      members: List<String>.from(json['members'] ?? []),
      memberNames: List<String>.from(json['memberNames'] ?? []),
      createdByName: json['createdByName'] ?? '',
    );
  }
}

class ChatMessageModel {
  final String id;
  final String channelId;
  final String senderId;
  final String senderName;
  final String senderRole;
  final String content;
  final String type;
  final String? createdAt;

  ChatMessageModel({
    required this.id,
    required this.channelId,
    required this.senderId,
    required this.senderName,
    required this.senderRole,
    required this.content,
    required this.type,
    this.createdAt,
  });

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    return ChatMessageModel(
      id: json['id'] ?? '',
      channelId: json['channelId'] ?? '',
      senderId: json['senderId'] ?? '',
      senderName: json['senderName'] ?? '',
      senderRole: json['senderRole'] ?? '',
      content: json['content'] ?? '',
      type: json['type'] ?? 'TEXT',
      createdAt: json['createdAt'],
    );
  }
}
