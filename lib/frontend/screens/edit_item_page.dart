import 'package:flutter/material.dart';
import 'package:freshio/data/models/item.dart';

class EditItemPage extends StatefulWidget {
  final Item item;
  final int index;

  const EditItemPage({
    super.key,
    required this.item,
    required this.index,
  });

  @override
  State<EditItemPage> createState() => _EditItemPageState();
}

class _EditItemPageState extends State<EditItemPage> {

  final _formKey = GlobalKey<FormState>();

  late TextEditingController nameController;
  late TextEditingController quantityController;

  DateTime? selectedDate;

  @override
  void initState() {
    super.initState();

    nameController = TextEditingController(text: widget.item.name);
    quantityController =
        TextEditingController(text: widget.item.quantity.toString());

    selectedDate = widget.item.expiry;
  }

  ////////////////////////////////////////////////////////////
  // 📅 DATE PICKER
  ////////////////////////////////////////////////////////////

  Future<void> pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
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

    final updated = Item(
      name: nameController.text.trim(),
      category: widget.item.category,
      expiry: selectedDate ?? widget.item.expiry,
      quantity: double.tryParse(quantityController.text) ?? 1,
      isWaste: widget.item.isWaste,
    );

    Navigator.pop(context, updated);
  }

  ////////////////////////////////////////////////////////////
  // CLEANUP
  ////////////////////////////////////////////////////////////

  @override
  void dispose() {
    nameController.dispose();
    quantityController.dispose();
    super.dispose();
  }

  ////////////////////////////////////////////////////////////
  // UI
  ////////////////////////////////////////////////////////////

  @override
  Widget build(BuildContext context) {

    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(title: const Text("Edit Item")),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),

          child: Form(
            key: _formKey,

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                //////////////////////////////////////////////////
                // NAME
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
                // QUANTITY
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
                // DATE
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
                              : "${selectedDate!.toLocal()}".split(" ")[0],
                        ),
                        Icon(Icons.calendar_today, color: primary),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                //////////////////////////////////////////////////
                // SAVE BUTTON
                //////////////////////////////////////////////////

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: save,
                    child: const Text("Save Changes"),
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