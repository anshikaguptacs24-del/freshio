import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'package:freshio/core/theme/app_theme.dart';
import 'package:freshio/providers/inventory_provider.dart';
import 'package:freshio/data/models/item.dart';
import 'package:freshio/frontend/screens/add_item_page.dart';
import 'package:freshio/frontend/screens/edit_item_page.dart';
import 'package:freshio/frontend/widgets/shopping_tab.dart';
import 'package:freshio/providers/shopping_provider.dart';
import 'package:freshio/core/constants/app_constants.dart';

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

      body: SafeArea(
        child: TabBarView(
          controller: _tabController,
          children: [
            _PantryTab(searchQuery: _searchQuery),
            const ShoppingTab(),
          ],
        ),
      ),
      floatingActionButton: AnimatedBuilder(
        animation: _tabController,
        builder: (context, _) {
          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            transitionBuilder: (child, animation) {
              return ScaleTransition(scale: animation, child: child);
            },
            child: FloatingActionButton.extended(
              key: ValueKey(_tabController.index),
              onPressed: () {
                HapticFeedback.lightImpact();
                if (_tabController.index == 0) {
                  // Pantry tab
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AddItemPage()),
                  );
                } else {
                  // Shopping tab
                  _showAddShoppingDialog(context);
                }
              },
              icon: const Icon(Icons.add_rounded, color: Colors.white),
              backgroundColor: theme.colorScheme.primary,
              label: Text(
                _tabController.index == 0 ? "Add Item" : "Add to List",
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          );
        },
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
          decoration: const InputDecoration(
            hintText: "Enter item name",
            border: UnderlineInputBorder(),
          ),
          onSubmitted: (val) {
            if (val.trim().isNotEmpty) {
              Provider.of<ShoppingProvider>(context, listen: false).addItem(val.trim());
              Navigator.pop(context);
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                Provider.of<ShoppingProvider>(context, listen: false).addItem(controller.text.trim());
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
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
    final theme = Theme.of(context);

    final filteredItems = provider.items.where((item) {
      final name = (item.name ?? '').toLowerCase();
      final query = (_localSearch ?? '').toLowerCase();
      return query.isEmpty || name.contains(query);
    }).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(24),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 4))],
            ),
            child: TextField(
              onChanged: (v) => setState(() => _localSearch = v),
              decoration: InputDecoration(
                hintText: 'Search pantry...',
                prefixIcon: Icon(Icons.search_rounded, color: theme.colorScheme.primary),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ),
        Expanded(
          child: filteredItems.isEmpty
              ? _buildEmpty(context)
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 120),
                  itemCount: filteredItems.length,
                  itemBuilder: (context, i) {
                    final item = filteredItems[i];
                    return Dismissible(
                      key: Key(item.id),
                      direction: DismissDirection.endToStart,
                      confirmDismiss: (direction) async {
                        return await showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text("Delete Item?"),
                            content: Text("Are you sure you want to remove ${item.name} from your pantry?"),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text("Cancel"),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                style: TextButton.styleFrom(foregroundColor: Colors.red),
                                child: const Text("Delete"),
                              ),
                            ],
                          ),
                        );
                      },
                      background: Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.only(right: 24),
                        alignment: Alignment.centerRight,
                        decoration: BoxDecoration(
                          color: Colors.redAccent,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(Icons.delete_outline, color: Colors.white, size: 28),
                      ),
                      onDismissed: (_) {
                        provider.deleteItem(item.id);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("${item.name} deleted")),
                        );
                      },
                      child: InkWell(
                        onTap: () async {
                          HapticFeedback.selectionClick();
                          final updated = await Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => EditItemPage(item: item)),
                          );
                          if (updated != null && updated is Item) {
                            provider.updateItem(updated);
                          }
                        },
                        borderRadius: BorderRadius.circular(20),
                        child: _InventoryItemCard(
                          item: item,
                          onFinish: () {
                            provider.markAsFinished(item.id);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("🎉 ${item.name} consumed!"),
                                backgroundColor: Colors.green,
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
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
          Icon(Icons.shopping_basket_outlined, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          const Text('Your pantry is empty 🛒\nStart adding items!', 
            textAlign: TextAlign.center, 
            style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 16)
          ),
        ],
      ),
    );
  }
}


class _InventoryItemCard extends StatelessWidget {
  final Item item;
  final VoidCallback onFinish;
  const _InventoryItemCard({required this.item, required this.onFinish});

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
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          Container(
            width: 56, height: 56,
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(16)),
            child: Icon(Icons.fastfood_rounded, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Text('${item.quantityDisplay ?? ''} • ${item.category ?? ''}', style: TextStyle(color: Colors.grey.shade500, fontSize: 13, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(days <= 0 ? 'Expired' : '$days days', style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 14)),
              const Text('left', style: TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.w500)),
            ],
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.check_circle_outline_rounded, color: Colors.green, size: 28),
            onPressed: onFinish,
            tooltip: "Mark as finished",
          ),
        ],
      ),
    );
  }
}

