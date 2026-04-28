import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:freshio/core/theme/app_theme.dart';
import 'package:freshio/providers/inventory_provider.dart';

//////////////////////////////////////////////////////////////
// 📊 ANALYTICS PAGE — PREMIUM / LIVE DATA
//////////////////////////////////////////////////////////////

class AnalyticsPage extends StatelessWidget {
  const AnalyticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final items = Provider.of<InventoryProvider>(context).items;
    final screen = MediaQuery.of(context).size;

    // ── ALL LIVE CALCULATIONS ──────────────────────────────────
    final double totalKg =
        items.fold(0.0, (s, e) => s + e.weightKg);
    final double wastedKg =
        items.where((e) => e.isWaste).fold(0.0, (s, e) => s + e.weightKg);
    final double savedKg = totalKg - wastedKg;
    final int freshCount = items.where((e) => !e.isWaste).length;
    final int totalCount = items.length;
    final double wasteRate =
        totalCount == 0 ? 0 : (wastedKg / totalKg) * 100;

    // ── WEEKLY WASTE DATA ──────────────────────────────────────
    final Map<String, double> weekly = {
      'Mon': 0, 'Tue': 0, 'Wed': 0, 'Thu': 0,
      'Fri': 0, 'Sat': 0, 'Sun': 0,
    };
    for (final item in items.where((e) => e.isWaste)) {
      final key = weekly.keys.elementAt(item.expiry.weekday - 1);
      weekly[key] = weekly[key]! + item.weightKg;
    }
    final maxWeekly =
        weekly.values.fold(0.0, (a, b) => a > b ? a : b);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: false,
        title: const Text(
          'Analytics',
          style: TextStyle(
            color: AppColors.textDark,
            fontWeight: FontWeight.w700,
            fontSize: 22,
          ),
        ),
      ),
      body: items.isEmpty
          ? _buildEmpty(screen)
          : SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.symmetric(
                horizontal: screen.width * 0.05,
                vertical: 8,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  ////////////////////////////////////////////////
                  // SUMMARY STAT CARDS
                  ////////////////////////////////////////////////

                  Row(
                    children: [
                      _StatCard(
                        label: 'Food Saved',
                        value: '${savedKg.toStringAsFixed(1)} kg',
                        icon: Icons.eco_rounded,
                        color: AppColors.fresh,
                      ),
                      const SizedBox(width: 12),
                      _StatCard(
                        label: 'Food Wasted',
                        value: '${wastedKg.toStringAsFixed(1)} kg',
                        icon: Icons.delete_sweep_rounded,
                        color: AppColors.danger,
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  Row(
                    children: [
                      _StatCard(
                        label: 'Fresh Items',
                        value: '$freshCount',
                        icon: Icons.check_circle_outline,
                        color: AppColors.secondary,
                      ),
                      const SizedBox(width: 12),
                      _StatCard(
                        label: 'Waste Rate',
                        value: '${wasteRate.toStringAsFixed(0)}%',
                        icon: Icons.pie_chart_outline,
                        color: AppColors.expiring,
                      ),
                    ],
                  ),

                  const SizedBox(height: 28),

                  ////////////////////////////////////////////////
                  // SAVINGS PROGRESS BAR
                  ////////////////////////////////////////////////

                  if (totalKg > 0) ...[
                    const Text(
                      'Savings Overview',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.08),
                            blurRadius: 14,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Saved',
                                  style: TextStyle(
                                      color: AppColors.fresh,
                                      fontWeight: FontWeight.w600)),
                              Text('Wasted',
                                  style: TextStyle(
                                      color: AppColors.danger,
                                      fontWeight: FontWeight.w600)),
                            ],
                          ),
                          const SizedBox(height: 10),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: LinearProgressIndicator(
                              value: totalKg > 0 ? savedKg / totalKg : 0,
                              backgroundColor: AppColors.danger
                                  .withValues(alpha: 0.2),
                              valueColor:
                                  const AlwaysStoppedAnimation<Color>(
                                      AppColors.fresh),
                              minHeight: 10,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${savedKg.toStringAsFixed(1)} kg',
                                style: const TextStyle(
                                    fontSize: 13,
                                    color: AppColors.textMuted),
                              ),
                              Text(
                                'Total: ${totalKg.toStringAsFixed(1)} kg',
                                style: const TextStyle(
                                    fontSize: 13,
                                    color: AppColors.textMuted),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),
                  ],

                  ////////////////////////////////////////////////
                  // WEEKLY WASTE CHART
                  ////////////////////////////////////////////////

                  const Text(
                    'Weekly Waste',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.08),
                          blurRadius: 14,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: weekly.entries.map((entry) {
                        final h = maxWeekly == 0
                            ? 0.0
                            : (entry.value / maxWeekly) * 100;
                        return _WeekBar(
                          day: entry.key,
                          value: entry.value,
                          heightFactor: h,
                          color: entry.value > 0
                              ? AppColors.danger
                              : AppColors.background,
                        );
                      }).toList(),
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
    );
  }

  Widget _buildEmpty(Size screen) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.bar_chart_rounded,
              size: screen.width * 0.2,
              color: AppColors.primary.withValues(alpha: 0.3)),
          const SizedBox(height: 16),
          const Text(
            'No data yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Add items to your pantry\nto see analytics here.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textMuted, fontSize: 14),
          ),
        ],
      ),
    );
  }
}

//////////////////////////////////////////////////////////////
// STAT CARD
//////////////////////////////////////////////////////////////

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.2)),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.15),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textMuted,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

//////////////////////////////////////////////////////////////
// WEEK BAR
//////////////////////////////////////////////////////////////

class _WeekBar extends StatelessWidget {
  final String day;
  final double value;
  final double heightFactor;
  final Color color;

  const _WeekBar({
    required this.day,
    required this.value,
    required this.heightFactor,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (value > 0)
          Text(
            '${value.toStringAsFixed(1)}',
            style: const TextStyle(
                fontSize: 9,
                color: AppColors.textMuted,
                fontWeight: FontWeight.w600),
          ),
        const SizedBox(height: 4),
        AnimatedContainer(
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeOut,
          width: 22,
          height: heightFactor < 6 ? 6 : heightFactor,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          day.substring(0, 2),
          style: const TextStyle(
            fontSize: 11,
            color: AppColors.textMuted,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}