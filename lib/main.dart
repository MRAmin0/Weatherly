import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:device_preview/device_preview.dart';

import 'l10n/app_localizations.dart';
import 'package:weatherly_app/presentation/screens/splash/splash_screen.dart';
import 'viewmodels/weather_viewmodel.dart';
import 'config/config_reader.dart';
import 'package:weatherly_app/data/services/notification_service.dart';

import 'package:weatherly_app/data/services/background_service_export.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ConfigReader.initialize();

  // Initialize background tasks (mobile only, handled internally)
  await initializeWorkmanager();

  // Request notification permission on app start
  // Now enabled for Web too
  try {
    final notificationService = NotificationService();
    await notificationService.initialize();
    // await notificationService.requestPermission(); // Moved to SplashScreen
  } catch (e) {
    debugPrint('Notification init error: $e');
  }

  runApp(
    DevicePreview(
      enabled: !kReleaseMode,
      builder: (context) {
        return ChangeNotifierProvider(
          create: (_) => WeatherViewModel(),
          child: Consumer<WeatherViewModel>(
            builder: (context, viewModel, _) {
              // Light Theme
              final lightScheme = ColorScheme.fromSeed(
                seedColor: viewModel.seedColor,
                brightness: Brightness.light,
              );

              // Dark Theme
              final darkScheme = ColorScheme.fromSeed(
                seedColor: viewModel.seedColor,
                brightness: Brightness.dark,
              );

              return MaterialApp(
                title: 'Weatherly',
                debugShowCheckedModeBanner: false,

                locale: Locale(viewModel.lang),

                builder: (context, child) {
                  child = DevicePreview.appBuilder(context, child);
                  final isFarsi =
                      Localizations.localeOf(context).languageCode == 'fa';
                  return Directionality(
                    textDirection: isFarsi
                        ? TextDirection.rtl
                        : TextDirection.ltr,
                    child: child,
                  );
                },

                supportedLocales: AppLocalizations.supportedLocales,
                localizationsDelegates: AppLocalizations.localizationsDelegates,

                themeMode: viewModel.themeMode,

                theme: ThemeData(
                  useMaterial3: true,
                  fontFamily: 'Vazir',
                  colorScheme: lightScheme,
                ),
                darkTheme: ThemeData(
                  useMaterial3: true,
                  fontFamily: 'Vazir',
                  colorScheme: darkScheme,
                ),

                home: const SplashScreen(),
              );
            },
          ),
        );
      },
    ),
  );
}
