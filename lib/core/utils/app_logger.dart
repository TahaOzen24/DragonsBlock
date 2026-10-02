import 'package:flutter/foundation.dart';

/// Professional, color-coded, readable console logger for Block Survivor.
/// Uses ANSI color codes, structured timestamps, and clean box borders.
class AppLog {
  AppLog._();

  // ANSI Escape Codes
  static const String _reset = '\x1B[0m';
  static const String _bold = '\x1B[1m';
  static const String _dim = '\x1B[2m';

  static const String _red = '\x1B[31m';
  static const String _green = '\x1B[32m';
  static const String _yellow = '\x1B[33m';
  static const String _blue = '\x1B[34m';
  static const String _magenta = '\x1B[35m';
  static const String _cyan = '\x1B[36m';

  static String _timestamp() {
    final now = DateTime.now();
    final h = now.hour.toString().padLeft(2, '0');
    final m = now.minute.toString().padLeft(2, '0');
    final s = now.second.toString().padLeft(2, '0');
    final ms = now.millisecond.toString().padLeft(3, '0');
    return '$h:$m:$s.$ms';
  }

  /// 🎮 In-Game Action (Placements, Clears, Board Events)
  static void game(String message, [Map<String, dynamic>? data]) {
    if (!kDebugMode) return;
    final time = _timestamp();
    final dataStr = (data != null && data.isNotEmpty)
        ? ' $_dim${data.toString()}$_reset'
        : '';
    debugPrint('$_cyan[$time] 🎮 [GAME]$_reset $_bold$message$_reset$dataStr');
  }

  /// ⚡ Great Combo & Realm Shift Event
  static void combo({
    required int streak,
    required int lines,
    required String realmTitle,
  }) {
    if (!kDebugMode) return;
    final time = _timestamp();
    debugPrint('$_magenta╔══════════════════════════════════════════════════════════════╗$_reset');
    debugPrint('$_magenta║ $_bold[$time] ⚡ COMBO AWAKENING: $realmTitle$_reset');
    debugPrint('$_magenta║    Streak: ${streak}x  │  Lines Cleared: $lines  │  Realm Shift: Active$_reset');
    debugPrint('$_magenta╚══════════════════════════════════════════════════════════════╝$_reset');
  }

  /// 🪙 Reward / Shard Earning
  static void reward(String title, int amount, [String? source]) {
    if (!kDebugMode) return;
    final time = _timestamp();
    final src = source != null ? ' ($source)' : '';
    debugPrint('$_yellow[$time] 🪙 [REWARD]$_reset $_bold$title: +$amount 🪙$src$_reset');
  }

  /// 📊 Analytics & Telemetry Events
  static void analytics(String eventName, [Map<String, dynamic>? params]) {
    if (!kDebugMode) return;
    final time = _timestamp();
    final paramStr = (params != null && params.isNotEmpty)
        ? ' $_dim${params.toString()}$_reset'
        : '';
    debugPrint('$_blue[$time] 📊 [EVENT]$_reset $_bold$eventName$_reset$paramStr');
  }

  /// 💡 General Informational Log
  static void info(String tag, String message) {
    if (!kDebugMode) return;
    final time = _timestamp();
    debugPrint('$_green[$time] 💡 [$tag]$_reset $message');
  }

  /// ⚠️ Warning / Degraded Fallback Log
  static void warn(String tag, String message) {
    if (!kDebugMode) return;
    final time = _timestamp();
    debugPrint('$_yellow[$time] ⚠️ [$tag]$_reset $_bold$message$_reset');
  }

  /// 💥 Error Log with Formatted Stack Trace
  static void error(String tag, dynamic error, [StackTrace? stack]) {
    if (!kDebugMode) return;
    final time = _timestamp();
    debugPrint('$_red╔══════════════════════════════════════════════════════════════╗$_reset');
    debugPrint('$_red║ [$time] 💥 ERROR in [$tag]: $error$_reset');
    if (stack != null) {
      final lines = stack.toString().split('\n').take(6).join('\n║    ');
      debugPrint('$_red║    $lines$_reset');
    }
    debugPrint('$_red╚══════════════════════════════════════════════════════════════╝$_reset');
  }

  /// 📦 Pretty Box Display (e.g. for App Startup, Milestones)
  static void box(String title, List<String> lines, {String color = _cyan}) {
    if (!kDebugMode) return;
    const width = 62;
    debugPrint('$color┌${'─' * width}┐$_reset');
    debugPrint('$color│ $_bold${title.padRight(width - 2)}$_reset$color │$_reset');
    debugPrint('$color├${'─' * width}┤$_reset');
    for (final line in lines) {
      debugPrint('$color│ ${line.padRight(width - 2)} │$_reset');
    }
    debugPrint('$color└${'─' * width}┘$_reset');
  }
}
