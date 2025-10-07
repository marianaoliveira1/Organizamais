import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'dart:async';

class AdsBanner extends StatefulWidget {
  const AdsBanner({super.key});

  @override
  State<AdsBanner> createState() => _AdsBannerState();
}

class _AdsBannerState extends State<AdsBanner> {
  BannerAd? _bannerAd;
  bool _isAdLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadBannerAd();
  }

  void _loadBannerAd() {
    _bannerAd = BannerAd(
      adUnitId: 'ca-app-pub-8308246738505070/6410645428', // Seu ID do banner
      size: AdSize.banner, // Banner com altura menor (320x50)
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (Ad ad) {
          setState(() {
            _isAdLoaded = true;
          });
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          debugPrint('Erro ao carregar o banner: $error');
          ad.dispose();
        },
      ),
    );

    _bannerAd!.load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isAdLoaded && _bannerAd != null) {
      return Align(
        alignment: Alignment.center,
        child: SizedBox(
          width: _bannerAd!.size.width.toDouble(),
          height: _bannerAd!.size.height.toDouble(),
          child: AdWidget(ad: _bannerAd!),
        ),
      );
    } else {
      return const SizedBox(); // Retorna vazio se o anúncio não está pronto
    }
  }
}

// Interstitial ad helper (for one-off show on save)
class AdsInterstitial {
  static InterstitialAd? _ad;
  static bool _isLoading = false;

  static Future<void> preload() async {
    if (_ad != null || _isLoading) return;
    debugPrint('AdsInterstitial.preload: start');
    _isLoading = true;
    await InterstitialAd.load(
      adUnitId: 'ca-app-pub-8308246738505070/3973050625',
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _ad = ad;
          _isLoading = false;
          debugPrint('AdsInterstitial.preload: loaded');
        },
        onAdFailedToLoad: (error) {
          _ad = null;
          _isLoading = false;
          debugPrint('AdsInterstitial.preload: failed $error');
        },
      ),
    );
  }

  static Future<bool> showIfReady() async {
    final ad = _ad;
    debugPrint('AdsInterstitial.showIfReady: ready=${ad != null}');
    if (ad == null) return false;
    final Completer<bool> completer = Completer<bool>();
    _ad = null;
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        debugPrint('AdsInterstitial.showIfReady: dismissed');
        if (!completer.isCompleted) completer.complete(true);
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        debugPrint('AdsInterstitial.showIfReady: failed to show $error');
        if (!completer.isCompleted) completer.complete(false);
      },
    );
    debugPrint('AdsInterstitial.showIfReady: showing');
    ad.show();
    return completer.future;
  }

  static Future<void> show() async {
    final Completer<void> completer = Completer<void>();
    debugPrint('AdsInterstitial.show: load-then-show start');
    await InterstitialAd.load(
      adUnitId: 'ca-app-pub-8308246738505070/4767435153',
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          debugPrint('AdsInterstitial.show: loaded, showing');
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              debugPrint('AdsInterstitial.show: dismissed');
              if (!completer.isCompleted) completer.complete();
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              debugPrint('AdsInterstitial.show: failed to show $error');
              if (!completer.isCompleted) completer.complete();
            },
          );
          ad.show();
        },
        onAdFailedToLoad: (error) {
          debugPrint('AdsInterstitial.show: failed to load $error');
          if (!completer.isCompleted) completer.complete();
        },
      ),
    );
    return completer.future;
  }
}

// Rewarded ad helper (watch-to-unlock flow)
class AdsRewardedPremium {
  static Future<bool> show() async {
    final Completer<bool> completer = Completer<bool>();
    bool earned = false;
    debugPrint('AdsRewardedPremium.show: load start');
    await RewardedAd.load(
      adUnitId: 'ca-app-pub-8308246738505070/6946853855',
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          debugPrint('AdsRewardedPremium.show: loaded');
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              debugPrint('AdsRewardedPremium.show: dismissed, earned=$earned');
              if (!completer.isCompleted) completer.complete(earned);
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              debugPrint('AdsRewardedPremium.show: failed to show $error');
              if (!completer.isCompleted) completer.complete(false);
            },
          );
          ad.show(onUserEarnedReward: (ad, reward) {
            debugPrint('AdsRewardedPremium.show: reward earned');
            earned = true;
          });
        },
        onAdFailedToLoad: (error) {
          debugPrint('AdsRewardedPremium.show: failed to load $error');
          if (!completer.isCompleted) completer.complete(false);
        },
      ),
    );
    return completer.future;
  }
}
