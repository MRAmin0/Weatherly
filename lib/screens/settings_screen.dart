import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// 👇 آدرس‌دهی مطلق (مطمئن شو 'weatherly_app' اسم پروژه در pubspec.yaml باشه)
import 'package:weatherly_app/weather_store.dart';
import 'package:weatherly_app/screens/about_screen.dart'; 

class SettingsScreen extends StatelessWidget {
  final ThemeMode currentThemeMode;
  final Function(ThemeMode) onThemeChanged;
  final VoidCallback onGoToDefaultCity; // برای برگشت به تب خانه
  final VoidCallback onGoToRecentCity; // برای برگشت به تب خانه

  const SettingsScreen({
    super.key,
    required this.currentThemeMode,
    required this.onThemeChanged,
    required this.onGoToDefaultCity,
    required this.onGoToRecentCity,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<WeatherStore>(
      builder: (context, store, _) {
        return Scaffold( 
          appBar: AppBar(
            title: const Text('تنظیمات'),
          ),
          body: ListView(
            // 👇 پدینگ پایین برای اسکرول کامل (120 پیکسل)
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 120), 
            children: [
              // --- بخش حالت نمایش ---
              Container( 
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'حالت نمایش',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const Divider(height: 24),
                    Center(
                      // 👇 بازگرداندن ToggleButtons
                      child: ToggleButtons(
                        isSelected: [
                          currentThemeMode == ThemeMode.system,
                          currentThemeMode == ThemeMode.light,
                          currentThemeMode == ThemeMode.dark,
                        ],
                        onPressed: (index) {
                          switch (index) {
                            case 0:
                              onThemeChanged(ThemeMode.system);
                              break;
                            case 1:
                              onThemeChanged(ThemeMode.light);
                              break;
                            case 2:
                              onThemeChanged(ThemeMode.dark);
                              break;
                          }
                        },
                        borderRadius: const BorderRadius.all(Radius.circular(12)),
                        constraints: const BoxConstraints(
                          minHeight: 40,
                          minWidth: 56,
                        ),
                        children: const [
                          Tooltip(
                            message: 'هماهنگ با سیستم',
                            child: Icon(Icons.phone_iphone),
                          ),
                          Tooltip(message: 'روشن', child: Icon(Icons.light_mode)),
                          Tooltip(message: 'تاریک', child: Icon(Icons.dark_mode)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 16), 

              // --- بخش تنظیمات نمایش ---
              Container( 
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    SwitchListTile(
                      title: const Text('نمایش دمای ساعتی'),
                      value: store.showHourly,
                      onChanged: (val) {
                        store.updatePreference('showHourly', val);
                      },
                    ),
                    SwitchListTile(
                      title: const Text('نمایش آلودگی هوا'),
                      value: store.showAirQuality,
                      onChanged: (val) {
                        store.updatePreference('showAirQuality', val);
                      },
                    ),
                    SwitchListTile(
                      title: const Text('واحد دما: سلسیوس'), 
                      subtitle: const Text('روشن: °C / خاموش: °F'),
                      value: store.useCelsius,
                      onChanged: (val) {
                        store.updatePreference('useCelsius', val);
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16), 
              
              // --- بخش شهر پیش‌فرض ---
              Container( 
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding( 
                      padding: const EdgeInsets.only(top: 8, right: 8, bottom: 8),
                      child: Text(
                        'شهر پیش‌فرض',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    const Divider(),
                    ListTile(
                      title: const Text('تنظیم شهر فعلی به عنوان پیش‌فرض'),
                      subtitle: Text('شهر فعلی: ${store.location}'),
                      trailing: const Icon(Icons.push_pin_outlined),
                      onTap: () {
                        store.updatePreference('defaultCity', store.location);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'شهر پیش‌فرض روی ${store.location} تنظیم شد',
                            ),
                          ),
                        );
                      },
                    ),
                    ListTile(
                      title: const Text('رفتن به شهر پیش‌فرض'),
                      subtitle: Text('پیش‌فرض فعلی: ${store.defaultCity}'),
                      trailing: const Icon(Icons.location_city_outlined),
                      onTap: () async {
                        await store.goToDefaultCity();
                        onGoToDefaultCity(); // 👈 به تب خانه برمی‌گردیم
                      },
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 16), 

              // --- بخش جستجوهای اخیر ---
              Container( 
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ExpansionTile(
                  title: const Text('جستجوهای اخیر'),
                  children: [
                    if (store.recentSearches.isEmpty)
                      const ListTile(title: Text('موردی وجود ندارد'))
                    else ...[
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxHeight: 200),
                        child: ListView(
                          shrinkWrap: true,
                          children: [
                            for (int i = 0; i < store.recentSearches.length; i++)
                              Dismissible(
                                key: ValueKey(
                                  'recent_${i}_${store.recentSearches[i]}',
                                ),
                                direction: DismissDirection.endToStart,
                                background: Container(
                                  alignment: Alignment.centerRight,
                                  color: Colors.redAccent,
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  child: const Icon(
                                    Icons.delete,
                                    color: Colors.white,
                                  ),
                                ),
                                onDismissed: (_) => store.removeRecentAt(i),
                                child: ListTile(
                                  title: Text(store.recentSearches[i]),
                                  onTap: () async {
                                    await store.searchAndFetchByCityName(
                                      store.recentSearches[i],
                                    );
                                    onGoToRecentCity(); // 👈 به تب خانه برمی‌گردیم
                                  },
                                ),
                              ),
                          ],
                        ),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        title: const Text('پاک کردن همه'),
                        trailing: const Icon(Icons.cleaning_services_outlined, color: Colors.redAccent),
                        onTap: store.clearRecentSearches,
                      ),
                    ],
                  ],
                ),
              ),
              
              const SizedBox(height: 16), 
              
              // --- بخش درباره ---
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: const Text('درباره برنامه'),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const AboutScreen()),
                    );
                  },
                ),
              ),
            ],
          ),
        );
        },
    );
  }
}