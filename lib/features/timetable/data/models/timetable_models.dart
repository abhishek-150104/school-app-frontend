class TimetableEntryModel {
  final String id;
  final String sectionId;
  final String sectionName;
  final String classRoomName;
  final String subjectId;
  final String subjectName;
  final String teacherName;
  final String dayOfWeek;
  final int periodNumber;
  final String startTime;
  final String endTime;

  const TimetableEntryModel({
    required this.id,
    required this.sectionId,
    required this.sectionName,
    required this.classRoomName,
    required this.subjectId,
    required this.subjectName,
    required this.teacherName,
    required this.dayOfWeek,
    required this.periodNumber,
    required this.startTime,
    required this.endTime,
  });

  factory TimetableEntryModel.fromJson(Map<String, dynamic> j) => TimetableEntryModel(
    id: j['id'] ?? '',
    sectionId: j['sectionId'] ?? '',
    sectionName: j['sectionName'] ?? '',
    classRoomName: j['classRoomName'] ?? '',
    subjectId: j['subjectId'] ?? '',
    subjectName: j['subjectName'] ?? '',
    teacherName: j['teacherName'] ?? '',
    dayOfWeek: j['dayOfWeek'] ?? '',
    periodNumber: j['periodNumber'] ?? 0,
    startTime: j['startTime'] ?? '',
    endTime: j['endTime'] ?? '',
  );
}
