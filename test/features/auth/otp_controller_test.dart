import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:sakukiapp/core/errors/api_exception.dart';
import 'package:sakukiapp/features/auth/domain/entities/owner.dart';
import 'package:sakukiapp/features/auth/domain/repositories/auth_repository.dart';
import 'package:sakukiapp/features/auth/domain/usecases/request_otp.dart';
import 'package:sakukiapp/features/auth/domain/usecases/verify_otp.dart';
import 'package:sakukiapp/features/auth/presentation/controllers/otp_controller.dart';

class StubRepo implements AuthRepository {
  Object? verifyError;
  String? verifiedOtp;

  @override
  Future<int> requestOtp(String phone) async => 300;

  @override
  Future<Owner> verifyOtp({required String phone, required String otp}) async {
    verifiedOtp = otp;
    if (verifyError != null) throw verifyError!;
    return const Owner(id: 1, name: 'م', nationalId: '1', phone: '0511111111');
  }

  @override
  Future<void> logout() async {}
  @override
  Future<Owner?> savedOwner() async => null;
  @override
  Future<bool> hasSession() async => false;
}

OtpController _make(StubRepo repo) => OtpController(
      verifyOtp: VerifyOtp(repo),
      requestOtp: RequestOtp(repo),
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => Get.testMode = true);
  tearDown(Get.reset);

  test('short otp sets otp_invalid without calling API', () async {
    final repo = StubRepo();
    final c = _make(repo)..onInit();

    c.onOtpChanged('66');
    await c.verify();

    expect(c.error.value, 'otp_invalid');
    expect(repo.verifiedOtp, isNull);
    c.onClose();
  });

  test('wrong code surfaces field error from 422', () async {
    final repo = StubRepo()
      ..verifyError = const ApiException(
        statusCode: 422,
        message: 'Invalid verification code',
        fieldErrors: {
          'otp': ['رمز التحقق غير صحيح']
        },
      );
    final c = _make(repo)..onInit();

    c.onOtpChanged('1234'); // auto-submits at otpLength

    await Future<void>.delayed(Duration.zero);
    expect(repo.verifiedOtp, '1234');
    expect(c.error.value, 'رمز التحقق غير صحيح');
    c.onClose();
  });
}
