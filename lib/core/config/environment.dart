/// 环境配置
enum Environment {
  development,
  staging,
  production,
}

class EnvironmentConfig {
  EnvironmentConfig._();

  static Environment _env = Environment.development;

  static Environment get current => _env;

  static void setEnvironment(Environment env) {
    _env = env;
  }

  static bool get isDevelopment => _env == Environment.development;
  static bool get isStaging => _env == Environment.staging;
  static bool get isProduction => _env == Environment.production;

  // API 基础 URL（预留）
  static String get apiBaseUrl => switch (_env) {
    Environment.development => 'http://localhost:8080',
    Environment.staging => 'https://staging-api.cattrace.app',
    Environment.production => 'https://api.cattrace.app',
  };

  // AI 识别服务 URL（预留）
  static String get aiApiUrl => switch (_env) {
    Environment.development => 'http://localhost:5000',
    Environment.staging => 'https://staging-ai.cattrace.app',
    Environment.production => 'https://ai.cattrace.app',
  };
}
