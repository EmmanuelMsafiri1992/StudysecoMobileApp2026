import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../../features/splash/screens/splash_screen.dart';
import '../../features/onboarding/screens/onboarding_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/auth/screens/forgot_password_screen.dart';
import '../../features/auth/screens/verification_screen.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/student/screens/student_dashboard_screen.dart';
import '../../features/subjects/screens/subjects_screen.dart';
import '../../features/subjects/screens/subject_detail_screen.dart';
import '../../features/lessons/screens/lessons_screen.dart';
import '../../features/lessons/screens/lesson_player_screen.dart';
import '../../features/quizzes/screens/quizzes_screen.dart';
import '../../features/quizzes/screens/quiz_detail_screen.dart';
import '../../features/quizzes/screens/quiz_take_screen.dart';
import '../../features/quizzes/screens/quiz_result_screen.dart';
import '../../features/exams/screens/exams_screen.dart';
import '../../features/exams/screens/exam_detail_screen.dart';
import '../../features/exams/screens/exam_take_screen.dart';
import '../../features/exams/screens/exam_result_screen.dart';
import '../../features/assignments/screens/assignments_screen.dart';
import '../../features/assignments/screens/assignment_detail_screen.dart';
import '../../features/assignments/screens/assignment_submit_screen.dart';
import '../../features/games/screens/games_screen.dart';
import '../../features/games/screens/game_play_screen.dart';
import '../../features/games/screens/leaderboard_screen.dart';
import '../../features/library/screens/library_screen.dart';
import '../../features/library/screens/resource_viewer_screen.dart';
import '../../features/chat/screens/chat_groups_screen.dart';
import '../../features/chat/screens/chat_room_screen.dart';
import '../../features/community/screens/community_screen.dart';
import '../../features/community/screens/post_detail_screen.dart';
import '../../features/community/screens/create_post_screen.dart';
import '../../features/ai_tutor/screens/ai_tutor_screen.dart';
import '../../features/achievements/screens/achievements_screen.dart';
import '../../features/certificates/screens/certificates_screen.dart';
import '../../features/payments/screens/payments_screen.dart';
import '../../features/payments/screens/enrollment_screen.dart';
import '../../features/payments/screens/extension_screen.dart';
import '../../features/support/screens/support_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../features/profile/screens/edit_profile_screen.dart';
import '../../features/profile/screens/settings_screen.dart';
import '../../features/notifications/screens/notifications_screen.dart';
import '../../features/teacher/screens/teacher_dashboard_screen.dart';
import '../../features/teacher/screens/teacher_students_screen.dart';
import '../../features/teacher/screens/grade_assignment_screen.dart';
import '../../features/admin/screens/admin_dashboard_screen.dart';
import '../../features/admin/screens/admin_users_screen.dart';
import '../../features/admin/screens/admin_payments_screen.dart';
import '../../features/admin/screens/admin_reports_screen.dart';

class AppRouter {
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();
  static final _shellNavigatorKey = GlobalKey<NavigatorState>();

  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/splash',
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final authProvider = context.read<AuthProvider>();
      final isLoggedIn = authProvider.isAuthenticated;
      final isOnSplash = state.matchedLocation == '/splash';
      final isOnOnboarding = state.matchedLocation == '/onboarding';
      final isOnAuth = state.matchedLocation.startsWith('/auth');

      // Allow splash and onboarding
      if (isOnSplash || isOnOnboarding) return null;

      // Redirect to login if not authenticated
      if (!isLoggedIn && !isOnAuth) {
        return '/auth/login';
      }

      // Redirect to home if authenticated and on auth pages
      if (isLoggedIn && isOnAuth) {
        return '/home';
      }

