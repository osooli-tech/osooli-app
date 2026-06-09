import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'core/lang/app_translations.dart';
import 'routes/app_pages.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      translations: AppTranslations(),
      locale: const Locale('ar', 'SA'),
      fallbackLocale: const Locale('en', 'US'),
      debugShowCheckedModeBanner: false,
      title: 'Osoli',
      // أول شاشة
      initialRoute: AppPages.initial,
      // جميع Routes
      getPages: AppPages.routes,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Tajawal',
      ),
    );
  }
}
