import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:freshio/frontend/screens/create_account_page.dart';
import 'package:freshio/frontend/screens/login_page.dart';
import 'package:freshio/frontend/navigation/main_navigation.dart';

import 'package:freshio/providers/inventory_provider.dart';
import 'package:freshio/providers/user_provider.dart';
import 'package:freshio/providers/analytics_provider.dart';

//////////////////////////////////////////////////////////////
// 💫 SPLASH PAGE — Image-based splash + routing logic
//////////////////////////////////////////////////////////////

// Added the missing StatefulWidget class
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _controller.forward();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // ⏱️ 3.5 seconds minimum delay
    final minTime = Future.delayed(const Duration(milliseconds: 3500));

    // Capture providers before the async gap to ensure stability
    final inventoryProvider = context.read<InventoryProvider>();
    final analyticsProvider = context.read<AnalyticsProvider>();

    final inventoryLoad = inventoryProvider.loadItems(analyticsProvider);

    // Wait for both the timer and the data loading to complete
    await Future.wait([minTime, inventoryLoad]);

    if (mounted) {
      _navigate();
    }
  }

  Future<void> _navigate() async {
    final userProvider = context.read<UserProvider>();

    Widget nextPage;
    if (!userProvider.isLoggedIn) {
      nextPage = const LoginPage();
    } else if (userProvider.isFirstTimeUser) {
      nextPage = const CreateAccountPage();
    } else {
      nextPage = const MainNavigation();
    }

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => nextPage,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 800),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 🖼️ Updated Background splash image with error handling
          Positioned.fill(
            child: Image.asset(
              "assets/images/splash.png",
              fit: BoxFit.cover,
              // This part tells you EXACTLY if the path is wrong
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.redAccent, // Red makes it obvious
                  child: Center(
                    child: Text(
                      "Image not found!\nCheck pubspec.yaml",
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                );
              },
            ),
          ),

          // 🌫️ Overlay
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.1),
            ),
          ),
        ],
      ),
    );
  }
    }