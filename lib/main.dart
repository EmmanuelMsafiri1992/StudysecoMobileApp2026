import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'core/config/app_config.dart';
import 'core/config/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/providers/auth_provider.dart';
import 'core/providers/theme_provider.dart';
import 'core/providers/connectivity_provider.dart';
import 'features/student/providers/student_provider.dart';
import 'features/subjects/providers/subjects_provider.dart';
import 'features/lessons/providers/lessons_provider.dart';
import 'features/quizzes/providers/quiz_provider.dart';
import 'features/exams/providers/exam_provider.dart';
import 'features/assignments/providers/assignment_provider.dart';
import 'features/games/providers/games_provider.dart';
import 'features/chat/providers/chat_provider.dart';
import 'features/community/providers/community_provider.dart';
import 'features/ai_tutor/providers/ai_tutor_provider.dart';
import 'features/payments/providers/payment_provider.dart';
import 'features/achievements/providers/achievement_provider.dart';
import 'features/notifications/providers/notification_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive for local storage
  await Hive.initFlutter();

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const StudySecoApp());
}

class StudySecoApp extends StatelessWidget {
  const StudySecoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => ConnectivityProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProxyProvider<AuthProvider, StudentProvider>(
          create: (_) => StudentProvider(),
          update: (_, auth, student) => student!..updateAuth(auth),
        ),
        ChangeNotifierProxyProvider<AuthProvider, SubjectsProvider>(
          create: (_) => SubjectsProvider(),
          update: (_, auth, subjects) => subjects!..updateAuth(auth),
        ),
        ChangeNotifierProxyProvider<AuthProvider, LessonsProvider>(
          create: (_) => LessonsProvider(),
          update: (_, auth, lessons) => lessons!..updateAuth(auth),
        ),
        ChangeNotifierProxyProvider<AuthProvider, QuizProvider>(
          create: (_) => QuizProvider(),
          update: (_, auth, quiz) => quiz!..updateAuth(auth),
        ),
        ChangeNotifierProxyProvider<AuthProvider, ExamProvider>(
          create: (_) => ExamProvider(),
          update: (_, auth, exam) => exam!..updateAuth(auth),
        ),
        ChangeNotifierProxyProvider<AuthProvider, AssignmentProvider>(
          create: (_) => AssignmentProvider(),
          update: (_, auth, assignment) => assignment!..updateAuth(auth),
        ),
        ChangeNotifierProxyProvider<AuthProvider, GamesProvider>(
          create: (_) => GamesProvider(),
          update: (_, auth, games) => games!..updateAuth(auth),
        ),
        ChangeNotifierProxyProvider<AuthProvider, ChatProvider>(
          create: (_) => ChatProvider(),
          update: (_, auth, chat) => chat!..updateAuth(auth),
        ),
        ChangeNotifierProxyProvider<AuthProvider, CommunityProvider>(
          create: (_) => CommunityProvider(),
          update: (_, auth, community) => community!..updateAuth(auth),
        ),
        ChangeNotifierProxyProvider<AuthProvider, AiTutorProvider>(
          create: (_) => AiTutorProvider(),
          update: (_, auth, tutor) => tutor!..updateAuth(auth),
        ),
        ChangeNotifierProxyProvider<AuthProvider, PaymentProvider>(
          create: (_) => PaymentProvider(),
          update: (_, auth, payment) => payment!..updateAuth(auth),
        ),
        ChangeNotifierProxyProvider<AuthProvider, AchievementProvider>(
          create: (_) => AchievementProvider(),
          update: (_, auth, achievement) => achievement!..updateAuth(auth),
        ),
        ChangeNotifierProxyProvider<AuthProvider, NotificationProvider>(
          create: (_) => NotificationProvider(),
          update: (_, auth, notification) => notification!..updateAuth(auth),
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp.router(
            title: AppConfig.appName,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            routerConfig: AppRouter.router,
          );
        },
      ),
    );
  }
}
