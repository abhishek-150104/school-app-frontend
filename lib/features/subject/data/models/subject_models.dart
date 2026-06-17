class SubjectModel {
  final String id;
  final String schoolId;
  final String classRoomId;
  final String classRoomName;
  final String name;
  final String? code;
  final String createdById;
  final String createdByName;

  SubjectModel({
    required this.id,
    required this.schoolId,
    required this.classRoomId,
    required this.classRoomName,
    required this.name,
    this.code,
    required this.createdById,
    required this.createdByName,
  });

  factory SubjectModel.fromJson(Map<String, dynamic> json) => SubjectModel(
        id: json['id'] ?? '',
        schoolId: json['schoolId'] ?? '',
        classRoomId: json['classRoomId'] ?? '',
        classRoomName: json['classRoomName'] ?? '',
        name: json['name'] ?? '',
        code: json['code'],
        createdById: json['createdById'] ?? '',
        createdByName: json['createdByName'] ?? '',
      );
}
