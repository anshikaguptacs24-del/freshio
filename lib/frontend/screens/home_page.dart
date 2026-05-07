import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'dart:ui'; // Required for ImageFilter (Glassmorphism)

// Core & Data imports
import 'package:freshio/core/services/smart_assistant_service.dart';
import 'package:freshio/data/models/item.dart';
import 'package:freshio/data/services/storage_service.dart';
import 'package:freshio/providers/inventory_provider.dart';
import 'package:freshio/providers/recipe_provider.dart';

// Screen imports
import 'package:freshio/frontend/screens/inventory_page.dart';
import 'package:freshio/frontend/screens/analytics_page.dart';
import 'package:freshio/frontend/screens/notification_page.dart';
import 'package:freshio/frontend/screens/recipe_detail_page.dart';
import 'package:freshio/frontend/screens/donation_page.dart';
import 'package:freshio/frontend/screens/recipe_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  String _userName = '';
  String? _assistantMsg;
  IconData? _assistantIcon;
  RecipeMatch? _suggestionRecipe;

  @override
  void initState() {
    super.initState();
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

  void _updateIntelligence(List<Item> items, RecipeProvider recipeProvider) {
    if (_assistantMsg != null) return;
    final insight = SmartAssistantService.generateIntelligence(items, recipeProvider);
    if (mounted) {
      setState(() {
        _assistantMsg = insight.message;
        _assistantIcon = insight.icon;
        _suggestionRecipe = insight.suggestionRecipe;
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
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

          WidgetsBinding.instance.addPostFrameCallback((_) {
            _updateIntelligence(items, recipes);
          });

          return CustomScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            slivers: [
              // --- HERO HEADER ---
              SliverToBoxAdapter(
                child: Container(
                  padding: EdgeInsets.fromLTRB(24, MediaQuery.of(context).padding.top + 20, 24, 32),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [theme.colorScheme.primary, theme.colorScheme.primary.withOpacity(0.8)],
                    ),
                    borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Welcome back,', style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 16)),
                          Text('$_userName 👋', style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      _CircleIconButton(
                        icon: Icons.notifications_none_rounded,
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationPage())),
                      ),
                    ],
                  ),
                ),
              ),

              // --- 2x2 GLASSMORPHIC STATS GRID ---
              SliverPadding(
                padding: const EdgeInsets.all(24),
                sliver: SliverGrid.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 0.9,
                  children: [
                    _StatCard(
                      label: 'Items',
                      value: items.length.toString(),
                      icon: Icons.inventory_2_rounded,
                      color: const Color(0xFFFDE9ED), 
                      imagePath: 'assets/images/box_illustration.png',
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const InventoryPage())),
                    ),
                    _StatCard(
                      label: 'Expiring',
                      value: inventory.expiringSoonItems.length.toString(),
                      icon: Icons.timer_rounded,
                      color: const Color(0xFFFEF5E7), 
                      imagePath: 'assets/images/calender_illustration.png',
                      onTap: () => _scrollController.animateTo(600, duration: const Duration(milliseconds: 500), curve: Curves.easeOut),
                    ),
                    _StatCard(
                      label: 'Donations',
                      value: inventory.donatableItems.length.toString(),
                      icon: Icons.volunteer_activism_rounded,
                      color: const Color(0xFFE8F6F8), 
                      imagePath: 'assets/images/heart_box_illustration.png',
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DonationPage())),
                    ),
                    _StatCard(
                      label: 'Efficiency',
                      value: '${items.isEmpty ? 100 : (100 - (items.where((i) => i.isWaste).length / items.length * 100)).toInt()}%',
                      icon: Icons.eco_rounded,
                      color: const Color(0xFFE9F7EF), 
                      imagePath: 'assets/images/graph_illustration.png',
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AnalyticsPage())),
                    ),
                  ],
                ),
              ),

              // --- ANALYTICS CTA ---
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: _CtaButton(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AnalyticsPage())),
                    title: '📊 View Detailed Analytics',
                  ),
                ),
              ),

              // --- SMART INSIGHT BANNER ---
              if (_assistantMsg != null)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                    child: _PremiumMaroonCard(
                      message: _assistantMsg!,
                      icon: _assistantIcon ?? Icons.auto_awesome,
                      onDismiss: () => setState(() => _assistantMsg = null),
                      onTap: _suggestionRecipe != null 
                          ? () => Navigator.push(context, MaterialPageRoute(builder: (_) => RecipeDetailPage(recipe: _suggestionRecipe!.recipe)))
                          : null,
                    ),
                  ),
                ),

              // --- TOP MATCHES SECTION ---
              if (smartRecipes.isNotEmpty) ...[
                _SectionHeader(title: 'Top Matches for You', onSeeAll: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RecipePage()))),
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 230,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: smartRecipes.length,
                      itemBuilder: (context, index) => _RecipeActionCard(match: smartRecipes[index]),
                    ),
                  ),
                ),
              ],

              // --- SMART FOOD ACTIONS ---
              _SectionHeader(title: 'Smart Food Actions', onSeeAll: () {}),
              
              if (inventory.expiringSoonItems.isEmpty && inventory.donatableItems.isEmpty)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(40),
                    child: Center(child: Text("Your fridge is looking great!", style: TextStyle(color: Colors.grey))),
                  ),
                ),

              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final item = inventory.expiringSoonItems[index];
                      return _SmartActionTile(
                        item: item,
                        type: "recipe",
                        color: const Color(0xFF801E35),
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RecipePage())),
                      );
                    },
                    childCount: inventory.expiringSoonItems.length,
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          );
        },
      ),
    );
  }
}

