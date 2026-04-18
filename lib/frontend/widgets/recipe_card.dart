import 'package:flutter/material.dart';

// Reusable card for recipes
class RecipeCard extends StatelessWidget {
  final String name; // recipe name

  const RecipeCard({
    super.key,
    required this.name,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      margin: const EdgeInsets.only(left: 12),

      decoration: BoxDecoration(
        color: Colors.green[100],
        borderRadius: BorderRadius.circular(12),
      ),

      // Center recipe name
      child: Center(
        child: Text(
          name,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}