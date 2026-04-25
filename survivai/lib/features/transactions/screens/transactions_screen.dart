import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/models/transaction_model.dart';
import '../../../core/services/mock_data_service.dart';
import '../../../shared/widgets/bottom_nav.dart';
import '../../../shared/widgets/glass_card.dart';
import '../../../shared/widgets/category_chip.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  TransactionCategory? _filter;

  @override
  Widget build(BuildContext context) {
    final all = MockDataService.getRecentTransactions();
    final filtered = _filter == null ? all : all.where((t) => t.category == _filter).toList();

    final essential = all.where((t) => t.category == TransactionCategory.essential).fold(0.0, (s, t) => s + t.amount);
    final discretionary = all.where((t) => t.category == TransactionCategory.discretionary).fold(0.0, (s, t) => s + t.amount);

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: AppColors.primary,
            automaticallyImplyLeading: false,
            flexibleSpace: FlexibleSpaceBar(
              background: _TransactionHeader(essential: essential, discretionary: discretionary),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Filter chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _FilterChip(label: 'All', selected: _filter == null, onTap: () => setState(() => _filter = null)),
                      const SizedBox(width: 8),
                      _FilterChip(
                        label: 'Essential',
                        selected: _filter == TransactionCategory.essential,
                        color: AppColors.essential,
                        onTap: () => setState(() => _filter = TransactionCategory.essential),
                      ),
                      const SizedBox(width: 8),
                      _FilterChip(
                        label: 'Discretionary',
                        selected: _filter == TransactionCategory.discretionary,
                        color: AppColors.discretionary,
                        onTap: () => setState(() => _filter = TransactionCategory.discretionary),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text('${filtered.length} transactions', style: AppTypography.bodySm),
                const SizedBox(height: 8),
                ...filtered.map((txn) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _TransactionRow(txn: txn),
                )),
              ]),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 3),
    );
  }
}

class _TransactionHeader extends StatelessWidget {
  final double essential;
  final double discretionary;

  const _TransactionHeader({required this.essential, required this.discretionary});

  @override
  Widget build(BuildContext context) {
    final total = essential + discretionary;
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
              Text('TRANSACTION HISTORY', style: AppTypography.labelCaps.copyWith(color: Colors.white.withOpacity(0.6))),
              const SizedBox(height: 8),
              Text('RM ${total.toStringAsFixed(2)}',
                style: AppTypography.headlineLg.copyWith(color: Colors.white)),
              Text('Last 90 days', style: AppTypography.bodySm.copyWith(color: Colors.white.withOpacity(0.6))),
              const SizedBox(height: 16),
              Row(
                children: [
                  _HeaderStat('Essential', 'RM ${essential.toStringAsFixed(0)}', AppColors.survivalGreen),
                  const SizedBox(width: 12),
                  _HeaderStat('Discretionary', 'RM ${discretionary.toStringAsFixed(0)}', AppColors.discretionary),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeaderStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _HeaderStat(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppTypography.bodySm.copyWith(color: Colors.white.withOpacity(0.6), fontSize: 10)),
              Text(value, style: AppTypography.bodyBold.copyWith(color: Colors.white, fontSize: 13)),
            ],
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final Color? color;
  final VoidCallback onTap;

  const _FilterChip({required this.label, required this.selected, this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.primary;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? c.withOpacity(0.12) : AppColors.surfaceBright,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? c : AppColors.surfaceContainerHighest),
        ),
        child: Text(
          label,
          style: AppTypography.bodyBase.copyWith(
            color: selected ? c : AppColors.onSurfaceVariant,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

class _TransactionRow extends StatelessWidget {
  final TransactionModel txn;

  const _TransactionRow({required this.txn});

  IconData get _icon {
    switch (txn.category) {
      case TransactionCategory.essential:
        return Icons.shopping_bag_rounded;
      case TransactionCategory.discretionary:
        return Icons.local_dining_rounded;
      case TransactionCategory.savings:
        return Icons.savings_rounded;
    }
  }

  Color get _iconColor {
    switch (txn.category) {
      case TransactionCategory.essential:
        return AppColors.essential;
      case TransactionCategory.discretionary:
        return AppColors.discretionary;
      case TransactionCategory.savings:
        return AppColors.savings;
    }
  }

  String _timeAgo() {
    final diff = DateTime.now().difference(txn.timestamp);
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: _iconColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(_icon, color: _iconColor, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(txn.merchantName,
                  style: AppTypography.bodyBold.copyWith(fontSize: 13),
                  maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 3),
                Row(
                  children: [
                    CategoryChip(category: txn.category),
                    const SizedBox(width: 6),
                    Text(_timeAgo(), style: AppTypography.bodySm.copyWith(fontSize: 10)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '−RM ${txn.amount.toStringAsFixed(2)}',
            style: AppTypography.bodyBold.copyWith(fontSize: 14),
          ),
        ],
      ),
    );
  }
}
