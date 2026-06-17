class ApiConstants {
  // Change to your machine's IP when testing on a physical device
  // Android emulator: 10.0.2.2 maps to host localhost
  static const String baseUrl = 'http://10.0.2.2:8080';

  // Auth
  static const String login = '/api/auth/login';
  static const String register = '/api/auth/register';
  static const String sendOtp = '/api/auth/otp/send';
  static const String verifyOtp = '/api/auth/otp/verify';
  static const String forgotPassword = '/api/auth/forgot-password';
  static const String resetPassword = '/api/auth/reset-password';
  static const String refreshToken = '/api/auth/refresh-token';
  static const String logout = '/api/auth/logout';
  static const String profile = '/api/users/profile';

  // Schools
  static const String schools = '/api/schools';
  static String school(String id) => '/api/schools/$id';

  // Academic Years
  static String academicYears(String schoolId) =>
      '/api/schools/$schoolId/academic-years';
  static String academicYear(String schoolId, String yearId) =>
      '/api/schools/$schoolId/academic-years/$yearId';
  static String activateYear(String schoolId, String yearId) =>
      '/api/schools/$schoolId/academic-years/$yearId/activate';

  // Classrooms
  static String classrooms(String schoolId) =>
      '/api/schools/$schoolId/classrooms';
  static String classroom(String schoolId, String classId) =>
      '/api/schools/$schoolId/classrooms/$classId';

  // Sections
  static String sections(String schoolId, String classId) =>
      '/api/schools/$schoolId/classrooms/$classId/sections';
  static String section(String schoolId, String classId, String sectionId) =>
      '/api/schools/$schoolId/classrooms/$classId/sections/$sectionId';
  static String assignTeacher(String schoolId, String classId, String sectionId) =>
      '/api/schools/$schoolId/classrooms/$classId/sections/$sectionId/assign-teacher';

  // Staff
  static String staff(String schoolId) => '/api/schools/$schoolId/staff';
  static String staffMember(String schoolId, String staffId) =>
      '/api/schools/$schoolId/staff/$staffId';
  static String staffSearch(String schoolId) =>
      '/api/schools/$schoolId/staff/search';
  static const String teacherMyProfile = '/api/teacher/me/profile';

  // Students
  static String students(String schoolId) =>
      '/api/schools/$schoolId/students';
  static String student(String schoolId, String studentId) =>
      '/api/schools/$schoolId/students/$studentId';
  static String studentSearch(String schoolId) =>
      '/api/schools/$schoolId/students/search';
  static String linkParent(String schoolId, String studentId) =>
      '/api/schools/$schoolId/students/$studentId/link-parent';
  static String transferStudent(String schoolId, String studentId) =>
      '/api/schools/$schoolId/students/$studentId/transfer';
  static const String myChildren = '/api/parents/me/students';
}

class StorageKeys {
  static const String accessToken = 'access_token';
  static const String refreshToken = 'refresh_token';
  static const String userId = 'user_id';
  static const String userRole = 'user_role';
  static const String userEmail = 'user_email';
  static const String userFullName = 'user_full_name';
}
