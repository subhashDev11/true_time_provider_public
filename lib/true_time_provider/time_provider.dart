import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import 'firebase_cloud_provider.dart';
import 'ntp_server_provider.dart';

class TrueTimeProvider {
  TrueTimeProvider._();

  static final TrueTimeProvider _instance = TrueTimeProvider._();

  static TrueTimeProvider get instance => _instance;

  // --- Firebase Provider (for fallback time source) ---
  final FirebaseCloudProvider _firebaseCloudProvider =
      FirebaseCloudProvider.instance;

  FirebaseOptions? firebaseOptions;

  // Initialize FirebaseCloudProvider (should be called at app startup)
  Future<void> init({required FirebaseOptions options}) async {
    firebaseOptions = options;
    await _firebaseCloudProvider.init(options: options);
  }

  /// Returns a reliable DateTime.
  /// Priority:
  /// 1. NTP server (most accurate)
  /// 2. Firebase Cloud (if NTP fails)
  /// 3. Device local time (last fallback)
  Future<TrueTimeResult> now({
    Duration? ntpFetchDuration,
    String? ntoLookUpAddress,
    int? ntpLookupPort,
  }) async {
    // --- 1. Try NTP server ---
    debugPrint(
      "NTP Request at - ${"${DateTime.now().minute} : ${DateTime.now().second}"}",
    );
    var ntpTime = await NtpServerProvider.now(
      timeout: ntpFetchDuration ?? Duration(seconds: 5),
      lookUpAddress: ntoLookUpAddress,
      port: ntpLookupPort,
    );
    debugPrint(
      "NTP Request end at - ${"${DateTime.now().minute} : ${DateTime.now().second}"}",
    );

    if (ntpTime != null) {
      return TrueTimeResult(dateTime: ntpTime, source: DateSource.ntpServer);
    }

    // --- 2. Try Firebase ---
    if (firebaseOptions == null) {
      return TrueTimeResult(
        dateTime: DateTime.now(),
        source: DateSource.localDevice,
      );
    }
    if (!_firebaseCloudProvider.initialized) {
      _firebaseCloudProvider.init(options: firebaseOptions!);
    }
    var fireSTime = await FirebaseCloudProvider.instance.now();

    // --- 3. Last fallback: device time ---
    return TrueTimeResult(
      dateTime: fireSTime ?? DateTime.now(),
      source: fireSTime != null
          ? DateSource.firebaseCloud
          : DateSource.localDevice,
    );
  }
}

/// It fetched date-time value and it's source
class TrueTimeResult {
  final DateTime dateTime;
  final DateSource source;

  TrueTimeResult({required this.dateTime, required this.source});
}

/// DateSource
enum DateSource { firebaseCloud, ntpServer, localDevice }
