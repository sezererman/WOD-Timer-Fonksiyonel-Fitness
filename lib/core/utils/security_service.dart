import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_ce/hive.dart';

/// Mobil güvenlik standartlarına (OWASP M1, M2) uygun güvenlik servisi.
class SecurityService {
  final FlutterSecureStorage _storage;
  static const _hiveKeyName = 'hive_encryption_key';

  SecurityService({required FlutterSecureStorage storage}) : _storage = storage;

  /// Hive kutularını şifrelemek için güvenli bir anahtar getirir veya oluşturur.
  Future<Uint8List> getEncryptionKey() async {
    // 1. Keychain/Keystore'dan mevcut anahtarı oku
    final encodedKey = await _storage.read(key: _hiveKeyName);

    if (encodedKey == null) {
      // 2. Anahtar yoksa, kriptografik olarak güvenli yeni bir anahtar üret
      final newKey = Hive.generateSecureKey();
      
      // 3. Yeni anahtarı donanımsal kasada (Keychain/Keystore) sakla
      await _storage.write(
        key: _hiveKeyName,
        value: base64UrlEncode(newKey),
      );
      
      return Uint8List.fromList(newKey);
    }

    // 4. Mevcut anahtarı decode et ve dön
    return base64Url.decode(encodedKey);
  }

  /// Hassas verileri (Token, Premium Status vb.) doğrudan donanımsal kasada saklar.
  Future<void> saveSecureData(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  /// Güvenli veriyi okur.
  Future<String?> readSecureData(String key) async {
    return await _storage.read(key: key);
  }
}
