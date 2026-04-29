import 'package:flutter/material.dart';
import 'package:freshio/core/theme/app_theme.dart';
import 'package:freshio/frontend/screens/create_account_page.dart';
import 'package:freshio/frontend/screens/login_page.dart';
import 'package:freshio/frontend/navigation/main_navigation.dart';

//////////////////////////////////////////////////////////////
// 💫 SPLASH PAGE — checks isNewUser → routes accordingly
//////////////////////////////////////////////////////////////

import 'package:provider/provider.dart';
import 'package:freshio/providers/inventory_provider.dart';
import 'package:freshio/providers/user_provider.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _scale = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    _fade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
    );

    _controller.forward();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // 1. Minimum animation time
    final minTime = Future.delayed(const Duration(milliseconds: 1500));
    
    // 2. Load essential data
    final inventoryLoad = context.read<InventoryProvider>().loadItems();
    
    // Wait for both
    await Future.wait([minTime, inventoryLoad]);
    
    if (mounted) _navigate();
  }

  Future<void> _navigate() async {
    final userProvider = context.read<UserProvider>();
    
    if (!mounted) return;

    Widget nextPage;
    if (!userProvider.isLoggedIn) {
      nextPage = const LoginPage();
    } else if (userProvider.isFirstTimeUser) {
      nextPage = const CreateAccountPage();
    } else {
      nextPage = const MainNavigation();
    }

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, a, __) => nextPage,
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 600),
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
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primary,
              AppColors.primary.withValues(alpha: 0.75),
              AppColors.secondary.withValues(alpha: 0.5),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: FadeTransition(
              opacity: _fade,
              child: ScaleTransition(
                scale: _scale,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // LOGO
                    Container(
                      width: 96,
                      height: 96,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.25),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white38, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.white.withValues(alpha: 0.2),
                            blurRadius: 30,
                            spreadRadius: 6,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.eco_rounded,
                        color: Colors.white,
                        size: 48,
                      ),
                    ),

                    const SizedBox(height: 24),

                    const Text(
                      'Freshio',
                      style: TextStyle(
                        fontSize: 40,
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                      ),
                    ),

                    const SizedBox(height: 8),

                    const Text(
                      'Eat it or Lose it 🌿',
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.white70,
                        letterSpacing: 0.5,
                      ),
                    ),

                    const SizedBox(height: 60),

                    SizedBox(
                      width: 28,
                      height: 28,
                      child: CircularProgressIndicator(
                        color: Colors.white.withValues(alpha: 0.85),
                        strokeWidth: 2.5,
                      ),
                    ),
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