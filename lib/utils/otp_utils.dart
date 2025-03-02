import 'package:flutter/foundation.dart';
import 'package:otp/otp.dart';
import 'package:base32/base32.dart';

String generateTOTP(String secret) {
  final normalizedSecret = secret.replaceAll(' ', '').toUpperCase();

  try {
    return OTP.generateTOTPCodeString(
      normalizedSecret,
      DateTime.now().millisecondsSinceEpoch,
      interval: 30,
      length: 6,
      algorithm: Algorithm.SHA1,
      isGoogle: true,
    );
  } catch (e) {
    if (kDebugMode) {
      print('Error generating TOTP: $e');
    }
    return '------';
  }
}
