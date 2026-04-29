import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:freshio/providers/inventory_provider.dart';
import 'package:freshio/providers/analytics_provider.dart';
import 'dart:math' as math;

class AnalyticsPage extends StatelessWidget {
  const AnalyticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final inventory = Provider.of<InventoryProvider>(context);
    final analytics = Provider.of<AnalyticsProvider>(context);
    
    final items = inventory.items;
    final totalConsumed = analytics.totalConsumed;
    
    if (items.isEmpty && totalConsumed == 0) return _buildEmpty();

    // Calculations
    final totalItems = items.length;
    final expiringSoon = inventory.expiringSoonItems.length;
    final efficiency = (totalItems + totalConsumed) == 0 
        ? 0.0 
        : totalConsumed / (totalItems + totalConsumed);

    // Trend data (Last 7 Days)
    final List<DateTime> last7Days = List.generate(
      7,
      (i) => DateTime.now().subtract(Duration(days: 6 - i)),
    );

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Impact & Analytics', style: TextStyle(fontWeight: FontWeight.w900, color: Colors.black87)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Efficiency Header
            _EfficiencyHeader(efficiency: efficiency),
            
            const SizedBox(height: 32),
            // Smart Suggestion
            _SmartInsightCard(suggestion: analytics.getPersonalizedSuggestion(inventory.expiringSoonItems)),

            const SizedBox(height: 32),
            const Text("Weekly Trend", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
            const SizedBox(height: 16),
            _TrendGraph(
              last7Days: last7Days,
              consumedPerDay: analytics.consumedPerDay,
              wastedPerDay: analytics.wastedPerDay,
            ),

            const SizedBox(height: 32),
            const Text("Key Metrics", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
            const SizedBox(height: 16),

            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.1,
              children: [
                _StatCard(
                  label: "In Pantry",
                  value: totalItems.toString(),
                  icon: Icons.inventory_2_rounded,
                  color: Colors.blue,
                ),
                _StatCard(
                  label: "Expiring Soon",
                  value: expiringSoon.toString(),
                  icon: Icons.timer_rounded,
                  color: Colors.orange,
                ),
                _StatCard(
                  label: "Consumed",
                  value: totalConsumed.toString(),
                  icon: Icons.check_circle_rounded,
                  color: Colors.green,
                ),
                _StatCard(
                  label: "Waste Prevented",
                  value: totalConsumed.toString(),
                  icon: Icons.eco_rounded,
                  color: Colors.teal,
                ),
              ],
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.insights_rounded, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          const Text('No data yet', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
          const SizedBox(height: 8),
          const Text('Start marking items as finished to see analytics.', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}

class _EfficiencyHeader extends StatelessWidget {
  final double efficiency;
  const _EfficiencyHeader({required this.efficiency});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Theme.of(context).colorScheme.primary, Theme.of(context).colorScheme.primary.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Theme.of(context).colorScheme.primary.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Efficiency Score", style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1)),
          const SizedBox(height: 8),
          Text("${(efficiency * 100).toInt()}%", style: const TextStyle(color: Colors.white, fontSize: 42, fontWeight: FontWeight.w900)),
          const SizedBox(height: 12),
          Text(
            efficiency > 0.8 ? "Great job! You're minimizing waste 🎉" : "Try using items before they expire ⚠️",
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 14),
          ),
          const SizedBox(height: 20),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: efficiency,
              backgroundColor: Colors.white.withOpacity(0.2),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }
}

class _SmartInsightCard extends StatelessWidget {
  final String suggestion;
  const _SmartInsightCard({required this.suggestion});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.purple.shade50,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.purple.shade100),
      ),
      child: Row(
        children: [
          Icon(Icons.auto_awesome_rounded, color: Colors.purple.shade400, size: 28),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("SMART INSIGHT", style: TextStyle(color: Colors.purple.shade300, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
                const SizedBox(height: 4),
                Text(
                  suggestion,
                  style: TextStyle(color: Colors.purple.shade900, fontWeight: FontWeight.w700, fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TrendGraph extends StatelessWidget {
  final List<DateTime> last7Days;
  final Map<String, int> consumedPerDay;
  final Map<String, int> wastedPerDay;

  const _TrendGraph({
    required this.last7Days,
    required this.consumedPerDay,
    required this.wastedPerDay,
  });

  String _normalize(DateTime d) => "${d.year}-${d.month}-${d.day}";

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: last7Days.map((date) {
              final key = _normalize(date);
              final consumed = consumedPerDay[key] ?? 0;
              final wasted = wastedPerDay[key] ?? 0;
              final total = math.max(consumed + wasted, 1);

              return Column(
                children: [
                  Container(
                    height: 100,
                    width: 12,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Stack(
                      alignment: Alignment.bottomCenter,
                      children: [
                        // Wasted part (Red)
                        FractionallySizedBox(
                          heightFactor: (consumed + wasted) / math.max(total, 5), // relative to max 5 items
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.red.shade200,
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                        ),
                        // Consumed part (Green)
                        FractionallySizedBox(
                          heightFactor: consumed / math.max(total, 5),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.green.shade400,
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    date.day.toString(),
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey.shade400),
                  ),
                ],
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _LegendItem(color: Colors.green.shade400, label: "Consumed"),
              const SizedBox(width: 24),
              _LegendItem(color: Colors.red.shade200, label: "Wasted"),
            ],
          ),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontWeight: FontWeight.bold)),
      ],
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
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 20),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.black87)),
              Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }
}