import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/models/transaction_model.dart';

class CategoryChip extends StatelessWidget {
  final TransactionCategory category;

  const CategoryChip({super.key, required this.category});

  Color get _color {
    switch (category) {
      case TransactionCategory.essential:
        return AppColors.essential;
      case TransactionCategory.discretionary:
        return AppColors.discretionary;
      case TransactionCategory.savings:
        return AppColors.savings;
    }
  }

  String get _label {
    switch (category) {
      case TransactionCategory.essential:
        return 'ESSENTIAL';
      case TransactionCategory.discretionary:
        return 'DISCRETIONARY';
      case TransactionCategory.savings:
        return 'SAVINGS';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: _color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _color.withOpacity(0.3), width: 0.5),
      ),
      child: Text(
        _label,
        style: AppTypography.labelCaps.copyWith(
          color: _color,
          fontSize: 8,
          letterSpacing: 1.5,
        ),
      ),
    );
  }
}
