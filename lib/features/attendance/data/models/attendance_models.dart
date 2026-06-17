class AttendanceModel {
  final String id;
  final String schoolId;
  final String classRoomId;
  final String classRoomName;
  final String sectionId;
  final String sectionName;
  final String date;
  final String studentId;
  final String studentFullName;
  final String admissionNumber;
  final AttendanceStatus status;
  final String? markedById;
  final String? markedByName;
  final String? remarks;

  const AttendanceModel({
    required this.id,
    required this.schoolId,
    required this.classRoomId,
    required this.classRoomName,
    required this.sectionId,
    required this.sectionName,
    required this.date,
    required this.studentId,
    required this.studentFullName,
    required this.admissionNumber,
    required this.status,
    this.markedById,
    this.markedByName,
    this.remarks,
  });

  factory AttendanceModel.fromJson(Map<String, dynamic> json) {
    return AttendanceModel(
      id: json['id'] as String,
      schoolId: json['schoolId'] as String,
      classRoomId: json['classRoomId'] as String,
      classRoomName: json['classRoomName'] as String,
      sectionId: json['sectionId'] as String,
      sectionName: json['sectionName'] as String,
      date: json['date'] as String,
      studentId: json['studentId'] as String,
      studentFullName: json['studentFullName'] as String,
      admissionNumber: json['admissionNumber'] as String,
      status: AttendanceStatus.fromString(json['status'] as String),
      markedById: json['markedById'] as String?,
      markedByName: json['markedByName'] as String?,
      remarks: json['remarks'] as String?,
    );
  }
}

enum AttendanceStatus {
  present,
  absent,
  late,
  excused;

  static AttendanceStatus fromString(String value) {
    return AttendanceStatus.values.firstWhere(
      (e) => e.name.toUpperCase() == value.toUpperCase(),
      orElse: () => AttendanceStatus.absent,
    );
  }

  String get displayName {
    switch (this) {
      case AttendanceStatus.present:
        return 'Present';
      case AttendanceStatus.absent:
        return 'Absent';
      case AttendanceStatus.late:
        return 'Late';
      case AttendanceStatus.excused:
        return 'Excused';
    }
  }

  String get apiValue => name.toUpperCase();
}

class AttendanceEntry {
  final String studentId;
  AttendanceStatus status;
  String? remarks;

  AttendanceEntry({
    required this.studentId,
    this.status = AttendanceStatus.present,
    this.remarks,
  });

  Map<String, dynamic> toJson() => {
        'studentId': studentId,
        'status': status.apiValue,
        if (remarks != null) 'remarks': remarks,
      };
}

class StudentAttendanceStat {
  final String studentId;
  final String fullName;
  final String admissionNumber;
  final int present;
  final int absent;
  final int late;
  final int excused;
  final double percentage;

  const StudentAttendanceStat({
    required this.studentId,
    required this.fullName,
    required this.admissionNumber,
    required this.present,
    required this.absent,
    required this.late,
    required this.excused,
    required this.percentage,
  });

  factory StudentAttendanceStat.fromJson(Map<String, dynamic> json) {
    return StudentAttendanceStat(
      studentId: json['studentId'] as String,
      fullName: json['fullName'] as String,
      admissionNumber: json['admissionNumber'] as String,
      present: json['present'] as int,
      absent: json['absent'] as int,
      late: json['late'] as int,
      excused: json['excused'] as int,
      percentage: (json['percentage'] as num).toDouble(),
    );
  }

  int get total => present + absent + late + excused;
}

class AttendanceSummaryModel {
  final String sectionId;
  final String sectionName;
  final String classRoomName;
  final String from;
  final String to;
  final int totalDays;
  final List<StudentAttendanceStat> students;

  const AttendanceSummaryModel({
    required this.sectionId,
    required this.sectionName,
    required this.classRoomName,
    required this.from,
    required this.to,
    required this.totalDays,
    required this.students,
  });

  factory AttendanceSummaryModel.fromJson(Map<String, dynamic> json) {
    return AttendanceSummaryModel(
      sectionId: json['sectionId'] as String,
      sectionName: json['sectionName'] as String,
      classRoomName: json['classRoomName'] as String,
      from: json['from'] as String,
      to: json['to'] as String,
      totalDays: json['totalDays'] as int,
      students: (json['students'] as List)
          .map((e) => StudentAttendanceStat.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
