class ApiConstants {
  // Change to your machine's IP when testing on a physical device
  // Android emulator: 10.0.2.2 maps to host localhost
  static const String baseUrl = 'http://localhost:8080';

  // Auth
  static const String login = '/api/auth/login';
  static const String register = '/api/auth/register';
  static const String sendOtp = '/api/auth/otp/send';
  static const String verifyOtp = '/api/auth/otp/verify';
  static const String forgotPassword = '/api/auth/forgot-password';
  static const String resetPassword = '/api/auth/reset-password';
  static const String refreshToken = '/api/auth/refresh-token';
  static const String logout = '/api/auth/logout';
  static const String setupAccount = '/api/auth/setup-account';
  static const String profile = '/api/users/profile';

  // School (single)
  static const String school = '/api/school';

  // Admins
  static const String admins = '/api/admins';
  static String adminDisable(String userId) => '/api/admins/$userId/disable';

  // Academic Years
  static const String academicYears = '/api/academic-years';
  static String academicYear(String yearId) => '/api/academic-years/$yearId';
  static String activateYear(String yearId) =>
      '/api/academic-years/$yearId/activate';

  // Classrooms
  static const String classrooms = '/api/classrooms';
  static String classroom(String classId) => '/api/classrooms/$classId';

  // Sections
  static String sections(String classId) =>
      '/api/classrooms/$classId/sections';
  static String section(String classId, String sectionId) =>
      '/api/classrooms/$classId/sections/$sectionId';
  static String assignTeacher(String classId, String sectionId) =>
      '/api/classrooms/$classId/sections/$sectionId/assign-teacher';

  // Staff
  static const String staff = '/api/staff';
  static String staffMember(String staffId) => '/api/staff/$staffId';
  static const String staffSearch = '/api/staff/search';
  static const String teacherMyProfile = '/api/teacher/me/profile';

  // Students
  static const String students = '/api/students';
  static String student(String studentId) => '/api/students/$studentId';
  static const String studentSearch = '/api/students/search';
  static String linkParent(String studentId) =>
      '/api/students/$studentId/link-parent';
  static String transferStudent(String studentId) =>
      '/api/students/$studentId/transfer';
  static const String myChildren = '/api/parents/me/students';

  // Subjects
  static String subjects(String classId) =>
      '/api/classrooms/$classId/subjects';
  static String subject(String classId, String subjectId) =>
      '/api/classrooms/$classId/subjects/$subjectId';

  // Homework
  static String sectionHomework(String sectionId) => '/api/sections/$sectionId/homework';
  static String homework(String homeworkId) => '/api/homework/$homeworkId';
  static String homeworkSubmissions(String homeworkId) => '/api/homework/$homeworkId/submissions';
  static String myChildHomework(String studentId) => '/api/parents/me/students/$studentId/homework';

  // Fees
  static const String feeStructures = '/api/fees/structures';
  static const String feeInvoices = '/api/fees/invoices';
  static String studentFeeInvoices(String studentId) => '/api/fees/invoices/student/$studentId';
  static const String feePayments = '/api/fees/payments';
  static String invoicePayments(String invoiceId) => '/api/fees/invoices/$invoiceId/payments';

  // Circulars
  static const String circulars = '/api/circulars';
  static String circular(String id) => '/api/circulars/$id';
  static String markCircularRead(String id) => '/api/circulars/$id/read';
  static const String circularUnreadCount = '/api/circulars/unread-count';

  // Attendance
  static String sectionAttendance(String sectionId) =>
      '/api/sections/$sectionId/attendance';
  static String attendanceSummary(String sectionId) =>
      '/api/sections/$sectionId/attendance/summary';
  static String studentAttendance(String studentId) =>
      '/api/students/$studentId/attendance';
  static String attendanceRecord(String attendanceId) =>
      '/api/attendance/$attendanceId';
  static String myChildAttendance(String studentId) =>
      '/api/parents/me/students/$studentId/attendance';
}

class StorageKeys {
  static const String accessToken = 'access_token';
  static const String refreshToken = 'refresh_token';
  static const String userId = 'user_id';
  static const String userRole = 'user_role';
  static const String userEmail = 'user_email';
  static const String userFullName = 'user_full_name';
}
