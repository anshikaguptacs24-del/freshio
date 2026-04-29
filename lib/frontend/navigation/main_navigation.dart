import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../screens/home_page.dart';
import '../screens/inventory_page.dart';
import '../screens/recipe_page.dart';
import '../screens/profile_page.dart';
import '../screens/add_item_page.dart';
import 'package:provider/provider.dart';
import 'package:freshio/providers/inventory_provider.dart';
import 'package:freshio/providers/shopping_provider.dart';
import 'package:freshio/data/models/item.dart';
import 'package:flutter/services.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _index = 0;
  bool _showNav = true;
  final List<bool> _loadedPages = List.filled(4, false);

  @override
  void initState() {
    super.initState();
    _loadedPages[0] = true; // Home is always loaded
  }

  Widget _getPage(int index) {
    switch (index) {
      case 0: return const HomePage();
      case 1: return const InventoryPage();
      case 2: return RecipePage();
      case 3: return const ProfilePage();
      default: return const HomePage();
    }
  }

  void _onTap(int index) {
    if (index != _index) {
      setState(() {
        _index = index;
        _loadedPages[index] = true;
      });
    }
  }

  bool _onScroll(ScrollNotification n) {
    if (n is UserScrollNotification) {
      if (n.direction == ScrollDirection.reverse) {
        if (_showNav) setState(() => _showNav = false);
      } else if (n.direction == ScrollDirection.forward) {
        if (!_showNav) setState(() => _showNav = true);
      }
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final inventoryProvider = Provider.of<InventoryProvider>(context);

    return Scaffold(
      extendBody: true,
      body: NotificationListener<ScrollNotification>(
        onNotification: _onScroll,
        child: IndexedStack(
          index: _index,
          children: List.generate(4, (i) => _loadedPages[i] ? _getPage(i) : const SizedBox.shrink()),
        ),
      ),

      bottomNavigationBar: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        height: _showNav ? 100 : 0,
        alignment: Alignment.bottomCenter,
        child: _showNav
            ? Container(
                margin: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(32),
                  child: BottomNavigationBar(
                    currentIndex: _index,
                    onTap: _onTap,
                    type: BottomNavigationBarType.fixed,
                    elevation: 0,
                    backgroundColor: Colors.white,
                    selectedItemColor: primary,
                    unselectedItemColor: Colors.grey.shade400,
                    selectedFontSize: 12,
                    unselectedFontSize: 12,
                    showSelectedLabels: true,
                    showUnselectedLabels: false,
                    selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
                    items: const [
                      BottomNavigationBarItem(
                        icon: Icon(Icons.home_filled),
                        activeIcon: Icon(Icons.home_filled),
                        label: "Home",
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.inventory_2_outlined),
                        activeIcon: Icon(Icons.inventory_2_rounded),
                        label: "Pantry",
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.restaurant_menu_outlined),
                        activeIcon: Icon(Icons.restaurant_menu_rounded),
                        label: "Recipes",
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.person_outline_rounded),
                        activeIcon: Icon(Icons.person_rounded),
                        label: "Profile",
                      ),
                    ],
                  ),
                ),
              )
            : const SizedBox(),
      ),
    );
  }
}