import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/glass_card.dart';

class ConsentScreen extends StatefulWidget {
  const ConsentScreen({super.key});

  @override
  State<ConsentScreen> createState() => _ConsentScreenState();
}

class _ConsentScreenState extends State<ConsentScreen> {
  bool _tngConsent = false;
  bool _pdpaConsent = false;

  bool get _canProceed => _tngConsent && _pdpaConsent;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.onSurface),
          onPressed: () => context.pop(),
        ),
        title: Text('Data Access', style: AppTypography.headlineSm),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
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
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: AppColors.secondary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.lock_rounded, color: AppColors.primary, size: 28),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Your Data is Protected',
                    style: AppTypography.headlineMd.copyWith(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'SurvivAI only reads your transaction history to compute your Survival Score. We never share your personal data.',
                    style: AppTypography.bodyBase.copyWith(color: Colors.white.withOpacity(0.75)),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text('What we access', style: AppTypography.headlineSm),
            const SizedBox(height: 12),
            ...[
              ('90-day TNG transaction history', Icons.receipt_long_rounded, true),
              ('Wallet balance (read-only)', Icons.account_balance_wallet_rounded, true),
              ('Top-up frequency & patterns', Icons.trending_up_rounded, true),
              ('Utility payment history', Icons.bolt_rounded, true),
            ].map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: GlassCard(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.primaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(item.$2, color: AppColors.primary, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(item.$1, style: AppTypography.bodyBase),
                    ),
                    const Icon(Icons.check_circle_rounded, color: AppColors.essential, size: 20),
                  ],
                ),
              ),
            )),
            const SizedBox(height: 16),
            Text('We never access', style: AppTypography.headlineSm),
            const SizedBox(height: 12),
            ...[
              ('Your NRIC or passport number', Icons.block_rounded),
              ('Banking credentials or OTPs', Icons.no_encryption_rounded),
              ('Contacts or photos', Icons.person_off_rounded),
            ].map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: GlassCard(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.error.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(item.$2, color: AppColors.error, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: Text(item.$1, style: AppTypography.bodyBase)),
                  ],
                ),
              ),
            )),
            const SizedBox(height: 24),
            // Consent toggles
            GlassCard(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _ConsentTile(
                    title: 'TNG Transaction Data Access',
                    subtitle: 'Allow SurvivAI to read 90 days of transaction history',
                    value: _tngConsent,
                    onChanged: (v) => setState(() => _tngConsent = v),
                  ),
                  const Divider(height: 24, color: AppColors.surfaceContainerHighest),
                  _ConsentTile(
                    title: 'PDPA Data Processing Consent',
                    subtitle: 'I understand my data will be used to compute my Survival Score under PDPA guidelines',
                    value: _pdpaConsent,
                    onChanged: (v) => setState(() => _pdpaConsent = v),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            AnimatedOpacity(
              opacity: _canProceed ? 1.0 : 0.5,
              duration: const Duration(milliseconds: 200),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _canProceed ? () => context.go('/home') : null,
                  child: const Text('Analyze My Data'),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: Text(
                'You can withdraw consent anytime in Settings',
                style: AppTypography.bodySm.copyWith(color: AppColors.onSurfaceVariant),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _ConsentTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ConsentTile({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTypography.bodyBold.copyWith(fontSize: 14)),
              const SizedBox(height: 4),
              Text(subtitle, style: AppTypography.bodySm),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: AppColors.primary,
          activeTrackColor: AppColors.primaryContainer,
        ),
      ],
    );
  }
}
