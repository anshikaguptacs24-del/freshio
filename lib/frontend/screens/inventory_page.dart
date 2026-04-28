import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:freshio/core/theme/app_theme.dart';
import 'package:freshio/providers/inventory_provider.dart';
import 'package:freshio/data/models/item.dart';
import 'package:freshio/frontend/screens/add_item_page.dart';
import 'package:freshio/frontend/screens/edit_item_page.dart';

//////////////////////////////////////////////////////////////
// 📦 INVENTORY PAGE — PREMIUM
//////////////////////////////////////////////////////////////

class InventoryPage extends StatelessWidget {
  const InventoryPage({super.key});

  /// Maps item name/category to a local asset image
  String _getImage(Item item) {
    final n = item.name.toLowerCase();
    if (n.contains('apple'))  return 'assets/images/items/apple.png';
    if (n.contains('milk'))   return 'assets/images/items/milk.png';
    if (n.contains('egg'))    return 'assets/images/items/egg.png';
    if (n.contains('tomato')) return 'assets/images/items/tomato.png';
    return 'assets/images/items/default.png';
  }

  Color _statusColor(Item item) {
    if (item.isWaste) return AppColors.waste;
    final days = item.expiry.difference(DateTime.now()).inDays;
    if (days <= 1)   return AppColors.expired;
    if (days <= 3)   return AppColors.expiring;
    return AppColors.fresh;
  }

  String _statusLabel(Item item) {
    if (item.isWaste) return 'Wasted';
    final days = item.expiry.difference(DateTime.now()).inDays;
    if (days < 0)  return 'Expired';
    if (days <= 1) return 'Expiring today!';
    if (days <= 3) return 'Expiring in $days days';
    return 'Fresh ✓';
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<InventoryProvider>(context);
    final screen = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.background,

      ////////////////////////////////////////////////////////////
      // APP BAR
      ////////////////////////////////////////////////////////////

      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: false,
        title: const Text(
          'My Pantry',
          style: TextStyle(
            color: AppColors.textDark,
            fontWeight: FontWeight.w700,
            fontSize: 22,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Text(
              '${provider.items.length} items',
              style: const TextStyle(
                color: AppColors.textMuted,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),

      ////////////////////////////////////////////////////////////
      // FAB
      ////////////////////////////////////////////////////////////

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final newItem = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddItemPage()),
          );
          if (newItem != null && newItem is Item) {
            provider.addItem(newItem);
          }
        },
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add Item',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      ),

      ////////////////////////////////////////////////////////////
      // BODY
      ////////////////////////////////////////////////////////////

      body: provider.items.isEmpty
          ? _buildEmpty(screen)
          : ListView.builder(
              padding: EdgeInsets.fromLTRB(
                screen.width * 0.04,
                8,
                screen.width * 0.04,
                100,
              ),
              physics: const BouncingScrollPhysics(),
              itemCount: provider.items.length,
              itemBuilder: (_, i) {
                final item = provider.items[i];
                return _buildItemCard(context, provider, item, i, screen);
              },
            ),
    );
  }

  //////////////////////////////////////////////////////////////
  // 📭 EMPTY STATE
  //////////////////////////////////////////////////////////////

  Widget _buildEmpty(Size screen) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: screen.width * 0.3,
            height: screen.width * 0.3,
            decoration: BoxDecoration(
              color: AppColors.card,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: const Icon(
              Icons.inventory_2_outlined,
              size: 60,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Your pantry is empty',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Add some items to track freshness!',
            style: TextStyle(color: AppColors.textMuted, fontSize: 14),
          ),
        ],
      ),
    );
  }

  //////////////////////////////////////////////////////////////
  // 🃏 ITEM CARD
  //////////////////////////////////////////////////////////////

  Widget _buildItemCard(BuildContext context, InventoryProvider provider,
      Item item, int i, Size screen) {
    final statusColor = _statusColor(item);

    return Dismissible(
      key: Key('${item.name}$i'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.symmetric(horizontal: 24),
        decoration: BoxDecoration(
          color: AppColors.danger,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.delete_rounded, color: Colors.white, size: 28),
            SizedBox(height: 4),
            Text('Delete', style: TextStyle(color: Colors.white, fontSize: 12)),
          ],
        ),
      ),
      onDismissed: (_) {
        final deleted = item;
        provider.deleteItem(i);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${deleted.name} removed'),
            action: SnackBarAction(
              label: 'UNDO',
              onPressed: () => provider.addItem(deleted),
            ),
          ),
        );
      },
      child: GestureDetector(
        onTap: () async {
          final updated = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => EditItemPage(item: item, index: i),
            ),
          );
          if (updated != null && updated is Item) {
            provider.updateItem(i, updated);
          }
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: statusColor.withValues(alpha: 0.12),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              ////////////////////////////////////////////////////
              // IMAGE
              ////////////////////////////////////////////////////

              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  bottomLeft: Radius.circular(20),
                ),
                child: Container(
                  width: screen.width * 0.2,
                  height: screen.width * 0.2,
                  color: statusColor.withValues(alpha: 0.08),
                  child: Image.asset(
                    _getImage(item),
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => Icon(
                      Icons.food_bank_outlined,
                      size: 36,
                      color: statusColor,
                    ),
                  ),
                ),
              ),

              ////////////////////////////////////////////////////
              // INFO
              ////////////////////////////////////////////////////

              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: AppColors.textDark,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.category,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textMuted,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: statusColor.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              _statusLabel(item),
                              style: TextStyle(
                                fontSize: 11,
                                color: statusColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const Spacer(),
                          Text(
                            'Qty: ${item.quantity.toInt()}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const Padding(
                padding: EdgeInsets.only(right: 14),
                child: Icon(Icons.chevron_right_rounded,
                    color: AppColors.textMuted),
              ),
            ],
          ),
        ),
      ),
    );
  }
}