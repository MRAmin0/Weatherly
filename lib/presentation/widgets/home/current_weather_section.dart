import 'package:flutter/material.dart';
import 'package:weatherly_app/l10n/app_localizations.dart';
import 'package:weatherly_app/core/utils/weather_formatters.dart';

import 'package:weatherly_app/viewmodels/weather_viewmodel.dart';
import 'package:weatherly_app/presentation/widgets/animations/main_weather_icon.dart';

class CurrentWeatherSection extends StatelessWidget {
  final WeatherViewModel viewModel;
  final AppLocalizations l10n;

  const CurrentWeatherSection({
    super.key,
    required this.viewModel,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final current = viewModel.currentWeather;
    if (current == null) return const SizedBox.shrink();

    final isPersian = viewModel.lang == 'fa';
    final theme = Theme.of(context);

    final tempFormatted = formatTemperature(
      current.temp,
      isCelsius: viewModel.useCelsius,
      isPersian: isPersian,
    );

    return Column(
      children: [
        MainWeatherIcon(weatherType: current.weatherType, size: 160),
        const SizedBox(height: 16),
        Text(
          tempFormatted,
          style: theme.textTheme.displayLarge?.copyWith(
            fontWeight: FontWeight.w900,
            fontSize: 96,
            height: 1.0,
            color: Colors.white,
            shadows: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 15,
                offset: const Offset(0, 6),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),

        // --- Real Feel ---
        _buildRealFeel(current.feelsLike, viewModel.useCelsius, isPersian),

        const SizedBox(height: 12),
        Text(
          current.cityName,
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.white.withValues(alpha: 0.95),
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          translateWeatherDescription(current.main, lang: viewModel.lang),
          style: theme.textTheme.titleLarge?.copyWith(
            color: Colors.white.withValues(alpha: 0.8),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildRealFeel(double feelsLike, bool useCelsius, bool isPersian) {
    final formattedStr = formatTemperature(
      feelsLike,
      isCelsius: useCelsius,
      isPersian: isPersian,
    );
    final label = isPersian ? "حس واقعی" : "Real Feel";

    return Text(
      "$label: $formattedStr",
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w500,
        color: Colors.white.withValues(alpha: 0.7),
      ),
    );
  }
}
