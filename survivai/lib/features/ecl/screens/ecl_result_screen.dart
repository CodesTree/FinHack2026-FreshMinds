import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/providers/app_provider.dart';
import '../../../shared/widgets/glass_card.dart';

class EclResultScreen extends StatefulWidget {
  const EclResultScreen({super.key});

  @override
  State<EclResultScreen> createState() => _EclResultScreenState();
}

class _EclResultScreenState extends State<EclResultScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scaleAnim;

  final List<Map<String, dynamic>> _factors = [
    {'label': 'Regular weekly top-ups', 'positive': true, 'icon': Icons.trending_up_rounded},
    {'label': 'Electricity bill paid consistently', 'positive': true, 'icon': Icons.bolt_rounded},
    {'label': 'High food delivery spending', 'positive': false, 'icon': Icons.delivery_dining_rounded},
  ];

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _scaleAnim = CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut);
    _ctrl.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppProvider>().approveLoan();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.onSurface),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 0),
              // Approval badge
              ScaleTransition(
                scale: _scaleAnim,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: AppColors.survivalGreen.withOpacity(0.12),
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.survivalGreen, width: 3),
                  ),
                  child: const Icon(Icons.check_circle_rounded, color: AppColors.survivalGreen, size: 52),
                ),
              ),
              const SizedBox(height: 20),
              Text('APPROVED', style: AppTypography.labelCaps.copyWith(color: AppColors.survivalGreen, fontSize: 14, letterSpacing: 4)),
              const SizedBox(height: 8),
              Text(
                'RM 150',
                style: AppTypography.headlineXl.copyWith(color: AppColors.primary, fontSize: 56),
              ),
              Text(
                'Emergency Credit Lifeline',
                style: AppTypography.bodyBase.copyWith(color: AppColors.onSurfaceVariant),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text('Disbursed to TNG Visa Card — Restricted',
                  style: AppTypography.bodySm.copyWith(color: AppColors.primary, fontWeight: FontWeight.w600)),
              ),
              const SizedBox(height: 28),
              // Decision factors
              GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.insights_rounded, color: AppColors.primary, size: 18),
                        const SizedBox(width: 8),
                        Text('Why You Were Approved', style: AppTypography.headlineSm),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text('SHAP Explainability — Top 3 Factors',
                      style: AppTypography.labelCaps.copyWith(color: AppColors.onSurfaceVariant)),
                    const SizedBox(height: 16),
                    ..._factors.map((f) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: f['positive']
                                  ? AppColors.survivalGreen.withOpacity(0.12)
                                  : AppColors.error.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              f['icon'] as IconData,
                              color: f['positive'] ? AppColors.survivalGreen : AppColors.error,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(child: Text(f['label'] as String, style: AppTypography.bodyBase)),
                          Text(
                            f['positive'] ? '(+)' : '(−)',
                            style: AppTypography.bodyBold.copyWith(
                              color: f['positive'] ? AppColors.survivalGreen : AppColors.error,
                            ),
                          ),
                        ],
                      ),
                    )),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Repayment schedule
              GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Repayment Schedule', style: AppTypography.headlineSm),
                    const SizedBox(height: 4),
                    Text('Auto-deducted from TNG wallet top-ups',
                      style: AppTypography.bodySm.copyWith(color: AppColors.onSurfaceVariant)),
                    const SizedBox(height: 14),
                    ...List.generate(3, (i) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: AppColors.primaryContainer,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              child: Text('W${i + 1}',
                                style: AppTypography.bodyBold.copyWith(color: AppColors.primary, fontSize: 11)),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text('Week ${i + 1}', style: AppTypography.bodyBase),
                          const Spacer(),
                          Text('RM 15.00', style: AppTypography.bodyBold),
                        ],
                      ),
                    )),
                    Center(
                      child: Text('+ 7 more weeks  (total: RM 155.00 incl. RM5 fee)',
                        style: AppTypography.bodySm.copyWith(color: AppColors.onSurfaceVariant)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => context.go('/card'),
                  child: const Text('View My ECL Card'),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => context.go('/home'),
                child: Text('Back to Home',
                  style: AppTypography.bodyBase.copyWith(color: AppColors.onSurfaceVariant)),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
