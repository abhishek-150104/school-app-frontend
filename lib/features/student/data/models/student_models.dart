class AddressModel {
  final String? street;
  final String? city;
  final String? state;
  final String? pincode;

  AddressModel({this.street, this.city, this.state, this.pincode});

  factory AddressModel.fromJson(Map<String, dynamic> j) => AddressModel(
        street: j['street'],
        city: j['city'],
        state: j['state'],
        pincode: j['pincode'],
      );

  Map<String, dynamic> toJson() => {
        if (street != null) 'street': street,
        if (city != null) 'city': city,
        if (state != null) 'state': state,
        if (pincode != null) 'pincode': pincode,
      };
}

class StudentModel {
  final String id;
  final String schoolId;
  final String schoolName;
  final String academicYearId;
  final String academicYearLabel;
  final String classRoomId;
  final String classRoomName;
  final String sectionId;
  final String sectionName;
  final String admissionNumber;
  final int rollNumber;
  final String? admissionDate;
  final String firstName;
  final String lastName;
  final String fullName;
  final String? dateOfBirth;
  final String gender;
  final String? bloodGroup;
  final String? religion;
  final String? category;
  final String? profilePhotoUrl;
  final AddressModel? address;
  final String? parentId;
  final String? parentName;
  final String? parentPhone;
  final bool active;
  final String? createdAt;
  final String? updatedAt;

  StudentModel({
    required this.id,
    required this.schoolId,
    required this.schoolName,
    required this.academicYearId,
    required this.academicYearLabel,
    required this.classRoomId,
    required this.classRoomName,
    required this.sectionId,
    required this.sectionName,
    required this.admissionNumber,
    required this.rollNumber,
    this.admissionDate,
    required this.firstName,
    required this.lastName,
    required this.fullName,
    this.dateOfBirth,
    required this.gender,
    this.bloodGroup,
    this.religion,
    this.category,
    this.profilePhotoUrl,
    this.address,
    this.parentId,
    this.parentName,
    this.parentPhone,
    required this.active,
    this.createdAt,
    this.updatedAt,
  });

  factory StudentModel.fromJson(Map<String, dynamic> j) => StudentModel(
        id: j['id'],
        schoolId: j['schoolId'] ?? '',
        schoolName: j['schoolName'] ?? '',
        academicYearId: j['academicYearId'] ?? '',
        academicYearLabel: j['academicYearLabel'] ?? '',
        classRoomId: j['classRoomId'] ?? '',
        classRoomName: j['classRoomName'] ?? '',
        sectionId: j['sectionId'] ?? '',
        sectionName: j['sectionName'] ?? '',
        admissionNumber: j['admissionNumber'] ?? '',
        rollNumber: j['rollNumber'] ?? 0,
        admissionDate: j['admissionDate']?.toString(),
        firstName: j['firstName'] ?? '',
        lastName: j['lastName'] ?? '',
        fullName: j['fullName'] ?? '',
        dateOfBirth: j['dateOfBirth']?.toString(),
        gender: j['gender'] ?? 'MALE',
        bloodGroup: j['bloodGroup'],
        religion: j['religion'],
        category: j['category'],
        profilePhotoUrl: j['profilePhotoUrl'],
        address:
            j['address'] != null ? AddressModel.fromJson(j['address']) : null,
        parentId: j['parentId'],
        parentName: j['parentName'],
        parentPhone: j['parentPhone'],
        active: j['active'] ?? true,
        createdAt: j['createdAt']?.toString(),
        updatedAt: j['updatedAt']?.toString(),
      );

  String get displayGender =>
      gender == 'MALE' ? 'Male' : gender == 'FEMALE' ? 'Female' : 'Other';

  String get classSectionDisplay => '$classRoomName - $sectionName';

  bool get hasParent => parentId != null && parentId!.isNotEmpty;
}
