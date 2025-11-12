import 'package:flutter/material.dart';

import '../models/weather_models.dart';

String toPersianDigits(String input) {
  const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '.'];
  const persian = ['۰', '۱', '۲', '۳', '۴', '۵', '۶', '۷', '۸', '۹', '٫'];

  var output = input;
  for (var i = 0; i < english.length; i++) {
    output = output.replaceAll(english[i], persian[i]);
  }

  return output;
}

String formatLocalHour(DateTime utc, int offsetSeconds) {
  final local = utc.add(Duration(seconds: offsetSeconds));
  final hour = local.hour.toString().padLeft(2, '0');
  return '$hour:00';
}

String weatherTypeToApiName(WeatherType type) {
  switch (type) {
    case WeatherType.clear:
      return 'Clear';
    case WeatherType.clouds:
      return 'Clouds';
    case WeatherType.rain:
      return 'Rain';
    case WeatherType.drizzle:
      return 'Drizzle';
    case WeatherType.thunderstorm:
      return 'Thunderstorm';
    case WeatherType.snow:
      return 'Snow';
    default:
      return 'unknown';
  }
}

String translateWeather(WeatherType type) {
  switch (type) {
    case WeatherType.clear:
      return 'صاف';
    case WeatherType.clouds:
      return 'ابری';
    case WeatherType.rain:
    case WeatherType.drizzle:
    case WeatherType.thunderstorm:
      return 'بارانی';
    case WeatherType.snow:
      return 'برفی';
    default:
      return 'نامشخص';
  }
}

String weatherIconAsset(String weather) {
  switch (weather) {
    case 'Clear':
      return 'assets/icons/sun.svg';
    case 'Clouds':
      return 'assets/icons/cloud.svg';
    case 'Rain':
    case 'Drizzle':
      return 'assets/icons/rain.svg';
    case 'Thunderstorm':
      return 'assets/icons/storm.svg';
    case 'Snow':
      return 'assets/icons/snow.svg';
    default:
      return 'assets/icons/cloud.svg';
  }
}

Color statusColorForAqi(int aqi) {
  switch (aqi) {
    case 1:
      return Colors.greenAccent;
    case 2:
      return Colors.yellowAccent;
    case 3:
      return Colors.orangeAccent;
    case 4:
      return Colors.redAccent;
    case 5:
      return Colors.purpleAccent;
    default:
      return Colors.grey;
  }
}

String labelForAqi(int aqi) {
  switch (aqi) {
    case 1:
      return 'خوب';
    case 2:
      return 'متوسط';
    case 3:
      return 'ناسالم برای گروه‌های حساس';
    case 4:
      return 'ناسالم';
    case 5:
      return 'خیلی ناسالم';
    default:
      return 'نامشخص';
  }
}


