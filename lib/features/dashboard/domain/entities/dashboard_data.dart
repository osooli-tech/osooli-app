class DashboardStats {
  final int parcelsTotal;
  final int deedsActive;
  final int deedsExpired;
  final int parcelsWithoutDeed;
  final int surveyDecisionsTotal;
  final double areaTotalSqm;
  final int citiesCount;
  final int documentsCount;

  const DashboardStats({
    required this.parcelsTotal,
    required this.deedsActive,
    required this.deedsExpired,
    required this.parcelsWithoutDeed,
    required this.surveyDecisionsTotal,
    required this.areaTotalSqm,
    required this.citiesCount,
    required this.documentsCount,
  });
}

/// One row of the by-city / by-district breakdowns.
class NamedCount {
  final String name;
  final int parcelsCount;

  const NamedCount({required this.name, required this.parcelsCount});
}

class DashboardData {
  final String greetingName;
  final DashboardStats stats;
  final List<NamedCount> byCity;
  final List<NamedCount> byDistrict;
  final int unreadNotifications;

  const DashboardData({
    required this.greetingName,
    required this.stats,
    required this.byCity,
    required this.byDistrict,
    required this.unreadNotifications,
  });
}
