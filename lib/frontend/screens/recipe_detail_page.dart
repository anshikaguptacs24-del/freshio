import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:freshio/providers/inventory_provider.dart';
import 'package:freshio/core/theme/app_theme.dart';
import 'package:freshio/data/models/recipe.dart';

class RecipeDetailPage extends StatefulWidget {
  final Recipe recipe;

  const RecipeDetailPage({super.key, required this.recipe});

  @override
  State<RecipeDetailPage> createState() => _RecipeDetailPageState();
}

class _RecipeDetailPageState extends State<RecipeDetailPage> {
  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.of(context).size;
    final theme = Theme.of(context);

    return GestureDetector(
      onHorizontalDragUpdate: (details) {
        if (details.delta.dx > 12) {
          HapticFeedback.mediumImpact();
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        backgroundColor: theme.colorScheme.surface,
        body: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverAppBar(
              expandedHeight: screen.height * 0.38,
              pinned: true,
              backgroundColor: theme.colorScheme.primary,
              leading: Padding(
                padding: const EdgeInsets.all(8),
                child: _MicroInteraction(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.9),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: theme.colorScheme.onSurface,
                      size: 18,
                    ),
                  ),
                ),
              ),
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  widget.recipe.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    shadows: [
                      Shadow(color: Colors.black54, blurRadius: 4),
                    ],
                  ),
                ),
                background: RepaintBoundary(
                  child: Hero(
                    tag: 'recipe_image_${widget.recipe.name}',
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        _buildHeroImage(theme),
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withValues(alpha: 0.6),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.symmetric(
                horizontal: screen.width * 0.05,
                vertical: 24,
              ),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  RepaintBoundary(
                    child: _SectionHeader(
                      icon: Icons.kitchen_rounded,
                      title: 'Ingredients',
                      count: widget.recipe.ingredients.length,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...widget.recipe.ingredients.map((ing) => RepaintBoundary(
                        child: _IngredientTile(
                          ingredient: ing,
                        ),
                      )),
                  const SizedBox(height: 24),
                  RepaintBoundary(
                    child: _SectionHeader(
                      icon: Icons.format_list_numbered_rounded,
                      title: 'Steps',
                      count: widget.recipe.steps.length,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...widget.recipe.steps.asMap().entries.map(
                        (e) => RepaintBoundary(
                          child: _StepTile(
                            step: e.value,
                            index: e.key + 1,
                          ),
                        ),
                      ),
                  const SizedBox(height: 40),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroImage(ThemeData theme) {
    return CachedNetworkImage(
      imageUrl: (widget.recipe.image != null && widget.recipe.image.isNotEmpty) ? widget.recipe.image : "https://source.unsplash.com/400x300/?food",
      fit: BoxFit.cover,
      placeholder: (context, url) => Container(
        color: Colors.grey.shade300,
        child: const Center(
          child: Icon(Icons.image, color: Colors.grey),
        ),
      ),
      errorWidget: (context, url, error) => const Icon(Icons.broken_image),
    );
  }
}

class _MicroInteraction extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;

  const _MicroInteraction({required this.child, required this.onTap});

  @override
  State<_MicroInteraction> createState() => _MicroInteractionState();
}

class _MicroInteractionState extends State<_MicroInteraction> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        HapticFeedback.lightImpact();
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 120),
        child: widget.child,
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final int count;

  const _SectionHeader({
    required this.icon,
    required this.title,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: theme.colorScheme.primary, size: 18),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const Spacer(),
        Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '$count',
            style: TextStyle(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }
}

class _IngredientTile extends StatelessWidget {
  final String ingredient;

  const _IngredientTile({required this.ingredient});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final items = Provider.of<InventoryProvider>(context).items;

    // Matching logic
    final matchingItems = items
        .where((i) => !i.isWaste && (i.name ?? '').toLowerCase().contains((ingredient ?? '').toLowerCase()))
        .toList();

    final validItems = matchingItems.where((i) => !InventoryProvider.isExpired(i)).toList();
    final isAvailable = validItems.isNotEmpty;
    final isExpiring = validItems.any((i) => InventoryProvider.isExpiringSoon(i));

    Color iconColor = isAvailable ? theme.colorScheme.secondary : Colors.grey.shade400;
    if (isExpiring) iconColor = Colors.orange;

    return _MicroInteraction(
      onTap: () {},
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.primary.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
              border: Border.all(
                color: isExpiring ? Colors.orange.withValues(alpha: 0.3) : theme.colorScheme.onSurface.withValues(alpha: 0.05),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: iconColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    (ingredient ?? ''),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      decoration: !isAvailable ? TextDecoration.lineThrough : null,
                      color: !isAvailable ? Colors.grey : null,
                    ),
                  ),
                ),
                Icon(isAvailable ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded, color: iconColor, size: 18),
              ],
            ),
          ),
          if (isExpiring)
            Padding(
              padding: const EdgeInsets.only(bottom: 12, left: 4),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    "Use soon to avoid waste",
                    style: TextStyle(color: Colors.orange.shade700, fontSize: 11, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _StepTile extends StatelessWidget {
  final String step;
  final int index;

  const _StepTile({required this.step, required this.index});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return _MicroInteraction(
      onTap: () {},
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.primary.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: theme.colorScheme.onSurface.withValues(alpha: 0.05)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  '$index',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  (step ?? ''),
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}