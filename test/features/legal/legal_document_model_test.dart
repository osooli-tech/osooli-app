import 'package:flutter_test/flutter_test.dart';
import 'package:sakukiapp/features/legal/data/models/legal_document_model.dart';

void main() {
  test('parses the legal document payload', () {
    final model = LegalDocumentModel.fromJson({
      'key': 'privacy',
      'title': 'سياسة الخصوصية',
      'content_html': '<h2>مقدمة</h2><p>نص</p>',
      'updated_at': '2026-08-07T10:30:00+00:00',
    });

    expect(model.key, 'privacy');
    expect(model.title, 'سياسة الخصوصية');
    expect(model.contentHtml, contains('<h2>'));
    expect(model.updatedDate, isNotEmpty);
  });

  test('tolerates missing fields', () {
    final model = LegalDocumentModel.fromJson(const {});
    expect(model.contentHtml, '');
    expect(model.updatedDate, '');
  });
}
