class LegalDocumentModel {
  final String key;
  final String title;
  final String contentHtml;
  final String? updatedAt;

  const LegalDocumentModel({
    required this.key,
    required this.title,
    required this.contentHtml,
    this.updatedAt,
  });

  factory LegalDocumentModel.fromJson(Map<String, dynamic> json) =>
      LegalDocumentModel(
        key: json['key'] as String? ?? '',
        title: json['title'] as String? ?? '',
        contentHtml: json['content_html'] as String? ?? '',
        updatedAt: json['updated_at'] as String?,
      );

  /// yyyy/mm/dd from the ISO timestamp, empty when absent.
  String get updatedDate {
    final parsed = updatedAt == null ? null : DateTime.tryParse(updatedAt!);
    if (parsed == null) return '';
    final local = parsed.toLocal();
    return '${local.year}/${local.month.toString().padLeft(2, '0')}/${local.day.toString().padLeft(2, '0')}';
  }
}
