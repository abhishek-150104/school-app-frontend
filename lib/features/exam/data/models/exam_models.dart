class ExamModel {
  final String id;
  final String classRoomId;
  final String classRoomName;
  final String academicYearName;
  final String title;
  final String? description;
  final String startDate;
  final String endDate;
  final String status;

  const ExamModel({
    required this.id,
    required this.classRoomId,
    required this.classRoomName,
    required this.academicYearName,
    required this.title,
    this.description,
    required this.startDate,
    required this.endDate,
    required this.status,
  });

  factory ExamModel.fromJson(Map<String, dynamic> j) => ExamModel(
    id: j['id'] ?? '',
    classRoomId: j['classRoomId'] ?? '',
    classRoomName: j['classRoomName'] ?? '',
    academicYearName: j['academicYearName'] ?? '',
    title: j['title'] ?? '',
    description: j['description'],
    startDate: j['startDate']?.toString() ?? '',
    endDate: j['endDate']?.toString() ?? '',
    status: j['status'] ?? 'UPCOMING',
  );
}

class ExamResultModel {
  final String id;
  final String examTitle;
  final String studentFullName;
  final String subjectName;
  final double marksObtained;
  final double maxMarks;
  final double percentage;
  final String grade;

  const ExamResultModel({
    required this.id,
    required this.examTitle,
    required this.studentFullName,
    required this.subjectName,
    required this.marksObtained,
    required this.maxMarks,
    required this.percentage,
    required this.grade,
  });

  factory ExamResultModel.fromJson(Map<String, dynamic> j) => ExamResultModel(
    id: j['id'] ?? '',
    examTitle: j['examTitle'] ?? '',
    studentFullName: j['studentFullName'] ?? '',
    subjectName: j['subjectName'] ?? '',
    marksObtained: (j['marksObtained'] ?? 0).toDouble(),
    maxMarks: (j['maxMarks'] ?? 0).toDouble(),
    percentage: (j['percentage'] ?? 0).toDouble(),
    grade: j['grade'] ?? '',
  );
}
