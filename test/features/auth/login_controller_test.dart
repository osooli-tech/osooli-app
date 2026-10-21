import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:sakukiapp/core/errors/api_exception.dart';
import 'package:sakukiapp/features/auth/domain/entities/owner.dart';
import 'package:sakukiapp/features/auth/domain/repositories/auth_repository.dart';
import 'package:sakukiapp/features/auth/domain/usecases/request_otp.dart';
import 'package:sakukiapp/features/auth/presentation/controllers/login_controller.dart';

class StubRepo implements AuthRepository {
  Object? requestOtpError;
  String? lastPhone;

  @override
  Future<int> requestOtp(String phone) async {
    lastPhone = phone;
    if (requestOtpError != null) throw requestOtpError!;
    return 300;
  }

  @override
  Future<Owner> verifyOtp({required String phone, required String otp}) =>
      throw UnimplementedError();
  @override
  Future<void> logout() => throw UnimplementedError();
  @override
  Future<Owner?> savedOwner() async => null;
  @override
  Future<bool> hasSession() async => false;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => Get.testMode = true);
  tearDown(Get.reset);

  test('rejects invalid phone without calling API', () async {
    final repo = StubRepo();
    final c = LoginController(RequestOtp(repo));
    c.phoneController.text = '123';

    await c.submit();

    expect(c.error.value, 'phone_invalid');
    expect(repo.lastPhone, isNull);
  });

  test('normalizes phone and surfaces API errors', () async {
    final repo = StubRepo()
      ..requestOtpError =
          const ApiException(statusCode: 404, message: 'رقم الجوال غير مسجل');
    final c = LoginController(RequestOtp(repo));
    c.phoneController.text = '05 1111 1111';

    await c.submit();

    expect(repo.lastPhone, '0511111111');
    expect(c.error.value, 'رقم الجوال غير مسجل');
    expect(c.isLoading.value, isFalse);
  });
}
