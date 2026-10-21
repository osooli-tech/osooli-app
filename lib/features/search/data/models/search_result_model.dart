import '../../domain/entities/search_result.dart';

class SearchResultModel extends SearchResult {
  const SearchResultModel({
    required super.type,
    required super.id,
    required super.title,
    super.subtitle,
    super.badge,
  });

  factory SearchResultModel.fromJson(Map<String, dynamic> json) =>
      SearchResultModel(
        type: json['type'] as String? ?? 'parcel',
        id: (json['id'] as num?)?.toInt() ?? 0,
        title: json['title'] as String? ?? '',
        subtitle: json['subtitle'] as String?,
        badge: json['badge'] as String?,
      );
}
