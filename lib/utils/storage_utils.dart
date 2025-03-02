import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final storage = FlutterSecureStorage();

Future<void> saveAccount(String account, String secret, String issuer) async {
  await storage.write(key: account, value: '$issuer::$secret');
}

Future<Map<String, String>> getAccounts() async => await storage.readAll();

Future<void> deleteAccount(String account) async {
  await storage.delete(key: account);
}
