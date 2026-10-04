import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'config/app_config.dart';
import 'services/product_repository.dart';
import 'services/price_history_repository.dart';
import 'services/failed_search_repository.dart';
import 'data/dummy_products.dart';
import 'widgets/main_nav.dart';
import 'theme/app_theme.dart';
import 'theme/theme_notifier.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();

  // Register every Hive adapter + open every box before runApp().
  await ProductRepository.init();
  await PriceHistoryRepository.init();
  await FailedSearchRepository.init();

  if (AppConfig.useDummyData) {
    await ProductRepository().seedIfEmpty(dummyProducts);
  }

  runApp(const SanitaryStoreApp());
}

class SanitaryStoreApp extends StatelessWidget {
  const SanitaryStoreApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, mode, _) {
        return MaterialApp(
          title: 'Lahore Sanitary',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: mode,
          home: const MainNav(),
        );
      },
    );
  }
}