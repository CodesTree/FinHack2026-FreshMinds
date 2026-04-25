import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/providers/app_provider.dart';
import '../../../shared/widgets/bottom_nav.dart';
import '../../../shared/widgets/glass_card.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  void _showUpdateSalaryDialog(BuildContext context, AppProvider provider) {
    final salaryController = TextEditingController(
      text: provider.user.monthlyIncome.toStringAsFixed(0),
    );

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text('Update Monthly Salary', style: AppTypography.headlineSm),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Current: RM ${provider.user.monthlyIncome.toStringAsFixed(0)}',
              style: AppTypography.bodySm.copyWith(color: AppColors.onSurfaceVariant),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: salaryController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'New Salary (RM)',
                prefixText: 'RM ',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: AppColors.primaryContainer,
              ),
              style: AppTypography.bodyBase,
            ),
            const SizedBox(height: 12),
            Text(
              'Your Survival Score will recalculate based on the new income.',
              style: AppTypography.bodySm.copyWith(color: AppColors.onSurfaceVariant, fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: AppTypography.bodyBase.copyWith(color: AppColors.onSurfaceVariant)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondary,
              foregroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
            onPressed: () {
              final newSalary = double.tryParse(salaryController.text) ?? provider.user.monthlyIncome;
              provider.updateMonthlyIncome(newSalary);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Salary updated to RM ${newSalary.toStringAsFixed(0)}',
                    style: AppTypography.bodyBase.copyWith(color: Colors.white)),
                  backgroundColor: AppColors.primary,
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final user = provider.user;

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: AppColors.primary,
            automaticallyImplyLeading: false,
            flexibleSpace: FlexibleSpaceBar(
              background: _ProfileHeader(name: user.name),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Financial profile
                GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Financial Profile', style: AppTypography.headlineSm),
                      const SizedBox(height: 14),
                      ...[
                        ('Monthly Income', 'RM ${user.monthlyIncome.toStringAsFixed(0)}', Icons.attach_money_rounded),
                        ('Income Tier', 'B40', Icons.people_rounded),
                        ('Survival Score', '${user.survivalDays} days', Icons.timer_rounded),
                        ('Daily Burn Rate', 'RM ${user.dailyBurnRate.toStringAsFixed(2)}/day', Icons.local_fire_department_rounded),
                        ('TNG History', '90 days analysed', Icons.history_rounded),
                        ('CTOS Consent', provider.ctosConsented ? 'Granted' : 'Not granted', Icons.verified_user_rounded),
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
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => _showUpdateSalaryDialog(context, provider),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.secondary,
                            foregroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          ),
                          icon: const Icon(Icons.edit_rounded, size: 18),
                          label: const Text('Update Salary'),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Emergency mode toggle
                GlassCard(
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: user.emergencyModeActive
                                  ? AppColors.error.withOpacity(0.1)
                                  : AppColors.primaryContainer,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.warning_amber_rounded,
                              color: user.emergencyModeActive ? AppColors.error : AppColors.primary,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Emergency Mode', style: AppTypography.bodyBold),
                                Text(
                                  user.emergencyModeActive ? 'Currently active' : 'Not active',
                                  style: AppTypography.bodySm.copyWith(
                                    color: user.emergencyModeActive ? AppColors.error : AppColors.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Switch(
                            value: user.emergencyModeActive,
                            onChanged: (v) {
                              if (v) {
                                provider.activateEmergencyMode();
                              } else {
                                provider.deactivateEmergencyMode();
                              }
                            },
                            activeColor: AppColors.error,
                            activeTrackColor: AppColors.error.withOpacity(0.2),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Privacy & data
                GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Privacy & Data', style: AppTypography.headlineSm),
                      const SizedBox(height: 12),
                      ...[
                        ('Data Usage Policy', Icons.description_rounded, false),
                        ('Manage Consents', Icons.tune_rounded, false),
                        ('Download My Data', Icons.download_rounded, false),
                        ('Delete My Account', Icons.delete_forever_rounded, true),
                      ].map((item) => _SettingsTile(
                        label: item.$1,
                        icon: item.$2,
                        isDanger: item.$3,
                        onTap: () {},
                      )),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // About
                GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('About', style: AppTypography.headlineSm),
                      const SizedBox(height: 12),
                      ...[
                        ('Version', '1.0.0 (FinHack 2026)'),
                        ('Team', 'SurvivAI'),
                        ('Built for', 'TNG FinHack 2026'),
                        ('Track', 'Financial Inclusion'),
                      ].map((item) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(item.$1, style: AppTypography.bodyBase.copyWith(color: AppColors.onSurfaceVariant)),
                            Text(item.$2, style: AppTypography.bodyBold.copyWith(fontSize: 13)),
                          ],
                        ),
                      )),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => context.go('/'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.onSurfaceVariant,
                      side: const BorderSide(color: AppColors.surfaceContainerHighest),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
                    ),
                    child: const Text('Sign Out'),
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 4),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final String name;

  const _ProfileHeader({required this.name});

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
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppColors.secondary,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withOpacity(0.3), width: 3),
                ),
                child: Center(
                  child: Text(
                    name.substring(0, 1),
                    style: AppTypography.headlineLg.copyWith(color: AppColors.primary),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(name, style: AppTypography.headlineMd.copyWith(color: Colors.white)),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text('B40 • Shah Alam',
                  style: AppTypography.bodySm.copyWith(color: Colors.white.withOpacity(0.8))),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isDanger;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.label,
    required this.icon,
    required this.isDanger,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: isDanger ? AppColors.error.withOpacity(0.1) : AppColors.primaryContainer,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: isDanger ? AppColors.error : AppColors.primary, size: 18),
            ),
            const SizedBox(width: 12),
            Text(label, style: AppTypography.bodyBase.copyWith(color: isDanger ? AppColors.error : AppColors.onSurface)),
            const Spacer(),
            Icon(Icons.chevron_right_rounded, color: AppColors.onSurfaceVariant, size: 20),
          ],
        ),
      ),
    );
  }
}
