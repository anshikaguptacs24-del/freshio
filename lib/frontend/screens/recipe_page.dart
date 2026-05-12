import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:freshio/core/theme/app_theme.dart';
import 'package:freshio/providers/inventory_provider.dart';
import 'package:freshio/providers/recipe_provider.dart';
import 'package:freshio/data/models/recipe.dart';
import 'package:freshio/data/models/item.dart';
import 'package:freshio/frontend/screens/recipe_detail_page.dart';

class RecipePage extends StatefulWidget {
  const RecipePage({super.key});

  @override
  State<RecipePage> createState() => _RecipePageState();
}

class _RecipePageState extends State<RecipePage> with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  late final AnimationController _listController;
  String _searchQuery = '';
  String _selectedCategory = 'All';
  String _selectedSort = 'Match %';

  final List<String> _categories = const ['All', 'Fruits', 'Dairy', 'Veggies', 'Grains'];
  final List<String> _sortOptions = const ['Match %', 'Name'];

  @override
  void initState() {
    super.initState();
    _listController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _listController.forward();
    
    // Lazy fetch
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RecipeProvider>().fetchRecipes();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _listController.dispose();
    super.dispose();
  }

  void _showFilterSheet(ThemeData theme) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => RepaintBoundary(
          child: Container(
            height: MediaQuery.of(context).size.height * 0.6,
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            ),
            child: Column(
              children: [
                const SizedBox(height: 12),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
                ),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Recipe Filters', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900)),
                      TextButton(
                        onPressed: () => setSheetState(() {
                          _selectedCategory = 'All';
                          _selectedSort = 'Match %';
                        }),
                        child: Text('Reset', style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.w700)),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSheetSection(theme, 'Category'),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: _categories
                              .map((c) => _FilterChip(
                                    label: c,
                                    isSelected: _selectedCategory == c,
                                    onSelected: (val) => setSheetState(() => _selectedCategory = c),
                                  ))
                              .toList(),
                        ),
                        const SizedBox(height: 32),
                        _buildSheetSection(theme, 'Sort By'),
                        const SizedBox(height: 12),
                        ..._sortOptions.map((s) => _SortRadio(
                              label: s,
                              isSelected: _selectedSort == s,
                              onTap: () => setSheetState(() => _selectedSort = s),
                            )),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                  child: SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {});
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        elevation: 0,
                      ),
                      child: const Text('Apply Filters', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSheetSection(ThemeData theme, String title) {
    return Text(
      title,
      style: theme.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w900,
        color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
        letterSpacing: 1.0,
        fontSize: 13,
      ),
    );
  }

  Route _createRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeOut;
        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        return FadeTransition(opacity: animation, child: SlideTransition(position: animation.drive(tween), child: child));
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }

  @override
  Widget build(BuildContext context) {
    final recipeProvider = Provider.of<RecipeProvider>(context);
    final inventoryItems = Provider.of<InventoryProvider>(context).items;
    final theme = Theme.of(context);
    final screen = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        centerTitle: false,
        title: Text(
          'Smart Recipes',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w900,
            color: theme.colorScheme.onSurface,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh_rounded, color: theme.colorScheme.primary),
            onPressed: () => recipeProvider.fetchRecipes(),
          ),
        ],
      ),
      body: Column(
        children: [
          RepaintBoundary(child: _buildSearchBar(theme)),
          Expanded(
            child: _buildContent(recipeProvider, inventoryItems, screen, theme),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(RecipeProvider provider, List<Item> items, Size screen, ThemeData theme) {
    if (provider.isLoading) {
      return ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: screen.width * 0.05, vertical: 12),
        itemCount: 4,
        itemBuilder: (context, index) => const _LoadingCard(),
      );
    }

    if (provider.error != null && provider.recipes.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.cloud_off_rounded, size: 64, color: Colors.red.shade200),
              const SizedBox(height: 16),
              Text(
                provider.error!,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade800, fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => provider.fetchRecipes(force: true),
                icon: const Icon(Icons.replay_rounded, color: Colors.white),
                label: const Text('Try Again', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final matches = provider.getSmartRecipes(items);

    // Apply filtering efficiently
    final filteredMatches = matches.where((m) {
      final name = (m.recipe.name ?? '').toLowerCase();
      final query = (_searchQuery ?? '').toLowerCase();
      final category = (_selectedCategory ?? 'All').toLowerCase();
      
      final matchesSearch = query.isEmpty || name.contains(query);
      final matchesCategory = category == 'all' || name.contains(category);
      return matchesSearch && matchesCategory;
    }).toList();

    // Apply Sorting
    if (_selectedSort == 'Name') {
      filteredMatches.sort((a, b) => (a.recipe.name ?? '').compareTo(b.recipe.name ?? ''));
    } else {
      filteredMatches.sort((a, b) => b.score.compareTo(a.score));
    }

    if (filteredMatches.isEmpty) {
      return _buildEmpty(screen);
    }

    return ListView.builder(
      key: ValueKey('recipe_list_$_selectedCategory$_selectedSort$_searchQuery'),
      controller: _scrollController,
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: screen.width * 0.05, vertical: 12),
      itemCount: filteredMatches.length,
      itemBuilder: (_, i) {
        final m = filteredMatches[i];
        return _RecipeCard(
          recipe: m.recipe,
          matchPercentage: m.matchPercentage,
          hasExpiring: m.hasExpiring,
          missing: m.missing,
          scrollController: _scrollController,
          onTap: () => Navigator.push(context, _createRoute(RecipeDetailPage(recipe: m.recipe))),
        );
      },
    );
  }

  Widget _buildSearchBar(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: TextField(
          onChanged: (val) => setState(() => _searchQuery = val),
          decoration: InputDecoration(
            hintText: 'Search recipes...',
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
            prefixIcon: Icon(Icons.search_rounded, color: theme.colorScheme.primary, size: 22),
            suffixIcon: IconButton(
              icon: Icon(Icons.tune_rounded, color: theme.colorScheme.primary, size: 20),
              onPressed: () => _showFilterSheet(theme),
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 15),
          ),
        ),
      ),
    );
  }

  Widget _buildEmpty(Size screen) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.restaurant_menu_rounded, size: 80, color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2)),
          const SizedBox(height: 20),
          Text(
            _selectedCategory == 'All' ? 'No recipes found' : 'No $_selectedCategory recipes found',
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final ValueChanged<bool> onSelected;

  const _FilterChip({required this.label, required this.isSelected, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onSelected(!isSelected);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? theme.colorScheme.primary : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? Colors.transparent : Colors.grey.shade300),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : theme.colorScheme.onSurface,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _SortRadio extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _SortRadio({required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: isSelected ? theme.colorScheme.primary : Colors.grey.shade400, width: isSelected ? 6 : 2),
              ),
            ),
            const SizedBox(width: 12),
            Text(label, style: TextStyle(fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500, color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface)),
          ],
        ),
      ),
    );
  }
}

