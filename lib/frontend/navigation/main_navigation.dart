import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../screens/home_page.dart';
import '../screens/inventory_page.dart';
import '../screens/recipe_page.dart';
import '../screens/notification_page.dart';
import '../screens/profile_page.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _index = 0;
  bool _showNav = true;

  final pages = [
    const HomePage(),
    const InventoryPage(),
    RecipePage(),
    const NotificationPage(),
    const ProfilePage(),
  ];

  ////////////////////////////////////////////////////////////
  // 🔄 HIDE NAV ON SCROLL
  ////////////////////////////////////////////////////////////

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

  ////////////////////////////////////////////////////////////
  // UI
  ////////////////////////////////////////////////////////////

  @override
  Widget build(BuildContext context) {

    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      body: NotificationListener<ScrollNotification>(
        onNotification: _onScroll,
        child: IndexedStack(
          index: _index,
          children: pages,
        ),
      ),

      ////////////////////////////////////////////////////////////
      // 🧭 BOTTOM NAV
      ////////////////////////////////////////////////////////////

      bottomNavigationBar: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: _showNav ? 70 : 0,

        child: _showNav
            ? BottomNavigationBar(
                currentIndex: _index,
                onTap: (i) => setState(() => _index = i),
                type: BottomNavigationBarType.fixed,

                //////////////////////////////////////////////////
                // 🎨 THEME COLORS
                //////////////////////////////////////////////////

                selectedItemColor: primary,
                unselectedItemColor: Colors.grey,

                //////////////////////////////////////////////////
                // 📱 ITEMS
                //////////////////////////////////////////////////

                items: const [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.home),
                    label: "Home",
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.inventory),
                    label: "Inventory",
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.restaurant),
                    label: "Recipes",
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.notifications),
                    label: "Alerts",
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.person),
                    label: "Profile",
                  ),
                ],
              )
            : const SizedBox(),
      ),
    );
  }
}