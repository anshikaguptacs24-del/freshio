import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:freshio/providers/shopping_provider.dart';
import 'package:freshio/providers/inventory_provider.dart';
import 'package:freshio/data/models/item.dart';
import 'package:freshio/data/models/shopping_item.dart';
import 'package:freshio/core/constants/app_constants.dart';

class ShoppingTab extends StatefulWidget {
  const ShoppingTab({super.key});

  @override
  State<ShoppingTab> createState() => _ShoppingTabState();
}

class _ShoppingTabState extends State<ShoppingTab> {
  String? _movingItemId;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _handleBought(ShoppingItem item, ShoppingProvider shoppingProvider) async {
    if (item.isBought) {
      shoppingProvider.toggleBought(item.id);
      return;
    }

    // Mark as bought locally first
    shoppingProvider.toggleBought(item.id);
    HapticFeedback.mediumImpact();

    // Show confirmation dialog
    final move = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("✔ Item Bought!"),
        content: Text("Do you want to move ${item.name} to your pantry inventory?"),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("No, just check"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text("Move to Pantry"),
          ),
        ],
      ),
    );

    if (move == true) {
      setState(() => _movingItemId = item.id);
    }
  }

  void _moveToPantry(ShoppingItem shoppingItem) {
    final inventory = Provider.of<InventoryProvider>(context, listen: false);
    final shopping = Provider.of<ShoppingProvider>(context, listen: false);

    final category = AppConstants.detectCategory(shoppingItem.name);
    final shelfLife = AppConstants.estimateShelfLifeDays(shoppingItem.name);

    final newItem = Item(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: shoppingItem.name,
      quantity: 1,
      unit: "pcs",
      category: category,
      expiry: DateTime.now().add(Duration(days: shelfLife)),
    );

    inventory.addItem(newItem);
    shopping.removeItem(shoppingItem.id);
    
    if (mounted) {
      setState(() => _movingItemId = null);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("🎉 ${shoppingItem.name} added to pantry!"),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: "UNDO",
          onPressed: () {
            inventory.deleteItem(newItem.id);
            shopping.addItem(shoppingItem.name);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final shoppingProvider = Provider.of<ShoppingProvider>(context);
    final items = shoppingProvider.items;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
      child: Column(
        children: [
          Expanded(
            child: items.isEmpty
                ? const Center(
                    child: Text(
                      'Shopping list is empty',
                      style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w600),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(bottom: 120),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return _ShoppingItemCard(
                        item: item,
                        isMoving: _movingItemId == item.id,
                        onBought: () => _handleBought(item, shoppingProvider),
                        onDelete: () => shoppingProvider.removeItem(item.id),
                        onAnimationComplete: () => _moveToPantry(item),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _ShoppingItemCard extends StatefulWidget {
  final ShoppingItem item;
  final bool isMoving;
  final VoidCallback onBought;
  final VoidCallback onDelete;
  final VoidCallback onAnimationComplete;

  const _ShoppingItemCard({
    required this.item,
    required this.isMoving,
    required this.onBought,
    required this.onDelete,
    required this.onAnimationComplete,
  });

  @override
  State<_ShoppingItemCard> createState() => _ShoppingItemCardState();
}

class _ShoppingItemCardState extends State<_ShoppingItemCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;
  late Animation<double> _scale;
  late Animation<Offset> _offset;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _opacity = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.8, curve: Curves.easeIn)),
    );

    _scale = Tween<double>(begin: 1.0, end: 0.4).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInBack),
    );

    _offset = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(2.0, -3.0),
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutCubic),
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onAnimationComplete();
      }
    });
  }

  @override
  void didUpdateWidget(_ShoppingItemCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isMoving && !oldWidget.isMoving) {
      HapticFeedback.heavyImpact();
      SystemSound.play(SystemSoundType.click);
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return SlideTransition(
      position: _offset,
      child: FadeTransition(
        opacity: _opacity,
        child: ScaleTransition(
          scale: _scale,
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                )
              ],
            ),
            child: ListTile(
              leading: Checkbox(
                value: widget.item.isBought,
                onChanged: (_) => widget.onBought(),
                activeColor: theme.colorScheme.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
              ),
              title: Text(
                widget.item.name,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  decoration: widget.item.isBought ? TextDecoration.lineThrough : null,
                  color: widget.item.isBought ? Colors.grey : null,
                ),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
                onPressed: widget.onDelete,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
