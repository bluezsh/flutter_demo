/// 应用环境枚举
enum AppEnv { dev, pre, prod }

/// 应用环境配置
class AppEnvConfig {
  static AppEnv env = AppEnv.dev;

  static String get apiBaseUrl {
    switch (env) {
      case AppEnv.dev:
        return 'https://api.dev.example.com';
      case AppEnv.pre:
        return 'https://api.pre.example.com';
      case AppEnv.prod:
        return 'https://api.prod.example.com';
    }
  }

  static String get sslHash {
    switch (env) {
      case AppEnv.dev:
        return 'your_dev_ssl_hash_here';
      case AppEnv.pre:
        return 'your_pre_ssl_hash_here';
      case AppEnv.prod:
        return 'your_prod_ssl_hash_here';
    }
  }

  /// 是否启用证书固定
  static bool get enableCertificatePinning => sslHash.isNotEmpty;
}
