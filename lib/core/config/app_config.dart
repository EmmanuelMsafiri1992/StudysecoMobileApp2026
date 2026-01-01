class AppConfig {
  static const String appName = 'StudySeco';
  static const String appVersion = '1.0.0';

  // API Configuration
  static const String baseUrl = 'https://studyseco.com/api';
  static const String webUrl = 'https://studyseco.com';

  // Timeouts
  static const int connectionTimeout = 30000; // 30 seconds
  static const int receiveTimeout = 30000;

  // Pagination
  static const int defaultPageSize = 20;

  // Cache Duration
  static const int cacheDuration = 3600; // 1 hour in seconds

  // Trial Period
  static const int trialDays = 7;

  // File Upload
  static const int maxFileSize = 10 * 1024 * 1024; // 10 MB
  static const List<String> allowedImageTypes = ['jpg', 'jpeg', 'png', 'gif'];
  static const List<String> allowedDocTypes = ['pdf', 'doc', 'docx'];

  // Video Settings
  static const int videoBufferDuration = 5000; // 5 seconds

  // Quiz/Exam Settings
  static const int defaultQuizTimeLimit = 30; // minutes
  static const int defaultExamTimeLimit = 180; // 3 hours

  // Chat Settings
  static const int maxMessageLength = 2000;
  static const int maxChatGroupMembers = 100;

  // Supported Currencies
  static const Map<String, String> currencies = {
    'MWK': 'Malawi Kwacha',
    'ZAR': 'South African Rand',
    'USD': 'US Dollar',
  };

  // Grade Levels (Forms)
  static const List<String> gradeLevels = [
    'Form 1',
    'Form 2',
    'Form 3',
    'Form 4',
  ];

  // Achievement Levels
  static const List<String> achievementLevels = [
    'Bronze',
    'Silver',
    'Gold',
    'Platinum',
  ];

  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  static const String themeKey = 'theme_mode';
  static const String onboardingKey = 'onboarding_completed';
  static const String notificationKey = 'notification_settings';
}
