import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:freshio/core/theme/app_theme.dart';
import 'package:freshio/providers/inventory_provider.dart';
import 'package:freshio/providers/recipe_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:freshio/frontend/screens/inventory_page.dart';
import 'package:freshio/frontend/screens/recipe_page.dart';
import 'package:freshio/frontend/screens/analytics_page.dart';
import 'package:freshio/frontend/screens/shopping_list_page.dart';
import 'package:freshio/frontend/screens/profile_page.dart';
import 'package:freshio/frontend/widgets/smart_assistant.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late final AnimationController _headerController;
  late final Animation<double> _headerFade;
  late final Animation<Offset> _headerSlide;
  late final AnimationController _statsController;
  final ScrollController _scrollController = ScrollController();

  String _userName = '';

  String? _currentAssistantMsg;
  IconData? _currentAssistantIcon;
  String _lastAssistantMsg = '';
  DateTime? _lastAssistantTime;
  bool _welcomeShown = false;
  double _scrollOffset = 0.0;

  @override
  void initState() {
    super.initState();
    _headerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _headerFade = CurvedAnimation(parent: _headerController, curve: Curves.easeOut);
    _headerSlide = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _headerController, curve: Curves.easeOut));

    _statsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _headerController.forward();
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) _statsController.forward();
    });

    _scrollController.addListener(_onScroll);
    _loadName();
  }

  void _onScroll() {
    if (mounted) {
      setState(() {
        _scrollOffset = _scrollController.offset;
      });
    }
  }

  Future<void> _loadName() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _userName = prefs.getString('user_name') ?? 'Friend';
      });
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _headerController.dispose();
    _statsController.dispose();
    super.dispose();
  }

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good Morning ☀️';
    if (h < 17) return 'Good Afternoon 🌤️';
    return 'Good Evening 🌙';
  }

  Route _createRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeOut;
        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(position: animation.drive(tween), child: child),
        );
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }

  void _checkAssistantContext(InventoryProvider inventory, RecipeProvider recipe) {
    if (_currentAssistantMsg != null) return;

    String? newMsg;
    IconData newIcon = Icons.info_outline_rounded;

    final expiring = inventory.items.where((e) => e.expiry.difference(DateTime.now()).inDays <= 1 && !e.isWaste).toList();

    if (expiring.isNotEmpty) {
      newMsg = "Use these items before they expire ⏰";
      newIcon = Icons.timer_rounded;
    } else if (inventory.items.isEmpty) {
      newMsg = "Add your first item 🥦";
      newIcon = Icons.add_circle_outline_rounded;
    } else {
      final recipes = recipe.getSmartRecipes(inventory.items);
      if (recipes.isEmpty) {
        newMsg = "Check recipe suggestions 🍳";
        newIcon = Icons.restaurant_rounded;
      } else if (!_welcomeShown) {
        newMsg = "Welcome to your smart guide 🌱";
        newIcon = Icons.waving_hand_rounded;
        _welcomeShown = true;
      }
    }

    if (newMsg != null) {
      if (newMsg == _lastAssistantMsg && _lastAssistantTime != null) {
        if (DateTime.now().difference(_lastAssistantTime!).inSeconds < 30) return;
      }
      
      setState(() {
        _currentAssistantMsg = newMsg;
        _currentAssistantIcon = newIcon;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<InventoryProvider>(context);
    final recipeProvider = Provider.of<RecipeProvider>(context);
    final items = provider.items;
    final screen = MediaQuery.of(context).size;

    final int totalItems = items.length;
    final int expiring = items.where((e) => e.expiry.difference(DateTime.now()).inDays <= 1 && !e.isWaste).length;
    final recipes = recipeProvider.getSmartRecipes(items);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAssistantContext(provider, recipeProvider);
    });

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RepaintBoundary(
                    child: FadeTransition(
                      opacity: _headerFade,
                      child: SlideTransition(
                        position: _headerSlide,
                        child: _buildHeader(screen),
                      ),
                    ),
                  ),
                  RepaintBoundary(child: _buildSearchBar()),
                  const SizedBox(height: 24),
                  RepaintBoundary(child: _buildDashboardGrid(context, totalItems, expiring, recipes.length)),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
          if (_currentAssistantMsg != null)
            SmartAssistant(
              message: _currentAssistantMsg!,
              icon: _currentAssistantIcon ?? Icons.info,
              onDismiss: () {
                setState(() {
                  _lastAssistantMsg = _currentAssistantMsg!;
                  _lastAssistantTime = DateTime.now();
                  _currentAssistantMsg = null;
                });
              },
            ),
        ],
      ),
    );
  }

  Widget _buildHeader(Size screen) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Padding(
      padding: EdgeInsets.all(screen.width * 0.05),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              primary,
              primary.withValues(alpha: 0.8),
            ],
          ),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: primary.withValues(alpha: 0.2),
              blurRadius: 12,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _greeting(),
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 8),
            Text(
              'Hello, $_userName 👋',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "Let’s reduce food waste today 🌱",
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: TextField(
          decoration: InputDecoration(
            hintText: 'Search food or recipes...',
            prefixIcon: Icon(Icons.search_rounded, color: theme.colorScheme.primary),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 15),
          ),
        ),
      ),
    );
  }

  Widget _buildDashboardGrid(BuildContext context, int total, int expiring, int recipesCount) {
    final screen = MediaQuery.of(context).size;
    
    final cards = [
      _DashboardCardData(
        title: 'Inventory',
        badge: '$total items',
        icon: Icons.inventory_2_rounded,
        color: Theme.of(context).colorScheme.primary,
        page: const InventoryPage(),
      ),
      _DashboardCardData(
        title: 'Recipes',
        badge: '$recipesCount suggestions',
        icon: Icons.restaurant_rounded,
        color: Colors.orangeAccent,
        page: RecipePage(),
      ),
      _DashboardCardData(
        title: 'Analytics',
        badge: 'View insights',
        icon: Icons.bar_chart_rounded,
        color: Colors.purpleAccent,
        page: const AnalyticsPage(),
      ),
      _DashboardCardData(
        title: 'Shopping List',
        badge: 'Manage items',
        icon: Icons.shopping_cart_rounded,
        color: Colors.teal,
        page: const ShoppingListPage(),
      ),
      _DashboardCardData(
        title: 'Expiry Tracker',
        badge: '$expiring expiring',
        icon: Icons.timer_rounded,
        color: Colors.redAccent,
        page: const InventoryPage(),
      ),
      _DashboardCardData(
        title: 'Profile',
        badge: 'Your account',
        icon: Icons.person_rounded,
        color: Colors.blueAccent,
        page: const ProfilePage(),
      ),
    ];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screen.width * 0.05),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: cards.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.9,
        ),
        itemBuilder: (context, index) {
          return _Dashboard3DCard(
            data: cards[index],
            index: index,
            controller: _statsController,
            scrollOffset: _scrollOffset,
            onTap: () => Navigator.push(context, _createRoute(cards[index].page)),
          );
        },
      ),
    );
  }
}

