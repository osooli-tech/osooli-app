import 'package:get/get.dart';

import '../features/auth/presentation/bindings/auth_binding.dart';
import '../features/auth/presentation/pages/login_page.dart';
import '../features/auth/presentation/pages/otp_page.dart';
import '../features/auth/presentation/pages/splash_page.dart';
import '../features/compare/presentation/bindings/compare_binding.dart';
import '../features/compare/presentation/pages/compare_page.dart';
import '../features/dashboard/presentation/pages/cities_page.dart';
import '../features/legal/presentation/pages/policy_page.dart';
import '../features/onboarding/presentation/bindings/onboarding_binding.dart';
import '../features/onboarding/presentation/pages/onboarding_page.dart';
import '../features/parcels/presentation/bindings/parcels_bindings.dart';
import '../features/parcels/presentation/pages/documents_page.dart';
import '../features/parcels/presentation/pages/parcel_detail_page.dart';
import '../features/parcels/presentation/pages/parcels_page.dart';
import '../features/parcels/presentation/pages/survey_decisions_page.dart';
import '../features/requests/presentation/bindings/requests_binding.dart';
import '../features/requests/presentation/pages/requests_page.dart';
import '../features/shell/presentation/bindings/shell_binding.dart';
import '../features/shell/presentation/pages/shell_page.dart';

class Routes {
  static const splash = '/splash';
  static const onboarding = '/onboarding';
  static const login = '/login';
  static const otp = '/otp';
  static const home = '/home';
  static const parcels = '/parcels';
  static const parcelDetail = '/parcel-detail';
  static const compare = '/compare';
  static const requests = '/requests';
  static const cities = '/cities';
  static const surveyDecisions = '/survey-decisions';
  static const documents = '/documents';
  static const policy = '/policy';
}

class AppPages {
  static const initial = Routes.splash;

  static final routes = [
    GetPage(
      name: Routes.splash,
      page: () => const SplashPage(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: Routes.onboarding,
      page: () => const OnboardingPage(),
      binding: OnboardingBinding(),
    ),
    GetPage(
      name: Routes.login,
      page: () => const LoginPage(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: Routes.otp,
      page: () => const OtpPage(),
      binding: OtpBinding(),
    ),
    GetPage(
      name: Routes.home,
      page: () => const ShellPage(),
      binding: ShellBinding(),
    ),
    GetPage(
      name: Routes.parcels,
      page: () => const ParcelsPage(),
      binding: ParcelsBinding(),
    ),
    GetPage(
      name: Routes.parcelDetail,
      page: () => const ParcelDetailPage(),
      binding: ParcelDetailBinding(),
    ),
    GetPage(
      name: Routes.compare,
      page: () => const ComparePage(),
      binding: CompareBinding(),
    ),
    GetPage(
      name: Routes.requests,
      page: () => const RequestsPage(),
      binding: RequestsBinding(),
    ),
    GetPage(
      name: Routes.cities,
      page: () => const CitiesPage(),
    ),
    GetPage(
      name: Routes.surveyDecisions,
      page: () => const SurveyDecisionsPage(),
      binding: ParcelAggregatesBinding(),
    ),
    GetPage(
      name: Routes.documents,
      page: () => const DocumentsPage(),
      binding: ParcelAggregatesBinding(),
    ),
    GetPage(
      name: Routes.policy,
      page: () => const PolicyPage(),
    ),
  ];
}
