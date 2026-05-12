import 'package:flutter/material.dart';

//////////////////////////////////////////////////////////////
// 🎯 CONFIG
//////////////////////////////////////////////////////////////

class PremiumCardConfig {
  static const double borderRadius = 18;
  static const double padding = 16;
  static const Duration animationDuration = Duration(milliseconds: 600);
}

//////////////////////////////////////////////////////////////
// 📄 PREMIUM STAT CARD
//////////////////////////////////////////////////////////////

class PremiumStatCard extends StatefulWidget {
  final double value;
  final String label;
  final IconData icon;

  final List<Color>? gradient;
  final List<double>? chartData;

  const PremiumStatCard({
    super.key,
    required this.value,
    required this.label,
    required this.icon,
    this.gradient,
    this.chartData,
  });

  @override
  State<PremiumStatCard> createState() => _PremiumStatCardState();
}

class _PremiumStatCardState extends State<PremiumStatCard> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    ////////////////////////////////////////////////////////////
    // 🔢 COUNT ANIMATION
    ////////////////////////////////////////////////////////////

    _controller = AnimationController(
      vsync: this,
      duration: PremiumCardConfig.animationDuration,
    );

    _animation = Tween<double>(
      begin: 0,
      end: widget.value,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  ////////////////////////////////////////////////////////////
  // 📊 MINI CHART
  ////////////////////////////////////////////////////////////

  Widget _buildChart() {
    if (widget.chartData == null || widget.chartData!.isEmpty) {
      return const SizedBox.shrink();
    }

    final maxVal = widget.chartData!.reduce((a, b) => a > b ? a : b);
    if (maxVal == 0) return const SizedBox.shrink();

    return SizedBox(
      height: 30,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: widget.chartData!.map((e) {
          return Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 1),
              height: (e / maxVal) * 30,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  ////////////////////////////////////////////////////////////
  // UI
  ////////////////////////////////////////////////////////////

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final gradientColors = widget.gradient ??
        [
          theme.colorScheme.primary,
          theme.colorScheme.primary.withValues(alpha: 0.8),
        ];

    return RepaintBoundary(
      child: Container(
        padding: const EdgeInsets.all(PremiumCardConfig.padding),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(PremiumCardConfig.borderRadius),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //////////////////////////////////////////////////////
            // 🔝 ICON
            //////////////////////////////////////////////////////

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(widget.icon, color: Colors.white, size: 20),
                const Icon(Icons.trending_up, color: Colors.white70, size: 16),
              ],
            ),

            const SizedBox(height: 12),

            //////////////////////////////////////////////////////
            // 🔢 ANIMATED VALUE
            //////////////////////////////////////////////////////

            AnimatedBuilder(
              animation: _animation,
              builder: (context, _) {
                return Text(
                  _animation.value.toStringAsFixed(widget.value % 1 == 0 ? 0 : 1),
                  style: const TextStyle(
                    fontSize: 24,
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
                );
              },
            ),

            const SizedBox(height: 4),

            //////////////////////////////////////////////////////
            // 📝 LABEL
            //////////////////////////////////////////////////////

            Text(
              widget.label,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),

            const SizedBox(height: 12),

            //////////////////////////////////////////////////////
            // 📊 MINI CHART
            //////////////////////////////////////////////////////

            _buildChart(),
          ],
        ),
      ),
    );
  }
}