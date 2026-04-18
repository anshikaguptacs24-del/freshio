import 'package:flutter/material.dart';

// Reusable card for dashboard stats
class StatCard extends StatelessWidget {
  final String title; // label (e.g. Total Items)
  final String value; // number (e.g. 24)
  final Color color;  // color for styling

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15), // light background
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(12),

      // Center content vertically
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [

          // Number
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),

          const SizedBox(height: 5),

          // Title
          Text(
            title,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}