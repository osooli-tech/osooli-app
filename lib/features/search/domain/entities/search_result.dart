class SearchResult {
  final String type;
  final int id;
  final String title;
  final String? subtitle;
  final String? badge;

  const SearchResult({
    required this.type,
    required this.id,
    required this.title,
    this.subtitle,
    this.badge,
  });
}
