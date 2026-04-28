import 'package:flutter/material.dart';
import 'package:freshio/core/theme/app_theme.dart';
import 'package:freshio/providers/inventory_provider.dart';
import 'package:freshio/providers/recipe_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

//////////////////////////////////////////////////////////////
// 🏠 HOME PAGE — PREMIUM / ALL LIVE DATA
//////////////////////////////////////////////////////////////

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnim;

  int _selectedCategory = 0;
  String _userName = '';

  final List<String> _categories = [
    '🥗 All', '🍎 Fruits', '🥛 Dairy', '🥦 Veggies', '🍞 Grains',
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnim =
        CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _controller.forward();
    _loadName();
  }

  Future<void> _loadName() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = prefs.getString('user_name') ?? '';
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good Morning ☀️';
    if (h < 17) return 'Good Afternoon 🌤️';
    return 'Good Evening 🌙';
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<InventoryProvider>(context);
    final recipeProvider = Provider.of<RecipeProvider>(context);
    final items = provider.items;
    final screen = MediaQuery.of(context).size;

    // ── ALL REAL DATA ──────────────────────────────────────────
    final int totalItems = items.length;
    final int expiring = items
        .where((e) =>
            e.expiry.difference(DateTime.now()).inDays <= 1 && !e.isWaste)
        .length;
    final int wasteCount = items.where((e) => e.isWaste).length;
    final recipes = recipeProvider.getSmartRecipes(items);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: FadeTransition(
        opacity: _fadeAnim,
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                ////////////////////////////////////////////////
                // HEADER
                ////////////////////////////////////////////////

                _buildHeader(screen),

                ////////////////////////////////////////////////
                // FLOATING SEARCH BAR
                ////////////////////////////////////////////////

                _buildSearchBar(),

                ////////////////////////////////////////////////
                // 3D STAT CARDS — LIVE DATA
                ////////////////////////////////////////////////

                _buildStatCards(totalItems, expiring, wasteCount),

                const SizedBox(height: 24),

                ////////////////////////////////////////////////
                // CATEGORY CHIPS
                ////////////////////////////////////////////////

                _buildCategoryChips(),

                const SizedBox(height: 20),

                ////////////////////////////////////////////////
                // EXPIRY ALERT — only shown if items expiring
                ////////////////////////////////////////////////

                if (expiring > 0) _buildExpiryAlert(expiring, screen),

                ////////////////////////////////////////////////
                // RECIPE SUGGESTIONS — LIVE from inventory
                ////////////////////////////////////////////////

                Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: screen.width * 0.05),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Recipe Suggestions',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                        ),
                      ),
                      Text(
                        '${recipes.length} found',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                if (recipes.isEmpty)
                  Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: screen.width * 0.05),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Add items to your pantry to get recipe suggestions!',
                        style: TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                else
                  SizedBox(
                    height: screen.height * 0.27,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      padding: EdgeInsets.only(
                          left: screen.width * 0.05, right: 8),
                      itemCount: recipes.length,
                      itemBuilder: (_, i) => _RecipePreviewCard(
                        name: recipes[i].recipe.name,
                        image: recipes[i].recipe.image,
                        score: recipes[i].score,
                        width: screen.width * 0.55,
                      ),
                    ),
                  ),

                const SizedBox(height: 24),

                ////////////////////////////////////////////////
                // QUICK ACTIONS
                ////////////////////////////////////////////////

                Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: screen.width * 0.05),
                  child: const Text(
                    'Quick Actions',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                _buildQuickActions(screen),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  //////////////////////////////////////////////////////////////
  // HEADER — name from SharedPreferences
  //////////////////////////////////////////////////////////////

  Widget _buildHeader(Size screen) {
    final theme    = Theme.of(context);
    final primary  = theme.colorScheme.primary;
    final initials = _userName.isNotEmpty
        ? _userName.trim().split(' ').map((w) => w[0].toUpperCase()).take(2).join()
        : '?';

    return AnimatedOpacity(
      opacity: _userName.isEmpty ? 0.85 : 1.0,
      duration: const Duration(milliseconds: 500),
      child: Transform(
        // Subtle 3D tilt — top edge slightly closer, bottom slightly farther
        transform: Matrix4.identity()
          ..setEntry(3, 2, 0.0008)          // perspective
          ..rotateX(-0.012),               // ~0.7° tilt
        alignment: Alignment.center,
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(
              screen.width * 0.05, 20, screen.width * 0.05, 28),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                primary,
                primary.withValues(alpha: 0.75),
              ],
            ),
            borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(32)),
            boxShadow: [
              BoxShadow(
                color: primary.withValues(alpha: 0.35),
                blurRadius: 24,
                spreadRadius: 2,
                offset: const Offset(0, 10),
              ),
              BoxShadow(
                color: primary.withValues(alpha: 0.12),
                blurRadius: 40,
                offset: const Offset(0, 20),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // TOP ROW — greeting + avatar
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _greeting(),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _userName.isNotEmpty
                              ? 'Hello, $_userName 👋'
                              : 'Hello 👋',
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Avatar with glow ring
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: Colors.white.withValues(alpha: 0.5),
                          width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.white.withValues(alpha: 0.2),
                          blurRadius: 12,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 22,
                      backgroundColor: Colors.white.withValues(alpha: 0.22),
                      child: Text(
                        initials,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // SUBTITLE
              Text(
                "Let's reduce food waste today 🌱",
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.white.withValues(alpha: 0.75),
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  //////////////////////////////////////////////////////////////
  // SEARCH BAR
  //////////////////////////////////////////////////////////////

  Widget _buildSearchBar() {
    final primary = Theme.of(context).colorScheme.primary;
    return Padding(
      // Normal padding — no negative translate that clips layout
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: primary.withValues(alpha: 0.15),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: const TextField(
          decoration: InputDecoration(
            hintText: 'Search food, recipes...',
            hintStyle: TextStyle(color: AppColors.textMuted, fontSize: 14),
            icon: Icon(Icons.search, color: AppColors.primary),
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
          ),
        ),
      ),
    );
  }

  //////////////////////////////////////////////////////////////
  // 3D STAT CARDS — LIVE
  //////////////////////////////////////////////////////////////

  Widget _buildStatCards(int total, int expiring, int waste) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          _Stat3DCard(
              value: '$total',
              label: 'Total',
              icon: Icons.inventory_2_rounded,
              color: AppColors.primary),
          const SizedBox(width: 10),
          _Stat3DCard(
              value: '$expiring',
              label: 'Expiring',
              icon: Icons.timer_rounded,
              color: AppColors.expiring),
          const SizedBox(width: 10),
          _Stat3DCard(
              value: '$waste',
              label: 'Wasted',
              icon: Icons.delete_sweep_rounded,
              color: AppColors.danger),
        ],
      ),
    );
  }

  //////////////////////////////////////////////////////////////
  // EXPIRY ALERT BANNER
  //////////////////////////////////////////////////////////////

  Widget _buildExpiryAlert(int expiring, Size screen) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
          screen.width * 0.05, 0, screen.width * 0.05, 20),
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.expiring,
              AppColors.expiring.withValues(alpha: 0.7)
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.expiring.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            const Icon(Icons.warning_amber_rounded,
                color: Colors.white, size: 22),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                '$expiring item${expiring > 1 ? 's' : ''} expiring within 24 hours!',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  //////////////////////////////////////////////////////////////
  // CATEGORY CHIPS
  //////////////////////////////////////////////////////////////

  Widget _buildCategoryChips() {
    return SizedBox(
      height: 44,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.only(left: 20, right: 8),
        itemCount: _categories.length,
        itemBuilder: (_, i) {
          final selected = i == _selectedCategory;
          return GestureDetector(
            onTap: () => setState(() => _selectedCategory = i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.symmetric(
                  horizontal: 18, vertical: 10),
              decoration: BoxDecoration(
                color: selected ? AppColors.primary : Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: selected
                        ? AppColors.primary.withValues(alpha: 0.3)
                        : Colors.black.withValues(alpha: 0.06),
                    blurRadius: selected ? 10 : 6,
                    offset:
                        selected ? const Offset(0, 4) : Offset.zero,
                  ),
                ],
              ),
              child: Text(
                _categories[i],
                style: TextStyle(
                  color: selected
                      ? Colors.white
                      : AppColors.textMuted,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  //////////////////////////////////////////////////////////////
  // QUICK ACTIONS
  //////////////////////////////////////////////////////////////

  Widget _buildQuickActions(Size screen) {
    final actions = [
      {
        'label': 'Add Item',
        'icon': Icons.add_circle_outline,
        'color': AppColors.primary
      },
      {
        'label': 'Scan QR',
        'icon': Icons.qr_code_scanner,
        'color': AppColors.secondary
      },
      {
        'label': 'Analytics',
        'icon': Icons.bar_chart_rounded,
        'color': AppColors.accent
      },
      {
        'label': 'Shopping',
        'icon': Icons.shopping_cart_outlined,
        'color': AppColors.danger
      },
    ];

    return Padding(
      padding:
          EdgeInsets.symmetric(horizontal: screen.width * 0.05),
      child: Row(
        children: actions.map((a) {
          final color = a['color'] as Color;
          return Expanded(
            child: _PressCard(
              child: Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                      color: color.withValues(alpha: 0.2)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(a['icon'] as IconData,
                        color: color, size: 24),
                    const SizedBox(height: 7),
                    Text(
                      a['label'] as String,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: color,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

//////////////////////////////////////////////////////////////
// RECIPE PREVIEW CARD (live from recipe engine)
//////////////////////////////////////////////////////////////

class _RecipePreviewCard extends StatefulWidget {
  final String name;
  final String image;
  final double score;
  final double width;

  const _RecipePreviewCard({
    required this.name,
    required this.image,
    required this.score,
    required this.width,
  });

  @override
  State<_RecipePreviewCard> createState() =>
      _RecipePreviewCardState();
}

class _RecipePreviewCardState extends State<_RecipePreviewCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 150),
        child: Container(
          width: widget.width,
          margin: const EdgeInsets.only(right: 14, bottom: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.15),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(
                  widget.image,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: AppColors.card,
                    child: const Icon(Icons.restaurant,
                        size: 50, color: AppColors.textMuted),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.65),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  bottom: 12,
                  left: 12,
                  right: 12,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: widget.score >= 1.0
                              ? AppColors.fresh
                              : AppColors.expiring,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${(widget.score * 100).toInt()}% match',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

//////////////////////////////////////////////////////////////
// 3D STAT CARD
//////////////////////////////////////////////////////////////

class _Stat3DCard extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color color;

  const _Stat3DCard({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(20),
          border:
              Border.all(color: color.withValues(alpha: 0.2)),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.2),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
            BoxShadow(
              color: Colors.white.withValues(alpha: 0.8),
              blurRadius: 6,
              offset: const Offset(-2, -2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 10),
            Text(
              value,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                color: AppColors.textMuted,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

//////////////////////////////////////////////////////////////
// PRESSABLE SCALE WRAPPER
//////////////////////////////////////////////////////////////

class _PressCard extends StatefulWidget {
  final Widget child;
  const _PressCard({required this.child});

  @override
  State<_PressCard> createState() => _PressCardState();
}

class _PressCardState extends State<_PressCard> {
  bool _p = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _p = true),
      onTapUp: (_) => setState(() => _p = false),
      onTapCancel: () => setState(() => _p = false),
      child: AnimatedScale(
        scale: _p ? 0.94 : 1.0,
        duration: const Duration(milliseconds: 150),
        child: widget.child,
      ),
    );
  }
}