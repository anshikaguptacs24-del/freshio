import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:freshio/core/theme/app_theme.dart';
import 'package:freshio/data/models/item.dart';
import 'package:freshio/data/services/storage_service.dart';
import 'package:freshio/providers/inventory_provider.dart';
import 'package:freshio/providers/recipe_provider.dart';
import 'package:freshio/providers/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:freshio/frontend/screens/inventory_page.dart';
import 'package:freshio/frontend/screens/recipe_page.dart';
import 'package:freshio/frontend/screens/analytics_page.dart';
import 'package:freshio/frontend/screens/notification_page.dart';
import 'package:freshio/frontend/screens/recipe_detail_page.dart';
import 'package:freshio/core/utils/donation_helper.dart';
import 'package:freshio/frontend/widgets/smart_assistant.dart';
import 'package:freshio/frontend/screens/donation_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late final AnimationController _staggerController;
  final ScrollController _scrollController = ScrollController();
  String _userName = '';

  String? _assistantMsg;
  IconData? _assistantIcon;
  RecipeMatch? _suggestionRecipe;

  @override
  void initState() {
    super.initState();
    _staggerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _staggerController.forward();
    _loadName();
  }

  Future<void> _loadName() async {
    final storage = StorageService();
    if (mounted) {
      setState(() {
        _userName = storage.getString('user_name') ?? 'Chef';
      });
    }
  }

  @override
  void dispose() {
    _staggerController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _generateIntelligence(List<Item> items, RecipeProvider recipeProvider) {
    if (_assistantMsg != null) return;

    final expiring = items.where((e) => !e.isWaste && InventoryProvider.isExpiringSoon(e)).toList();
    
    if (expiring.isNotEmpty) {
      final matches = recipeProvider.getSmartRecipes(items);
      final topMatch = matches.isNotEmpty ? matches.first : null;

      if (topMatch != null && topMatch.hasExpiring) {
        _assistantMsg = "Use your expiring ${expiring.first.name} for ${topMatch.recipe.name}! 🥘";
        _assistantIcon = Icons.auto_awesome_rounded;
        _suggestionRecipe = topMatch;
      } else {
        _assistantMsg = "You have ${expiring.length} items expiring soon. Use them now! ⚠️";
        _assistantIcon = Icons.timer_rounded;
      }
    } else if (items.isEmpty) {
      _assistantMsg = "Your pantry is empty. Let's add some items! 🛒";
      _assistantIcon = Icons.shopping_basket_rounded;
    }
    
    if (mounted && _assistantMsg != null) setState(() {});
  }



  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: Consumer2<InventoryProvider, RecipeProvider>(
        builder: (context, inventory, recipes, child) {
          final items = inventory.items;
          final smartRecipes = recipes.getSmartRecipes(items).take(3).toList();
          final expiring = items.where((e) => !e.isWaste && InventoryProvider.isExpiringSoon(e)).toList();

          WidgetsBinding.instance.addPostFrameCallback((_) {
            _generateIntelligence(items, recipes);
          });

          return Stack(
            children: [
              CustomScrollView(
                controller: _scrollController,
                physics: const BouncingScrollPhysics(),
                slivers: [
                  // HEADER (HERO)
                  SliverToBoxAdapter(
                    child: Container(
                      padding: EdgeInsets.fromLTRB(24, MediaQuery.of(context).padding.top + 24, 24, 32),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            theme.colorScheme.primary,
                            theme.colorScheme.primary.withOpacity(0.85),
                          ],
                        ),
                        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
                        boxShadow: [
                          BoxShadow(
                            color: theme.colorScheme.primary.withOpacity(0.2),
                            blurRadius: 12,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Welcome back,', style: theme.textTheme.bodyLarge?.copyWith(color: Colors.white.withOpacity(0.9), fontWeight: FontWeight.w500)),
                                const SizedBox(height: 4),
                                Text('$_userName 👋', style: theme.textTheme.displaySmall?.copyWith(fontWeight: FontWeight.bold, fontSize: 28, letterSpacing: -0.5, color: Colors.white)),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              HapticFeedback.lightImpact();
                              Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationPage()));
                            },
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.notifications_none_rounded, color: Colors.white, size: 24),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // STATS GRID
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
                    sliver: SliverGrid.count(
                      crossAxisCount: 2,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 1.1,
                      children: [
                        _AnimatedStatCard(
                          label: 'Items',
                          value: items.length.toString(),
                          icon: Icons.inventory_2_rounded,
                          color: theme.colorScheme.primary,
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const InventoryPage())),
                          delay: 0,
                        ),
                        _AnimatedStatCard(
                          label: 'Expiring',
                          value: inventory.expiringSoonItems.length.toString(),
                          icon: Icons.timer_rounded,
                          color: Colors.orange.shade400,
                          onTap: () {
                            _scrollController.animateTo(
                              400,
                              duration: const Duration(milliseconds: 500),
                              curve: Curves.easeOut,
                            );
                          },
                          delay: 100,
                        ),
                        _AnimatedStatCard(
                          label: 'Donations',
                          value: inventory.donatableItems.length.toString(),
                          icon: Icons.volunteer_activism_rounded,
                          color: Colors.teal.shade400,
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DonationPage())),
                          delay: 200,
                        ),
                        _AnimatedStatCard(
                          label: 'Efficiency',
                          value: '${items.isEmpty ? 100 : (100 - (items.where((i) => i.isWaste).length / items.length * 100)).toInt()}%',
                          icon: Icons.eco_rounded,
                          color: Colors.green.shade400,
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AnalyticsPage())),
                          delay: 300,
                        ),
                      ],
                    ),
                  ),

                  // CTA SECTION
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                      child: _CtaButton(
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AnalyticsPage())),
                        title: '📊 View Detailed Analytics',
                      ),
                    ),
                  ),

                  // ASSISTANT (INLINE)
                  if (_assistantMsg != null)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                        child: _PremiumAssistantCard(
                          message: _assistantMsg!,
                          icon: _assistantIcon!,
                          onTap: _suggestionRecipe != null 
                              ? () => Navigator.push(context, MaterialPageRoute(builder: (_) => RecipeDetailPage(recipe: _suggestionRecipe!.recipe)))
                              : null,
                          onDismiss: () => setState(() => _assistantMsg = null),
                        ),
                      ),
                    ),

                  // SMART RECIPES
                  if (smartRecipes.isNotEmpty) ...[
                    _SectionHeader(title: 'Top Matches for You', onSeeAll: () {}),
                    SliverToBoxAdapter(
                      child: Container(
                        height: 220,
                        margin: const EdgeInsets.only(top: 8),
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          physics: const BouncingScrollPhysics(),
                          itemCount: smartRecipes.length,
                          itemBuilder: (context, index) => _SmallRecipeCard(match: smartRecipes[index]),
                        ),
                      ),
                    ),
                  ],

                  // SMART FOOD ACTIONS
                  _SectionHeader(title: 'Smart Food Actions', onSeeAll: () {}),
                  
                  // EXPIRING SOON SECTION
                  if (inventory.expiringSoonItems.isNotEmpty) ...[
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                        child: Text('🚨 USE THESE SOON', style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1)),
                      ),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final item = inventory.expiringSoonItems[index];
                            final matches = recipes.getSmartRecipes([item]);
                            final bestRecipe = matches.isNotEmpty ? matches.first.recipe : null;
                            
                            return _SmartActionCard(
                              item: item,
                              type: SmartActionType.recipe,
                              suggestion: bestRecipe?.name,
                              onTap: bestRecipe != null 
                                  ? () => Navigator.push(context, MaterialPageRoute(builder: (_) => RecipeDetailPage(recipe: bestRecipe)))
                                  : () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RecipePage())),
                            );
                          },
                          childCount: inventory.expiringSoonItems.length,
                        ),
                      ),
                    ),
                  ],

                  // DONATE SECTION
                  if (inventory.donatableItems.isNotEmpty) ...[
                    const SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        child: Text('🤝 ELIGIBLE FOR DONATION', style: TextStyle(color: Colors.teal, fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1)),
                      ),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final item = inventory.donatableItems[index];
                            return _SmartActionCard(
                              item: item,
                              type: SmartActionType.donation,
                              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DonationPage())),
                            );
                          },
                          childCount: inventory.donatableItems.length,
                        ),
                      ),
                    ),
                  ],

                  const SliverToBoxAdapter(child: SizedBox(height: 100)),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class _AnimatedStatCard extends StatefulWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final int delay;

  const _AnimatedStatCard({required this.label, required this.value, required this.icon, required this.color, required this.onTap, required this.delay});

  @override
  State<_AnimatedStatCard> createState() => _AnimatedStatCardState();
}

