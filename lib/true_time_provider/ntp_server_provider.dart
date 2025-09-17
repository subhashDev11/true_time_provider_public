import 'dart:io';
import 'dart:math';
import 'package:flutter/cupertino.dart';

part 'flutter_ntp_message.dart';

const _defaultLookup = 'time.google.com';

class NtpServerProvider {
  /// Return NTP delay in milliseconds
  static Future<int?> getNtpOffset({
    String lookUpAddress = _defaultLookup,
    int port = 123,
    DateTime? localTime,
    Duration? timeout,
  }) async {
    timeout = timeout ?? Duration(seconds: 40);
    try {
      final List<InternetAddress> addresses = await InternetAddress.lookup(
        lookUpAddress,
      );

      if (addresses.isEmpty) {
        debugPrint('❌ Could not resolve address for $lookUpAddress.');
        return null;
      }

      final InternetAddress serverAddress = addresses.first;
      InternetAddress clientAddress = InternetAddress.anyIPv4;
      if (serverAddress.type == InternetAddressType.IPv6) {
        clientAddress = InternetAddress.anyIPv6;
      }

      // Init datagram socket to anyIPv4 and to port 0
      final RawDatagramSocket datagramSocket = await RawDatagramSocket.bind(
        clientAddress,
        0,
      );

      final _TrueTimeProviderMessage ntpMessage = _TrueTimeProviderMessage();
      final List<int> buffer = ntpMessage.toByteArray();
      final DateTime time = localTime ?? DateTime.now();
      ntpMessage.encodeTimestamp(
        buffer,
        40,
        (time.millisecondsSinceEpoch / 1000.0) + ntpMessage.timeToUtc,
      );

      // Send buffer packet to the address [serverAddress] and port [port]
      datagramSocket.send(buffer, serverAddress, port);

      Datagram? packet;

      bool receivePacket(RawSocketEvent event) {
        if (event == RawSocketEvent.read) {
          packet = datagramSocket.receive();
        }
        return packet != null;
      }

      try {
        await datagramSocket.timeout(timeout).firstWhere(receivePacket);
      } catch (e) {
        debugPrint("⚠️ Timeout or receive error: $e");
        return null;
      } finally {
        datagramSocket.close();
      }

      if (packet == null) {
        debugPrint("⚠️ NTP fetch failed: Received empty response.");
        return null;
      }

      final int offset = _parseData(packet!.data, DateTime.now());
      return offset;
    } catch (e) {
      debugPrint("❌ NTP fetch failed with error: $e");
      return null;
    }
  }

  /// Get current NTP time
  static Future<DateTime?> now({
    String? lookUpAddress,
    int? port,
    Duration? timeout,
  }) async {
    try {
      final DateTime localTime = DateTime.now();
      final int? offset = await getNtpOffset(
        lookUpAddress: lookUpAddress ?? _defaultLookup,
        port: port ?? 123,
        localTime: localTime,
        timeout: timeout,
      );

      if (offset == null) {
        debugPrint("⚠️ Falling back: NTP server time.");
        return null; // caller (TrueTimeProvider) handles fallback
      }

      return localTime.add(Duration(milliseconds: offset));
    } catch (e) {
      debugPrint("❌ NTP now() failed: $e");
      return null; // caller handles fallback
    }
  }

  /// Parse data from datagram socket.
  static int _parseData(List<int> data, DateTime time) {
    final _TrueTimeProviderMessage ntpMessage = _TrueTimeProviderMessage(data);
    final double destinationTimestamp =
        (time.millisecondsSinceEpoch / 1000.0) + 2208988800.0;
    final double localClockOffset =
        ((ntpMessage._receiveTimestamp - ntpMessage._originateTimestamp) +
            (ntpMessage._transmitTimestamp - destinationTimestamp)) /
        2;

    return (localClockOffset * 1000).toInt();
  }
}
