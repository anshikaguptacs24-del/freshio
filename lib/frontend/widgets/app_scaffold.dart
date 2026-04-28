import 'package:flutter/material.dart';

//////////////////////////////////////////////////////////////
// 🎯 CONFIG (EDIT HERE IF NEEDED)
//////////////////////////////////////////////////////////////

class AppScaffoldConfig {
  static const double horizontalPadding = 16;
}

//////////////////////////////////////////////////////////////
// 📄 APP SCAFFOLD
//////////////////////////////////////////////////////////////

class AppScaffold extends StatelessWidget {
  final String title;
  final Widget body;

  // Optional features
  final Widget? floatingActionButton;
  final List<Widget>? actions;
  final bool showBackButton;
  final bool isScrollable;
  final bool isLoading;

  const AppScaffold({
    super.key,
    required this.title,
    required this.body,
    this.floatingActionButton,
    this.actions,
    this.showBackButton = false,
    this.isScrollable = true,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {

    ////////////////////////////////////////////////////////////
    // BODY WRAPPER (SCROLL / NON-SCROLL)
    ////////////////////////////////////////////////////////////

    Widget content = isScrollable
        ? SingleChildScrollView(
            child: body,
          )
        : body;

    ////////////////////////////////////////////////////////////
    // LOADING STATE
    ////////////////////////////////////////////////////////////

    if (isLoading) {
      content = const Center(
        child: CircularProgressIndicator(),
      );
    }

    ////////////////////////////////////////////////////////////
    // UI
    ////////////////////////////////////////////////////////////

    return Scaffold(
      appBar: AppBar(
        title: Text(title),

        automaticallyImplyLeading: showBackButton,

        actions: actions,
      ),

      floatingActionButton: floatingActionButton,

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: AppScaffoldConfig.horizontalPadding),
          child: content,
        ),
      ),
    );
  }
}