class _AnimatedStatCardState extends State<_AnimatedStatCard> with SingleTickerProviderStateMixin {
  late AnimationController _entranceController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _entranceController, curve: Curves.easeOut));
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(CurvedAnimation(parent: _entranceController, curve: Curves.easeOutCubic));

    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _entranceController.forward();
    });
  }

  @override
  void dispose() {
    _entranceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: GestureDetector(
          onTapDown: (_) => setState(() => _isPressed = true),
          onTapUp: (_) {
            setState(() => _isPressed = false);
            HapticFeedback.lightImpact();
            widget.onTap();
          },
          onTapCancel: () => setState(() => _isPressed = false),
          child: AnimatedScale(
            scale: _isPressed ? 0.96 : 1.0,
            duration: const Duration(milliseconds: 120),
            curve: Curves.easeOut,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
                gradient: LinearGradient(
                  colors: [Colors.white, widget.color.withOpacity(0.03)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: widget.color.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(widget.icon, color: widget.color, size: 22),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          widget.value,
                          style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: Colors.black87),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        widget.label,
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CtaButton extends StatefulWidget {
  final VoidCallback onTap;
  final String title;

  const _CtaButton({required this.onTap, required this.title});

  @override
  State<_CtaButton> createState() => _CtaButtonState();
}

class _CtaButtonState extends State<_CtaButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        HapticFeedback.lightImpact();
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: BoxDecoration(
            color: primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: primary.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Text(
            widget.title,
            textAlign: TextAlign.center,
            style: TextStyle(color: primary, fontSize: 15, fontWeight: FontWeight.w700),
          ),
        ),
      ),
    );
  }
}

