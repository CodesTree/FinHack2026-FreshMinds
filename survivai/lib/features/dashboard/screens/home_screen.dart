import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/providers/app_provider.dart';
import '../../../core/models/user_model.dart';
import '../../../core/services/mock_data_service.dart';
import '../../../shared/widgets/bottom_nav.dart';
import '../../../shared/widgets/glass_card.dart';
import '../../../shared/widgets/survival_score_ring.dart';
import '../../../shared/widgets/category_chip.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AppProvider>().user;
    final transactions = MockDataService.getRecentTransactions().take(3).toList();
    final nudges = MockDataService.getNudges();

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: CustomScrollView(
        slivers: [
          // Blue header
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: AppColors.primary,
            flexibleSpace: FlexibleSpaceBar(
              background: _HomeHeader(user: user),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const SizedBox(height: 20),
                // Today's nudge
                if (nudges.isNotEmpty) ...[
                  _NudgeCard(nudge: nudges.first),
                  const SizedBox(height: 16),
                ],
                // Quick actions
                _QuickActions(user: user),
                const SizedBox(height: 20),
                // Spending breakdown
                _SpendingBreakdown(),
                const SizedBox(height: 20),
                // Recent transactions
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Recent Transactions', style: AppTypography.headlineSm),
                    TextButton(
                      onPressed: () => context.go('/transactions'),
                      child: Text('See All', style: AppTypography.bodyBase.copyWith(color: AppColors.primary)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ...transactions.map((txn) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: GlassCard(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppColors.primaryContainer,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(Icons.store_rounded, color: AppColors.primary, size: 22),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(txn.merchantName,
                                style: AppTypography.bodyBold.copyWith(fontSize: 13),
                                maxLines: 1, overflow: TextOverflow.ellipsis),
                              const SizedBox(height: 2),
                              CategoryChip(category: txn.category),
                            ],
                          ),
                        ),
                        Text(
                          '−RM ${txn.amount.toStringAsFixed(2)}',
                          style: AppTypography.bodyBold.copyWith(
                            color: AppColors.onSurface,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                )),
              ]),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 0),
    );
  }
}

class _HomeHeader extends StatelessWidget {
  final UserModel user;

  const _HomeHeader({required this.user});

  String get _trendText {
    switch (user.trend) {
      case SurvivalTrend.improving:
        return '↑ Improving';
      case SurvivalTrend.stable:
        return '→ Stable';
      case SurvivalTrend.declining:
        return '↓ Declining';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, Color(0xFF0052CC)],
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
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'SELAMAT PAGI',
                        style: AppTypography.labelCaps.copyWith(color: Colors.white.withOpacity(0.6)),
                      ),
                      Text(
                        user.name.split(' ').first,
                        style: AppTypography.headlineMd.copyWith(color: Colors.white),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.account_balance_wallet_rounded, color: Colors.white, size: 14),
                            const SizedBox(width: 4),
                            Text(
                              'RM ${user.walletBalance.toStringAsFixed(2)}',
                              style: AppTypography.bodyBold.copyWith(color: Colors.white, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Score section
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SurvivalScoreRing(days: user.survivalDays, band: user.colorBand, size: 120),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Survival Score',
                          style: AppTypography.labelCaps.copyWith(
                            color: Colors.white.withOpacity(0.6),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'You can survive\n${user.survivalDays} days without income',
                          style: AppTypography.bodyBase.copyWith(color: Colors.white, height: 1.4),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                user.trend == SurvivalTrend.improving
                                    ? Icons.trending_up_rounded
                                    : Icons.trending_down_rounded,
                                color: user.trend == SurvivalTrend.improving
                                    ? AppColors.survivalGreen
                                    : AppColors.survivalRed,
                                size: 14,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _trendText,
                                style: AppTypography.bodySm.copyWith(color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Burn rate: RM ${user.dailyBurnRate.toStringAsFixed(2)}/day',
                          style: AppTypography.bodySm.copyWith(color: Colors.white.withOpacity(0.6)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NudgeCard extends StatelessWidget {
  final dynamic nudge;

  const _NudgeCard({required this.nudge});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.secondary.withOpacity(0.15),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.secondary.withOpacity(0.4)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.secondary,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.tips_and_updates_rounded, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('AI NUDGE', style: AppTypography.labelCaps.copyWith(color: AppColors.primary)),
                const SizedBox(height: 2),
                Text(nudge.message, style: AppTypography.bodyBase.copyWith(fontSize: 13)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: AppColors.onSurfaceVariant),
        ],
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  final UserModel user;

  const _QuickActions({required this.user});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ActionButton(
            icon: Icons.warning_amber_rounded,
            label: user.emergencyModeActive ? 'Emergency\nACTIVE' : 'Emergency\nMode',
            color: user.emergencyModeActive ? AppColors.error : AppColors.primary,
            onTap: () => context.go('/emergency'),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _ActionButton(
            icon: Icons.credit_card_rounded,
            label: 'ECL\nCard',
            color: AppColors.primary,
            onTap: () => context.go('/card'),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _ActionButton(
            icon: Icons.lightbulb_rounded,
            label: 'Daily\nNudges',
            color: AppColors.primary,
            onTap: () => context.go('/nudges'),
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 6),
            Text(
              label,
              style: AppTypography.bodySm.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 11,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _SpendingBreakdown extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('This Week\'s Spending', style: AppTypography.headlineSm),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text('7 days', style: AppTypography.bodySm.copyWith(color: AppColors.primary)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Stacked bar
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              height: 12,
              child: Row(
                children: [
                  Expanded(flex: 62, child: Container(color: AppColors.essential)),
                  Expanded(flex: 38, child: Container(color: AppColors.discretionary)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _Legend(color: AppColors.essential, label: 'Essential', value: 'RM 152.30', pct: '62%'),
              const SizedBox(width: 20),
              _Legend(color: AppColors.discretionary, label: 'Discretionary', value: 'RM 94.40', pct: '38%'),
            ],
          ),
        ],
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  final Color color;
  final String label;
  final String value;
  final String pct;

  const _Legend({required this.color, required this.label, required this.value, required this.pct});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Row(
        children: [
          Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppTypography.bodySm.copyWith(fontSize: 11)),
              Text(value, style: AppTypography.bodyBold.copyWith(fontSize: 12)),
              Text(pct, style: AppTypography.bodySm.copyWith(color: color, fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }
}
