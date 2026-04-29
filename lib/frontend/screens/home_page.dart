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

  void _showDonationSheet(BuildContext context, List<Item> items, ThemeData theme) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Donate Items 🌍', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900)),
                  IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
                ],
              ),
            ),
            Expanded(
              child: items.isEmpty
                  ? Center(child: Text('No items eligible for donation', style: TextStyle(color: Colors.grey.shade400)))
                  : ListView.builder(
                      padding: const EdgeInsets.all(24),
                      itemCount: items.length,
                      itemBuilder: (context, i) {
                        final item = items[i];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.grey.shade100),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(item.name ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                                    Text('Expires in ${item.expiry.difference(DateTime.now()).inDays} days', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                  ],
                                ),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  DonationHelper.openDonationLink(context, item);
                                },
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                                child: const Text('Donate'),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
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
                  // APPBAR
                  SliverAppBar(
                    expandedHeight: 0,
                    floating: true,
                    backgroundColor: theme.colorScheme.surface,
                    elevation: 0,
                    actions: [
                      IconButton(
                        icon: const Icon(Icons.notifications_none_rounded, size: 28),
                        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationPage())),
                      ),
                      const SizedBox(width: 8),
                    ],
                  ),

                  // HEADER
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Welcome back,', style: theme.textTheme.bodyLarge?.copyWith(color: Colors.grey)),
                          Text('${_userName ?? 'Chef'} 👋', style: theme.textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w900, letterSpacing: -1)),
                        ],
                      ),
                    ),
                  ),

                  // STATS
                  SliverToBoxAdapter(
                    child: Container(
                      height: 140,
                      margin: const EdgeInsets.symmetric(vertical: 16),
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        physics: const BouncingScrollPhysics(),
                        children: [
                          _StatCard(
                            label: 'Items',
                            value: items.length.toString(),
                            icon: Icons.inventory_2_rounded,
                            color: theme.colorScheme.primary,
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const InventoryPage())),
                          ),
                          _StatCard(
                            label: 'Expiring',
                            value: inventory.expiringSoonItems.length.toString(),
                            icon: Icons.timer_rounded,
                            color: Colors.orangeAccent,
                            onTap: () {
                              _scrollController.animateTo(
                                400,
                                duration: const Duration(milliseconds: 500),
                                curve: Curves.easeOut,
                              );
                            },
                          ),
                          _StatCard(
                            label: 'Donations',
                            value: inventory.donatableItems.length.toString(),
                            icon: Icons.volunteer_activism_rounded,
                            color: Colors.teal,
                            onTap: () => _showDonationSheet(context, inventory.donatableItems, theme),
                          ),
                          _StatCard(
                            label: 'Efficiency',
                            value: '${inventory.items.isEmpty ? 100 : (100 - (inventory.items.where((i) => i.isWaste).length / inventory.items.length * 100)).toInt()}%',
                            icon: Icons.eco_rounded,
                            color: Colors.indigo,
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AnalyticsPage())),
                          ),
                        ],
                      ),
                    ),
                  ),

                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: TextButton.icon(
                        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AnalyticsPage())),
                        icon: const Icon(Icons.analytics_outlined, size: 18),
                        label: const Text('View Detailed Analytics', style: TextStyle(fontWeight: FontWeight.bold)),
                        style: TextButton.styleFrom(
                          foregroundColor: theme.colorScheme.primary,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          backgroundColor: theme.colorScheme.primary.withOpacity(0.05),
                        ),
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
                              onTap: () => DonationHelper.openDonationLink(context, item),
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

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _StatCard({required this.label, required this.value, required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 130,
        margin: const EdgeInsets.only(right: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: color.withOpacity(0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 24),
            const Spacer(),
            Text(value ?? '0', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
            Text(label ?? '', style: TextStyle(color: Colors.grey.shade600, fontSize: 13, fontWeight: FontWeight.w600)),
          ],
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [theme.colorScheme.primary, theme.colorScheme.primary.withOpacity(0.8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(28),
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
              onPressed: onDismiss,
            ),
          ],
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
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => RecipeDetailPage(recipe: match.recipe))),
      child: Container(
        width: 160,
        margin: const EdgeInsets.only(right: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Image.network(
                match.recipe.image,
                height: 140,
                width: 160,
                fit: BoxFit.cover,
                errorBuilder: (context, _, __) => Container(color: Colors.grey.shade200),
              ),
            ),
            const SizedBox(height: 8),
            Text(match.recipe.name ?? '', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold)),
            Text('${(match.matchPercentage * 100).toInt()}% Match', style: TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.w700)),
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