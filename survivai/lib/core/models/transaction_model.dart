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

  factory TransactionModel.fromApi(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] as String,
      merchantName: json['merchant_name'] as String,
      amount: (json['amount'] as num).toDouble(),
      category: TransactionCategory.values.byName(json['category'] as String),
      timestamp: DateTime.parse(json['timestamp'] as String),
      mcc: json['mcc'] as String?,
    );
  }
}

enum TransactionCategory { essential, discretionary, savings }