      return null;
    },
    routes: [
      // Splash
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),

      // Onboarding
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),

      // Auth Routes
      GoRoute(
        path: '/auth/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/auth/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/auth/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/auth/verify',
        builder: (context, state) {
          final email = state.extra as String?;
          return VerificationScreen(email: email ?? '');
        },
      ),

      // Main App Shell
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => HomeScreen(child: child),
        routes: [
          // Dashboard
          GoRoute(
            path: '/home',
            builder: (context, state) => const StudentDashboardScreen(),
          ),

          // Subjects
          GoRoute(
            path: '/subjects',
            builder: (context, state) => const SubjectsScreen(),
            routes: [
              GoRoute(
                path: ':id',
                builder: (context, state) {
                  final id = state.pathParameters['id']!;
                  return SubjectDetailScreen(subjectId: id);
                },
              ),
            ],
          ),

          // Lessons
          GoRoute(
            path: '/lessons',
            builder: (context, state) => const LessonsScreen(),
          ),

          // Quizzes
          GoRoute(
            path: '/quizzes',
            builder: (context, state) => const QuizzesScreen(),
            routes: [
              GoRoute(
                path: ':id',
                builder: (context, state) {
                  final id = state.pathParameters['id']!;
                  return QuizDetailScreen(quizId: id);
                },
              ),
            ],
          ),

          // Exams
          GoRoute(
            path: '/exams',
            builder: (context, state) => const ExamsScreen(),
            routes: [
              GoRoute(
                path: ':id',
                builder: (context, state) {
                  final id = state.pathParameters['id']!;
                  return ExamDetailScreen(examId: id);
                },
              ),
            ],
          ),

          // Assignments
          GoRoute(
            path: '/assignments',
            builder: (context, state) => const AssignmentsScreen(),
            routes: [
              GoRoute(
                path: ':id',
                builder: (context, state) {
                  final id = state.pathParameters['id']!;
                  return AssignmentDetailScreen(assignmentId: id);
                },
              ),
            ],
          ),

          // Games
          GoRoute(
            path: '/games',
            builder: (context, state) => const GamesScreen(),
          ),

          // Library
          GoRoute(
            path: '/library',
            builder: (context, state) => const LibraryScreen(),
          ),

          // Chat
          GoRoute(
            path: '/chat',
            builder: (context, state) => const ChatGroupsScreen(),
          ),

          // Community
          GoRoute(
            path: '/community',
            builder: (context, state) => const CommunityScreen(),
          ),

          // AI Tutor
          GoRoute(
            path: '/ai-tutor',
            builder: (context, state) => const AiTutorScreen(),
          ),

          // Achievements
          GoRoute(
            path: '/achievements',
            builder: (context, state) => const AchievementsScreen(),
          ),

          // Certificates
          GoRoute(
            path: '/certificates',
            builder: (context, state) => const CertificatesScreen(),
          ),

          // Payments
          GoRoute(
            path: '/payments',
            builder: (context, state) => const PaymentsScreen(),
          ),

          // Support
          GoRoute(
            path: '/support',
            builder: (context, state) => const SupportScreen(),
          ),

          // Profile
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfileScreen(),
          ),

          // Settings
          GoRoute(
            path: '/settings',
            builder: (context, state) => const SettingsScreen(),
          ),

          // Notifications
          GoRoute(
            path: '/notifications',
            builder: (context, state) => const NotificationsScreen(),
          ),

          // Teacher Routes
          GoRoute(
            path: '/teacher/dashboard',
            builder: (context, state) => const TeacherDashboardScreen(),
          ),
          GoRoute(
            path: '/teacher/students',
            builder: (context, state) => const TeacherStudentsScreen(),
          ),

          // Admin Routes
          GoRoute(
            path: '/admin/dashboard',
            builder: (context, state) => const AdminDashboardScreen(),
          ),
          GoRoute(
            path: '/admin/users',
            builder: (context, state) => const AdminUsersScreen(),
          ),
          GoRoute(
            path: '/admin/payments',
            builder: (context, state) => const AdminPaymentsScreen(),
          ),
          GoRoute(
            path: '/admin/reports',
            builder: (context, state) => const AdminReportsScreen(),
          ),
        ],
      ),

      // Full-screen routes (outside shell)
      GoRoute(
        path: '/lesson/:id/play',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return LessonPlayerScreen(lessonId: id);
        },
      ),
      GoRoute(
        path: '/quiz/:id/take',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return QuizTakeScreen(quizId: id);
        },
      ),
      GoRoute(
        path: '/quiz/:id/result',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          final attemptId = state.extra as String?;
          return QuizResultScreen(quizId: id, attemptId: attemptId);
        },
      ),
      GoRoute(
        path: '/exam/:id/take',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return ExamTakeScreen(examId: id);
        },
      ),
      GoRoute(
        path: '/exam/:id/result',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          final attemptId = state.extra as String?;
          return ExamResultScreen(examId: id, attemptId: attemptId);
        },
      ),
      GoRoute(
        path: '/assignment/:id/submit',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return AssignmentSubmitScreen(assignmentId: id);
        },
      ),
      GoRoute(
        path: '/game/:id/play',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return GamePlayScreen(gameId: id);
        },
      ),
      GoRoute(
        path: '/game/:id/leaderboard',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return LeaderboardScreen(gameId: id);
        },
      ),
      GoRoute(
        path: '/resource/:id/view',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return ResourceViewerScreen(resourceId: id);
        },
      ),
      GoRoute(
        path: '/chat/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return ChatRoomScreen(groupId: id);
        },
      ),
      GoRoute(
        path: '/community/post/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return PostDetailScreen(postId: id);
        },
      ),
      GoRoute(
        path: '/community/create',
        builder: (context, state) => const CreatePostScreen(),
      ),
      GoRoute(
        path: '/enrollment',
        builder: (context, state) => const EnrollmentScreen(),
      ),
      GoRoute(
        path: '/extension',
        builder: (context, state) => const ExtensionScreen(),
      ),
      GoRoute(
        path: '/profile/edit',
        builder: (context, state) => const EditProfileScreen(),
      ),
      GoRoute(
        path: '/teacher/grade/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return GradeAssignmentScreen(submissionId: id);
        },
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Page not found',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(state.matchedLocation),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go('/home'),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
  );
}
