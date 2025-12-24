import 'dart:io' show Platform;

import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:flutter/foundation.dart';

class TrackingTransparencyService {
  const TrackingTransparencyService();

  Future<TrackingStatus> ensurePromptBeforeTracking() async {
    if (kIsWeb || !Platform.isIOS) {
      return TrackingStatus.notSupported;
    }

    try {
      var status = await AppTrackingTransparency.trackingAuthorizationStatus;
      if (status == TrackingStatus.notDetermined) {
        status = await AppTrackingTransparency.requestTrackingAuthorization();
      }
      return status;
    } catch (e, stackTrace) {
      debugPrint('Failed to request App Tracking Transparency consent: $e');
      debugPrint('$stackTrace');
      return TrackingStatus.notDetermined;
    }
  }
}

