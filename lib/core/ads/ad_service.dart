import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../iap/iap_service.dart';
import '../utils/app_logger.dart';

/// Centralized rewarded & interstitial ad service for DragonsBlock.
///
/// Debug: Google resmi test birimleri (doldurma garantili).
/// Release: dart-define prod ID'leri.
/// Test device: ADMOB_TEST_DEVICE_IDS=hash1,hash2 (logcat'ten)
class AdService {
  static final AdService instance = AdService._();
  AdService._();

  static const String testAndroidRewardedUnitId =
      'ca-app-pub-3940256099942544/5224354917';
  static const String testIosRewardedUnitId =
      'ca-app-pub-3940256099942544/1712485313';
  static const String testAndroidInterstitialUnitId =
      'ca-app-pub-3940256099942544/1033173712';
  static const String testIosInterstitialUnitId =
      'ca-app-pub-3940256099942544/4411468910';

  static const String _prodAndroidRewardedUnitId = String.fromEnvironment(
    'ADMOB_REWARDED_ANDROID',
    defaultValue: testAndroidRewardedUnitId,
  );
  static const String _prodIosRewardedUnitId = String.fromEnvironment(
    'ADMOB_REWARDED_IOS',
    defaultValue: testIosRewardedUnitId,
  );

  static const String _prodAndroidInterstitialUnitId = String.fromEnvironment(
    'ADMOB_INTERSTITIAL_ANDROID',
    defaultValue: testAndroidInterstitialUnitId,
  );
  static const String _prodIosInterstitialUnitId = String.fromEnvironment(
    'ADMOB_INTERSTITIAL_IOS',
    defaultValue: testIosInterstitialUnitId,
  );

  /// Debug'da bile gerçek birimleri zorla: --dart-define=ADMOB_FORCE_PROD=true
  static const bool _forceProd = bool.fromEnvironment(
    'ADMOB_FORCE_PROD',
    defaultValue: false,
  );

  /// Virgülle ayrılmış test device hash'leri (AdMob log / console).
  static const String _testDeviceIdsRaw = String.fromEnvironment(
    'ADMOB_TEST_DEVICE_IDS',
    defaultValue: '',
  );

  RewardedAd? _rewardedAd;
  InterstitialAd? _interstitialAd;
  bool _initialized = false;
  bool _loadingRewarded = false;
  bool _loadingInterstitial = false;

  bool get _isMobilePlatform =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  /// Debug = Google test ads (yeni App ID "inceleme" iken prod çoğu zaman No fill).
  bool get _useTestUnits => kDebugMode && !_forceProd;

  bool get isUsingTestAds => _useTestUnits;

  String get _rewardedUnitId {
    if (_useTestUnits) {
      return defaultTargetPlatform == TargetPlatform.iOS
          ? testIosRewardedUnitId
          : testAndroidRewardedUnitId;
    }
    return defaultTargetPlatform == TargetPlatform.iOS
        ? _prodIosRewardedUnitId
        : _prodAndroidRewardedUnitId;
  }

  String get _interstitialUnitId {
    if (_useTestUnits) {
      return defaultTargetPlatform == TargetPlatform.iOS
          ? testIosInterstitialUnitId
          : testAndroidInterstitialUnitId;
    }
    return defaultTargetPlatform == TargetPlatform.iOS
        ? _prodIosInterstitialUnitId
        : _prodAndroidInterstitialUnitId;
  }

  Future<void> initialize() async {
    if (_initialized || !_isMobilePlatform) return;
    try {
      final testIds = _testDeviceIdsRaw
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();

      // Emulator her zaman test cihazı sayılır.
      final devices = <String>{
        ...testIds,
        if (kDebugMode) 'EMULATOR',
      }.toList();

      await MobileAds.instance.updateRequestConfiguration(
        RequestConfiguration(testDeviceIds: devices),
      );

      await MobileAds.instance.initialize();
      _initialized = true;

      AppLog.game('AdMob hazir', {
        'mode': _useTestUnits ? 'TEST_ADS' : 'PROD_ADS',
        'rewarded': _rewardedUnitId,
        'interstitial': _interstitialUnitId,
        'testDevices': devices.join('|'),
      });

      // Arka planda ön-yükle — butona basınca "hazır değil" azalır.
      unawaited(_loadRewardedAd());
      unawaited(_loadInterstitialAd());
    } catch (e, st) {
      _initialized = false;
      AppLog.error('AdMob init', e, st);
    }
  }

