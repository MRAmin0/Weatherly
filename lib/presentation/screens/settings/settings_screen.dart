import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:weatherly_app/l10n/app_localizations.dart';
import 'package:weatherly_app/presentation/screens/about/about_screen.dart';
import 'package:weatherly_app/viewmodels/weather_viewmodel.dart';
import 'package:weatherly_app/presentation/widgets/home/weather_background_wrapper.dart';
import 'package:weatherly_app/data/models/weather_type.dart';
import 'package:weatherly_app/presentation/widgets/common/glass_container.dart';
import 'package:weatherly_app/data/services/notification_service.dart';

class SettingsScreen extends StatefulWidget {
  final VoidCallback onGoToRecentCity;

  const SettingsScreen({super.key, required this.onGoToRecentCity});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _showLanguageDialog(AppLocalizations l10n, WeatherViewModel vm) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.4),
      builder: (context) {
        final dialogContent = AlertDialog(
          backgroundColor: Colors.white.withValues(alpha: 0.25),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
            side: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
          ),
          title: Text(
            l10n.language,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _LanguageOptionTile(
                flag: '🇮🇷',
                label: l10n.persian,
                isSelected: vm.lang == 'fa',
                textColor: Colors.white,
                onTap: () {
                  vm.setLang('fa');
                  Navigator.pop(context);
                },
              ),
              Divider(color: Colors.white.withValues(alpha: 0.1)),
              _LanguageOptionTile(
                flag: '🇬🇧',
                label: l10n.english,
                isSelected: vm.lang == 'en',
                textColor: Colors.white,
                onTap: () {
                  vm.setLang('en');
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );

        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: dialogContent,
        );
      },
    );
  }

  String _formatTime(int hour, int minute) {
    final h = hour.toString().padLeft(2, '0');
    final m = minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  Future<void> _showTimePicker(
    BuildContext context,
    WeatherViewModel vm,
  ) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: vm.dailyNotificationHour,
        minute: vm.dailyNotificationMinute,
      ),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: ColorScheme.dark(
              primary: Colors.white,
              onPrimary: Colors.black,
              surface: Colors.grey[900]!,
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      await vm.setDailyNotificationTime(picked.hour, picked.minute);
    }
  }

  Future<void> _testDailyNotification(
    BuildContext context,
    WeatherViewModel vm,
  ) async {
    final notificationService = NotificationService();
    await notificationService.initialize();
    await notificationService.requestPermission();

    final isFarsi = vm.lang == 'fa';
    await notificationService.showWeatherNotification(
      title: isFarsi ? '☀️ هوای امروز' : '☀️ Today\'s Weather',
      body: isFarsi
          ? 'این یک نوتیفیکیشن تستی است!'
          : 'This is a test notification!',
    );
  }

  Color _getWeatherColor(WeatherType type, bool isDark) {
    switch (type) {
      case WeatherType.clear:
        return isDark ? const Color(0xFF1A237E) : const Color(0xFF01579B);
      case WeatherType.clouds:
        return isDark ? const Color(0xFF37474F) : const Color(0xFF546E7A);
      case WeatherType.rain:
      case WeatherType.drizzle:
        return isDark ? const Color(0xFF01579B) : const Color(0xFF1976D2);
      case WeatherType.thunderstorm:
        return isDark ? const Color(0xFF311B92) : const Color(0xFF512DA8);
      case WeatherType.snow:
        return isDark ? const Color(0xFF455A64) : const Color(0xFF0288D1);
      case WeatherType.mist:
      case WeatherType.smoke:
      case WeatherType.haze:
      case WeatherType.fog:
      case WeatherType.sand:
      case WeatherType.dust:
      case WeatherType.ash:
      case WeatherType.squall:
      case WeatherType.tornado:
      case WeatherType.atmosphere:
      case WeatherType.windy:
        return isDark ? const Color(0xFF263238) : const Color(0xFF607D8B);
      case WeatherType.unknown:
        return const Color.fromARGB(128, 73, 73, 73);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final vm = context.watch<WeatherViewModel>();
    final theme = Theme.of(context);
    final isAppDark = theme.brightness == Brightness.dark;
    final weatherType = vm.currentWeather?.weatherType ?? WeatherType.unknown;
    final activeColor = _getWeatherColor(weatherType, isAppDark);

    final textColor = isAppDark ? Colors.white : Colors.black;
    final subTextColor = isAppDark
        ? Colors.white.withValues(alpha: 0.6)
        : Colors.black.withValues(alpha: 0.6);

    return WeatherBackgroundWrapper(
      weatherType: weatherType,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SafeArea(
                        bottom: false,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Center(
                            child: Text(
                              l10n.settings,
                              style: TextStyle(
                                color: textColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 24,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                        ),
                      ),

                      // LANGUAGE
                      _buildSectionTitle(l10n.language, isDark: isAppDark),
                      GlassContainer(
                        isDark: isAppDark,
                        blur: 0, // Performance optimization
                        padding: EdgeInsets.zero,
                        borderRadius: 25,
                        child: ListTile(
                          leading: Icon(
                            Icons.language_rounded,
                            color: textColor,
                          ),
                          title: Text(
                            l10n.language,
                            style: TextStyle(color: textColor),
                          ),
                          subtitle: Text(
                            vm.lang == 'fa' ? l10n.persian : l10n.english,
                            style: TextStyle(color: subTextColor),
                          ),
                          onTap: () => _showLanguageDialog(l10n, vm),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // THEME
                      _buildSectionTitle(l10n.displayMode, isDark: isAppDark),
                      GlassContainer(
                        isDark: isAppDark,
                        blur: 0, // Performance optimization
                        borderRadius: 25,
                        child: _buildThemeModeSelector(
                          l10n,
                          vm,
                          isAppDark,
                          activeColor,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // WEATHER SOURCE
                      _buildSectionTitle(l10n.weatherSource, isDark: isAppDark),
                      GlassContainer(
                        isDark: isAppDark,
                        blur: 0, // Performance optimization
                        borderRadius: 25,
                        child: _buildWeatherProviderSelector(
                          l10n,
                          vm,
                          isAppDark,
                          activeColor,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // UNITS
                      _buildSectionTitle(
                        l10n.temperatureUnitCelsius,
                        isDark: isAppDark,
                      ),
                      GlassContainer(
                        isDark: isAppDark,
                        blur: 0, // Performance optimization
                        padding: EdgeInsets.zero,
                        borderRadius: 25,
                        child: SwitchListTile(
                          title: Text(
                            l10n.temperatureUnitCelsius,
                            style: TextStyle(color: textColor),
                          ),
                          subtitle: Text(
                            l10n.celsiusFahrenheit,
                            style: TextStyle(color: subTextColor),
                          ),
                          activeThumbColor: Colors.white,
                          value: vm.useCelsius,
                          onChanged: vm.setUseCelsius,
                          activeTrackColor: Colors.white,
                          inactiveTrackColor: Colors.transparent,
                          thumbColor: WidgetStateProperty.resolveWith((states) {
                            if (states.contains(WidgetState.selected)) {
                              return activeColor; // User requested "not black"
                            }
                            return isAppDark ? Colors.white60 : Colors.grey;
                          }),
                          trackOutlineColor: WidgetStateProperty.resolveWith((
                            states,
                          ) {
                            if (states.contains(WidgetState.selected)) {
                              return Colors.white;
                            }
                            return isAppDark ? Colors.white60 : Colors.grey;
                          }),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // NOTIFICATIONS
                      _buildSectionTitle(
                        l10n.smartNotifications,
                        isDark: isAppDark,
                      ),
                      GlassContainer(
                        isDark: isAppDark,
                        blur: 0, // Performance optimization
                        padding: EdgeInsets.zero,
                        borderRadius: 25,
                        child: Column(
                          children: [
                            SwitchListTile(
                              secondary: Icon(
                                Icons.notifications_active_rounded,
                                color: textColor,
                              ),
                              title: Text(
                                l10n.smartNotifications,
                                style: TextStyle(color: textColor),
                              ),
                              subtitle: Text(
                                l10n.smartNotificationsDesc,
                                style: TextStyle(color: subTextColor),
                              ),
                              activeThumbColor: Colors.white,
                              value: vm.smartNotificationsEnabled,
                              onChanged: vm.setSmartNotifications,
                              activeTrackColor: Colors.white,
                              inactiveTrackColor: Colors.transparent,
                              thumbColor: WidgetStateProperty.resolveWith((
                                states,
                              ) {
                                if (states.contains(WidgetState.selected)) {
                                  return activeColor;
                                }
                                return isAppDark ? Colors.white60 : Colors.grey;
                              }),
                              trackOutlineColor:
                                  WidgetStateProperty.resolveWith((states) {
                                    if (states.contains(WidgetState.selected)) {
                                      return Colors.white;
                                    }
                                    return isAppDark
                                        ? Colors.white60
                                        : Colors.grey;
                                  }),
                            ),
                            Divider(
                              color: isAppDark
                                  ? Colors.white.withValues(alpha: 0.1)
                                  : Colors.black.withValues(alpha: 0.1),
                            ),
                            SwitchListTile(
                              secondary: Icon(
                                Icons.alarm_rounded,
                                color: textColor,
                              ),
                              title: Text(
                                l10n.dailyNotifications,
                                style: TextStyle(color: textColor),
                              ),
                              subtitle: Text(
                                vm.lang == 'fa'
                                    ? 'ساعت ${_formatTime(vm.dailyNotificationHour, vm.dailyNotificationMinute)}'
                                    : 'Daily summary at ${_formatTime(vm.dailyNotificationHour, vm.dailyNotificationMinute)}',
                                style: TextStyle(color: subTextColor),
                              ),
                              activeThumbColor: Colors.white,
                              value: vm.dailyNotificationsEnabled,
                              onChanged: vm.setDailyNotifications,
                              activeTrackColor: Colors.white,
                              inactiveTrackColor: Colors.transparent,
                              thumbColor: WidgetStateProperty.resolveWith((
                                states,
                              ) {
                                if (states.contains(WidgetState.selected)) {
                                  return activeColor;
                                }
                                return isAppDark ? Colors.white60 : Colors.grey;
                              }),
                              trackOutlineColor:
                                  WidgetStateProperty.resolveWith((states) {
                                    if (states.contains(WidgetState.selected)) {
                                      return Colors.white;
                                    }
                                    return isAppDark
                                        ? Colors.white60
                                        : Colors.grey;
                                  }),
                            ),
                            if (vm.dailyNotificationsEnabled) ...[
                              ListTile(
                                leading: Icon(
                                  Icons.schedule_rounded,
                                  color: textColor,
                                ),
                                title: Text(
                                  l10n.notificationTimeLabel,
                                  style: TextStyle(color: textColor),
                                ),
                                trailing: Icon(
                                  Icons.edit_rounded,
                                  color: subTextColor,
                                  size: 18,
                                ),
                                onTap: () => _showTimePicker(context, vm),
                              ),
                              ListTile(
                                leading: Icon(
                                  Icons.play_arrow_rounded,
                                  color: textColor,
                                ),
                                title: Text(
                                  vm.lang == 'fa'
                                      ? 'تست نوتیفیکیشن'
                                      : 'Test Notification',
                                  style: TextStyle(color: textColor),
                                ),
                                onTap: () =>
                                    _testDailyNotification(context, vm),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // ABOUT
                      _buildSectionTitle(l10n.aboutApp, isDark: isAppDark),
                      GlassContainer(
                        isDark: isAppDark,
                        blur: 0, // Performance optimization
                        padding: EdgeInsets.zero,
                        borderRadius: 25,
                        child: ListTile(
                          leading: Icon(
                            Icons.info_outline_rounded,
                            color: textColor,
                          ),
                          title: Text(
                            l10n.aboutApp,
                            style: TextStyle(color: textColor),
                          ),
                          trailing: Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 16,
                            color: subTextColor,
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const AboutScreen(),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 48),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildThemeModeSelector(
    AppLocalizations l10n,
    WeatherViewModel vm,
    bool isAppDark,
    Color activeColor,
  ) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildThemeChip(
            ThemeMode.system,
            l10n.system,
            Icons.brightness_auto_rounded,
            vm,
            isAppDark,
            activeColor,
          ),
          const SizedBox(width: 8),
          _buildThemeChip(
            ThemeMode.light,
            l10n.light,
            Icons.wb_sunny_rounded,
            vm,
            isAppDark,
            activeColor,
          ),
          const SizedBox(width: 8),
          _buildThemeChip(
            ThemeMode.dark,
            l10n.dark,
            Icons.nightlight_round,
            vm,
            isAppDark,
            activeColor,
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherProviderSelector(
    AppLocalizations l10n,
    WeatherViewModel vm,
    bool isAppDark,
    Color activeColor,
  ) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildProviderChip(
            WeatherProvider.openWeather,
            'OpenWeather',
            Icons.cloud_queue_rounded,
            vm,
            isAppDark,
            activeColor,
          ),
          const SizedBox(width: 8),
          _buildProviderChip(
            WeatherProvider.accuWeather,
            'AccuWeather',
            Icons.wb_sunny_outlined,
            vm,
            isAppDark,
            activeColor,
          ),
          const SizedBox(width: 8),
          _buildProviderChip(
            WeatherProvider.weatherCom,
            'Weather.com',
            Icons.language_rounded,
            vm,
            isAppDark,
            activeColor,
            isComingSoon: true,
          ),
        ],
      ),
    );
  }

  Widget _buildProviderChip(
    WeatherProvider targetProvider,
    String label,
    IconData icon,
    WeatherViewModel vm,
    bool isAppDark,
    Color activeColor, {
    bool isComingSoon = false,
  }) {
    final isSelected = vm.provider == targetProvider;

    return ChoiceChip(
      label: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label),
          if (isComingSoon)
            Text(
              vm.lang == 'fa' ? 'به زودی' : 'Soon',
              style: const TextStyle(
                color: Colors.redAccent,
                fontSize: 8,
                fontWeight: FontWeight.bold,
              ),
            ),
        ],
      ),
      selected: isSelected && !isComingSoon,
      onSelected: isComingSoon
          ? null
          : (val) {
              if (val) {
                vm.setWeatherProvider(targetProvider);
              }
            },
      avatar: Icon(
        icon,
        color: (isSelected && !isComingSoon)
            ? activeColor
            : (isAppDark ? Colors.white : Colors.black),
        size: 18,
      ),
      selectedColor: Colors.white,
      backgroundColor: Colors.transparent,
      // Removed color: property to avoid conflicts since we used explicit background/selected colors
      // but ChoiceChip in older flutter versions might rely on 'selectedColor' and 'backgroundColor'.
      // If 'color' was working for selected state (returning white), it might be redundant now.
      // However, to be absolutely sure unselected is transparent:
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      pressElevation: 0,
      shadowColor: Colors.transparent,
      selectedShadowColor: Colors.transparent,
      labelStyle: TextStyle(
        color: (isSelected && !isComingSoon)
            ? activeColor
            : (isAppDark ? Colors.white : Colors.black),
        fontWeight: FontWeight.bold, // Always bold for better legibility
      ),
      iconTheme: IconThemeData(
        color: (isSelected && !isComingSoon)
            ? activeColor
            : (isAppDark ? Colors.white : Colors.black),
        size: 18,
      ),
      side: BorderSide(
        color: (isSelected && !isComingSoon)
            ? Colors.white
            : Colors.transparent, // Outline only when selected for style
        width: 1.5,
      ),

      showCheckmark: false,
    );
  }

  Widget _buildThemeChip(
    ThemeMode mode,
    String label,
    IconData icon,
    WeatherViewModel vm,
    bool isAppDark,
    Color activeColor,
  ) {
    final isSelected = vm.themeMode == mode;

    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (val) {
        if (val) {
          vm.setThemeMode(mode);
        }
      },
      avatar: Icon(
        icon,
        color: isSelected
            ? activeColor
            : (isAppDark ? Colors.white : Colors.black),
        size: 18,
      ),
      selectedColor: Colors.white,
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      pressElevation: 0,
      shadowColor: Colors.transparent,
      selectedShadowColor: Colors.transparent,
      labelStyle: TextStyle(
        color: isSelected
            ? activeColor
            : (isAppDark ? Colors.white : Colors.black),
        fontWeight: FontWeight.bold, // Always bold for better legibility
      ),
      iconTheme: IconThemeData(
        color: isSelected
            ? activeColor
            : (isAppDark ? Colors.white : Colors.black),
        size: 18,
      ),
      side: BorderSide(
        color: isSelected ? Colors.white : Colors.transparent,
        width: 1.5,
      ),

      showCheckmark: false,
    );
  }

  Widget _buildSectionTitle(String title, {bool isDark = true}) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, right: 8, bottom: 12),
      child: Text(
        title,
        style: TextStyle(
          color: isDark ? Colors.white : Colors.black,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }
}

class _LanguageOptionTile extends StatelessWidget {
  final String flag;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Color? textColor;

  const _LanguageOptionTile({
    required this.flag,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Text(flag, style: const TextStyle(fontSize: 24)),
      title: Text(
        label,
        style: TextStyle(
          color: textColor ?? Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      trailing: isSelected
          ? const Icon(Icons.check_circle_rounded, color: Colors.white)
          : null,
      onTap: onTap,
    );
  }
}
