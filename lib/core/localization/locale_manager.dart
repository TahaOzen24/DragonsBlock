import 'package:flutter/foundation.dart';
import '../storage/app_prefs.dart';

export 'app_strings.dart';

enum AppLanguage {
  tr,
  en;

  String get displayName {
    switch (this) {
      case AppLanguage.tr:
        return 'Türkçe 🇹🇷';
      case AppLanguage.en:
        return 'English 🇬🇧';
    }
  }
}

class LocaleManager extends ChangeNotifier {
  static final LocaleManager instance = LocaleManager._();
  LocaleManager._();

  AppLanguage _currentLanguage = AppLanguage.tr;
  AppLanguage get currentLanguage => _currentLanguage;

  bool get isTurkish => _currentLanguage == AppLanguage.tr;

  Future<void> loadLanguage() async {
    await AppPrefs.instance.init();
    final savedCode = AppPrefs.instance.getString(AppPrefs.kLocale);
    if (savedCode == 'en') {
      _currentLanguage = AppLanguage.en;
    } else {
      _currentLanguage = AppLanguage.tr;
    }
    notifyListeners();
  }

  Future<void> setLanguage(AppLanguage language) async {
    _currentLanguage = language;
    await AppPrefs.instance.setString(AppPrefs.kLocale, language.name);
    notifyListeners();
  }

  void toggleLanguage() {
    setLanguage(_currentLanguage == AppLanguage.tr ? AppLanguage.en : AppLanguage.tr);
  }
}
