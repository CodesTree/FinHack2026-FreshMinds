class TransactionModel {
  final String id;
  final String merchantName;
  final double amount;
  final TransactionCategory category;
  final DateTime timestamp;
  final String? mcc;

  const TransactionModel({
    required this.id,
    required this.merchantName,
    required this.amount,
    required this.category,
    required this.timestamp,
    this.mcc,
  });
}

enum TransactionCategory { essential, discretionary, savings }