class _PremiumAssistantCard extends StatelessWidget {
  final String message;
  final IconData icon;
  final VoidCallback? onTap;
  final VoidCallback onDismiss;

  const _PremiumAssistantCard({required this.message, required this.icon, this.onTap, required this.onDismiss});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 50 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: GestureDetector(
        onTap: () {
          if (onTap != null) {
            HapticFeedback.lightImpact();
            onTap!();
          }
        },
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [theme.colorScheme.primary, theme.colorScheme.primary.withOpacity(0.8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(color: theme.colorScheme.primary.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8)),
            ],
          ),
          child: Row(
            children: [
              Icon(icon, color: Colors.white, size: 32),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('SMART INSIGHT', style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1)),
                    const SizedBox(height: 4),
                    Text(message ?? '', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white54, size: 20),
                onPressed: () {
                  HapticFeedback.selectionClick();
                  onDismiss();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback onSeeAll;

  const _SectionHeader({required this.title, required this.onSeeAll});

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 32, 24, 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title ?? '', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
            TextButton(onPressed: onSeeAll, child: const Text('See All')),
          ],
        ),
      ),
    );
  }
}

class _SmallRecipeCard extends StatelessWidget {
  final RecipeMatch match;

  const _SmallRecipeCard({required this.match});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        Navigator.push(context, MaterialPageRoute(builder: (_) => RecipeDetailPage(recipe: match.recipe)));
      },
      child: Container(
        width: 180,
        margin: const EdgeInsets.only(right: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      match.recipe.image,
                      fit: BoxFit.cover,
                      errorBuilder: (context, _, __) => Container(color: Colors.grey.shade200, child: const Icon(Icons.broken_image, color: Colors.grey)),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.transparent, Colors.black.withOpacity(0.6)],
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 12, left: 12, right: 12,
                      child: Text(match.recipe.name ?? '', maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 14)),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.check_circle_rounded, color: Theme.of(context).colorScheme.primary, size: 16),
                const SizedBox(width: 4),
                Text('${(match.matchPercentage * 100).toInt()}% Match', style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: 13, fontWeight: FontWeight.w800)),
              ],
            )
          ],
        ),
      ),
    );
  }
}

enum SmartActionType { recipe, donation }

class _SmartActionCard extends StatelessWidget {
  final Item item;
  final SmartActionType type;
  final String? suggestion;
  final VoidCallback onTap;

  const _SmartActionCard({
    required this.item,
    required this.type,
    this.suggestion,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isRecipe = type == SmartActionType.recipe;
    final color = isRecipe ? theme.colorScheme.primary : Colors.teal;
    final days = item.expiry.difference(DateTime.now()).inDays;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(color: color.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(16)),
            child: Icon(isRecipe ? Icons.restaurant_menu_rounded : Icons.volunteer_activism_rounded, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name ?? '', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                const SizedBox(height: 4),
                if (isRecipe)
                  Text(
                    suggestion != null ? 'Use for: $suggestion' : 'Suggest a recipe...',
                    style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.w600, fontSize: 13),
                  )
                else
                  const Text('Available for donation', style: TextStyle(color: Colors.teal, fontWeight: FontWeight.w600, fontSize: 13)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                days == 0 ? 'Today' : '$days days left',
                style: TextStyle(color: days <= 2 ? Colors.red : Colors.grey, fontWeight: FontWeight.w900, fontSize: 12),
              ),
              const SizedBox(height: 8),
              _ActionButton(
                label: isRecipe ? 'USE' : 'DONATE',
                color: color,
                onTap: onTap,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(color: color.withOpacity(0.3), blurRadius: 4, offset: const Offset(0, 2)),
          ],
        ),
        child: Text(
          label,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 0.5),
        ),
      ),
    );
  }
}