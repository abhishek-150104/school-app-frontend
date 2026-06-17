class AuthResponse {
  final String accessToken;
  final String refreshToken;
  final bool firstLogin;
  final UserProfile user;

  AuthResponse({
    required this.accessToken,
    required this.refreshToken,
    this.firstLogin = false,
    required this.user,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) => AuthResponse(
        accessToken: json['accessToken'],
        refreshToken: json['refreshToken'],
        firstLogin: json['firstLogin'] ?? false,
        user: UserProfile(
          id: json['userId'] ?? '',
          fullName: json['fullName'] ?? '',
          role: (json['role'] ?? '').toString(),
          enabled: true,
        ),
      );
}

class UserProfile {
  final String id;
  final String fullName;
  final String? email;
  final String? phone;
  final String role;
  final bool enabled;
  final String? profilePhotoUrl;

  UserProfile({
    required this.id,
    required this.fullName,
    this.email,
    this.phone,
    required this.role,
    required this.enabled,
    this.profilePhotoUrl,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
        id: json['id'],
        fullName: json['fullName'],
        email: json['email'],
        phone: json['phone'],
        role: json['role'],
        enabled: json['enabled'] ?? true,
        profilePhotoUrl: json['profilePhotoUrl'],
      );

  String get displayIdentifier => email ?? phone ?? '';

  bool get isSuperAdmin => role == 'SUPER_ADMIN';
  bool get isSchoolAdmin => role == 'SCHOOL_ADMIN';
  bool get isTeacher => role == 'TEACHER';
  bool get isParent => role == 'PARENT';
  bool get isStudent => role == 'STUDENT';
}

class LoginRequest {
  final String identifier; // email or phone
  final String password;

  LoginRequest({required this.identifier, required this.password});

  Map<String, dynamic> toJson() => {
        'username': identifier,
        'password': password,
      };
}

class RegisterRequest {
  final String fullName;
  final String? email;
  final String? phone;
  final String password;

  RegisterRequest({
    required this.fullName,
    this.email,
    this.phone,
    required this.password,
  });

  Map<String, dynamic> toJson() => {
        'fullName': fullName,
        if (email != null) 'email': email,
        if (phone != null) 'phone': phone,
        'password': password,
        'role': 'PARENT',
      };
}
