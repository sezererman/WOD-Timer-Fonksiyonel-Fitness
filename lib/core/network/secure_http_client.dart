// import 'dart:io';
// import 'package:flutter/foundation.dart';
// import 'package:dio/dio.dart'; // İleride backend eklendiğinde açılacak

/// OWASP M3 (Insecure Communication) standardına uygun güvenli HTTP istemcisi.
/// Sunucuyla iletişimin araya girilmesini (Man-in-the-Middle) engellemek için 
/// SSL Pinning (Sertifika Sabitleme) mimarisi içerir.
class SecureHttpClient {
  // Örnek: API sunucusunun SHA-256 parmak izi (Public Key Hash)
  // static const List<String> _allowedCertFingerprints = [
  //   "A1:B2:C3:D4:E5:F6:78:90:12:34:56:78:90:AB:CD:EF:12:34:56:78:90:AB:CD:EF:12:34:56:78:90:AB:CD:EF",
  // ];

  /* 
  /// Dio kullanarak güvenli HTTP Client oluşturur.
  static Dio createSecureClient() {
    final dio = Dio();

    // 1. SSL Sertifika Doğrulama (Pinning)
    dio.httpClientAdapter = IOHttpClientAdapter(
      createHttpClient: () {
        final client = HttpClient();
        client.badCertificateCallback = (X509Certificate cert, String host, int port) {
          if (kDebugMode) {
            // Geliştirme ortamında self-signed sertifikalara izin verilebilir
            return true;
          }
          
          // Canlı ortamda sertifika parmak izi eşleşmeli (SSL Pinning)
          return _allowedCertFingerprints.contains(cert.sha256.toUpperCase());
        };
        return client;
      },
    );

    // 2. Güvenli Interceptor'lar (Token Injection & Logging)
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Güvenli depolamadan token'ı al ve header'a ekle
        // final token = await sl<SecurityService>().readSecureData('auth_token');
        // if (token != null) {
        //   options.headers['Authorization'] = 'Bearer $token';
        // }
        return handler.next(options);
      },
      onResponse: (response, handler) {
        return handler.next(response);
      },
      onError: (DioException e, handler) {
        // Hata loglarında hassas bilgileri filtrele
        return handler.next(e);
      },
    ));

    return dio;
  }
  */
}
