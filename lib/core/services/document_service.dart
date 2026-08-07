import 'dart:io';

import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';

import '../constants/api_endpoints.dart';
import '../network/api_client.dart';

/// Downloads a protected document (Bearer token attached) to the temp
/// directory and opens it with the platform viewer.
class DocumentService {
  final ApiClient client;
  const DocumentService(this.client);

  Future<void> openDocument({
    required int documentId,
    String? fileType,
  }) async {
    final bytes = await client.getBytes(ApiEndpoints.documentDownload(documentId));
    final extension = (fileType == null || fileType.isEmpty) ? 'pdf' : fileType;
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/document_$documentId.$extension');
    await file.writeAsBytes(bytes, flush: true);
    await OpenFilex.open(file.path);
  }
}
