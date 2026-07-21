import 'package:flutter/foundation.dart';

class AppConstants {
  // NestJS Backend API Base URL
  static String get apiBaseUrl {
    const override = String.fromEnvironment('API_BASE_URL', defaultValue: '');
    if (override.isNotEmpty) return override;

    if (kIsWeb) {
      try {
        final origin = Uri.base.origin;
        if (origin.isNotEmpty && (origin.contains('ngrok') || origin.contains(':8080'))) {
          return '$origin/api/v1';
        }
      } catch (_) {}
    }
    return 'http://10.23.40.142:3001/api/v1';
  }

  static String get socketBaseUrl {
    const override = String.fromEnvironment('SOCKET_BASE_URL', defaultValue: '');
    if (override.isNotEmpty) return override;

    if (kIsWeb) {
      try {
        final origin = Uri.base.origin;
        if (origin.isNotEmpty && (origin.contains('ngrok') || origin.contains(':8080'))) {
          return origin;
        }
      } catch (_) {}
    }
    return 'http://10.23.40.142:3001';
  }

  // Map tile provider URL (OpenStreetMap by default, configurable via build args)
  static const String mapTileUrl = String.fromEnvironment(
    'MAP_TILE_URL',
    defaultValue: 'https://a.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}@2x.png',
  );

  // Routing provider URL (OSRM public demo by default, configurable via build args)
  // IMPORTANT: Public OSRM demo servers have rate limits.
  // For production, self-host OSRM or use a paid routing provider.
  static const String routingBaseUrl = String.fromEnvironment(
    'ROUTING_BASE_URL',
    defaultValue: 'https://router.project-osrm.org',
  );

  // Attribution text for map tiles
  static const String mapAttribution =
      '© OpenStreetMap contributors';

  // Location tracking intervals
  static const int locationUpdateIntervalSeconds = 10;
  static const double locationUpdateDistanceMeters = 50.0;

  // Route recalculation thresholds
  static const double routeRecalculationDistanceMeters = 200.0;

  // ETA format helper
  static String formatDuration(Duration duration) {
    if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes.remainder(60)}min';
    }
    return '${duration.inMinutes} min';
  }

  static String formatDistance(double meters) {
    if (meters >= 1000) {
      return '${(meters / 1000).toStringAsFixed(1)} km';
    }
    return '${meters.round()} m';
  }
}
