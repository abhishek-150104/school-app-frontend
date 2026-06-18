class HomeworkModel {
  final String id;
  final String schoolId;
  final String sectionId;
  final String sectionName;
  final String classRoomId;
  final String classRoomName;
  final String title;
  final String description;
  final String subject;
  final String dueDate; // yyyy-MM-dd string
  final String assignedById;
  final String assignedByName;
  final String? createdAt;
  final String? updatedAt;

  HomeworkModel({
    required this.id,
    required this.schoolId,
    required this.sectionId,
    required this.sectionName,
    required this.classRoomId,
    required this.classRoomName,
    required this.title,
    required this.description,
    required this.subject,
    required this.dueDate,
    required this.assignedById,
    required this.assignedByName,
    this.createdAt,
    this.updatedAt,
  });

  factory HomeworkModel.fromJson(Map<String, dynamic> json) => HomeworkModel(
        id: json['id'] ?? '',
        schoolId: json['schoolId'] ?? '',
        sectionId: json['sectionId'] ?? '',
        sectionName: json['sectionName'] ?? '',
        classRoomId: json['classRoomId'] ?? '',
        classRoomName: json['classRoomName'] ?? '',
        title: json['title'] ?? '',
        description: json['description'] ?? '',
        subject: json['subject'] ?? '',
        dueDate: json['dueDate'] ?? '',
        assignedById: json['assignedById'] ?? '',
        assignedByName: json['assignedByName'] ?? '',
        createdAt: json['createdAt'],
        updatedAt: json['updatedAt'],
      );

  Map<String, dynamic> toJson() => {
        'title': title,
        'description': description,
        'subject': subject,
        'dueDate': dueDate,
      };

  HomeworkModel copyWith({
    String? title,
    String? description,
    String? subject,
    String? dueDate,
  }) =>
      HomeworkModel(
        id: id,
        schoolId: schoolId,
        sectionId: sectionId,
        sectionName: sectionName,
        classRoomId: classRoomId,
        classRoomName: classRoomName,
        title: title ?? this.title,
        description: description ?? this.description,
        subject: subject ?? this.subject,
        dueDate: dueDate ?? this.dueDate,
        assignedById: assignedById,
        assignedByName: assignedByName,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
}

class HomeworkSubmissionModel {
  final String id;
  final String homeworkId;
  final String studentId;
  final String studentFullName;
  final String admissionNumber;
  final String? remarks;
  final String? submittedAt;

  HomeworkSubmissionModel({
    required this.id,
    required this.homeworkId,
    required this.studentId,
    required this.studentFullName,
    required this.admissionNumber,
    this.remarks,
    this.submittedAt,
  });

  factory HomeworkSubmissionModel.fromJson(Map<String, dynamic> json) =>
      HomeworkSubmissionModel(
        id: json['id'] ?? '',
        homeworkId: json['homeworkId'] ?? '',
        studentId: json['studentId'] ?? '',
        studentFullName: json['studentFullName'] ?? '',
        admissionNumber: json['admissionNumber'] ?? '',
        remarks: json['remarks'],
        submittedAt: json['submittedAt'],
      );
}
