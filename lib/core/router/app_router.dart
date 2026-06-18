import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/auth/presentation/screens/reset_password_screen.dart';
import '../../features/auth/presentation/screens/profile_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/school/presentation/screens/academic_years_screen.dart';
import '../../features/school/presentation/screens/classrooms_screen.dart';
import '../../features/school/presentation/screens/sections_screen.dart';
import '../../features/student/presentation/screens/students_screen.dart';
import '../../features/student/presentation/screens/student_detail_screen.dart';
import '../../features/student/presentation/screens/enroll_student_screen.dart';
import '../../features/student/presentation/screens/my_children_screen.dart';
import '../../features/student/data/models/student_models.dart';
import '../../features/staff/presentation/screens/staff_screen.dart';
import '../../features/staff/presentation/screens/staff_detail_screen.dart';
import '../../features/staff/presentation/screens/create_staff_screen.dart';
import '../../features/staff/presentation/screens/teacher_profile_screen.dart';
import '../../features/staff/data/models/staff_models.dart';
import '../../features/attendance/presentation/screens/mark_attendance_screen.dart';
import '../../features/attendance/presentation/screens/attendance_report_screen.dart';
import '../../features/attendance/presentation/screens/student_attendance_screen.dart';
import '../../features/auth/presentation/screens/account_setup_screen.dart';
import '../../features/subject/presentation/screens/subjects_screen.dart';
import '../../features/school/presentation/screens/schools_screen.dart';
import '../../features/homework/presentation/screens/homework_screen.dart';
import '../../features/homework/presentation/screens/create_homework_screen.dart';
import '../../features/homework/presentation/screens/homework_detail_screen.dart';
import '../../features/homework/presentation/screens/my_child_homework_screen.dart';
import '../../features/homework/data/models/homework_models.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: _AuthChangeNotifier(ref),
    redirect: (context, state) {
      final authState = ref.read(authProvider);

      if (!authState.isInitialized) return '/splash';

      final isLoggedIn = authState.isAuthenticated;
      final isAuthRoute = state.matchedLocation.startsWith('/auth') ||
          state.matchedLocation == '/splash';

      if (!isLoggedIn && !isAuthRoute) return '/auth/login';
      if (isLoggedIn &&
          authState.firstLogin &&
          state.matchedLocation != '/auth/setup-account') {
        return '/auth/setup-account';
      }
      if (isLoggedIn && isAuthRoute) return '/home';
      return null;
    },
    routes: [
      GoRoute(path: '/splash', builder: (_, __) => const _SplashScreen()),

      // ── Auth ──────────────────────────────────────────────────────────────
      GoRoute(path: '/auth/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/auth/register', builder: (_, __) => const RegisterScreen()),
      GoRoute(path: '/auth/forgot-password', builder: (_, __) => const ForgotPasswordScreen()),
      GoRoute(path: '/auth/setup-account', builder: (_, __) => const AccountSetupScreen()),
      GoRoute(
        path: '/auth/reset-password',
        builder: (_, state) =>
            ResetPasswordScreen(email: state.extra as String? ?? ''),
      ),

      // ── Core ──────────────────────────────────────────────────────────────
      GoRoute(path: '/home', builder: (_, __) => const HomeScreen()),
      GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen()),

      // ── School Info ───────────────────────────────────────────────────────
      GoRoute(
        path: '/school-info',
        builder: (_, __) => const SchoolInfoScreen(),
      ),

      // ── Academic Years ────────────────────────────────────────────────────
      GoRoute(
        path: '/academic-years',
        builder: (_, __) => const AcademicYearsScreen(),
      ),

      // ── Classrooms ────────────────────────────────────────────────────────
      GoRoute(
        path: '/classrooms',
        builder: (_, __) => const ClassRoomsScreen(),
      ),

      GoRoute(
        path: '/classrooms/:classId/subjects',
        builder: (_, state) {
          final classId = state.pathParameters['classId']!;
          final extra = state.extra as Map<String, String>? ?? {};
          return SubjectsScreen(
            classId: classId,
            className: extra['className'] ?? 'Class',
          );
        },
      ),

      GoRoute(
        path: '/classrooms/:classId/sections',
        builder: (_, state) {
          final classId = state.pathParameters['classId']!;
          final extra = state.extra as Map<String, String>? ?? {};
          return SectionsScreen(
            classId: classId,
            className: extra['className'] ?? 'Class',
          );
        },
      ),

      // ── Students ──────────────────────────────────────────────────────────
      GoRoute(
        path: '/students',
        builder: (_, __) => const StudentsScreen(),
      ),

      GoRoute(
        path: '/students/enroll',
        builder: (_, __) => const EnrollStudentScreen(),
      ),

      GoRoute(
        path: '/students/:studentId',
        builder: (_, state) {
          final student = state.extra as StudentModel;
          return StudentDetailScreen(student: student);
        },
      ),

      // ── Parent ────────────────────────────────────────────────────────────
      GoRoute(
        path: '/my-children',
        builder: (_, __) => const MyChildrenScreen(),
      ),

      // ── Staff ─────────────────────────────────────────────────────────────
      GoRoute(
        path: '/staff',
        builder: (_, __) => const StaffScreen(),
      ),

      GoRoute(
        path: '/staff/create',
        builder: (_, __) => const CreateStaffScreen(),
      ),

      GoRoute(
        path: '/staff/:staffId',
        builder: (_, state) {
          final staff = state.extra as StaffModel;
          return StaffDetailScreen(staff: staff);
        },
      ),

      // ── Teacher ───────────────────────────────────────────────────────────
      GoRoute(
        path: '/teacher/my-profile',
        builder: (_, __) => const TeacherProfileScreen(),
      ),

      // ── Attendance ────────────────────────────────────────────────────────
      GoRoute(
        path: '/sections/:sectionId/mark-attendance',
        builder: (_, state) {
          final sectionId = state.pathParameters['sectionId']!;
          final extra = state.extra as Map<String, String>? ?? {};
          return MarkAttendanceScreen(
            sectionId: sectionId,
            sectionName: extra['sectionName'] ?? '',
            classRoomName: extra['classRoomName'] ?? '',
          );
        },
      ),

      GoRoute(
        path: '/sections/:sectionId/attendance-report',
        builder: (_, state) {
          final sectionId = state.pathParameters['sectionId']!;
          final extra = state.extra as Map<String, String>? ?? {};
          return AttendanceReportScreen(
            sectionId: sectionId,
            sectionName: extra['sectionName'] ?? '',
            classRoomName: extra['classRoomName'] ?? '',
          );
        },
      ),

      GoRoute(
        path: '/students/:studentId/attendance',
        builder: (_, state) {
          final studentId = state.pathParameters['studentId']!;
          final studentName = state.extra as String? ?? 'Student';
          return StudentAttendanceScreen(
            studentId: studentId,
            studentName: studentName,
          );
        },
      ),

      // ── Homework ──────────────────────────────────────────────────────────
      GoRoute(
        path: '/sections/:sectionId/homework',
        builder: (_, state) {
          final sectionId = state.pathParameters['sectionId']!;
          final extra = state.extra as Map<String, String>? ?? {};
          return HomeworkScreen(
            sectionId: sectionId,
            sectionName: extra['sectionName'] ?? 'Section',
          );
        },
      ),

      GoRoute(
        path: '/sections/:sectionId/homework/create',
        builder: (_, state) {
          final sectionId = state.pathParameters['sectionId']!;
          final sectionName = state.extra as String? ?? 'Section';
          return CreateHomeworkScreen(
            sectionId: sectionId,
            sectionName: sectionName,
          );
        },
      ),

      GoRoute(
        path: '/homework/:homeworkId',
        builder: (_, state) {
          final hw = state.extra as HomeworkModel;
          return HomeworkDetailScreen(homework: hw);
        },
      ),

      GoRoute(
        path: '/my-child-homework/:studentId',
        builder: (_, state) {
          final studentId = state.pathParameters['studentId']!;
          final studentName = state.extra as String? ?? 'Student';
          return MyChildHomeworkScreen(
            studentId: studentId,
            studentName: studentName,
          );
        },
      ),
    ],
  );
});

class _AuthChangeNotifier extends ChangeNotifier {
  _AuthChangeNotifier(Ref ref) {
    ref.listen(authProvider, (_, __) => notifyListeners());
  }
}

class _SplashScreen extends ConsumerWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    if (auth.isInitialized) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (auth.isAuthenticated) {
          context.go('/home');
        } else {
          context.go('/auth/login');
        }
      });
    }
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
