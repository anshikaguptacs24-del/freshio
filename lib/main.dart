import 'package:flutter/material.dart';
import 'package:freshio/frontend/screens/home_page.dart';

void main() {
  runApp(const FreshioApp());
}

class FreshioApp extends StatelessWidget {
  const FreshioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Freshio',

      theme: ThemeData(
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: Colors.grey[100],
      ),

      builder: (context, child) {
        return Container(
          color: Colors.grey[300], // outside background
          child: Center(
            child: Container(
              width: 400,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: child,
            ),
          ),
        );
      },

      home: HomePage(),
    );
  }
}