class _RecipeCard extends StatefulWidget {
  final Recipe recipe;
  final double matchPercentage;
  final bool hasExpiring;
  final List<String> missing;
  final ScrollController scrollController;
  final VoidCallback onTap;

  const _RecipeCard({
    required this.recipe,
    required this.matchPercentage,
    required this.hasExpiring,
    required this.missing,
    required this.scrollController,
    required this.onTap,
  });

  @override
  State<_RecipeCard> createState() => _RecipeCardState();
}

class _RecipeCardState extends State<_RecipeCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isFullMatch = widget.matchPercentage >= 1.0;
    final matchColor = isFullMatch ? Colors.green : Colors.orange;

    return RepaintBoundary(
      child: Dismissible(
        key: Key('recipe_${widget.recipe.name}'),
        direction: DismissDirection.startToEnd,
        background: Container(
          margin: const EdgeInsets.only(bottom: 24),
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          decoration: BoxDecoration(
            color: Colors.pink.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(28),
          ),
          child: const Icon(Icons.favorite_rounded, color: Colors.pinkAccent, size: 36),
        ),
        confirmDismiss: (direction) async {
          if (direction == DismissDirection.startToEnd) {
            HapticFeedback.mediumImpact();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${widget.recipe.name} added to favorites! ❤️'),
                backgroundColor: Colors.pinkAccent,
              ),
            );
          }
          return false;
        },
        child: GestureDetector(
          onTapDown: (_) => setState(() => _isPressed = true),
          onTapUp: (_) {
            setState(() => _isPressed = false);
            widget.onTap();
          },
          onTapCancel: () => setState(() => _isPressed = false),
          child: AnimatedScale(
            scale: _isPressed ? 0.98 : 1.0,
            duration: const Duration(milliseconds: 120),
            child: Container(
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: _isPressed ? 0.1 : 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                    child: SizedBox(
                      height: 200,
                      width: double.infinity,
                      child: Stack(
                        children: [
                          AnimatedBuilder(
                            animation: widget.scrollController,
                            builder: (context, child) {
                              final offset = widget.scrollController.hasClients ? widget.scrollController.offset : 0.0;
                              return Transform.translate(
                                offset: Offset(0, (offset * 0.05) % 30 - 15),
                                child: child,
                              );
                            },
                            child: Hero(
                              tag: 'recipe_image_${widget.recipe.name}',
                              child: _buildImage(widget.recipe.image ?? '', theme),
                            ),
                          ),
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
                          Positioned(
                            top: 16,
                            right: 16,
                            child: Row(
                              children: [
                                if (widget.hasExpiring)
                                  Container(
                                    margin: const EdgeInsets.only(right: 8),
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: Colors.redAccent,
                                      borderRadius: BorderRadius.circular(20),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.redAccent.withValues(alpha: 0.3),
                                          blurRadius: 8,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: const Row(
                                      children: [
                                        Icon(Icons.bolt_rounded, color: Colors.white, size: 14),
                                        SizedBox(width: 4),
                                        Text(
                                          'Eat First',
                                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 11),
                                        ),
                                      ],
                                    ),
                                  ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: matchColor,
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: matchColor.withValues(alpha: 0.2),
                                        blurRadius: 8,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Text(
                                    '${(widget.matchPercentage * 100).toInt()}% Match',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w900,
                                      fontSize: 12,
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
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.recipe.name,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.5,
                          ),
                        ),
                        if (widget.hasExpiring) ...[
                          const SizedBox(height: 4),
                          Text(
                            "Uses expiring items",
                            style: TextStyle(
                              color: Colors.redAccent.shade200,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                        const SizedBox(height: 12),
                        if (widget.missing.isEmpty)
                          Row(
                            children: [
                              Icon(Icons.check_circle_rounded, size: 18, color: Colors.green.shade600),
                              const SizedBox(width: 8),
                              Text(
                                'You have everything! Cook now ✨',
                                style: TextStyle(
                                  color: Colors.green.shade700,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          )
                        else
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Missing ${widget.missing.length} ingredients:',
                                style: const TextStyle(
                                  color: Colors.redAccent,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                widget.missing.join(', '),
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 12,
                                  height: 1.4,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
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

  Widget _buildImage(String url, ThemeData theme) {
    return CachedNetworkImage(
      imageUrl: (url != null && url.isNotEmpty) ? url : "https://source.unsplash.com/400x300/?food",
      fit: BoxFit.cover,
      width: double.infinity,
      height: 240,
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

class _LoadingCard extends StatefulWidget {
  const _LoadingCard();

  @override
  State<_LoadingCard> createState() => _LoadingCardState();
}

class _LoadingCardState extends State<_LoadingCard> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _opacity = Tween<double>(begin: 0.6, end: 1.0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: Container(
        height: 250,
        margin: const EdgeInsets.only(bottom: 24),
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(28),
        ),
      ),
    );
  }
}