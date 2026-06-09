import 'package:get/get.dart';

class AppTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
        'en_US': {
          'skip': 'Skip',
          'next': 'Next',
          'title': 'Welcome',
          'description': 'This is onboarding screen',
          'onboarding_title_1': 'Welcome to Osoli',
          'onboarding_desc_1': 'Your smart real estate management platform',
          'onboarding_title_2': 'Property Management',
          'onboarding_desc_2': 'Track all your properties easily',
          'onboarding_title_3': 'Smart Reports',
          'onboarding_desc_3': 'Get accurate and updated reports',
        },
        'ar_SA': {
          'skip': 'تخطي',
          'next': 'التالي',
          'title': 'مرحباً',
          'description': 'هذه شاشة التعريف',
          'onboarding_title_1': 'مرحباً في أصولي',
          'onboarding_desc_1': 'منصتك الذكية لإدارة عقاراتك وصكوكك',
          'onboarding_title_2': 'إدارة العقارات',
          'onboarding_desc_2': 'تابع جميع عقاراتك بسهولة',
          'onboarding_title_3': 'تقارير ذكية',
          'onboarding_desc_3': 'احصل على تقارير دقيقة ومحدثة',
        },
      };
}
