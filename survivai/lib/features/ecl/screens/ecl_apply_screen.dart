import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/providers/app_provider.dart';
import '../../../shared/widgets/glass_card.dart';

class EclApplyScreen extends StatelessWidget {
  const EclApplyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        title: Text('Emergency Credit Lifeline', style: AppTypography.headlineSm),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, Color(0xFF0052CC)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(32),
              ),
              child: Column(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(color: AppColors.secondary, shape: BoxShape.circle),
                    child: const Icon(Icons.bolt_rounded, color: AppColors.primary, size: 32),
                  ),
                  const SizedBox(height: 16),
                  Text('You Qualify!', style: AppTypography.headlineMd.copyWith(color: Colors.white)),
                  const SizedBox(height: 8),
                  Text(
                    'Based on your TNG history, you may receive RM100–RM200 in emergency credit disbursed instantly to your TNG Visa Card.',
                    style: AppTypography.bodyBase.copyWith(color: Colors.white.withOpacity(0.75)),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  // Loan tier options
                  Row(
                    children: [
                      _LoanTierChip(amount: 'RM 100', isSelected: false),
                      const SizedBox(width: 8),
                      _LoanTierChip(amount: 'RM 150', isSelected: true),
                      const SizedBox(width: 8),
                      _LoanTierChip(amount: 'RM 200', isSelected: false),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Key terms
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Loan Terms', style: AppTypography.headlineSm),
                  const SizedBox(height: 14),
                  ...[
                    ('Decision time', '≤ 30 seconds', Icons.timer_rounded),
                    ('Interest', 'ZERO for first loan', Icons.percent_rounded),
                    ('Service fee', 'RM 5.00', Icons.receipt_rounded),
                    ('Repayment', 'RM 15/week over 10 weeks', Icons.calendar_today_rounded),
                    ('Disbursed to', 'TNG Visa Card (restricted)', Icons.credit_card_rounded),
                  ].map((item) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: AppColors.primaryContainer,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(item.$3, color: AppColors.primary, size: 18),
                        ),
                        const SizedBox(width: 12),
                        Text(item.$1, style: AppTypography.bodyBase.copyWith(color: AppColors.onSurfaceVariant)),
                        const Spacer(),
                        Text(item.$2, style: AppTypography.bodyBold.copyWith(fontSize: 13)),
                      ],
                    ),
                  )),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // MCC info
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.secondary.withOpacity(0.12),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.secondary.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.lock_rounded, color: AppColors.primary, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Funds are MCC-locked — spendable only at groceries, fuel, pharmacies & utilities. Not Shopee.',
                      style: AppTypography.bodyBase.copyWith(fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => context.go('/ecl/consent'),
                child: const Text('Apply for RM 150 Now'),
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: Text(
                'By applying, you consent to a credit assessment using your TNG transaction history.',
                style: AppTypography.bodySm.copyWith(color: AppColors.onSurfaceVariant),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _LoanTierChip extends StatelessWidget {
  final String amount;
  final bool isSelected;

  const _LoanTierChip({required this.amount, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.secondary : Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.secondary : Colors.white.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Text(
              amount,
              style: AppTypography.bodyBold.copyWith(
                color: isSelected ? AppColors.primary : Colors.white,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            if (isSelected)
              Text('SELECTED', style: AppTypography.labelCaps.copyWith(color: AppColors.primary, fontSize: 7)),
          ],
        ),
      ),
    );
  }
}
