import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';

class RemoteConfigService {
  static final RemoteConfigService _instance = RemoteConfigService._internal();
  factory RemoteConfigService() => _instance;
  RemoteConfigService._internal();

  final FirebaseRemoteConfig _rc = FirebaseRemoteConfig.instance;
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    await _rc.setDefaults(const {
      'feature_graphs_pro': true,
      'show_ads': true,
      'min_supported_version': '1.0.0',
    });

    await _rc.setConfigSettings(RemoteConfigSettings(
      fetchTimeout: const Duration(seconds: 10),
      minimumFetchInterval:
          kDebugMode ? const Duration(seconds: 10) : const Duration(hours: 12),
    ));

    await fetchAndActivate();
    _initialized = true;
  }

  Future<bool> fetchAndActivate() async {
    try {
      final bool updated = await _rc.fetchAndActivate();
      if (kDebugMode) {
        debugPrint('RemoteConfig updated=$updated');
      }
      return updated;
    } catch (e) {
      if (kDebugMode) debugPrint('RemoteConfig fetch failed: $e');
      return false;
    }
  }

  bool get showAds => _rc.getBool('show_ads');
  bool get featureGraphsPro => _rc.getBool('feature_graphs_pro');
  String get minSupportedVersion => _rc.getString('min_supported_version');
}
