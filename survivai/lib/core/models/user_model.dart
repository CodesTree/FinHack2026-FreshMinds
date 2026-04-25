class UserModel {
  final String id;
  final String name;
  final double walletBalance;
  final int survivalDays;
  final double dailyBurnRate;
  final SurvivalTrend trend;
  final SurvivalBand colorBand;
  final bool emergencyModeActive;
  final String topDiscretionaryCategory;
  final double topDiscretionaryAmount;
  final bool hasActiveLoan;
  final double monthlyIncome;

  const UserModel({
    required this.id,
    required this.name,
    required this.walletBalance,
    required this.survivalDays,
    required this.dailyBurnRate,
    required this.trend,
    required this.colorBand,
    required this.emergencyModeActive,
    required this.topDiscretionaryCategory,
    required this.topDiscretionaryAmount,
    required this.hasActiveLoan,
    required this.monthlyIncome,
  });
}

enum SurvivalTrend { improving, stable, declining }

enum SurvivalBand { green, amber, red }
