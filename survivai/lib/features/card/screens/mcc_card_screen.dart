import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/providers/app_provider.dart';
import '../../../core/services/mock_data_service.dart';
import '../../../shared/widgets/bottom_nav.dart';
import '../../../shared/widgets/glass_card.dart';

class MccCardScreen extends StatefulWidget {
  const MccCardScreen({super.key});

  @override
  State<MccCardScreen> createState() => _MccCardScreenState();
}

class _MccCardScreenState extends State<MccCardScreen> {
  String? _simulationResult;
  bool? _simulationAllowed;
  String _selectedMerchant = '';

  void _simulateTransaction(String merchant, bool allowed, String reason) {
    setState(() {
      _selectedMerchant = merchant;
      _simulationAllowed = allowed;
      _simulationResult = allowed ? 'APPROVED' : reason;
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final loan = provider.activeLoan;
    final allowedMerchants = MockDataService.getMccAllowedMerchants();
    final blockedMerchants = MockDataService.getMccBlockedMerchants();

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 260,
            pinned: true,
            backgroundColor: AppColors.primary,
            flexibleSpace: FlexibleSpaceBar(
              background: _CardHeader(loan: loan),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                if (loan == null) ...[
                  _NoLoanState(),
                ] else ...[
                  // Transaction simulator
                  GlassCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Transaction Simulator', style: AppTypography.headlineSm),
                        const SizedBox(height: 4),
                        Text('Test which merchants are allowed',
                          style: AppTypography.bodySm.copyWith(color: AppColors.onSurfaceVariant)),
                        const SizedBox(height: 16),
                        // Allowed merchants
                        Text('ALLOWED MERCHANTS', style: AppTypography.labelCaps.copyWith(color: Colors.black87)),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: allowedMerchants.map((m) => GestureDetector(
                            onTap: () => _simulateTransaction(m['name']!, true, ''),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Colors.black.withOpacity(0.2)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(m['icon']!, style: const TextStyle(fontSize: 14)),
                                  const SizedBox(width: 6),
                                  Text(m['category']!, style: AppTypography.bodySm.copyWith(color: Colors.black87, fontWeight: FontWeight.w600)),
                                ],
                              ),
                            ),
                          )).toList(),
                        ),
                        const SizedBox(height: 16),
                        // Blocked merchants
                        Text('BLOCKED MERCHANTS', style: AppTypography.labelCaps.copyWith(color: Colors.black54)),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: blockedMerchants.map((m) => GestureDetector(
                            onTap: () => _simulateTransaction(
                              m['name']!,
                              false,
                              'MCC not in essential allowlist',
                            ),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.grey.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Colors.grey.withOpacity(0.4)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(m['icon']!, style: const TextStyle(fontSize: 14)),
                                  const SizedBox(width: 6),
                                  Text(m['category']!, style: AppTypography.bodySm.copyWith(color: Colors.black54, fontWeight: FontWeight.w600)),
                                ],
                              ),
                            ),
                          )).toList(),
                        ),
                        // Simulation result
                        if (_simulationResult != null) ...[
                          const SizedBox(height: 16),
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: _simulationAllowed!
                                  ? AppColors.essential.withOpacity(0.1)
                                  : AppColors.error.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: _simulationAllowed!
                                    ? AppColors.essential.withOpacity(0.3)
                                    : AppColors.error.withOpacity(0.3),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  _simulationAllowed! ? Icons.check_circle_rounded : Icons.cancel_rounded,
                                  color: _simulationAllowed! ? AppColors.essential : AppColors.error,
                                  size: 28,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _selectedMerchant,
                                        style: AppTypography.bodyBold.copyWith(fontSize: 13),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        _simulationAllowed! ? 'Transaction APPROVED ✓' : 'Transaction DECLINED — $_simulationResult',
                                        style: AppTypography.bodySm.copyWith(
                                          color: _simulationAllowed! ? AppColors.essential : AppColors.error,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Repayment progress
                  GlassCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Repayment Progress', style: AppTypography.headlineSm),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Week 0 of 10', style: AppTypography.bodyBase.copyWith(color: AppColors.onSurfaceVariant)),
                            Text('RM 0 / RM 150 repaid', style: AppTypography.bodyBold.copyWith(fontSize: 13)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: const LinearProgressIndicator(
                            value: 0,
                            backgroundColor: AppColors.surfaceContainerHighest,
                            valueColor: AlwaysStoppedAnimation(AppColors.primary),
                            minHeight: 10,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text('Next deduction: RM 15.00 on next top-up',
                          style: AppTypography.bodySm.copyWith(color: AppColors.onSurfaceVariant)),
                      ],
                    ),
                  ),
                ],
              ]),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 2),
    );
  }
}

class _CardHeader extends StatelessWidget {
  final dynamic loan;

  const _CardHeader({required this.loan});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, Color(0xFF0039A6)],
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(40)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('MY ECL CARD', style: AppTypography.labelCaps.copyWith(color: Colors.white.withOpacity(0.6))),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: loan != null ? AppColors.survivalGreen.withOpacity(0.2) : Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      loan != null ? 'ACTIVE' : 'NO LOAN',
                      style: AppTypography.labelCaps.copyWith(
                        color: loan != null ? AppColors.survivalGreen : Colors.white.withOpacity(0.5),
                        fontSize: 9,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Card visual
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1A3A6B), Color(0xFF0D1F3C)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('TNG VISA', style: AppTypography.bodyBold.copyWith(color: Colors.white, fontSize: 13)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.secondary.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.secondary.withOpacity(0.5)),
                          ),
                          child: Text('ESSENTIAL ONLY', style: AppTypography.labelCaps.copyWith(color: AppColors.secondary, fontSize: 7)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      loan != null ? 'RM ${loan.restrictedBalanceRemaining.toStringAsFixed(2)}' : 'RM 0.00',
                      style: AppTypography.headlineLg.copyWith(color: Colors.white, fontSize: 36),
                    ),
                    Text('Restricted Balance', style: AppTypography.bodySm.copyWith(color: Colors.white.withOpacity(0.5))),
                    const SizedBox(height: 12),
                    Text('•••• •••• •••• 4291', style: AppTypography.bodyBase.copyWith(color: Colors.white.withOpacity(0.6))),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NoLoanState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(color: AppColors.primaryContainer, shape: BoxShape.circle),
            child: const Icon(Icons.credit_card_off_rounded, color: AppColors.primary, size: 32),
          ),
          const SizedBox(height: 16),
          Text('No Active ECL Loan', style: AppTypography.headlineMd, textAlign: TextAlign.center),
          const SizedBox(height: 8),
          Text(
            'Activate Emergency Mode when you need it. If your Survival Score drops below 5 days, you\'ll be eligible for the Emergency Credit Lifeline.',
            style: AppTypography.bodyBase.copyWith(color: AppColors.onSurfaceVariant),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => context.go('/emergency'),
              child: const Text('Go to Emergency Mode'),
            ),
          ),
        ],
      ),
    );
  }
}
