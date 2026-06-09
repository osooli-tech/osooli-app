import 'package:get/get.dart';

import '../features/onboarding/presentation/pages/onboarding_page.dart';
import '../features/onboarding/presentation/bindings/onboarding_binding.dart';

class Routes {
  static const onboarding = '/onboarding';
}

class AppPages {
  static const initial = Routes.onboarding;

  static final routes = [
    GetPage(
      name: Routes.onboarding,
      page: () => const OnboardingPage(),
      binding: OnboardingBinding(),
    ),
  ];
}
