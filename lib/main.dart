import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:freshio/providers/inventory_provider.dart';
import 'package:freshio/providers/recipe_provider.dart';
import 'package:freshio/core/theme/app_theme.dart';
import 'package:freshio/frontend/screens/splash_page.dart';

void main() {
  runApp(const FreshioApp());
}

class FreshioApp extends StatelessWidget {
  const FreshioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [

        ////////////////////////////////////////////////////////
        // 📦 INVENTORY
        ////////////////////////////////////////////////////////

        ChangeNotifierProvider(
          create: (_) => InventoryProvider()..loadItems(),
        ),

        ////////////////////////////////////////////////////////
        // 🧠 SMART RECIPES
        ////////////////////////////////////////////////////////

        ChangeNotifierProvider(
          create: (_) => RecipeProvider(),
        ),
      ],

      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.theme,
        home: const SplashPage(),
      ),
    );
  }
}