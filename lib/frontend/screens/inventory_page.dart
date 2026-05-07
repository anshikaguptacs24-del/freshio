import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'package:freshio/providers/inventory_provider.dart';
import 'package:freshio/data/models/item.dart';
import 'package:freshio/frontend/screens/add_item_page.dart';
import 'package:freshio/frontend/screens/edit_item_page.dart';
import 'package:freshio/frontend/widgets/shopping_tab.dart';
import 'package:freshio/providers/shopping_provider.dart';
import 'package:freshio/providers/analytics_provider.dart';

class InventoryPage extends StatefulWidget {
  const InventoryPage({super.key});

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    
    Future.microtask(() {
      if (mounted) {
        final analytics = context.read<AnalyticsProvider>();
        context.read<InventoryProvider>().loadItems(analytics);
      }
    });

    _tabController.addListener(() {
      if (mounted) {
        context.read<InventoryProvider>().selectedInventoryTab = _tabController.index;
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9F8), // Light background like image 2
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Inventory',
          style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900, color: Colors.black),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF6B1126), // Deep wine color from your image
          unselectedLabelColor: Colors.grey,
          indicatorColor: const Color(0xFF6B1126),
          indicatorSize: TabBarIndicatorSize.label,
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          tabs: const [
            Tab(text: "My Pantry"),
            Tab(text: "Shopping List"),
          ],
        ),
      ),

      body: SafeArea(
        child: TabBarView(
          controller: _tabController,
          children: [
            _PantryTab(searchQuery: _searchQuery),
            const ShoppingTab(),
          ],
        ),
      ),
      
      // Fixed Floating Action Button to match Image 1
      floatingActionButton: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          if (_tabController.index == 0) {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const AddItemPage()));
          } else {
            _showAddShoppingDialog(context);
          }
        },
        child: Container(
          width: 80,
          height: 80,
          decoration: const BoxDecoration(
            color: Color(0xFF6B1126),
            shape: BoxShape.circle,
            boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 4))],
          ),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add, color: Colors.white, size: 28),
              Text("Add Item", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  void _showAddShoppingDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Add to Shopping List"),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: TextField(
          controller: controller,
          autofocus: true,
          onSubmitted: (val) {
            if (val.trim().isNotEmpty) {
              Provider.of<ShoppingProvider>(context, listen: false).addItem(val.trim());
              Navigator.pop(context);
            }
          },
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                Provider.of<ShoppingProvider>(context, listen: false).addItem(controller.text.trim());
                Navigator.pop(context);
              }
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }
}

class _PantryTab extends StatefulWidget {
  final String searchQuery;
  const _PantryTab({required this.searchQuery});

  @override
  State<_PantryTab> createState() => _PantryTabState();
}

class _PantryTabState extends State<_PantryTab> {
  String _localSearch = '';

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<InventoryProvider>(context);
    final filteredItems = provider.items.where((item) {
      final name = (item.name ?? '').toLowerCase();
      final query = _localSearch.toLowerCase();
      return query.isEmpty || name.contains(query);
    }).toList();

    return CustomScrollView(
      slivers: [
        // Search Bar
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
              ),
              child: TextField(
                onChanged: (v) => setState(() => _localSearch = v),
                decoration: const InputDecoration(
                  hintText: 'Search pantry...',
                  prefixIcon: Icon(Icons.search, color: Colors.grey),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
        ),

        // Grid View like Image 2
        filteredItems.isEmpty
            ? SliverFillRemaining(child: _buildEmpty())
            : SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 20,
                    crossAxisSpacing: 15,
                    childAspectRatio: 0.75,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final item = filteredItems[index];
                      return _InventoryGridItem(item: item);
                    },
                    childCount: filteredItems.length,
                  ),
                ),
              ),
        const SliverToBoxAdapter(child: SizedBox(height: 120)), // Space for FAB
      ],
    );
  }

  Widget _buildEmpty() {
    return const Center(
      child: Text('Your pantry is empty 🛒', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
    );
  }
}

class _InventoryGridItem extends StatelessWidget {
  final Item item;
  const _InventoryGridItem({required this.item});

  Color _getBgColor() {
    final colors = [
      const Color(0xFFD6EAF8), 
      const Color(0xFFFCF3CF), 
      const Color(0xFFD5F5E3), 
      const Color(0xFFFADBD8)
    ];
    return colors[(item.name ?? '').hashCode % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context, 
        MaterialPageRoute(builder: (_) => EditItemPage(item: item))
      ),
      child: Column(
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: _getBgColor(),
                borderRadius: BorderRadius.circular(24),
              ),
              // --- CHANGE STARTS HERE ---
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: (item.imageUrl != null && item.imageUrl!.isNotEmpty)
                    ? Image.network(
                        item.imageUrl!,
                        key: ValueKey(item.imageUrl),
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return const Center(child: CircularProgressIndicator(strokeWidth: 2));
                        },
                        errorBuilder: (context, error, stackTrace) => Center(
                          child: Text(
                            item.name?[0].toUpperCase() ?? '?',
                            style: const TextStyle(fontSize: 40),
                          ),
                        ),
                      )
                    : Center(
                        child: Text(
                          item.name?[0].toUpperCase() ?? '?',
                          style: const TextStyle(fontSize: 40),
                        ),
                      ),
              ),
              // --- CHANGE ENDS HERE ---
            ),
          ),
          const SizedBox(height: 8),
          Text(
            item.name ?? '',
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            item.quantityDisplay ?? '',
            style: const TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}