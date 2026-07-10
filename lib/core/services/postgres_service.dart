import 'package:postgres/postgres.dart';

class PostgresService {
  static Connection? _connection;
  static bool _hasConnectionError = false;

  static bool get hasConnectionError => _hasConnectionError;

  /// The database URL must be provided via --dart-define=DATABASE_URL=... at build time.
  static String get _dbUrl => const String.fromEnvironment(
    'DATABASE_URL',
    defaultValue: '',
  );

  static Future<Connection?> getConnection() async {
    if (_connection != null) {
      return _connection!;
    }

    if (_dbUrl.isEmpty) {
      _hasConnectionError = true;
      return null;
    }

    try {
      final uri = Uri.parse(_dbUrl);
      final userInfo = uri.userInfo.split(':');
      final username = userInfo[0];
      final password = userInfo.length > 1 ? userInfo[1] : '';
      final host = uri.host;
      final port = uri.port;
      final database = uri.pathSegments.isNotEmpty ? uri.pathSegments.first : 'farmfresh';

      _connection = await Connection.open(
        Endpoint(
          host: host,
          database: database,
          username: username,
          password: password,
          port: port,
        ),
        settings: const ConnectionSettings(
          sslMode: SslMode.disable,
          connectTimeout: Duration(seconds: 5),
        ),
      );
      _hasConnectionError = false;
      return _connection;
    } catch (e) {
      _hasConnectionError = true;
      _connection = null;
      return null;
    }
  }

  static Future<void> closeConnection() async {
    if (_connection != null) {
      await _connection!.close();
      _connection = null;
    }
  }
}
