class CircularModel {
  final String id, schoolId, title, content, targetType;
  final String? targetClassRoomId, targetClassRoomName;
  final String? targetSectionId, targetSectionName;
  final String publishedById, publishedByName;
  final bool read;
  final String publishedAt;

  const CircularModel({
    required this.id, required this.schoolId, required this.title,
    required this.content, required this.targetType,
    this.targetClassRoomId, this.targetClassRoomName,
    this.targetSectionId, this.targetSectionName,
    required this.publishedById, required this.publishedByName,
    required this.read, required this.publishedAt,
  });

  factory CircularModel.fromJson(Map<String, dynamic> json) => CircularModel(
    id: json['id'] ?? '',
    schoolId: json['schoolId'] ?? '',
    title: json['title'] ?? '',
    content: json['content'] ?? '',
    targetType: json['targetType'] ?? 'ALL',
    targetClassRoomId: json['targetClassRoomId'],
    targetClassRoomName: json['targetClassRoomName'],
    targetSectionId: json['targetSectionId'],
    targetSectionName: json['targetSectionName'],
    publishedById: json['publishedById'] ?? '',
    publishedByName: json['publishedByName'] ?? '',
    read: json['read'] ?? false,
    publishedAt: json['publishedAt'] ?? '',
  );

  CircularModel copyWith({bool? read}) => CircularModel(
    id: id, schoolId: schoolId, title: title, content: content,
    targetType: targetType, targetClassRoomId: targetClassRoomId,
    targetClassRoomName: targetClassRoomName, targetSectionId: targetSectionId,
    targetSectionName: targetSectionName, publishedById: publishedById,
    publishedByName: publishedByName, read: read ?? this.read,
    publishedAt: publishedAt,
  );
}
