import 'package:flutter/material.dart';

//////////////////////////////////////////////////////////////
// 🎯 CONFIG
//////////////////////////////////////////////////////////////

class PremiumCardConfig {
  static const double borderRadius = 18;
  static const double padding = 16;
  static const Duration animationDuration =
      Duration(milliseconds: 800);
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
  State<PremiumStatCard> createState() =>
      _PremiumStatCardState();
}

class _PremiumStatCardState extends State<PremiumStatCard>
    with SingleTickerProviderStateMixin {

  late AnimationController _controller;
  late Animation<double> _animation;

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
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

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
      return const SizedBox();
    }

    final maxVal = widget.chartData!.reduce((a, b) => a > b ? a : b);

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

    final gradient = widget.gradient ??
        [
          Theme.of(context).colorScheme.primary,
          Theme.of(context).colorScheme.primary.withValues(alpha: 0.7),
        ];

    return Container(
      padding: const EdgeInsets.all(PremiumCardConfig.padding),

      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius:
            BorderRadius.circular(PremiumCardConfig.borderRadius),
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
              Icon(widget.icon, color: Colors.white),

              const Icon(Icons.trending_up,
                  color: Colors.white70, size: 18),
            ],
          ),

          const SizedBox(height: 12),

          //////////////////////////////////////////////////////
          // 🔢 ANIMATED VALUE
          //////////////////////////////////////////////////////

          AnimatedBuilder(
            animation: _animation,
            builder: (_, __) {
              return Text(
                _animation.value.toStringAsFixed(1),
                style: const TextStyle(
                  fontSize: 24,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
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
            ),
          ),

          const SizedBox(height: 10),

          //////////////////////////////////////////////////////
          // 📊 MINI CHART
          //////////////////////////////////////////////////////

          _buildChart(),
        ],
      ),
    );
  }
}