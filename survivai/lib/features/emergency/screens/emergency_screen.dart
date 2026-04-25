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

class EmergencyScreen extends StatelessWidget {
  const EmergencyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final user = provider.user;

    if (!user.emergencyModeActive) {
      return _InactiveEmergency(user: user);
    }
    return _ActiveEmergency(user: user);
  }
}

class _InactiveEmergency extends StatelessWidget {
  final UserModel user;

  const _InactiveEmergency({required this.user});

  @override
  Widget build(BuildContext context) {
    final provider = context.read<AppProvider>();

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 20),
              // Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: AppColors.surfaceBright,
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.06),
                      blurRadius: 30,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text('EMERGENCY MODE', style: AppTypography.labelCaps.copyWith(color: AppColors.onSurfaceVariant)),
                    const SizedBox(height: 12),
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppColors.error.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.warning_amber_rounded, color: AppColors.error, size: 40),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Activate When You Need It',
                      style: AppTypography.headlineMd,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Emergency Mode turns on your survival dashboard — showing your daily countdown, burn rate, and access to the Emergency Credit Lifeline.',
                      style: AppTypography.bodyBase.copyWith(color: AppColors.onSurfaceVariant),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    // Current score preview
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.survivalRed.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.survivalRed.withOpacity(0.2)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${user.survivalDays}',
                            style: AppTypography.headlineLg.copyWith(color: AppColors.survivalRed),
                          ),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('days survival runway', style: AppTypography.bodyBase),
                              Text('RM ${user.dailyBurnRate.toStringAsFixed(2)}/day burn rate',
                                style: AppTypography.bodySm),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => provider.activateEmergencyMode(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.error,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: Text(
                          'Activate Emergency Mode',
                          style: AppTypography.bodyBold.copyWith(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // What happens next
              GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('What happens when activated', style: AppTypography.headlineSm),
                    const SizedBox(height: 12),
                    ...[
                      ('Real-time survival countdown', Icons.timer_rounded),
                      ('2x daily AI-powered nudges', Icons.tips_and_updates_rounded),
                      ('ECL eligibility check when < 5 days', Icons.credit_score_rounded),
                      ('Government benefits checker', Icons.policy_rounded),
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
                            child: Icon(item.$2, color: AppColors.primary, size: 18),
                          ),
                          const SizedBox(width: 10),
                          Text(item.$1, style: AppTypography.bodyBase),
                        ],
                      ),
                    )),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 1),
    );
  }
}

class _ActiveEmergency extends StatelessWidget {
  final UserModel user;

  const _ActiveEmergency({required this.user});

  @override
  Widget build(BuildContext context) {
    final provider = context.read<AppProvider>();
    final countdown = MockDataService.getSurvivalCountdown();
    final benefits = [
      {'name': 'Bantuan Rahmah', 'amount': 'RM 200', 'icon': '🏛️'},
      {'name': 'e-Kasih Aid', 'amount': 'RM 150', 'icon': '🤝'},
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A1A),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: AppColors.error,
            flexibleSpace: FlexibleSpaceBar(
              background: _EmergencyHeader(user: user),
            ),
            actions: [
              TextButton(
                onPressed: () => provider.deactivateEmergencyMode(),
                child: Text('DEACTIVATE',
                  style: AppTypography.labelCaps.copyWith(color: Colors.white, fontSize: 9)),
              ),
            ],
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // ECL Eligibility card
                if (user.survivalDays <= 5) ...[
                  _EclEligibilityBanner(),
                  const SizedBox(height: 16),
                ],
                // Daily countdown strip
                Text('14-Day Runway', style: AppTypography.headlineSm.copyWith(color: Colors.white)),
                const SizedBox(height: 12),
                SizedBox(
                  height: 80,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: countdown.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (_, i) {
                      final day = countdown[i];
                      final balance = day['projectedBalance'] as double;
                      final isEmpty = balance <= 0;
                      return Container(
                        width: 60,
                        decoration: BoxDecoration(
                          color: isEmpty
                              ? AppColors.error.withOpacity(0.3)
                              : Colors.white.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: i == 0
                                ? AppColors.secondary
                                : Colors.white.withOpacity(0.1),
                            width: i == 0 ? 2 : 1,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'D${day['day']}',
                              style: AppTypography.bodyBold.copyWith(
                                color: isEmpty ? AppColors.error : Colors.white,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              isEmpty ? 'RM 0' : 'RM ${balance.toStringAsFixed(0)}',
                              style: AppTypography.bodySm.copyWith(
                                color: isEmpty
                                    ? AppColors.error
                                    : Colors.white.withOpacity(0.6),
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),
                // Spend breakdown
                _EmergencySpendCard(user: user),
                const SizedBox(height: 16),
                // Government benefits
                GlassCard(
                  color: Colors.white.withOpacity(0.06),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.policy_rounded, color: AppColors.secondary, size: 18),
                          const SizedBox(width: 8),
                          Text('You May Be Eligible',
                            style: AppTypography.headlineSm.copyWith(color: Colors.white)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ...benefits.map((b) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Text(b['icon']!, style: const TextStyle(fontSize: 24)),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(b['name']!, style: AppTypography.bodyBold.copyWith(color: Colors.white)),
                                  Text('Up to ${b['amount']}',
                                    style: AppTypography.bodySm.copyWith(color: Colors.white.withOpacity(0.6))),
                                ],
                              ),
                            ),
                            TextButton(
                              onPressed: () {},
                              child: Text('Apply',
                                style: AppTypography.bodyBase.copyWith(color: AppColors.secondary)),
                            ),
                          ],
                        ),
                      )),
                    ],
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        color: const Color(0xFF0A0A1A),
        child: const AppBottomNav(currentIndex: 1),
      ),
    );
  }
}

