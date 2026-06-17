class SchoolModel {
  final String id;
  final String name;
  final String? email;
  final String? phone;
  final String? address;
  final String? city;
  final String? state;
  final String? pincode;
  final String? affiliationNumber;
  final bool active;
  final String? createdAt;

  SchoolModel({
    required this.id,
    required this.name,
    this.email,
    this.phone,
    this.address,
    this.city,
    this.state,
    this.pincode,
    this.affiliationNumber,
    required this.active,
    this.createdAt,
  });

  factory SchoolModel.fromJson(Map<String, dynamic> j) => SchoolModel(
        id: j['id'],
        name: j['name'],
        email: j['email'],
        phone: j['phone'],
        address: j['address'],
        city: j['city'],
        state: j['state'],
        pincode: j['pincode'],
        affiliationNumber: j['affiliationNumber'],
        active: j['active'] ?? true,
        createdAt: j['createdAt'],
      );
}

class AcademicYearModel {
  final String id;
  final String schoolId;
  final String label;
  final int startYear;
  final int endYear;
  final bool active;

  AcademicYearModel({
    required this.id,
    required this.schoolId,
    required this.label,
    required this.startYear,
    required this.endYear,
    required this.active,
  });

  factory AcademicYearModel.fromJson(Map<String, dynamic> j) =>
      AcademicYearModel(
        id: j['id'],
        schoolId: j['schoolId'],
        label: j['label'],
        startYear: j['startYear'],
        endYear: j['endYear'],
        active: j['active'] ?? false,
      );
}

class ClassRoomModel {
  final String id;
  final String schoolId;
  final String academicYearId;
  final String academicYearLabel;
  final String name;
  final int? displayOrder;

  ClassRoomModel({
    required this.id,
    required this.schoolId,
    required this.academicYearId,
    required this.academicYearLabel,
    required this.name,
    this.displayOrder,
  });

  factory ClassRoomModel.fromJson(Map<String, dynamic> j) => ClassRoomModel(
        id: j['id'],
        schoolId: j['schoolId'],
        academicYearId: j['academicYearId'],
        academicYearLabel: j['academicYearLabel'] ?? '',
        name: j['name'],
        displayOrder: j['displayOrder'],
      );
}

class SectionModel {
  final String id;
  final String classRoomId;
  final String classRoomName;
  final String name;
  final int capacity;
  final String? classTeacherId;
  final String? classTeacherName;

  SectionModel({
    required this.id,
    required this.classRoomId,
    required this.classRoomName,
    required this.name,
    required this.capacity,
    this.classTeacherId,
    this.classTeacherName,
  });

  factory SectionModel.fromJson(Map<String, dynamic> j) => SectionModel(
        id: j['id'],
        classRoomId: j['classRoomId'],
        classRoomName: j['classRoomName'] ?? '',
        name: j['name'],
        capacity: j['capacity'] ?? 0,
        classTeacherId: j['classTeacherId'],
        classTeacherName: j['classTeacherName'],
      );
}
