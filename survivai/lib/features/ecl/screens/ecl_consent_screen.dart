import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/providers/app_provider.dart';
import '../../../shared/widgets/glass_card.dart';

class EclConsentScreen extends StatefulWidget {
  const EclConsentScreen({super.key});

  @override
  State<EclConsentScreen> createState() => _EclConsentScreenState();
}

class _EclConsentScreenState extends State<EclConsentScreen> {
  bool _ctosConsent = false;

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
        title: Text('Credit Check Consent', style: AppTypography.headlineSm),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // CTOS info card
            GlassCard(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: AppColors.primaryContainer,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.verified_user_rounded, color: AppColors.primary, size: 28),
                  ),
                  const SizedBox(height: 14),
                  Text('CTOS Credit Check', style: AppTypography.headlineMd, textAlign: TextAlign.center),
                  const SizedBox(height: 8),
                  Text(
                    'To offer you the best loan amount, SurvivAI uses your CTOS thin-file signal combined with 90 days of TNG transaction data.',
                    style: AppTypography.bodyBase.copyWith(color: AppColors.onSurfaceVariant),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text('What CTOS provides', style: AppTypography.headlineSm),
            const SizedBox(height: 12),
            ...[
              ('Credit enquiry history (last 12 months)', true),
              ('CCRIS status (performing/non-performing)', true),
              ('Negative records flag (if any)', true),
            ].map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Icon(
                    item.$2 ? Icons.check_circle_rounded : Icons.cancel_rounded,
                    color: item.$2 ? AppColors.essential : AppColors.error,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(child: Text(item.$1, style: AppTypography.bodyBase)),
                ],
              ),
            )),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primaryContainer,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_rounded, color: AppColors.primary, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'If you decline CTOS check, you can still apply — we\'ll use TNG data only, with a maximum loan of RM 100.',
                      style: AppTypography.bodyBase.copyWith(color: AppColors.onPrimaryContainer, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            GlassCard(
              padding: const EdgeInsets.all(20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Allow CTOS Credit Check', style: AppTypography.bodyBold),
                        const SizedBox(height: 4),
                        Text(
                          'I consent to SurvivAI querying my CTOS thin-file for this loan application. This is a soft check and will not affect my credit score.',
                          style: AppTypography.bodySm,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Switch(
                    value: _ctosConsent,
                    onChanged: (v) => setState(() => _ctosConsent = v),
                    activeColor: AppColors.primary,
                    activeTrackColor: AppColors.primaryContainer,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  context.read<AppProvider>().setCtosConsent(_ctosConsent);
                  context.go('/ecl/processing');
                },
                child: Text(_ctosConsent ? 'Proceed with CTOS Check' : 'Proceed without CTOS'),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
