import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/ads/ad_service.dart';
import 'core/analytics/analytics_service.dart';
import 'core/localization/locale_manager.dart';
import 'core/storage/app_prefs.dart';
import 'core/state/managers.dart';
import 'core/theme/game_theme.dart';
import 'core/utils/app_logger.dart';
import 'core/audio/procedural_audio.dart';
import 'features/game/presentation/screens/main_menu_screen.dart';
import 'features/game/presentation/screens/splash_screen.dart';

void main() async {
  await runZonedGuarded<Future<void>>(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      // Central storage layer (SharedPreferences wrapper) + version migrations.
      await AppPrefs.instance.init();
      await AppPrefs.instance.runMigrations();

      // Load persisted locale so the first frame uses the correct language.
      await LocaleManager.instance.loadLanguage();

      Managers.ensureRegistered();
      await Managers.loadAll();

      AppLog.box('🎮 DRAGONSBLOCK', [
        'Storage & State: Initialized',
        'Locale: ${LocaleManager.instance.currentLanguage.name.toUpperCase()}',
        'Engine: Ready',
      ]);

      FlutterError.onError = (FlutterErrorDetails details) {
        FlutterError.presentError(details);
        AppLog.error('FlutterError', details.exception, details.stack);
        final stackStr = details.stack?.toString() ?? '';
        AnalyticsService.instance.logEvent('flutter_error', {
          'exception': details.exception.toString(),
          'stack': stackStr.length > 500 ? stackStr.substring(0, 500) : stackStr,
        });
      };

      PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
        AppLog.error('PlatformDispatcher', error, stack);
        AnalyticsService.instance.logEvent('uncaught_error', {
          'error': error.toString(),
        });
        return true;
      };

  // Lock orientation to portrait for optimal tactile single-hand gameplay
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Fullscreen Immersive Sticky Mode (Hides status bar and bottom navigation bar for true edge-to-edge game immersion)
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  // Make system navigation and status bar transparent
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

      // Pre-initialize the ad SDK (no-op on unsupported platforms)
      AdService.instance.initialize();

      // Record app launch (backend is console-only until a real SDK is wired in)
      AnalyticsService.instance.logEvent('app_open');

      runApp(const DragonsBlockApp());
    },
    (Object error, StackTrace stack) {
      AnalyticsService.instance.logEvent('zoned_error', {'error': error.toString()});
      AppLog.error('ZonedGuarded', error, stack);
    },
  );
}

class DragonsBlockApp extends StatefulWidget {
  const DragonsBlockApp({super.key});

  @override
  State<DragonsBlockApp> createState() => _DragonsBlockAppState();
}

class _DragonsBlockAppState extends State<DragonsBlockApp> with WidgetsBindingObserver {
  bool _showSplash = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    ProceduralAudio.instance.handleAppLifecycle(state);
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.hidden ||
        state == AppLifecycleState.detached) {
      Managers.onAppPaused();
    } else if (state == AppLifecycleState.resumed) {
      Managers.onAppResumed();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: LocaleManager.instance,
      builder: (context, _) {
        return MaterialApp(
          title: 'DragonsBlock',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            brightness: Brightness.dark,
            scaffoldBackgroundColor: GameTheme.bgDarkest,
            fontFamily: 'Outfit',
            useMaterial3: true,
          ),
          locale: LocaleManager.instance.isTurkish ? const Locale('tr') : const Locale('en'),
          supportedLocales: const [Locale('tr'), Locale('en')],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: _showSplash
              ? SplashScreen(onComplete: () {
                  setState(() {
                    _showSplash = false;
                  });
                })
              : const MainMenuScreen(),
        );
      },
    );
  }
}
