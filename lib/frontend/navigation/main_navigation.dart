import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../screens/home_page.dart';
import '../screens/inventory_page.dart';
import '../screens/recipe_page.dart';
import '../screens/profile_page.dart';

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

    return Scaffold(
      body: NotificationListener<ScrollNotification>(
        onNotification: _onScroll,
        child: IndexedStack(
          index: _index,
          children: List.generate(4, (i) => _loadedPages[i] ? _getPage(i) : const SizedBox.shrink()),
        ),
      ),

      bottomNavigationBar: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: _showNav ? 75 : 0,
        child: _showNav
            ? Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
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
                      label: "Inventory",
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
              )
            : const SizedBox(),
      ),
    );
  }
}