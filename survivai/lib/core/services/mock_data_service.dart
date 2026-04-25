import '../models/user_model.dart';
import '../models/transaction_model.dart';
import '../models/loan_model.dart';
import '../models/nudge_model.dart';

class MockDataService {
  static UserModel getSitiProfile() {
    return const UserModel(
      id: 'user_siti_001',
      name: 'Siti Nurhaliza',
      walletBalance: 87.00,
      survivalDays: 11,
      dailyBurnRate: 7.90,
      trend: SurvivalTrend.declining,
      colorBand: SurvivalBand.red,
      emergencyModeActive: false,
      topDiscretionaryCategory: 'Grab Food',
      topDiscretionaryAmount: 42.00,
      hasActiveLoan: false,
      monthlyIncome: 1800.00,
    );
  }

  static UserModel getSitiEmergencyProfile() {
    return const UserModel(
      id: 'user_siti_001',
      name: 'Siti Nurhaliza',
      walletBalance: 31.60,
      survivalDays: 4,
      dailyBurnRate: 7.90,
      trend: SurvivalTrend.declining,
      colorBand: SurvivalBand.red,
      emergencyModeActive: true,
      topDiscretionaryCategory: 'Grab Food',
      topDiscretionaryAmount: 42.00,
      hasActiveLoan: false,
      monthlyIncome: 1800.00,
    );
  }

  static List<TransactionModel> getRecentTransactions() {
    final now = DateTime.now();
    return [
      TransactionModel(
        id: 'txn_001',
        merchantName: 'Giant Hypermarket Shah Alam',
        amount: 45.80,
        category: TransactionCategory.essential,
        timestamp: now.subtract(const Duration(hours: 3)),
        mcc: '5411',
      ),
      TransactionModel(
        id: 'txn_002',
        merchantName: 'Grab Food',
        amount: 18.90,
        category: TransactionCategory.discretionary,
        timestamp: now.subtract(const Duration(hours: 7)),
        mcc: '5812',
      ),
      TransactionModel(
        id: 'txn_003',
        merchantName: 'Mini Mart Ali',
        amount: 12.50,
        category: TransactionCategory.essential,
        timestamp: now.subtract(const Duration(days: 1)),
        mcc: '5441',
      ),
      TransactionModel(
        id: 'txn_004',
        merchantName: 'Power Company',
        amount: 78.00,
        category: TransactionCategory.essential,
        timestamp: now.subtract(const Duration(days: 1, hours: 4)),
        mcc: '4900',
      ),
      TransactionModel(
        id: 'txn_005',
        merchantName: 'Grab Food',
        amount: 23.10,
        category: TransactionCategory.discretionary,
        timestamp: now.subtract(const Duration(days: 2)),
        mcc: '5812',
      ),
      TransactionModel(
        id: 'txn_006',
        merchantName: 'Shell Petrol Station',
        amount: 50.00,
        category: TransactionCategory.essential,
        timestamp: now.subtract(const Duration(days: 2, hours: 2)),
        mcc: '5541',
      ),
      TransactionModel(
        id: 'txn_007',
        merchantName: 'Shopee',
        amount: 34.90,
        category: TransactionCategory.discretionary,
        timestamp: now.subtract(const Duration(days: 3)),
        mcc: '5965',
      ),
      TransactionModel(
        id: 'txn_008',
        merchantName: 'Local Restaurant',
        amount: 8.50,
        category: TransactionCategory.essential,
        timestamp: now.subtract(const Duration(days: 3, hours: 6)),
        mcc: '5812',
      ),
      TransactionModel(
        id: 'txn_009',
        merchantName: 'Watson\'s Pharmacy',
        amount: 22.00,
        category: TransactionCategory.essential,
        timestamp: now.subtract(const Duration(days: 4)),
        mcc: '5912',
      ),
      TransactionModel(
        id: 'txn_010',
        merchantName: 'Water Utility',
        amount: 35.00,
        category: TransactionCategory.essential,
        timestamp: now.subtract(const Duration(days: 5)),
        mcc: '4900',
      ),
    ];
  }

