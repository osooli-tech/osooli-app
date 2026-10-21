import '../repositories/auth_repository.dart';

class RequestOtp {
  final AuthRepository repository;
  const RequestOtp(this.repository);

  Future<int> call(String phone) => repository.requestOtp(phone);
}
