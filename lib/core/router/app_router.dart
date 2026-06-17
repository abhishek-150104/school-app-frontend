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
import '../../features/school/presentation/screens/schools_screen.dart';
import '../../features/school/presentation/screens/academic_years_screen.dart';
import '../../features/school/presentation/screens/classrooms_screen.dart';
import '../../features/school/presentation/screens/sections_screen.dart';

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
      if (isLoggedIn && isAuthRoute) return '/home';
      return null;
    },
    routes: [
      GoRoute(path: '/splash', builder: (_, __) => const _SplashScreen()),

      // ── Auth ──────────────────────────────────────────────────────────────
      GoRoute(path: '/auth/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/auth/register', builder: (_, __) => const RegisterScreen()),
      GoRoute(path: '/auth/forgot-password', builder: (_, __) => const ForgotPasswordScreen()),
      GoRoute(
        path: '/auth/reset-password',
        builder: (_, state) =>
            ResetPasswordScreen(email: state.extra as String? ?? ''),
      ),

      // ── Core ──────────────────────────────────────────────────────────────
      GoRoute(path: '/home', builder: (_, __) => const HomeScreen()),
      GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen()),

      // ── Schools ───────────────────────────────────────────────────────────
      GoRoute(path: '/schools', builder: (_, __) => const SchoolsScreen()),

      GoRoute(
        path: '/schools/:schoolId/academic-years',
        builder: (_, state) {
          final schoolId = state.pathParameters['schoolId']!;
          final schoolName = state.extra as String? ?? 'School';
          return AcademicYearsScreen(
              schoolId: schoolId, schoolName: schoolName);
        },
      ),

      GoRoute(
        path: '/schools/:schoolId/classrooms',
        builder: (_, state) {
          final schoolId = state.pathParameters['schoolId']!;
          final schoolName = state.extra as String? ?? 'School';
          return ClassRoomsScreen(
              schoolId: schoolId, schoolName: schoolName);
        },
      ),

      GoRoute(
        path: '/schools/:schoolId/classrooms/:classId/sections',
        builder: (_, state) {
          final schoolId = state.pathParameters['schoolId']!;
          final classId = state.pathParameters['classId']!;
          final extra = state.extra as Map<String, String>? ?? {};
          return SectionsScreen(
            schoolId: schoolId,
            classId: classId,
            className: extra['className'] ?? 'Class',
            schoolName: extra['schoolName'] ?? 'School',
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

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