  Future<bool> _loadRewardedAd() async {
    if (_rewardedAd != null) return true;
    if (_loadingRewarded) return false;
    _loadingRewarded = true;

    final completer = Completer<bool>();
    try {
      await RewardedAd.load(
        adUnitId: _rewardedUnitId,
        request: const AdRequest(),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: (RewardedAd ad) {
            _rewardedAd = ad;
            _loadingRewarded = false;
            AppLog.game('Rewarded yuklendi', {'unit': _rewardedUnitId});
            if (!completer.isCompleted) completer.complete(true);
          },
          onAdFailedToLoad: (LoadAdError error) {
            _rewardedAd = null;
            _loadingRewarded = false;
            AppLog.error(
              'Rewarded yuklenemedi',
              '${error.code} ${error.message} domain=${error.domain}',
              null,
            );
            if (!completer.isCompleted) completer.complete(false);
          },
        ),
      );
    } catch (e, st) {
      _rewardedAd = null;
      _loadingRewarded = false;
      AppLog.error('Rewarded load exception', e, st);
      if (!completer.isCompleted) completer.complete(false);
    }
    return completer.future;
  }

  Future<bool> _loadInterstitialAd() async {
    if (_interstitialAd != null) return true;
    if (_loadingInterstitial) return false;
    _loadingInterstitial = true;

    final completer = Completer<bool>();
    try {
      await InterstitialAd.load(
        adUnitId: _interstitialUnitId,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (InterstitialAd ad) {
            _interstitialAd = ad;
            _loadingInterstitial = false;
            AppLog.game('Interstitial yuklendi', {'unit': _interstitialUnitId});
            if (!completer.isCompleted) completer.complete(true);
          },
          onAdFailedToLoad: (LoadAdError error) {
            _interstitialAd = null;
            _loadingInterstitial = false;
            AppLog.error(
              'Interstitial yuklenemedi',
              '${error.code} ${error.message} domain=${error.domain}',
              null,
            );
            if (!completer.isCompleted) completer.complete(false);
          },
        ),
      );
    } catch (e, st) {
      _interstitialAd = null;
      _loadingInterstitial = false;
      AppLog.error('Interstitial load exception', e, st);
      if (!completer.isCompleted) completer.complete(false);
    }
    return completer.future;
  }

  Future<bool> showRewardedAd() async {
    await initialize();
    if (!_initialized) return false;

    final loaded = await _loadRewardedAd();
    if (!loaded || _rewardedAd == null) {
      AppLog.error('Rewarded gosterilemedi', 'reklam hazir degil', null);
      return false;
    }

    final ad = _rewardedAd!;
    final completer = Completer<bool>();
    var rewarded = false;

    ad.fullScreenContentCallback = FullScreenContentCallback<RewardedAd>(
      onAdDismissedFullScreenContent: (RewardedAd ad) {
        ad.dispose();
        _rewardedAd = null;
        unawaited(_loadRewardedAd());
        if (!completer.isCompleted) completer.complete(rewarded);
      },
      onAdFailedToShowFullScreenContent: (RewardedAd ad, AdError error) {
        ad.dispose();
        _rewardedAd = null;
        AppLog.error('Rewarded show fail', '${error.code} ${error.message}', null);
        unawaited(_loadRewardedAd());
        if (!completer.isCompleted) completer.complete(false);
      },
    );

    try {
      await ad.show(onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
        rewarded = true;
      });
    } catch (e, st) {
      _rewardedAd = null;
      AppLog.error('Rewarded show exception', e, st);
      if (!completer.isCompleted) completer.complete(false);
    }

    return completer.future;
  }

  Future<bool> showInterstitialAd() async {
    if (IapService.instance.hasNoAds) return true;
    await initialize();
    if (!_initialized) return false;

    final loaded = await _loadInterstitialAd();
    if (!loaded || _interstitialAd == null) {
      AppLog.error('Interstitial gosterilemedi', 'reklam hazir degil', null);
      return false;
    }

    final ad = _interstitialAd!;
    final completer = Completer<bool>();

    ad.fullScreenContentCallback = FullScreenContentCallback<InterstitialAd>(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _interstitialAd = null;
        unawaited(_loadInterstitialAd());
        if (!completer.isCompleted) completer.complete(true);
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _interstitialAd = null;
        AppLog.error('Interstitial show fail', '${error.code} ${error.message}', null);
        unawaited(_loadInterstitialAd());
        if (!completer.isCompleted) completer.complete(false);
      },
    );

    try {
      await ad.show();
    } catch (e, st) {
      _interstitialAd = null;
      AppLog.error('Interstitial show exception', e, st);
      if (!completer.isCompleted) completer.complete(false);
    }

    return completer.future;
  }
}
