class LoanModel {
  final String id;
  final double amount;
  final double restrictedBalanceRemaining;
  final LoanStatus status;
  final DateTime disbursedAt;
  final List<RepaymentEntry> repaymentSchedule;
  final List<String> topFactors;
  final String riskTier;

  const LoanModel({
    required this.id,
    required this.amount,
    required this.restrictedBalanceRemaining,
    required this.status,
    required this.disbursedAt,
    required this.repaymentSchedule,
    required this.topFactors,
    required this.riskTier,
  });
}

class RepaymentEntry {
  final int week;
  final double amount;
  final bool paid;

  const RepaymentEntry({
    required this.week,
    required this.amount,
    required this.paid,
  });
}

enum LoanStatus { active, repaid, defaulted }
