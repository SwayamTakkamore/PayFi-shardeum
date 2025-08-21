abstract class AppConfig {
  String get appName;
  String get shardeumRpcUrl;
  int get shardeumChainId;
  String get explorerUrl;
  String get apiBaseUrl;
  bool get isDebugMode;
  String get sentryDsn;
  String get walletConnectProjectId;
}

class DevConfig implements AppConfig {
  @override
  String get appName => 'PayFi Tip Jar (Dev)';

  @override
  String get shardeumRpcUrl => 'https://sphinx.shardeum.org/';

  @override
  int get shardeumChainId => 8082;

  @override
  String get explorerUrl => 'https://explorer-sphinx.shardeum.org/';

  @override
  String get apiBaseUrl => 'https://dev-api.tipjar.app';

  @override
  bool get isDebugMode => true;

  @override
  String get sentryDsn => 'YOUR_DEV_SENTRY_DSN';

  @override
  String get walletConnectProjectId => 'YOUR_DEV_WC_PROJECT_ID';
}

class ProdConfig implements AppConfig {
  @override
  String get appName => 'PayFi Tip Jar';

  @override
  String get shardeumRpcUrl => 'https://sphinx.shardeum.org/';

  @override
  int get shardeumChainId => 8082;

  @override
  String get explorerUrl => 'https://explorer-sphinx.shardeum.org/';

  @override
  String get apiBaseUrl => 'https://api.tipjar.app';

  @override
  bool get isDebugMode => false;

  @override
  String get sentryDsn => 'YOUR_PROD_SENTRY_DSN';

  @override
  String get walletConnectProjectId => 'YOUR_PROD_WC_PROJECT_ID';
}

class ConfigManager {
  static late AppConfig _config;

  static void setConfig(AppConfig config) {
    _config = config;
  }

  static AppConfig get config => _config;
}
