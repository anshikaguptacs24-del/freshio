import 'package:flutter/material.dart';

//////////////////////////////////////////////////////////////
// 🎯 CONFIG (CHANGE WITHOUT TOUCHING UI)
//////////////////////////////////////////////////////////////

class RecipeCardConfig {
  static const double borderRadius = 16;
  static const double imageHeightRatio = 0.22;

  static const String defaultTime = "15 min";
}

//////////////////////////////////////////////////////////////
// 📄 RECIPE CARD
//////////////////////////////////////////////////////////////

class RecipeCard extends StatelessWidget {
  final String title;
  final String time;
  final String available;
  final String? imageUrl;
  final VoidCallback? onTap;

  const RecipeCard({
    super.key,
    required this.title,
    required this.time,
    required this.available,
    this.imageUrl,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {

    final primary = Theme.of(context).colorScheme.primary;

    return GestureDetector(
      onTap: onTap,

      child: Container(
        margin: const EdgeInsets.only(bottom: 12),

        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius:
              BorderRadius.circular(RecipeCardConfig.borderRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
            )
          ],
        ),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            //////////////////////////////////////////////////
            // 🖼 IMAGE (ASSET with fallback)
            //////////////////////////////////////////////////

            if (imageUrl != null)
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16)),
                child: Image.asset(
                  imageUrl!,
                  height: MediaQuery.of(context).size.height *
                      RecipeCardConfig.imageHeightRatio,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: MediaQuery.of(context).size.height *
                        RecipeCardConfig.imageHeightRatio,
                    color: const Color(0xFFFFF1E8),
                    child: const Icon(Icons.restaurant,
                        size: 40, color: Color(0xFF8C6D5A)),
                  ),
                ),
              ),

            //////////////////////////////////////////////////
            // 📄 CONTENT
            //////////////////////////////////////////////////

            Padding(
              padding: const EdgeInsets.all(12),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // 🍽 TITLE
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),

                  const SizedBox(height: 6),

                  // ⏱ TIME
                  Row(
                    children: [
                      const Icon(Icons.timer,
                          size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        time.isEmpty
                            ? RecipeCardConfig.defaultTime
                            : time,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 6),

                  // ✅ AVAILABILITY
                  Text(
                    available,
                    style: TextStyle(
                      fontSize: 12,
                      color: primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}