# Dashboard + Parcel Comparison — Design Spec

**Date:** 2026-08-07 · **App:** osooli-app · **API:** verified against osooli-web source (routes/api.php, OwnerStatisticsService, ParcelListResource, ParcelDetailResource)

## Scope

1. **Main shell** — bottom nav (IndexedStack, GetX): الرئيسية (dashboard) · العقارات (placeholder) · المقارنة (compare) · المزيد (owner info + logout). Route `/home` now renders the shell.
2. **Dashboard page** — from `GET /dashboard`: teal header (greeting + notification bell with `unread_notifications` badge), 8 stat cards (parcels_total, deeds_active, deeds_expired, parcels_without_deed, survey_decisions_total, area_total_sqm, cities_count, documents_count), two bar charts (by_city, by_district) drawn with plain widgets, pull-to-refresh.
3. **Comparison page** — two parcel pickers fed by `GET /parcels` (per_page=100); side-by-side table (area, district+city, deed status, hijri deed date, plan no) in teal/gold mockup style; `flutter_map` with both parcels' polygons (teal = أ, navy = ب) from `GET /parcels/{id}` geometry (MultiPolygon GeoJSON, [lng,lat] order, outer rings only).

**Mockup elements dropped (no API support):** pending/new parcel counts, data-completeness %, asset-type pie, add-parcel action.

## Architecture additions

```
core/constants/api_endpoints.dart      # endpoint path constants
core/network/api_client.dart           # get() gains Map<String,String>? query
core/models/paginated_data.dart        # PaginatedData<T>{items, currentPage, perPage, total, lastPage}
core/widgets/                          # StatCard, NoDataWidget, AppLoader, SimpleBarChart
features/dashboard/{domain,data,presentation}
  entities: DashboardData{greetingName, stats: DashboardStats, byCity/byDistrict: List<NamedCount>, unreadNotifications}
  usecase: GetDashboard
features/parcels/{domain,data}         # shared by compare (UI tab later)
  entities: ParcelSummary{id, parcelNo, assetType, planNo, city, district, areaSqm, deedStatus, deedDateHijri}
            ParcelDetail{...summary fields..., polygons: List<List<LatLng>>, centroid}
  usecases: GetParcels (paginated), GetParcelDetail
features/compare/presentation          # CompareController + page + widgets
features/shell/presentation            # ShellController(currentTab) + ShellPage + MoreTab
```

- Repos registered in `InitialBinding` (permanent, like AuthRepository).
- `flutter_map` v2 API: MapOptions(bounds: LatLngBounds.fromPoints(all points), boundsOptions padding), TileLayer OSM, PolygonLayer.
- Nullable-safe: any missing field renders `—`; parcels without geometry are shown in the table but excluded from the map.
- Errors: same ApiException flow; dashboard shows retry view on failure.
