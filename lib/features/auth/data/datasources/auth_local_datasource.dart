import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../../core/error/exceptions.dart';
import '../models/user_model.dart';

abstract class AuthLocalDataSource {
  Future<void> cacheUser(UserModel userToCache);
  Future<UserModel?> getCachedUser();
  Future<void> clearCache();
  
  /// Supabase için opsiyonel token kaydı (Supabase genelde kendi handle eder ama
  /// ek güvenlik katmanı olarak manuel yönetmek istenirse diye eklendi).
  Future<void> saveToken(String token);
  Future<String?> getToken();
}

const cachedUserKey = 'CACHED_USER';
const cachedTokenKey = 'CACHED_TOKEN';

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final FlutterSecureStorage secureStorage;

  AuthLocalDataSourceImpl({required this.secureStorage});

  @override
  Future<void> cacheUser(UserModel userToCache) async {
    try {
      final jsonString = json.encode(userToCache.toJson());
      await secureStorage.write(key: cachedUserKey, value: jsonString);
    } catch (e) {
      throw const CacheException('Kullanıcı bilgisi önbelleğe alınamadı.');
    }
  }

  @override
  Future<UserModel?> getCachedUser() async {
    try {
      final jsonString = await secureStorage.read(key: cachedUserKey);
      if (jsonString != null) {
        return UserModel.fromJson(json.decode(jsonString));
      }
      return null;
    } catch (e) {
      throw const CacheException('Önbellekten kullanıcı bilgisi okunamadı.');
    }
  }

  @override
  Future<void> clearCache() async {
    try {
      await secureStorage.delete(key: cachedUserKey);
      await secureStorage.delete(key: cachedTokenKey);
    } catch (e) {
      throw const CacheException('Önbellek temizlenemedi.');
    }
  }

  @override
  Future<void> saveToken(String token) async {
    try {
      await secureStorage.write(key: cachedTokenKey, value: token);
    } catch (e) {
      throw const CacheException('Token önbelleğe alınamadı.');
    }
  }

  @override
  Future<String?> getToken() async {
    try {
      return await secureStorage.read(key: cachedTokenKey);
    } catch (e) {
      throw const CacheException('Token okunamadı.');
    }
  }
}
