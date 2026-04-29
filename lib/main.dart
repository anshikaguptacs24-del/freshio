import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:freshio/providers/inventory_provider.dart';
import 'package:freshio/providers/recipe_provider.dart';
import 'package:freshio/providers/user_provider.dart';
import 'package:freshio/core/theme/app_theme.dart';
import 'package:freshio/frontend/screens/splash_page.dart';

import 'package:freshio/data/services/storage_service.dart';
import 'package:freshio/core/services/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await StorageService().init();
  await NotificationService.init();
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
          create: (_) => InventoryProvider(),
        ),

        ////////////////////////////////////////////////////////
        // 🧠 SMART RECIPES
        ////////////////////////////////////////////////////////

        ChangeNotifierProvider(
          create: (_) => RecipeProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => UserProvider(),
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