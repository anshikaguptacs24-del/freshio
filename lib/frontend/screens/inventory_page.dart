import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'package:freshio/core/theme/app_theme.dart';
import 'package:freshio/providers/inventory_provider.dart';
import 'package:freshio/data/models/item.dart';
import 'package:freshio/frontend/screens/add_item_page.dart';
import 'package:freshio/frontend/screens/edit_item_page.dart';
import 'package:freshio/frontend/widgets/voice_input_sheet.dart';

class InventoryPage extends StatefulWidget {
  const InventoryPage({super.key});

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> with SingleTickerProviderStateMixin {
  late final AnimationController _listController;
  String _searchQuery = '';
  String _selectedCategory = 'All';
  String _selectedExpiry = 'All';
  String _selectedSort = 'Name';

  final List<String> _categories = const ['All', 'Fruits', 'Dairy', 'Veggies', 'Grains'];
  final List<String> _expiryFilters = const ['All', 'Expiring Soon', 'Fresh'];

  @override
  void initState() {
    super.initState();
    _listController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _listController.forward();
  }

  @override
  void dispose() {
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
            height: MediaQuery.of(context).size.height * 0.7,
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
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Filters',
                        style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
                      ),
                      TextButton(
                        onPressed: () {
                          setSheetState(() {
                            _selectedCategory = 'All';
                            _selectedExpiry = 'All';
                            _selectedSort = 'Name';
                          });
                        },
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
                          children: _categories.map((c) => _FilterChip(
                                label: c,
                                isSelected: _selectedCategory == c,
                                onSelected: (val) => setSheetState(() => _selectedCategory = c),
                              )).toList(),
                        ),
                        const SizedBox(height: 32),
                        _buildSheetSection(theme, 'Expiry Status'),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: _expiryFilters.map((e) => _FilterChip(
                                label: e,
                                isSelected: _selectedExpiry == e,
                                onSelected: (val) => setSheetState(() => _selectedExpiry = e),
                              )).toList(),
                        ),
                        const SizedBox(height: 32),
                        _buildSheetSection(theme, 'Sort By'),
                        const SizedBox(height: 12),
                        _SortRadio(
                          label: 'Name (A-Z)',
                          isSelected: _selectedSort == 'Name',
                          onTap: () => setSheetState(() => _selectedSort = 'Name'),
                        ),
                        _SortRadio(
                          label: 'Expiry Date (Soonest First)',
                          isSelected: _selectedSort == 'Expiry Date',
                          onTap: () => setSheetState(() => _selectedSort = 'Expiry Date'),
                        ),
                        const SizedBox(height: 40),
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
                      child: const Text(
                        'Apply Filters',
                        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800),
                      ),
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

  String _getImage(Item item) {
    final n = item.name.toLowerCase();
    if (n.contains('apple')) return 'assets/images/items/apple.png';
    if (n.contains('milk')) return 'assets/images/items/milk.png';
    if (n.contains('egg')) return 'assets/images/items/egg.png';
    if (n.contains('tomato')) return 'assets/images/items/tomato.png';
    return 'assets/images/items/default.png';
  }

  Color _statusColor(Item item) {
    if (item.isWaste) return Colors.red;
    final days = item.expiry.difference(DateTime.now()).inDays;
    if (days <= 1) return Colors.redAccent;
    if (days <= 3) return Colors.orangeAccent;
    return Colors.greenAccent.shade700;
  }

  String _statusLabel(Item item) {
    if (item.isWaste) return 'Wasted';
    final days = item.expiry.difference(DateTime.now()).inDays;
    if (days < 0) return 'Expired';
    if (days <= 1) return 'Expiring Soon';
    if (days <= 3) return '$days days left';
    return 'Fresh';
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<InventoryProvider>(context);
    final screen = MediaQuery.of(context).size;
    final theme = Theme.of(context);

    // Apply filters efficiently
    final filteredItems = provider.items.where((item) {
      final matchesSearch = _searchQuery.isEmpty || item.name.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesCategory = _selectedCategory == 'All' || item.category == _selectedCategory;

      bool matchesExpiry = true;
      if (_selectedExpiry != 'All') {
        final days = item.expiry.difference(DateTime.now()).inDays;
        if (_selectedExpiry == 'Expiring Soon') matchesExpiry = days <= 3 && !item.isWaste;
        if (_selectedExpiry == 'Fresh') matchesExpiry = days > 3 && !item.isWaste;
      }

      return matchesSearch && matchesCategory && matchesExpiry;
    }).toList();

    // Apply Sorting
    if (_selectedSort == 'Name') {
      filteredItems.sort((a, b) => a.name.compareTo(b.name));
    } else if (_selectedSort == 'Expiry Date') {
      filteredItems.sort((a, b) => a.expiry.compareTo(b.expiry));
    }

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        centerTitle: false,
        title: Text(
          'My Pantry',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w900,
            color: theme.colorScheme.onSurface,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: Center(
              child: Text(
                '${filteredItems.length} Items',
                style: TextStyle(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: _FabMicroInteraction(
        onPressed: () async {
          final newItem = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddItemPage()),
          );
          if (newItem != null && newItem is Item) {
            provider.addItem(newItem);
          }
        },
        backgroundColor: theme.colorScheme.primary,
        icon: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
        label: 'Add New Item',
      ),
      body: Column(
        children: [
          RepaintBoundary(child: _buildSearchBar(theme)),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return FadeTransition(
                  opacity: animation,
                  child: child,
                );
              },
              child: filteredItems.isEmpty
                  ? _buildEmpty(context, screen)
                  : ListView.builder(
                      key: ValueKey('list_$_selectedCategory$_selectedExpiry$_selectedSort$_searchQuery'),
                      padding: EdgeInsets.fromLTRB(
                        screen.width * 0.05,
                        16,
                        screen.width * 0.05,
                        120,
                      ),
                      physics: const BouncingScrollPhysics(),
                      itemCount: filteredItems.length,
                      itemBuilder: (_, i) {
                        final item = filteredItems[i];
                        return _InventoryItemCard(
                          item: item,
                          index: i,
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
                          onDelete: () {
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
                          image: _getImage(item),
                          statusColor: _statusColor(item),
                          statusLabel: _statusLabel(item),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
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
            hintText: 'Search your pantry...',
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
            prefixIcon: Icon(Icons.search_rounded, color: theme.colorScheme.primary, size: 22),
            suffixIcon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.mic_none_rounded, color: theme.colorScheme.primary, size: 20),
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    showModalBottomSheet(
                      context: context,
                      backgroundColor: Colors.transparent,
                      builder: (context) => const VoiceInputSheet(),
                    ).then((value) {
                      if (value != null) {
                        setState(() => _searchQuery = value);
                      }
                    });
                  },
                ),
                IconButton(
                  icon: Icon(Icons.tune_rounded, color: theme.colorScheme.primary, size: 20),
                  onPressed: () => _showFilterSheet(theme),
                ),
              ],
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 15),
          ),
        ),
      ),
    );
  }

  Widget _buildEmpty(BuildContext context, Size screen) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.inventory_2_rounded,
              size: 80,
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            _searchQuery.isEmpty ? 'Your pantry is empty' : 'No items found',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isEmpty ? 'Add some items to track freshness!' : 'Try a different search or filter',
            style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w500),
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

