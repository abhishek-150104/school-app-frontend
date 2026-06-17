import '../../../student/data/models/student_models.dart';
import '../../../school/data/models/school_models.dart';

class StaffModel {
  final String id;
  final String schoolId;
  final String schoolName;
  final String userId;
  final String employeeId;
  final String firstName;
  final String lastName;
  final String fullName;
  final String? designation;
  final List<String> subjects;
  final String? qualification;
  final String? joiningDate;
  final String? profilePhotoUrl;
  final AddressModel? address;
  final bool active;
  final String? createdAt;
  final String? updatedAt;

  StaffModel({
    required this.id,
    required this.schoolId,
    required this.schoolName,
    required this.userId,
    required this.employeeId,
    required this.firstName,
    required this.lastName,
    required this.fullName,
    this.designation,
    required this.subjects,
    this.qualification,
    this.joiningDate,
    this.profilePhotoUrl,
    this.address,
    required this.active,
    this.createdAt,
    this.updatedAt,
  });

  factory StaffModel.fromJson(Map<String, dynamic> j) => StaffModel(
        id: j['id'],
        schoolId: j['schoolId'] ?? '',
        schoolName: j['schoolName'] ?? '',
        userId: j['userId'] ?? '',
        employeeId: j['employeeId'] ?? '',
        firstName: j['firstName'] ?? '',
        lastName: j['lastName'] ?? '',
        fullName: j['fullName'] ?? '',
        designation: j['designation'],
        subjects: j['subjects'] != null
            ? List<String>.from(j['subjects'])
            : [],
        qualification: j['qualification'],
        joiningDate: j['joiningDate']?.toString(),
        profilePhotoUrl: j['profilePhotoUrl'],
        address: j['address'] != null
            ? AddressModel.fromJson(j['address'])
            : null,
        active: j['active'] ?? true,
        createdAt: j['createdAt']?.toString(),
        updatedAt: j['updatedAt']?.toString(),
      );
}

class TeacherProfileModel {
  final StaffModel profile;
  final List<SectionModel> assignedSections;

  TeacherProfileModel({required this.profile, required this.assignedSections});

  factory TeacherProfileModel.fromJson(Map<String, dynamic> j) =>
      TeacherProfileModel(
        profile: StaffModel.fromJson(j['profile']),
        assignedSections: (j['assignedSections'] as List)
            .map((e) => SectionModel.fromJson(e))
            .toList(),
      );
}
