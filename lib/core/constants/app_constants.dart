
class AppConstants {
  // NestJS Backend API Base URL — loaded from build-time environment.
  // Use --dart-define=API_BASE_URL=http://your-server:3000/api/v1
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:3000/api/v1',
  );

  static const String socketBaseUrl = String.fromEnvironment(
    'SOCKET_BASE_URL',
    defaultValue: 'http://localhost:3000',
  );
}
