import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../../domain/entities/dashboard_data.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../models/dashboard_data_model.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  final ApiClient client;
  const DashboardRepositoryImpl(this.client);

  @override
  Future<DashboardData> getDashboard() async {
    final res = await client.get(ApiEndpoints.dashboard);
    return DashboardDataModel.fromJson(
        (res['data'] as Map<String, dynamic>?) ?? const {});
  }
}
