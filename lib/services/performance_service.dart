import 'package:firebase_performance/firebase_performance.dart';
import 'package:flutter/foundation.dart';

class PerformanceService {
  static final PerformanceService _instance = PerformanceService._internal();
  factory PerformanceService() => _instance;
  PerformanceService._internal();

  final FirebasePerformance _perf = FirebasePerformance.instance;

  Future<void> init() async {
    // Enable in release by default, in debug follow Firebase defaults (disabled).
    await _perf.setPerformanceCollectionEnabled(!kDebugMode);
  }

  Trace startTrace(String name) {
    return _perf.newTrace(name)..start();
  }
}
