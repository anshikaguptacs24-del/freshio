import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:freshio/core/theme/app_theme.dart';
import 'package:freshio/providers/inventory_provider.dart';
import 'package:freshio/providers/recipe_provider.dart';
import 'package:freshio/data/models/recipe.dart';
import 'package:freshio/frontend/screens/recipe_detail_page.dart';

//////////////////////////////////////////////////////////////
// 🍳 RECIPE PAGE — PREMIUM
//////////////////////////////////////////////////////////////

class RecipePage extends StatelessWidget {
  const RecipePage({super.key});

  @override
  Widget build(BuildContext context) {
    final items = Provider.of<InventoryProvider>(context).items;
    final matches = Provider.of<RecipeProvider>(context).getSmartRecipes(items);
    final screen = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: false,
        title: const Text(
          'Smart Recipes',
          style: TextStyle(
            color: AppColors.textDark,
            fontWeight: FontWeight.w700,
            fontSize: 22,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Chip(
              backgroundColor: AppColors.primary.withValues(alpha: 0.12),
              label: Text(
                '${matches.length} recipes',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
      body: matches.isEmpty
          ? _buildEmpty(screen)
          : ListView.builder(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.symmetric(
                horizontal: screen.width * 0.05,
                vertical: 8,
              ),
              itemCount: matches.length,
              itemBuilder: (_, i) {
                final m = matches[i];
                return _RecipeCard(
                  recipe: m.recipe,
                  score: m.score,
                  missing: m.missing,
                  screen: screen,
                );
              },
            ),
    );
  }

  Widget _buildEmpty(Size screen) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.restaurant_menu,
              size: screen.width * 0.2, color: AppColors.primary.withValues(alpha: 0.4)),
          const SizedBox(height: 16),
          const Text('Add items to see recipes!',
              style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 16,
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

//////////////////////////////////////////////////////////////
// 🃏 RECIPE CARD WIDGET
//////////////////////////////////////////////////////////////

class _RecipeCard extends StatefulWidget {
  final Recipe recipe;
  final double score;
  final List<String> missing;
  final Size screen;

  const _RecipeCard({
    required this.recipe,
    required this.score,
    required this.missing,
    required this.screen,
  });

  @override
  State<_RecipeCard> createState() => _RecipeCardState();
}

class _RecipeCardState extends State<_RecipeCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final isFullMatch = widget.score >= 1.0;
    final matchColor = isFullMatch ? AppColors.fresh : AppColors.expiring;

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (_, a, __) =>
                RecipeDetailPage(recipe: widget.recipe),
            transitionsBuilder: (_, anim, __, child) => FadeTransition(
              opacity: anim,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.05),
                  end: Offset.zero,
                ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOut)),
                child: child,
              ),
            ),
          ),
        );
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 150),
        child: Container(
          margin: const EdgeInsets.only(bottom: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              ////////////////////////////////////////////////
              // IMAGE
              ////////////////////////////////////////////////

              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(24)),
                child: SizedBox(
                  height: widget.screen.height * 0.22,
                  width: double.infinity,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.asset(
                        widget.recipe.image,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: AppColors.card,
                          child: const Icon(Icons.restaurant,
                              size: 60, color: AppColors.textMuted),
                        ),
                      ),
                      // gradient
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.3),
                            ],
                          ),
                        ),
                      ),
                      // match badge
                      Positioned(
                        top: 12,
                        right: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: matchColor,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: matchColor.withValues(alpha: 0.4),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                          child: Text(
                            '${(widget.score * 100).toInt()}% match',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              ////////////////////////////////////////////////
              // CONTENT
              ////////////////////////////////////////////////

              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.recipe.name,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // ingredients chips
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: widget.recipe.ingredients.map((ing) {
                        final isMissing = widget.missing.contains(ing);
                        return Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: isMissing
                                ? AppColors.danger.withValues(alpha: 0.1)
                                : AppColors.fresh.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isMissing
                                  ? AppColors.danger.withValues(alpha: 0.3)
                                  : AppColors.fresh.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Text(
                            isMissing ? '✗ $ing' : '✓ $ing',
                            style: TextStyle(
                              fontSize: 11,
                              color: isMissing
                                  ? AppColors.danger
                                  : AppColors.fresh,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    if (widget.missing.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Icon(Icons.shopping_cart_outlined,
                              size: 14, color: AppColors.textMuted),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              'Need: ${widget.missing.join(", ")}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textMuted,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ] else ...[
                      const SizedBox(height: 10),
                      const Row(
                        children: [
                          Icon(Icons.check_circle,
                              size: 14, color: AppColors.fresh),
                          SizedBox(width: 6),
                          Text(
                            'You have everything! Cook now 🎉',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.fresh,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}