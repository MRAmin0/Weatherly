import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart'; // 👈 ایمپورت اضافه شد

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  Future<String> _loadVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      // فقط نسخه نمایشی بدون شماره بیلد
      return info.version;
    } catch (_) {
      return '—';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('درباره برنامه'), centerTitle: true),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // متن "هواشناسی" حذف شد
              const Text(
                'یک اپلیکیشن ساده و شیک برای مشاهده وضعیت آب‌وهوا و پیش‌بینی.\nمنابع داده: OpenWeatherMap',
                textAlign: TextAlign.right,
              ),
              const SizedBox(height: 24),
              FutureBuilder<String>(
                future: _loadVersion(),
                builder: (context, snap) {
                  final ver = snap.data;
                  return Text(
                    ver == null ? 'در حال خواندن نسخه…' : 'نسخه $ver',
                    textAlign: TextAlign.right,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
