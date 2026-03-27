import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:dio_http2_adapter/dio_http2_adapter.dart';

/// HTTP Public Key Pinning 配置
///
/// 使用 SPKI（SubjectPublicKeyInfo）SHA256 哈希进行公钥固定
class CertificatePinning {
  static String? _cachedPublicKeyHash;

  /// 创建带有公钥固定的 Dio 实例
  static Dio createPinnedDio({
    required String baseUrl,
    Duration? connectTimeout,
    Duration? receiveTimeout,
    Duration? sendTimeout,
    Map<String, String>? headers,
  }) {
    if (_cachedPublicKeyHash == null) {
      throw Exception(
        'Public key hash not loaded. Call loadPublicKey() first.',
      );
    }

    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: connectTimeout,
        receiveTimeout: receiveTimeout,
        sendTimeout: sendTimeout,
        headers: headers,
      ),
    );

    dio.httpClientAdapter = Http2Adapter(
      ConnectionManager(
        idleTimeout: const Duration(seconds: 15),
        onClientCreate: (uri, config) {
          // 证书验证回调
          config.onBadCertificate = (cert) {
            final publicKeyHash = _extractPublicKeyHash(cert.pem);
            return publicKeyHash == _cachedPublicKeyHash;
          };

          // 额外的证书验证
          config.validateCertificate = (certificate, host, port) {
            if (certificate == null) {
              return false;
            }

            final certPem = certificate.pem;
            final publicKeyHash = _extractPublicKeyHash(certPem);

            return publicKeyHash == _cachedPublicKeyHash;
          };
        },
      ),
    );

    return dio;
  }

  /// 从证书 PEM 中提取公钥哈希（SPKI SHA256）
  ///
  /// 标准 HPKP 实现方法：
  /// 1. 解析证书的 DER 编码
  /// 2. 提取 SubjectPublicKeyInfo (SPKI) 字段
  /// 3. 对 SPKI 计算 SHA256 哈希
  /// 4. Base64 编码
  static String? _extractPublicKeyHash(String certPem) {
    try {
      final lines = certPem.split('\n');
      final startIndex = lines.indexOf('-----BEGIN CERTIFICATE-----');
      final endIndex = lines.indexOf('-----END CERTIFICATE-----');

      if (startIndex == -1 || endIndex == -1) {
        return null;
      }

      // 解码证书的 DER 编码
      final certBase64 = lines.sublist(startIndex + 1, endIndex).join('');
      final certDer = base64Decode(certBase64);

      // 从 DER 编码中提取 SubjectPublicKeyInfo (SPKI)
      final spki = _extractSPKIFromDER(certDer);
      if (spki == null) {
        return null;
      }

      // 对 SPKI 计算 SHA256 哈希
      final digest = sha256.convert(spki);

      return base64Encode(digest.bytes);
    } catch (e) {
      return null;
    }
  }

  /// 从 DER 编码的证书中提取 SubjectPublicKeyInfo (SPKI)
  ///
  /// X.509 证书结构：
  /// SEQUENCE (Certificate)
  ///   SEQUENCE (tbsCertificate)
  ///     ...
  ///     SEQUENCE (subjectPublicKeyInfo) <- 提取这个
  ///       SEQUENCE (algorithmIdentifier)
  ///       BIT STRING (publicKey)
  static List<int>? _extractSPKIFromDER(List<int> der) {
    try {
      int pos = 0;

      // 跳过外层 SEQUENCE (Certificate)
      if (der[pos] != 0x30) return null; // SEQUENCE tag
      pos++; // 跳过 tag
      final certLength = _decodeDERLength(der, pos);
      if (certLength == null) return null;
      pos += _lengthOfLength(der, pos);

      // 跳过 tbsCertificate SEQUENCE
      if (der[pos] != 0x30) return null;
      pos++; // 跳过 tag
      final tbsLength = _decodeDERLength(der, pos);
      if (tbsLength == null) return null;
      pos += _lengthOfLength(der, pos);

      // 跳过 version
      if (der[pos] == 0xA0) {
        // [0] EXPLICIT
        pos++;
        final versionLength = _decodeDERLength(der, pos);
        if (versionLength == null) return null;
        pos += _lengthOfLength(der, pos);
        pos += versionLength;
      }

      // 跳过 serialNumber
      if (der[pos] == 0x02) {
        // INTEGER
        pos++;
        final serialLength = _decodeDERLength(der, pos);
        if (serialLength == null) return null;
        pos += _lengthOfLength(der, pos);
        pos += serialLength;
      }

      // 跳过 signature (AlgorithmIdentifier)
      if (der[pos] != 0x30) return null;
      pos++;
      final sigLength = _decodeDERLength(der, pos);
      if (sigLength == null) return null;
      pos += _lengthOfLength(der, pos);
      pos += sigLength;

      // 跳过 issuer
      if (der[pos] != 0x30) return null;
      pos++;
      final issuerLength = _decodeDERLength(der, pos);
      if (issuerLength == null) return null;
      pos += _lengthOfLength(der, pos);
      pos += issuerLength;

      // 跳过 validity
      if (der[pos] != 0x30) return null;
      pos++;
      final validityLength = _decodeDERLength(der, pos);
      if (validityLength == null) return null;
      pos += _lengthOfLength(der, pos);
      pos += validityLength;

      // 跳过 subject
      if (der[pos] != 0x30) return null;
      pos++;
      final subjectLength = _decodeDERLength(der, pos);
      if (subjectLength == null) return null;
      pos += _lengthOfLength(der, pos);
      pos += subjectLength;

      // 找到 subjectPublicKeyInfo (SPKI) SEQUENCE
      if (der[pos] != 0x30) return null;
      int spkiStart = pos;
      pos++;
      final spkiLength = _decodeDERLength(der, pos);
      if (spkiLength == null) return null;
      pos += _lengthOfLength(der, pos);

      // 提取完整的 SPKI（包括 tag、length 和 content）
      int spkiEnd = pos + spkiLength;
      return der.sublist(spkiStart, spkiEnd);
    } catch (e) {
      return null;
    }
  }

  /// 解码 DER 长度字段
  static int? _decodeDERLength(List<int> der, int pos) {
    if (pos >= der.length) return null;

    final firstByte = der[pos];
    if (firstByte & 0x80 == 0) {
      // 短格式（0-127）
      return firstByte;
    } else {
      // 长格式
      final numBytes = firstByte & 0x7F;
      if (numBytes == 0 || pos + 1 + numBytes > der.length) return null;

      int length = 0;
      for (int i = 0; i < numBytes; i++) {
        length = (length << 8) | der[pos + 1 + i];
      }
      return length;
    }
  }

  /// 计算长度字段占用的字节数
  static int _lengthOfLength(List<int> der, int pos) {
    if (pos >= der.length) return 0;

    final firstByte = der[pos];
    if (firstByte & 0x80 == 0) {
      return 1;
    } else {
      return 1 + (firstByte & 0x7F);
    }
  }

  /// 加载公钥哈希
  static Future<void> loadPublicKey(String hash) async {
    if (_cachedPublicKeyHash != null) {
      return;
    }
    setPublicKeyHash(hash);
  }

  /// 设置公钥哈希
  static void setPublicKeyHash(String hash) {
    _cachedPublicKeyHash = hash;
  }

  /// 清除公钥哈希
  static void clearPublicKeyHash() {
    _cachedPublicKeyHash = null;
  }

  /// 获取当前公钥哈希
  static String? get currentPublicKeyHash => _cachedPublicKeyHash;
}
