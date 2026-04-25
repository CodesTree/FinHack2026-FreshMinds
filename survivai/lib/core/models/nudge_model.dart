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
}
