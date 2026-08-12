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

/// Estimated value of the owner's holdings, weighted by ownership share.
///
/// [totalValue] is null when none of the owner's parcels carry a price yet,
/// so the UI can hide the card instead of showing a misleading zero.
class PortfolioSummary {
  final double? totalValue;
  final int pricedParcels;
  final int totalParcels;
  final double? avgMPrice;

  const PortfolioSummary({
    this.totalValue,
    this.pricedParcels = 0,
    this.totalParcels = 0,
    this.avgMPrice,
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
  final PortfolioSummary portfolio;
  final List<NamedCount> byCity;
  final List<NamedCount> byDistrict;
  final int unreadNotifications;

  const DashboardData({
    required this.greetingName,
    required this.stats,
    this.portfolio = const PortfolioSummary(),
    required this.byCity,
    required this.byDistrict,
    required this.unreadNotifications,
  });
}
