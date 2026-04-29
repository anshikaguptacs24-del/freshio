import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'package:freshio/core/theme/app_theme.dart';
import 'package:freshio/providers/inventory_provider.dart';
import 'package:freshio/data/models/item.dart';
import 'package:freshio/frontend/screens/add_item_page.dart';
import 'package:freshio/frontend/screens/edit_item_page.dart';

class InventoryPage extends StatefulWidget {
  const InventoryPage({super.key});

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    
    // Load items when page opens
    Future.microtask(() {
      if (mounted) {
        context.read<InventoryProvider>().loadItems();
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
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        centerTitle: false,
        title: Text(
          'Inventory',
          style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: theme.colorScheme.primary,
          unselectedLabelColor: Colors.grey,
          indicatorColor: theme.colorScheme.primary,
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          tabs: const [
            Tab(text: "My Pantry"),
            Tab(text: "Shopping List"),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final newItem = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddItemPage()),
          );
          if (newItem != null && newItem is Item) {
            print("Received new item: ${newItem.name}");
            await context.read<InventoryProvider>().addItem(newItem);
          }
        },
        backgroundColor: theme.colorScheme.primary,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text('Add Item', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _PantryTab(searchQuery: _searchQuery),
          const _ShoppingTab(),
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
    final theme = Theme.of(context);

    final filteredItems = provider.items.where((item) {
      final name = (item.name ?? '').toLowerCase();
      final query = (_localSearch ?? '').toLowerCase();
      return query.isEmpty || name.contains(query);
    }).toList();

    print("Rendering PantryTab with ${filteredItems.length} items (Total: ${provider.items.length})");

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(24),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
            ),
            child: TextField(
              onChanged: (v) => setState(() => _localSearch = v),
              decoration: InputDecoration(
                hintText: 'Search pantry...',
                prefixIcon: Icon(Icons.search_rounded, color: theme.colorScheme.primary),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 15),
              ),
            ),
          ),
        ),
        Expanded(
          child: filteredItems.isEmpty
              ? _buildEmpty(context)
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 100),
                  itemCount: filteredItems.length,
                  itemBuilder: (context, i) => _InventoryItemCard(item: filteredItems[i]),
                ),
        ),
      ],
    );
  }

  Widget _buildEmpty(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          const Text('No items found', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _ShoppingTab extends StatefulWidget {
  const _ShoppingTab();

  @override
  State<_ShoppingTab> createState() => _ShoppingTabState();
}

class _ShoppingTabState extends State<_ShoppingTab> {
  final List<String> _shoppingItems = [];
  final _controller = TextEditingController();

  void _add() {
    if (_controller.text.isEmpty) return;
    setState(() {
      _shoppingItems.add(_controller.text);
      _controller.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
                  ),
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Add to shopping list...',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    ),
                    onSubmitted: (_) => _add(),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              CircleAvatar(
                backgroundColor: theme.colorScheme.primary,
                child: IconButton(icon: const Icon(Icons.add, color: Colors.white), onPressed: _add),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: _shoppingItems.isEmpty
                ? const Center(child: Text('Shopping list is empty', style: TextStyle(color: Colors.grey)))
                : ListView.builder(
                    itemCount: _shoppingItems.length,
                    itemBuilder: (context, index) => Card(
                      elevation: 0,
                      color: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        title: Text(_shoppingItems[index], style: const TextStyle(fontWeight: FontWeight.bold)),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
                          onPressed: () => setState(() => _shoppingItems.removeAt(index)),
                        ),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _InventoryItemCard extends StatelessWidget {
  final Item item;
  const _InventoryItemCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final days = item.expiry.difference(DateTime.now()).inDays;
    final color = days <= 2 ? Colors.orange : theme.colorScheme.primary;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        children: [
          Container(
            width: 60, height: 60,
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(16)),
            child: Icon(Icons.fastfood_rounded, color: color),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text('${item.quantityDisplay ?? ''} • ${item.category ?? ''}', style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(days <= 0 ? 'Expired' : '$days days', style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 14)),
              const Text('left', style: TextStyle(color: Colors.grey, fontSize: 10)),
            ],
          ),
        ],
      ),
    );
  }
}
