import '../entities/modification_request.dart';
import '../repositories/requests_repository.dart';

class CreateRequest {
  final RequestsRepository repository;
  const CreateRequest(this.repository);

  Future<ModificationRequestItem> call({
    required int parcelId,
    required String fieldName,
    required String newValue,
    String? notes,
  }) =>
      repository.createRequest(
        parcelId: parcelId,
        fieldName: fieldName,
        newValue: newValue,
        notes: notes,
      );
}
