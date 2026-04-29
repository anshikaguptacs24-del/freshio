import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:freshio/core/theme/app_theme.dart';
import 'package:freshio/core/constants/app_constants.dart';
import 'package:freshio/providers/inventory_provider.dart';

class AnalyticsPage extends StatelessWidget {
  const AnalyticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final items = Provider.of<InventoryProvider>(context).items;
    final screen = MediaQuery.of(context).size;

    if (items.isEmpty) return _buildEmpty(screen);

    // ── BASIC CALCULATIONS ──────────────────────────────────────
    final double totalKg = items.fold(0.0, (s, e) => s + e.weightKg);
    final double wastedKg = items.where((e) => e.isWaste).fold(0.0, (s, e) => s + e.weightKg);
    final double savedKg = totalKg - wastedKg;
    final double wasteRate = totalKg == 0 ? 0 : (wastedKg / totalKg) * 100;

    // ── CATEGORY CALCULATIONS ───────────────────────────────────
    final Map<String, int> categoryCounts = {};
    final Map<String, double> categoryWaste = {};
    
    for (var item in items) {
      categoryCounts[item.category] = (categoryCounts[item.category] ?? 0) + 1;
      if (item.isWaste) {
        categoryWaste[item.category] = (categoryWaste[item.category] ?? 0.0) + item.weightKg;
      }
    }

    final topCategory = categoryCounts.isEmpty ? "None" : categoryCounts.entries.reduce((a, b) => a.value > b.value ? a : b).key;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Insights & Analytics', style: TextStyle(fontWeight: FontWeight.w900, color: AppColors.textDark)),
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 📊 OVERVIEW CARDS
            Row(children: [
              _StatCard(label: 'Saved', value: '${savedKg.toStringAsFixed(1)}kg', icon: Icons.eco_rounded, color: AppColors.fresh),
              const SizedBox(width: 12),
              _StatCard(label: 'Wasted', value: '${wastedKg.toStringAsFixed(1)}kg', icon: Icons.delete_sweep_rounded, color: AppColors.danger),
            ]),
            const SizedBox(height: 12),
            Row(children: [
              _StatCard(label: 'Waste Rate', value: '${wasteRate.toStringAsFixed(0)}%', icon: Icons.pie_chart_outline, color: AppColors.expiring),
              const SizedBox(width: 12),
              _StatCard(label: 'Top Category', value: topCategory, icon: Icons.star_outline_rounded, color: AppColors.secondary),
            ]),

            const SizedBox(height: 32),
            _SectionTitle("Category Breakdown"),
            const SizedBox(height: 16),
            
            // 📂 CATEGORY LIST
            ...categoryCounts.entries.map((entry) {
              final waste = categoryWaste[entry.key] ?? 0.0;
              return _CategoryAnalyticsCard(
                category: entry.key,
                count: entry.value,
                wasteKg: waste,
                totalItems: items.length,
              );
            }),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _SectionTitle(String title) {
    return Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.textDark));
  }

  Widget _buildEmpty(Size screen) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.bar_chart_rounded, size: 80, color: AppColors.primary.withOpacity(0.2)),
          const SizedBox(height: 16),
          const Text('No data yet', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark)),
          const SizedBox(height: 8),
          const Text('Add items to see your pantry insights.', style: TextStyle(color: AppColors.textMuted)),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  const _StatCard({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [BoxShadow(color: color.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
          border: Border.all(color: color.withOpacity(0.1)),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 12),
          Text(value ?? '0', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: color), overflow: TextOverflow.ellipsis),
          Text(label ?? '', style: const TextStyle(fontSize: 11, color: AppColors.textMuted, fontWeight: FontWeight.bold)),
        ]),
      ),
    );
  }
}

class _CategoryAnalyticsCard extends StatelessWidget {
  final String category;
  final int count;
  final double wasteKg;
  final int totalItems;

  const _CategoryAnalyticsCard({required this.category, required this.count, required this.wasteKg, required this.totalItems});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final percent = (count / totalItems) * 100;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.grey.shade100)),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: theme.colorScheme.primary.withOpacity(0.05), borderRadius: BorderRadius.circular(14)),
            child: Icon(AppConstants.getCategoryIcon(category), color: theme.colorScheme.primary, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(category, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
              const SizedBox(height: 4),
              Text('$count Items • ${percent.toStringAsFixed(0)}% of Pantry', style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
            ]),
          ),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text('${wasteKg.toStringAsFixed(1)}kg', style: TextStyle(color: wasteKg > 0 ? AppColors.danger : AppColors.fresh, fontWeight: FontWeight.w900, fontSize: 16)),
            const Text('Waste', style: TextStyle(color: AppColors.textMuted, fontSize: 10, fontWeight: FontWeight.bold)),
          ]),
        ],
      ),
    );
  }
}