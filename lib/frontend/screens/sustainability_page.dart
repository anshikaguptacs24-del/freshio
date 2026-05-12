import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:freshio/core/theme/app_theme.dart';
import 'package:freshio/providers/inventory_provider.dart';

//////////////////////////////////////////////////////////////
// 🌱 SUSTAINABILITY PAGE — LIVE DATA
//////////////////////////////////////////////////////////////

class SustainabilityPage extends StatelessWidget {
  const SustainabilityPage({super.key});

  @override
  Widget build(BuildContext context) {
    final items = Provider.of<InventoryProvider>(context).items;
    final screen = MediaQuery.of(context).size;

    // ── LIVE CALCULATIONS ──────────────────────────────────────
    final double total =
        items.fold(0.0, (s, e) => s + e.weightKg);
    final double wasted =
        items.where((e) => e.isWaste).fold(0.0, (s, e) => s + e.weightKg);
    final double saved   = total - wasted;
    final double score   = total == 0 ? 100 : (saved / total) * 100;
    final int totalItems = items.length;
    final int savedItems = items.where((e) => !e.isWaste).length;

    // CO₂ equivalent: ~2.5 kg CO₂ per 1 kg food saved
    final double co2Saved = saved * 2.5;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: false,
        title: const Text(
          'Sustainability',
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
                  // ECO SCORE CARD
                  ////////////////////////////////////////////////

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: score > 70
                            ? [AppColors.secondary, AppColors.fresh]
                            : [AppColors.expiring,
                               AppColors.expiring.withValues(alpha: 0.7)],
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: (score > 70
                                  ? AppColors.secondary
                                  : AppColors.expiring)
                              .withValues(alpha: 0.35),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.eco_rounded,
                                color: Colors.white, size: 22),
                            const SizedBox(width: 8),
                            const Text(
                              'Eco Score',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.25),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                score > 70 ? '🌟 Great!' : '📈 Improve',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '${score.toStringAsFixed(0)}%',
                          style: const TextStyle(
                            fontSize: 52,
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            height: 1,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'of your food is being used wisely',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: score / 100,
                            backgroundColor: Colors.white24,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                                Colors.white),
                            minHeight: 8,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  ////////////////////////////////////////////////
                  // STAT GRID
                  ////////////////////////////////////////////////

                  Row(
                    children: [
                      _EcoCard(
                        icon: Icons.savings_outlined,
                        label: 'Food Saved',
                        value: '${saved.toStringAsFixed(1)} kg',
                        color: AppColors.fresh,
                      ),
                      const SizedBox(width: 12),
                      _EcoCard(
                        icon: Icons.delete_sweep_rounded,
                        label: 'Food Wasted',
                        value: '${wasted.toStringAsFixed(1)} kg',
                        color: AppColors.danger,
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  Row(
                    children: [
                      _EcoCard(
                        icon: Icons.cloud_outlined,
                        label: 'CO₂ Saved',
                        value: '${co2Saved.toStringAsFixed(1)} kg',
                        color: AppColors.secondary,
                      ),
                      const SizedBox(width: 12),
                      _EcoCard(
                        icon: Icons.inventory_2_outlined,
                        label: 'Items Used',
                        value: '$savedItems / $totalItems',
                        color: AppColors.primary,
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  ////////////////////////////////////////////////
                  // TIPS SECTION
                  ////////////////////////////////////////////////

                  const Text(
                    'Eco Tips 🌍',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 12),

                  ...[
                    '🛒 Plan your shopping based on what you already have.',
                    '❄️ Store items properly to extend their freshness.',
                    '🍲 Use expiring items first in your cooking.',
                    '♻️ Compost food scraps instead of throwing them away.',
                  ].map((tip) => _TipTile(tip: tip)),

                  const SizedBox(height: 32),
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
          Icon(Icons.eco_rounded,
              size: screen.width * 0.2,
              color: AppColors.secondary.withValues(alpha: 0.4)),
          const SizedBox(height: 16),
          const Text(
            'Start tracking to see your eco impact!',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textMuted,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

//////////////////////////////////////////////////////////////
// ECO STAT CARD
//////////////////////////////////////////////////////////////

class _EcoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _EcoCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.12),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
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
// TIP TILE
//////////////////////////////////////////////////////////////

class _TipTile extends StatelessWidget {
  final String tip;

  const _TipTile({required this.tip});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        tip,
        style: const TextStyle(
          fontSize: 13,
          color: AppColors.textDark,
          height: 1.4,
        ),
      ),
    );
  }
}