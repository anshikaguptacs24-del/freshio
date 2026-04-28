import 'package:flutter/material.dart';

class ShoppingListPage extends StatefulWidget {
  const ShoppingListPage({super.key});

  @override
  State<ShoppingListPage> createState() =>
      _ShoppingListPageState();
}

class _ShoppingListPageState
    extends State<ShoppingListPage> {

  List<String> items = [];

  final controller = TextEditingController();

  void addItem() {
    if (controller.text.isEmpty) return;

    setState(() {
      items.add(controller.text);
      controller.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Shopping List")),

      body: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          children: [

            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    decoration:
                        const InputDecoration(hintText: "Add item"),
                  ),
                ),
                IconButton(
                  onPressed: addItem,
                  icon: const Icon(Icons.add),
                )
              ],
            ),

            const SizedBox(height: 20),

            Expanded(
              child: ListView(
                children: items
                    .map((e) => ListTile(title: Text(e)))
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}