class _EmergencyHeader extends StatelessWidget {
  final UserModel user;

  const _EmergencyHeader({required this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFCC0000), Color(0xFFFF3D00)],
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
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 6, height: 6,
                          decoration: const BoxDecoration(color: AppColors.secondary, shape: BoxShape.circle),
                        ),
                        const SizedBox(width: 6),
                        Text('EMERGENCY MODE ACTIVE',
                          style: AppTypography.labelCaps.copyWith(color: Colors.white, fontSize: 8)),
                      ],
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Text(
                'SURVIVAL COUNTDOWN',
                style: AppTypography.labelCaps.copyWith(color: Colors.white.withOpacity(0.7)),
              ),
              const SizedBox(height: 6),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${user.survivalDays}',
                    style: AppTypography.headlineXl.copyWith(
                      color: Colors.white,
                      fontSize: 72,
                      height: 1.0,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      'days\nleft',
                      style: AppTypography.bodyBase.copyWith(color: Colors.white.withOpacity(0.7), height: 1.2),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'RM ${user.dailyBurnRate.toStringAsFixed(2)} burn rate/day',
                style: AppTypography.bodyBase.copyWith(color: Colors.white.withOpacity(0.7)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EclEligibilityBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.go('/ecl/apply'),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.secondary, Color(0xFFFFC107)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppColors.secondary.withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.bolt_rounded, color: AppColors.secondary, size: 26),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Emergency Credit Lifeline',
                    style: AppTypography.bodyBold.copyWith(color: AppColors.primary)),
                  Text('You may qualify for RM100–RM200. Decision in 30 seconds.',
                    style: AppTypography.bodySm.copyWith(color: AppColors.primary.withOpacity(0.7))),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.primary),
          ],
        ),
      ),
    );
  }
}

class _EmergencySpendCard extends StatelessWidget {
  final UserModel user;

  const _EmergencySpendCard({required this.user});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      color: Colors.white.withOpacity(0.06),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Weekly Spending', style: AppTypography.headlineSm.copyWith(color: Colors.white)),
          const SizedBox(height: 14),
          _SpendRow(label: 'Essential', amount: 152.30, color: AppColors.essential, pct: 62),
          const SizedBox(height: 10),
          _SpendRow(label: 'Discretionary', amount: 94.40, color: AppColors.discretionary, pct: 38),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.secondary.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.secondary.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.tips_and_updates_rounded, color: AppColors.secondary, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Cut Grab orders by 2 = +3 survival days',
                    style: AppTypography.bodySm.copyWith(color: Colors.white.withOpacity(0.85)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SpendRow extends StatelessWidget {
  final String label;
  final double amount;
  final Color color;
  final int pct;

  const _SpendRow({required this.label, required this.amount, required this.color, required this.pct});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
                const SizedBox(width: 8),
                Text(label, style: AppTypography.bodyBase.copyWith(color: Colors.white.withOpacity(0.8))),
              ],
            ),
            Text('RM ${amount.toStringAsFixed(2)} ($pct%)',
              style: AppTypography.bodyBold.copyWith(color: Colors.white, fontSize: 13)),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: pct / 100,
            backgroundColor: Colors.white.withOpacity(0.1),
            valueColor: AlwaysStoppedAnimation(color),
            minHeight: 6,
          ),
        ),
      ],
    );
  }
}
