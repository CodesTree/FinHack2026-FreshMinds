import 'package:flutter_test/flutter_test.dart';
import 'package:survivai/core/models/user_model.dart';
import 'package:survivai/core/providers/app_provider.dart';
import 'package:survivai/core/services/survivai_repository.dart';

class FakeRepository extends SurvivaiRepository {
  @override
  Future<UserModel> fetchSurvivalScore(String userId) async {
    return const UserModel(
      id: 'user_siti_001',
      name: 'Siti Nurhaliza',
      walletBalance: 87.0,
      survivalDays: 11,
      dailyBurnRate: 7.9,
      trend: SurvivalTrend.declining,
      colorBand: SurvivalBand.red,
      emergencyModeActive: false,
      topDiscretionaryCategory: 'Grab Food',
      topDiscretionaryAmount: 42.0,
      hasActiveLoan: false,
      monthlyIncome: 1800.0,
    );
  }
}

void main() {
  test('loads user from API repository', () async {
    final provider = AppProvider.test(repository: FakeRepository());
    await provider.loadDashboard();

    expect(provider.user.id, 'user_siti_001');
    expect(provider.user.survivalDays, 11);
    expect(provider.error, isNull);
  });
}