class _FabMicroInteraction extends StatefulWidget {
  final VoidCallback onPressed;
  final Color backgroundColor;
  final Widget icon;
  final String label;

  const _FabMicroInteraction({
    required this.onPressed,
    required this.backgroundColor,
    required this.icon,
    required this.label,
  });

  @override
  State<_FabMicroInteraction> createState() => _FabMicroInteractionState();
}

class _FabMicroInteractionState extends State<_FabMicroInteraction> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        HapticFeedback.lightImpact();
        setState(() => _isPressed = false);
        widget.onPressed();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 120),
        child: FloatingActionButton.extended(
          onPressed: null,
          backgroundColor: widget.backgroundColor,
          elevation: _isPressed ? 8 : 4,
          icon: widget.icon,
          label: Text(
            widget.label,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 0.5),
          ),
        ),
      ),
    );
  }
}

class _InventoryItemCard extends StatefulWidget {
  final Item item;
  final int index;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final String image;
  final Color statusColor;
  final String statusLabel;

  const _InventoryItemCard({
    required this.item,
    required this.index,
    required this.onTap,
    required this.onDelete,
    required this.image,
    required this.statusColor,
    required this.statusLabel,
  });

  @override
  State<_InventoryItemCard> createState() => _InventoryItemCardState();
}

class _InventoryItemCardState extends State<_InventoryItemCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return RepaintBoundary(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Dismissible(
          key: Key('${widget.item.name}${widget.index}'),
          background: Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(Icons.check_circle_rounded, color: Colors.white, size: 32),
          ),
          secondaryBackground: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            decoration: BoxDecoration(
              color: Colors.redAccent.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(Icons.delete_sweep_rounded, color: Colors.white, size: 32),
          ),
          confirmDismiss: (direction) async {
            if (direction == DismissDirection.startToEnd) {
              HapticFeedback.mediumImpact();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${widget.item.name} marked as used! ✨')),
              );
              return false;
            }
            final confirmed = await showDialog<bool>(
              context: context,
              builder: (ctx) => AlertDialog(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                title: const Text('Delete Item?', style: TextStyle(fontWeight: FontWeight.bold)),
                content: Text('Are you sure you want to remove ${widget.item.name}?'),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                  TextButton(
                    onPressed: () {
                      HapticFeedback.heavyImpact();
                      Navigator.pop(ctx, true);
                    },
                    child: const Text('Delete', style: TextStyle(color: Colors.red)),
                  ),
                ],
              ),
            );
            return confirmed;
          },
          onDismissed: (_) => widget.onDelete(),
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
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: _isPressed ? 0.1 : 0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  border: Border.all(color: theme.colorScheme.onSurface.withValues(alpha: 0.05)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        color: widget.statusColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.asset(
                          widget.image,
                          fit: BoxFit.contain,
                          cacheWidth: 140,
                          cacheHeight: 140,
                          errorBuilder: (context, error, stackTrace) {
                            return Image.asset(
                              "assets/images/items/default.png",
                              fit: BoxFit.contain,
                              cacheWidth: 140,
                              cacheHeight: 140,
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.item.name,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.2,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Text(
                                'Qty: ${widget.item.quantity.toInt()}',
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const SizedBox(
                                width: 4,
                                height: 4,
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    color: Colors.grey,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                widget.item.category,
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: widget.statusColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              widget.statusLabel,
                              style: TextStyle(
                                color: widget.statusColor,
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right_rounded, color: Colors.grey),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
