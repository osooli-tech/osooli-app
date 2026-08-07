import 'package:get/get.dart';

import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/request_otp.dart';
import '../../domain/usecases/verify_otp.dart';
import '../controllers/login_controller.dart';
import '../controllers/otp_controller.dart';
import '../controllers/splash_controller.dart';

class SplashBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => SplashController(Get.find<AuthRepository>()));
  }
}

class LoginBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => LoginController(RequestOtp(Get.find<AuthRepository>())));
  }
}

class OtpBinding extends Bindings {
  @override
  void dependencies() {
    final repo = Get.find<AuthRepository>();
    Get.lazyPut(() => OtpController(
          verifyOtp: VerifyOtp(repo),
          requestOtp: RequestOtp(repo),
        ));
  }
}