// --- UI COMPONENTS ---

class _StatCard extends StatefulWidget {
  final String label, value, imagePath;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _StatCard({required this.label, required this.value, required this.icon, required this.color, required this.onTap, required this.imagePath});

  @override
  State<_StatCard> createState() => _StatCardState();
}

class _StatCardState extends State<_StatCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        HapticFeedback.mediumImpact();
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              decoration: BoxDecoration(
                color: widget.color.withOpacity(0.7),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: Colors.white.withOpacity(0.4), width: 1.5),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 8))
                ],
              ),
              padding: const EdgeInsets.all(16),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Align(
                    alignment: Alignment.topLeft,
                    child: CircleAvatar(
                      backgroundColor: Colors.white.withOpacity(0.5), 
                      radius: 18, 
                      child: Icon(widget.icon, color: Colors.black87, size: 18)
                    ),
                  ),
                  Positioned(
                    right: -15,
                    bottom: -5,
                    child: Image.asset(
                      widget.imagePath, 
                      height: 95, 
                      fit: BoxFit.contain, 
                      errorBuilder: (_, __, ___) => const SizedBox()
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomLeft,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.value, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.black87)),
                        Text(widget.label, style: TextStyle(fontSize: 14, color: Colors.black.withOpacity(0.6), fontWeight: FontWeight.w700)),
                      ],
                    ),
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

class _RecipeActionCard extends StatelessWidget {
  final RecipeMatch match;
  const _RecipeActionCard({required this.match});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 4))],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Image.network(
                        match.recipe.image, 
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: const Color(0xFFF1E4E7),
                          child: const Icon(Icons.restaurant, color: Color(0xFF801E35)),
                        ),
                      ),
                    ),
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
                            stops: const [0.5, 1.0],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 12,
                      left: 12,
                      right: 12,
                      child: Text(
                        match.recipe.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8, left: 4),
            child: Row(
              children: [
                const Icon(Icons.check_circle, color: Color(0xFF801E35), size: 16),
                const SizedBox(width: 6),
                Text(
                  '${(match.matchPercentage * 100).toInt()}% Match',
                  style: const TextStyle(fontSize: 12, color: Color(0xFF801E35), fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PremiumMaroonCard extends StatelessWidget {
  final String message;
  final IconData icon;
  final VoidCallback onDismiss;
  final VoidCallback? onTap;

  const _PremiumMaroonCard({required this.message, required this.icon, required this.onDismiss, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF801E35),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [BoxShadow(color: const Color(0xFF801E35).withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 6))],
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 28),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('SMART INSIGHT', style: TextStyle(color: Colors.white60, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1)),
                  const SizedBox(height: 4),
                  Text(message, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                ],
              ),
            ),
            IconButton(icon: const Icon(Icons.close, color: Colors.white54, size: 18), onPressed: onDismiss),
          ],
        ),
      ),
    );
  }
}

class _SmartActionTile extends StatelessWidget {
  final Item item;
  final String type;
  final Color color;
  final VoidCallback onTap;

  const _SmartActionTile({required this.item, required this.type, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(type == "recipe" ? Icons.bakery_dining_rounded : Icons.volunteer_activism, color: color, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text("Expiring soon • Use in recipe", style: TextStyle(fontSize: 12, color: Colors.grey[600])),
              ],
            ),
          ),
          TextButton(
            onPressed: onTap,
            child: Text(type == "recipe" ? "USE" : "DONATE", style: TextStyle(color: color, fontWeight: FontWeight.bold)),
          )
        ],
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
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
            GestureDetector(onTap: onSeeAll, child: const Text('See All', style: TextStyle(color: Color(0xFF801E35), fontWeight: FontWeight.bold))),
          ],
        ),
      ),
    );
  }
}

class _CtaButton extends StatelessWidget {
  final VoidCallback onTap;
  final String title;
  const _CtaButton({required this.onTap, required this.title});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(color: const Color(0xFF801E35).withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
        child: Center(child: Text(title, style: const TextStyle(color: Color(0xFF801E35), fontWeight: FontWeight.bold, fontSize: 15))),
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _CircleIconButton({required this.icon, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
        child: Icon(icon, color: Colors.white, size: 24),
      ),
    );
  }
}