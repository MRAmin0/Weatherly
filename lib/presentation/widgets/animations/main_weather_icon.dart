import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:weatherly_app/data/models/weather_type.dart';
import 'package:weatherly_app/presentation/widgets/animations/weather_animator.dart';
// lib/widgets/animations/svg_assets.dart

import 'package:weatherly_app/presentation/widgets/animations/icon/svg_assets.dart';
import 'package:weatherly_app/presentation/widgets/animations/rain_drop_animator.dart';

class MainWeatherIcon extends StatelessWidget {
  final WeatherType weatherType;
  final double size;

  const MainWeatherIcon({
    super.key,
    required this.weatherType,
    this.size = 100,
  });

  @override
  Widget build(BuildContext context) {
    // اگر هوا صاف است، از آیکون ترکیبی (ابر + خورشید چرخان) استفاده کن
    if (weatherType == WeatherType.clear) {
      return SizedBox(
        width: size,
        height: size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // لایه ۱: ابر ثابت (زیر خورشید)
            SvgPicture.string(cloudSvg, width: size, height: size),

            // لایه ۲: خورشید چرخان
            WeatherAnimator(
              weatherType: WeatherType.clear, // تریگر چرخش
              customDuration: const Duration(seconds: 15), // سرعت چرخش ملایم
              child: SvgPicture.string(sunSvg, width: size, height: size),
            ),
          ],
        ),
      );
    }

    // اگر هوا بارانی است (یا رعدوبرق/نم‌نم)
    // نمایش ابر ثابت + قطرات متحرک
    if (weatherType == WeatherType.rain ||
        weatherType == WeatherType.drizzle ||
        weatherType == WeatherType.thunderstorm) {
      return SizedBox(
        width: size,
        height: size * 1.5, // افزایش ارتفاع برای فاصله گرفتن از دما
        child: Stack(
          alignment: Alignment.topCenter,
          clipBehavior: Clip.none,
          children: [
            // لایه ۱: ریزش قطرات (پشت ابر - پایین‌تر رفته تا بالای ابر دیده نشود)
            Positioned(
              top: size * 0.55,
              child: RainDropAnimator(width: size, height: size * 0.6),
            ),

            // لایه ۲: ابر متحرک (بالاتر رفته)
            Positioned(
              top: -size * 0.75,
              child: WeatherAnimator(
                weatherType: WeatherType.clouds, // بازگرداندن انیمیشن
                child: SvgPicture.string(
                  cloudSvg,
                  width: size * 1.6, // ۶۰ درصد بزرگتر
                  height: size * 1.6,
                ),
              ),
            ),

            // لایه ۳ (اختیاری): اگر رعدوبرق باشد
            if (weatherType == WeatherType.thunderstorm)
              Positioned(
                bottom: 0,
                right: size * 0.2,
                child: WeatherAnimator(
                  weatherType: WeatherType.thunderstorm,
                  child: const Icon(
                    Icons.flash_on,
                    color: Colors.amber,
                    size: 48,
                  ),
                ),
              ),
          ],
        ),
      );
    }

    // برای سایر وضعیت‌های آب‌وهوایی، از آیکون‌های پیش‌فرض استفاده کن
    final IconData iconData;
    final Color iconColor;

    switch (weatherType) {
      case WeatherType.clouds:
        iconData = Icons.cloud_rounded;
        iconColor = Colors.grey.shade400;
        break;

      case WeatherType.snow:
        iconData = Icons.ac_unit;
        iconColor = Colors.lightBlue.shade100;
        break;

      case WeatherType.windy:
        iconData = Icons.air;
        iconColor = Colors.blueGrey;
        break;

      case WeatherType.fog:
      case WeatherType.mist:
        iconData = Icons.foggy;
        iconColor = Colors.blueGrey.shade200;
        break;

      default:
        iconData = Icons.wb_cloudy;
        iconColor = Colors.grey;
    }

    return WeatherAnimator(
      weatherType: weatherType,
      child: Icon(
        iconData,
        size: size,
        color: iconColor,
        shadows: [
          BoxShadow(
            color: iconColor.withValues(alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
    );
  }
}
