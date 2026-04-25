import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/providers/app_provider.dart';
import '../../../core/services/mock_data_service.dart';
import '../../../shared/widgets/bottom_nav.dart';
import '../../../shared/widgets/glass_card.dart';

class NudgesScreen extends StatelessWidget {
  const NudgesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final nudges = MockDataService.getNudges();

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 180,
            pinned: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            automaticallyImplyLeading: false,
            flexibleSpace: FlexibleSpaceBar(
              background: _NudgeHeader(streak: provider.nudgeStreak),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Text('AI NUDGES', style: AppTypography.labelCaps.copyWith(color: AppColors.onSurfaceVariant)),
                const SizedBox(height: 12),
                ...nudges.asMap().entries.map((entry) {
                  final i = entry.key;
                  final nudge = entry.value;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _NudgeCard(
                      nudge: nudge,
                      isLatest: i == 0,
                      onAcknowledge: i == 0 ? () => provider.incrementNudgeStreak() : null,
                    ),
                  );
                }),
                const SizedBox(height: 16),
                // Savings potential
                GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.savings_rounded, color: AppColors.primary, size: 18),
                          const SizedBox(width: 8),
                          Text('This Week\'s Savings Potential', style: AppTypography.headlineSm),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('If you follow all nudges:', style: AppTypography.bodyBase.copyWith(color: AppColors.onSurfaceVariant)),
                              const SizedBox(height: 4),
                              Text(
                                'RM ${nudges.fold(0.0, (s, n) => s + n.potentialSavings).toStringAsFixed(2)}',
                                style: AppTypography.headlineMd.copyWith(color: AppColors.primary),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text('Survival extension:', style: AppTypography.bodyBase.copyWith(color: AppColors.onSurfaceVariant)),
                              const SizedBox(height: 4),
                              Text(
                                '+${(nudges.fold(0.0, (s, n) => s + n.potentialSavings) / 7.9).toStringAsFixed(1)} days',
                                style: AppTypography.headlineMd.copyWith(color: AppColors.survivalGreen),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: -1),
    );
  }
}

class _NudgeHeader extends StatelessWidget {
  final int streak;

  const _NudgeHeader({required this.streak});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, Color(0xFF0052CC)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(40)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('DAILY AI NUDGES', style: AppTypography.labelCaps.copyWith(color: Colors.white.withOpacity(0.6))),
              const SizedBox(height: 8),
              Text('Your survival coach', style: AppTypography.headlineMd.copyWith(color: Colors.white)),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.secondary.withOpacity(0.4)),
                    ),
                    child: Row(
                      children: [
                        const Text('🔥', style: TextStyle(fontSize: 16)),
                        const SizedBox(width: 6),
                        Text('$streak day streak!',
                          style: AppTypography.bodyBold.copyWith(color: AppColors.secondary, fontSize: 14)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text('Powered by AWS Bedrock',
                    style: AppTypography.bodySm.copyWith(color: Colors.white.withOpacity(0.5), fontSize: 10)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NudgeCard extends StatefulWidget {
  final dynamic nudge;
  final bool isLatest;
  final VoidCallback? onAcknowledge;

  const _NudgeCard({required this.nudge, required this.isLatest, this.onAcknowledge});

  @override
  State<_NudgeCard> createState() => _NudgeCardState();
}

class _NudgeCardState extends State<_NudgeCard> {
  bool _acknowledged = false;

  @override
  Widget build(BuildContext context) {
    final acknowledged = _acknowledged || widget.nudge.acknowledged;

    return GlassCard(
      color: widget.isLatest ? AppColors.primary.withOpacity(0.04) : AppColors.surfaceBright,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: widget.isLatest ? AppColors.secondary : AppColors.surfaceContainerHighest,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.tips_and_updates_rounded,
                  color: widget.isLatest ? AppColors.primary : AppColors.onSurfaceVariant,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.nudge.category as String,
                    style: AppTypography.labelCaps.copyWith(
                      color: widget.isLatest ? AppColors.primary : AppColors.onSurfaceVariant,
                    )),
                  Text(
                    widget.isLatest ? 'Today' : '${DateTime.now().difference(widget.nudge.timestamp as DateTime).inDays}d ago',
                    style: AppTypography.bodySm.copyWith(fontSize: 11),
                  ),
                ],
              ),
              const Spacer(),
              if (acknowledged)
                const Icon(Icons.check_circle_rounded, color: AppColors.survivalGreen, size: 20),
              if (widget.isLatest)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.secondary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text('NEW', style: AppTypography.labelCaps.copyWith(color: AppColors.primary, fontSize: 7)),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(widget.nudge.message as String, style: AppTypography.bodyBase.copyWith(height: 1.5)),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.add_circle_outline_rounded, color: AppColors.survivalGreen, size: 14),
              const SizedBox(width: 4),
              Text(
                '+${((widget.nudge.potentialSavings as double) / 7.9).toStringAsFixed(1)} survival days if actioned',
                style: AppTypography.bodySm.copyWith(color: AppColors.survivalGreen, fontSize: 11),
              ),
            ],
          ),
          if (widget.isLatest && !acknowledged) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  setState(() => _acknowledged = true);
                  widget.onAcknowledge?.call();
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                child: const Text('Got it! I\'ll try this today'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