  static LoanModel getApprovedLoan() {
    return LoanModel(
      id: 'loan_001',
      amount: 150.00,
      restrictedBalanceRemaining: 150.00,
      status: LoanStatus.active,
      disbursedAt: DateTime.now(),
      repaymentSchedule: List.generate(
        10,
        (i) => RepaymentEntry(week: i + 1, amount: 15.00, paid: false),
      ),
      topFactors: [
        'Regular weekly top-ups (+)',
        'Electricity bill paid consistently (+)',
        'High food delivery spending (-)',
      ],
      riskTier: 'MEDIUM',
    );
  }

  static List<NudgeModel> getNudges() {
    final now = DateTime.now();
    return [
      NudgeModel(
        id: 'nudge_001',
        message:
            'Skip 2 Grab orders this week = +3 survival days. You\'ve got this, Siti!',
        timestamp: now.subtract(const Duration(hours: 2)),
        acknowledged: false,
        category: 'Grab Food',
        potentialSavings: 23.70,
      ),
      NudgeModel(
        id: 'nudge_002',
        message:
            'Breakfast at local restaurant costs RM5 less than delivery. Swap once = +0.6 days.',
        timestamp: now.subtract(const Duration(days: 1, hours: 8)),
        acknowledged: true,
        category: 'Food & Drink',
        potentialSavings: 5.00,
      ),
      NudgeModel(
        id: 'nudge_003',
        message:
            'You spent RM42 on Grab this week. Cooking twice saves RM18 = +2 days.',
        timestamp: now.subtract(const Duration(days: 2, hours: 8)),
        acknowledged: true,
        category: 'Grab Food',
        potentialSavings: 18.00,
      ),
      NudgeModel(
        id: 'nudge_004',
        message:
            'Your Shopee spending (RM34) this week is not essential. Pausing = +4 days!',
        timestamp: now.subtract(const Duration(days: 3, hours: 8)),
        acknowledged: true,
        category: 'Shopping',
        potentialSavings: 34.90,
      ),
    ];
  }

  static List<Map<String, dynamic>> getMccAllowedMerchants() {
    return [
      {'name': 'Giant / Aeon / Mydin', 'icon': 'shopping_cart', 'category': 'Groceries'},
      {'name': 'Petronas / Shell / BHPetrol', 'icon': 'local_gas_station', 'category': 'Fuel'},
      {'name': 'Watson\'s / Guardian / Farmasi', 'icon': 'local_pharmacy', 'category': 'Pharmacy'},
      {'name': 'Power & Water Companies', 'icon': 'bolt', 'category': 'Utilities'},
      {'name': 'Mini Marts / Convenience Stores', 'icon': 'store', 'category': 'Convenience Stores'},
      {'name': 'Mamak / Hawker Stalls (≤RM15)', 'icon': 'restaurant', 'category': 'Essential Food'},
    ];
  }

  static List<Map<String, dynamic>> getMccBlockedMerchants() {
    return [
      {'name': 'Shopee / Lazada', 'icon': 'shopping_bag', 'category': 'Online Shopping'},
      {'name': 'Fashion Stores', 'icon': 'checkroom', 'category': 'Clothing'},
      {'name': 'Electronics Shops', 'icon': 'smartphone', 'category': 'Electronics'},
      {'name': 'Cinemas', 'icon': 'theaters', 'category': 'Entertainment'},
    ];
  }

  static List<Map<String, dynamic>> getSurvivalCountdown() {
    final now = DateTime.now();
    return List.generate(14, (i) {
      final balance = 87.0 - (i * 7.90);
      return {
        'day': i + 1,
        'date': now.add(Duration(days: i)),
        'projectedBalance': balance > 0 ? balance : 0.0,
      };
    });
  }
}
