import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OnboardingController extends GetxController {
  final PageController pageController = PageController();

  RxInt currentPage = 0.obs;

  final pages = [
    {
      "image": "assets/images/logo.jpg",
      "title": "onboarding_title_1",
      "description": "onboarding_desc_1",
    },
    {
      "image": "assets/images/logo.jpg",
      "title": "onboarding_title_2",
      "description": "onboarding_desc_2",
    },
    {
      "image": "assets/images/logo.jpg",
      "title": "onboarding_title_3",
      "description": "onboarding_desc_3",
    },
  ];

  void onPageChanged(int index) {
    currentPage.value = index;
  }

  void nextPage() {
    if (currentPage.value < pages.length - 1) {
      pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.ease,
      );
    } else {
      Get.offAllNamed('/login');
    }
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
}
