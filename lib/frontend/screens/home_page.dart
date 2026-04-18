import 'package:flutter/material.dart';

// Import reusable widgets
import '../widgets/stat_card.dart';
import '../widgets/recipe_card.dart';

// Home screen UI
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Top app bar
      appBar: AppBar(
        title: const Text("Freshio 🍃"),
        centerTitle: true,
      ),

      // Scrollable body
      body: SingleChildScrollView(
        child: Column(
          children: [

            // 🔥 Tagline
            const Padding(
              padding: EdgeInsets.all(12),
              child: Text(
                "Eat it or Lose it",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ),

            // 📊 Dashboard stats (Grid)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: GridView.count(
                crossAxisCount: 2, // 2 cards per row
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  StatCard(title: "Total Items", value: "24", color: Colors.green),
                  StatCard(title: "Expiring in 7 days", value: "8", color: Colors.orange),
                  StatCard(title: "Expiring in 1 day", value: "3", color: Colors.red),
                  StatCard(title: "Expired", value: "2", color: Colors.grey),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 🍲 Recipe section title
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Suggested Recipes 🍲",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),

            const SizedBox(height: 10),

            // 🍲 Horizontal recipe list
            SizedBox(
              height: 120,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  RecipeCard(name: "Vegetable Soup"),
                  RecipeCard(name: "Fruit Salad"),
                  RecipeCard(name: "Sandwich"),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 📉 Food waste analysis title
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Food Waste Analysis 📉",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),

            // 📊 Placeholder for chart UI
            Container(
              margin: const EdgeInsets.all(12),
              height: 150,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Text("Chart UI here"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}