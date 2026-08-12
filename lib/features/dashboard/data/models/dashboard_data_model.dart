import '../../domain/entities/dashboard_data.dart';

class DashboardDataModel extends DashboardData {
  const DashboardDataModel({
    required super.greetingName,
    required super.stats,
    super.portfolio,
    required super.byCity,
    required super.byDistrict,
    required super.unreadNotifications,
  });

  factory DashboardDataModel.fromJson(Map<String, dynamic> json) {
    final stats = (json['stats'] as Map<String, dynamic>?) ?? const {};
    final portfolio = (json['portfolio'] as Map<String, dynamic>?) ?? const {};
    return DashboardDataModel(
      greetingName: json['greeting_name'] as String? ?? '',
      stats: DashboardStats(
        parcelsTotal: _int(stats['parcels_total']),
        deedsActive: _int(stats['deeds_active']),
        deedsExpired: _int(stats['deeds_expired']),
        parcelsWithoutDeed: _int(stats['parcels_without_deed']),
        surveyDecisionsTotal: _int(stats['survey_decisions_total']),
        areaTotalSqm: _double(stats['area_total_sqm']),
        citiesCount: _int(stats['cities_count']),
        documentsCount: _int(stats['documents_count']),
      ),
      portfolio: PortfolioSummary(
        totalValue: (portfolio['total_value'] as num?)?.toDouble(),
        pricedParcels: _int(portfolio['priced_parcels']),
        totalParcels: _int(portfolio['total_parcels']),
        avgMPrice: (portfolio['avg_m_price'] as num?)?.toDouble(),
      ),
      byCity: _counts(json['by_city']),
      byDistrict: _counts(json['by_district']),
      unreadNotifications: _int(json['unread_notifications']),
    );
  }

  static int _int(Object? value) => (value as num?)?.toInt() ?? 0;

  static double _double(Object? value) => (value as num?)?.toDouble() ?? 0;

  static List<NamedCount> _counts(Object? value) =>
      (value as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map((row) => NamedCount(
                name: row['name'] as String? ?? '',
                parcelsCount: _int(row['parcels_count']),
              ))
          .toList();
}
