import 'package:flutter/material.dart';
import 'package:freshio/data/models/item.dart';

class AddItemPage extends StatefulWidget {
  const AddItemPage({super.key});

  @override
  State<AddItemPage> createState() => _AddItemPageState();
}

class _AddItemPageState extends State<AddItemPage> {

  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final quantityController = TextEditingController();

  DateTime? selectedDate;
  String selectedCategory = "General";

  ////////////////////////////////////////////////////////////
  // 📅 PICK DATE
  ////////////////////////////////////////////////////////////

  Future<void> pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 3)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() => selectedDate = picked);
    }
  }

  ////////////////////////////////////////////////////////////
  // 💾 SAVE
  ////////////////////////////////////////////////////////////

  void save() {
    if (!_formKey.currentState!.validate()) return;

    final item = Item(
      name: nameController.text.trim(),
      category: selectedCategory,
      expiry: selectedDate ?? DateTime.now().add(const Duration(days: 3)),
      quantity: double.tryParse(quantityController.text) ?? 1,
    );

    Navigator.pop(context, item);
  }

  ////////////////////////////////////////////////////////////
  // UI
  ////////////////////////////////////////////////////////////

  @override
  Widget build(BuildContext context) {

    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(title: const Text("Add Item")),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),

          child: Form(
            key: _formKey,

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                //////////////////////////////////////////////////
                // 📝 NAME
                //////////////////////////////////////////////////

                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: "Item Name",
                  ),
                  validator: (v) =>
                      v == null || v.isEmpty ? "Enter item name" : null,
                ),

                const SizedBox(height: 16),

                //////////////////////////////////////////////////
                // 🔢 QUANTITY
                //////////////////////////////////////////////////

                TextFormField(
                  controller: quantityController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: "Quantity",
                  ),
                ),

                const SizedBox(height: 16),

                //////////////////////////////////////////////////
                // 📂 CATEGORY
                //////////////////////////////////////////////////

                DropdownButtonFormField<String>(
                  value: selectedCategory,
                  items: ["General", "Vegetables", "Fruits", "Dairy"]
                      .map((e) => DropdownMenuItem(
                            value: e,
                            child: Text(e),
                          ))
                      .toList(),
                  onChanged: (v) {
                    if (v != null) {
                      setState(() => selectedCategory = v);
                    }
                  },
                  decoration: const InputDecoration(
                    labelText: "Category",
                  ),
                ),

                const SizedBox(height: 16),

                //////////////////////////////////////////////////
                // 📅 DATE PICKER
                //////////////////////////////////////////////////

                GestureDetector(
                  onTap: pickDate,
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          selectedDate == null
                              ? "Select Expiry Date"
                              : "${selectedDate!.toLocal()}"
                                  .split(" ")[0],
                        ),
                        Icon(Icons.calendar_today, color: primary),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                //////////////////////////////////////////////////
                // 💾 SAVE BUTTON
                //////////////////////////////////////////////////

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: save,
                    child: const Text("Save Item"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}