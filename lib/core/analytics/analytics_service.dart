import '../utils/app_logger.dart';

/// Lightweight, backend-agnostic analytics abstraction.
///
/// All game events funnel through [AnalyticsService.instance.logEvent]. The
/// default backend only logs to the VM console; swap in Firebase Analytics or
/// another provider later without touching any call site.
///
/// Wire-up example (add firebase_analytics to pubspec.yaml first):
/// ```dart
/// AnalyticsService.instance.setBackend((name, params) {
///   FirebaseAnalytics.instance.logEvent(name: name, parameters: params);
/// });
/// ```
class AnalyticsService {
  AnalyticsService._();

  static final AnalyticsService instance = AnalyticsService._();

  /// Pluggable sink. Defaults to console logging so the app never crashes on
  /// platforms without an analytics SDK.
  void Function(String name, Map<String, Object>? params)? _backend;

  bool _enabled = true;

  /// Replaces the backend (e.g. `FirebaseAnalytics.instance.logEvent`).
  void setBackend(void Function(String name, Map<String, Object>? params) sink) {
    _backend = sink;
  }

  void setEnabled(bool enabled) {
    _enabled = enabled;
  }

  /// Logs a named event with optional parameters.
  void logEvent(String name, [Map<String, Object>? params]) {
    if (!_enabled) return;
    if (_backend != null) {
      _backend!(name, params);
      return;
    }
    AppLog.analytics(name, params?.cast<String, dynamic>());
  }

  /// Logs a screen/view transition.
  void logScreen(String screenName) => logEvent('screen_view', {'screen': screenName});

  /// Convenience for crash/exception reporting (route to Crashlytics later).
  void logError(String name, Object error, StackTrace? stack) {
    final stackStr = stack?.toString() ?? '';
    logEvent(name, {
      'error': error.toString(),
      'stack': stackStr.length > 500 ? stackStr.substring(0, 500) : stackStr,
    });
  }
}
