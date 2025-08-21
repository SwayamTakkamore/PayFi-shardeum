import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:get_it/get_it.dart';
import 'config/app_config.dart';
import 'services/secure_storage_service.dart';
import 'providers/wallet_provider.dart';
import 'screens/home_screen.dart';
import 'utils/theme.dart';

final getIt = GetIt.instance;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set up configuration
  const bool isProduction = bool.fromEnvironment('dart.vm.product');
  ConfigManager.setConfig(isProduction ? ProdConfig() : DevConfig());

  // Initialize secure storage
  await SecureStorageService.instance.initialize();

  // Set up dependency injection
  await setupServiceLocator();

  // Temporarily disable Sentry until properly configured
  // TODO: Set up proper Sentry DSN for production
  if (isProduction && ConfigManager.config.sentryDsn.isNotEmpty) {
    await SentryFlutter.init(
      (options) {
        options.dsn = ConfigManager.config.sentryDsn;
        options.debug = false;
        options.tracesSampleRate = 0.1;
      },
      appRunner: () => runApp(const MyApp()),
    );
  } else {
    runApp(const MyApp());
  }
}

Future<void> setupServiceLocator() async {
  // Register services
  getIt.registerLazySingleton(() => SecureStorageService.instance);
  // Add other services here
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => WalletProvider(),
      child: MaterialApp(
        title: ConfigManager.config.appName,
        theme: AppTheme.lightTheme,
        home: const HomeScreen(),
        debugShowCheckedModeBanner: false,
        navigatorObservers: [
          SentryNavigatorObserver(),
        ],
      ),
    );
  }
}