class _DashboardCardData {
  final String title;
  final String badge;
  final IconData icon;
  final Color color;
  final Widget page;

  _DashboardCardData({
    required this.title,
    required this.badge,
    required this.icon,
    required this.color,
    required this.page,
  });
}

class _Dashboard3DCard extends StatefulWidget {
  final _DashboardCardData data;
  final int index;
  final AnimationController controller;
  final double scrollOffset;
  final VoidCallback onTap;

  const _Dashboard3DCard({
    required this.data,
    required this.index,
    required this.controller,
    required this.scrollOffset,
    required this.onTap,
  });

  @override
  State<_Dashboard3DCard> createState() => _Dashboard3DCardState();
}

class _Dashboard3DCardState extends State<_Dashboard3DCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Staggered entry
    final animation = CurvedAnimation(
      parent: widget.controller,
      curve: Interval(
        (widget.index * 0.08).clamp(0.0, 1.0),
        ((widget.index * 0.08) + 0.4).clamp(0.0, 1.0),
        curve: Curves.easeOut,
      ),
    );

    // Parallax effect calculations
    // Slightly shift the inner content based on scroll position
    final parallaxOffset = Offset(0, (widget.scrollOffset * 0.08) % 15 - 7.5);

    // Glow interaction
    final shadowColor = _isPressed 
        ? widget.data.color.withValues(alpha: 0.3) 
        : widget.data.color.withValues(alpha: 0.15);
    final blurRadius = _isPressed ? 20.0 : 15.0;

    // 3D Matrix
    final matrix = Matrix4.identity()
      ..setEntry(3, 2, 0.001)
      ..rotateX(_isPressed ? 0.05 : 0.02)
      ..rotateY(_isPressed ? -0.05 : -0.02);

    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(animation),
        child: GestureDetector(
          onTapDown: (_) => setState(() => _isPressed = true),
          onTapUp: (_) {
            HapticFeedback.mediumImpact(); // Stronger feedback on interaction
            setState(() => _isPressed = false);
            widget.onTap();
          },
          onTapCancel: () => setState(() => _isPressed = false),
          child: AnimatedScale(
            scale: _isPressed ? 0.96 : 1.0,
            duration: const Duration(milliseconds: 150),
            curve: Curves.easeOutBack,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              transform: matrix,
              transformAlignment: FractionalOffset.center,
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: shadowColor,
                    blurRadius: blurRadius,
                    offset: const Offset(2, 6),
                  ),
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 5,
                    offset: const Offset(0, -2),
                  ),
                ],
                border: Border.all(
                  color: _isPressed 
                      ? widget.data.color.withValues(alpha: 0.15) 
                      : widget.data.color.withValues(alpha: 0.05),
                ),
              ),
              child: Stack(
                children: [
                  // Subdued background gradient or pattern (Background layer)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            widget.data.color.withValues(alpha: 0.03),
                            theme.colorScheme.surface,
                          ],
                        ),
                      ),
                    ),
                  ),
                  
                  // Top layer (Icon + Text) with Parallax
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Transform.translate(
                      offset: parallaxOffset,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Icon container with slight glow
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: widget.data.color.withValues(alpha: _isPressed ? 0.15 : 0.1),
                              shape: BoxShape.circle,
                              boxShadow: [
                                if (_isPressed)
                                  BoxShadow(
                                    color: widget.data.color.withValues(alpha: 0.2),
                                    blurRadius: 10,
                                    spreadRadius: 2,
                                  ),
                              ],
                            ),
                            child: Icon(widget.data.icon, color: widget.data.color, size: 28),
                          ),
                          
                          // Text and Badges
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.data.title,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                  color: theme.colorScheme.onSurface,
                                  letterSpacing: -0.5,
                                  shadows: [
                                    Shadow(
                                      color: theme.colorScheme.onSurface.withValues(alpha: 0.05),
                                      blurRadius: 2,
                                      offset: const Offset(0, 1),
                                    ),
                                  ],
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 8),
                              
                              // Badge / Pill
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 150),
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: widget.data.color.withValues(alpha: _isPressed ? 0.15 : 0.08),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: widget.data.color.withValues(alpha: _isPressed ? 0.2 : 0.05),
                                  ),
                                ),
                                child: Text(
                                  widget.data.badge,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    color: widget.data.color,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
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
    );
  }
}