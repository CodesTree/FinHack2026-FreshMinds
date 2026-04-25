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

  factory UserModel.fromApi(Map<String, dynamic> json) {
    return UserModel(
      id: json['user_id'] as String,
      name: (json['name'] as String?) ?? 'Siti Nurhaliza',
      walletBalance: (json['wallet_balance'] as num).toDouble(),
      survivalDays: json['survival_days'] as int,
      dailyBurnRate: (json['daily_burn_rate'] as num).toDouble(),
      trend: SurvivalTrend.values.byName(json['trend_7d'] as String),
      colorBand: SurvivalBand.values.byName(json['color_band'] as String),
      emergencyModeActive: (json['emergency_mode'] as bool?) ?? false,
      topDiscretionaryCategory: json['top_discretionary_category'] as String,
      topDiscretionaryAmount: (json['top_discretionary_amount_7d'] as num).toDouble(),
      hasActiveLoan: (json['has_active_loan'] as bool?) ?? false,
      monthlyIncome: (json['monthly_income'] as num?)?.toDouble() ?? 1800.0,
    );
  }

  UserModel copyWith({
    String? id,
    String? name,
    double? walletBalance,
    int? survivalDays,
    double? dailyBurnRate,
    SurvivalTrend? trend,
    SurvivalBand? colorBand,
    bool? emergencyModeActive,
    String? topDiscretionaryCategory,
    double? topDiscretionaryAmount,
    bool? hasActiveLoan,
    double? monthlyIncome,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      walletBalance: walletBalance ?? this.walletBalance,
      survivalDays: survivalDays ?? this.survivalDays,
      dailyBurnRate: dailyBurnRate ?? this.dailyBurnRate,
      trend: trend ?? this.trend,
      colorBand: colorBand ?? this.colorBand,
      emergencyModeActive: emergencyModeActive ?? this.emergencyModeActive,
      topDiscretionaryCategory: topDiscretionaryCategory ?? this.topDiscretionaryCategory,
      topDiscretionaryAmount: topDiscretionaryAmount ?? this.topDiscretionaryAmount,
      hasActiveLoan: hasActiveLoan ?? this.hasActiveLoan,
      monthlyIncome: monthlyIncome ?? this.monthlyIncome,
    );
  }
}

enum SurvivalTrend { improving, stable, declining }

enum SurvivalBand { green, amber, red }
