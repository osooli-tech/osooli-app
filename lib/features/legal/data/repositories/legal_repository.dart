import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../models/legal_document_model.dart';

class LegalRepository {
  final ApiClient client;
  const LegalRepository(this.client);

  Future<LegalDocumentModel> getDocument(String key) async {
    final res = await client.get(ApiEndpoints.legal(key));
    return LegalDocumentModel.fromJson(
        (res['data'] as Map<String, dynamic>?) ?? const {});
  }
}
