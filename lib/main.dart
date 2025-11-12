import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
// 👇 آدرس‌دهی مطلق
import 'package:weatherly_app/screens/weather_screen.dart';
import 'package:weatherly_app/weather_store.dart';
import 'package:weatherly_app/config_reader.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ConfigReader.initialize();

  // 👇 از آنجایی که مشکل کرش داشتیم، یک خطای ساده در اینجا اضافه می‌کنم
  //    تا مطمئن بشیم کلید API شما لود شده.
  if (ConfigReader.getOpenWeatherApiKey() == 'API_KEY_NOT_FOUND') {
    runApp(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text(
              'خطا: کلید API در keys.json پیدا نشد.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.red),
            ),
          ),
        ),
      ),
    );
    return;
  }

  final themeNotifier = ValueNotifier<ThemeMode>(ThemeMode.system);

  runApp(
    ChangeNotifierProvider(
      create: (_) => WeatherStore(),
      child: ValueListenableBuilder<ThemeMode>(
        valueListenable: themeNotifier,
        builder: (context, themeMode, _) {
          return MaterialApp(
            title: 'هواشناسی',
            debugShowCheckedModeBanner: false,
            themeMode: themeMode,

            // 💡 پشتیبانی کامل از فارسی و راست‌به‌چپ
            locale: const Locale('fa', 'IR'),
            supportedLocales: const [Locale('fa', 'IR'), Locale('en', 'US')],
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],

            // 🌗 تم روشن و تاریک (تنظیمات نهایی)
            theme: ThemeData(
              useMaterial3: true,
              fontFamily: 'Vazir',
              brightness: Brightness.light,
              scaffoldBackgroundColor: const Color(0xFFF0F4F8),
              cardColor: Colors.white,
              primarySwatch: Colors.blue,
              appBarTheme: const AppBarTheme(
                backgroundColor: Colors.transparent,
                elevation: 0,
                iconTheme: IconThemeData(color: Colors.black),
                titleTextStyle: TextStyle(
                  color: Colors.black,
                  fontFamily: 'Vazir',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                systemOverlayStyle: SystemUiOverlayStyle(
                  statusBarIconBrightness: Brightness.dark,
                  statusBarBrightness: Brightness.light,
                ),
              ),
              inputDecorationTheme: InputDecorationTheme(
                filled: true,
                fillColor: Colors.white,
                hintStyle: TextStyle(color: Colors.grey.shade600),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24.0),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24.0),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
              ),
              textTheme: const TextTheme(
                bodyMedium: TextStyle(color: Colors.black87),
                titleMedium: TextStyle(color: Colors.black),
              ),
            ),
            darkTheme: ThemeData(
              useMaterial3: true,
              fontFamily: 'Vazir',
              brightness: Brightness.dark,
              scaffoldBackgroundColor: const Color(0xFF2A2C3E),
              cardColor: const Color(0xFF3C3E4F),
              appBarTheme: const AppBarTheme(
                backgroundColor: Colors.transparent,
                elevation: 0,
                iconTheme: IconThemeData(color: Colors.white),
                titleTextStyle: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Vazir',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                systemOverlayStyle: SystemUiOverlayStyle(
                  statusBarIconBrightness: Brightness.light,
                  statusBarBrightness: Brightness.dark,
                ),
              ),
              inputDecorationTheme: InputDecorationTheme(
                filled: true,
                fillColor: const Color(0xFF1E1F2C),
                hintStyle: TextStyle(color: Colors.grey.shade600),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24.0),
                  borderSide: BorderSide.none,
                ),
              ),
              textTheme: const TextTheme(
                bodyMedium: TextStyle(color: Colors.white70),
                titleMedium: TextStyle(color: Colors.white),
              ),
            ),

            // 🔄 اطمینان از راست‌به‌چپ بودن کل اپ
            builder: (context, child) {
              return Directionality(
                textDirection: TextDirection.rtl,
                child: child!,
              );
            },

            // 🏙️ صفحه اصلی
            home: WeatherScreen(
              currentThemeMode: themeMode,
              onThemeChanged: (newMode) => themeNotifier.value = newMode,
            ),
          );
        },
      ),
    ),
  );
}
