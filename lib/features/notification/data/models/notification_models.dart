class NotificationModel {
  final String id;
  final String schoolId;
  final String recipientId;
  final String title;
  final String body;
  final String type;
  final String? referenceId;
  final String? referenceType;
  final bool read;
  final String? createdAt;

  NotificationModel({
    required this.id,
    required this.schoolId,
    required this.recipientId,
    required this.title,
    required this.body,
    required this.type,
    this.referenceId,
    this.referenceType,
    required this.read,
    this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] ?? '',
      schoolId: json['schoolId'] ?? '',
      recipientId: json['recipientId'] ?? '',
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      type: json['type'] ?? 'GENERAL',
      referenceId: json['referenceId'],
      referenceType: json['referenceType'],
      read: json['read'] ?? false,
      createdAt: json['createdAt'],
    );
  }
}
