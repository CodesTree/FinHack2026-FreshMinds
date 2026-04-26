class NudgeModel {
  final String id;
  final String message;
  final DateTime timestamp;
  final bool acknowledged;
  final String category;
  final double potentialSavings;

  const NudgeModel({
    required this.id,
    required this.message,
    required this.timestamp,
    required this.acknowledged,
    required this.category,
    required this.potentialSavings,
  });

  factory NudgeModel.fromApi(Map<String, dynamic> json) {
    return NudgeModel(
      id: json['id'] as String,
      message: json['message'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      acknowledged: (json['acknowledged'] as bool?) ?? false,
      category: json['category'] as String,
      potentialSavings: (json['potential_savings'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
