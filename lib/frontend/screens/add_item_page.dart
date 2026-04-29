import 'package:flutter/material.dart';
import 'package:freshio/core/constants/app_constants.dart';
import 'package:freshio/data/models/item.dart';

class AddItemPage extends StatefulWidget {
  const AddItemPage({super.key});

  @override
  State<AddItemPage> createState() => _AddItemPageState();
}

class _AddItemPageState extends State<AddItemPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _qtyCtrl = TextEditingController(text: "1");
  final _otherCategoryCtrl = TextEditingController();

  DateTime? _selectedDate;
  String _selectedCategory = "General";
  String _selectedUnit = "pcs"; // Initial State
  bool _manualCategorySet = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl.addListener(_onNameChanged);
  }

  @override
  void dispose() {
    _nameCtrl.removeListener(_onNameChanged);
    _nameCtrl.dispose();
    _qtyCtrl.dispose();
    _otherCategoryCtrl.dispose();
    super.dispose();
  }

  void _onNameChanged() {
    if (_manualCategorySet) return;
    final text = _nameCtrl.text;
    final detected = AppConstants.detectCategory(text);
    if (detected != _selectedCategory) {
      setState(() => _selectedCategory = detected);
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 3)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) return;

    final categoryStr = _selectedCategory ?? 'General';
    final finalCategory = (categoryStr == 'Other') 
        ? _otherCategoryCtrl.text.trim() 
        : categoryStr;

    print("DEBUG category: $finalCategory");
    print("DEBUG unit: $_selectedUnit");

    final item = Item(
      name: name,
      category: finalCategory.isEmpty ? 'General' : finalCategory,
      expiry: _selectedDate ?? DateTime.now().add(const Duration(days: 3)),
      quantity: double.tryParse(_qtyCtrl.text) ?? 1,
      unit: _selectedUnit ?? 'pcs',
    );
    Navigator.pop(context, item);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text("Add New Item", style: TextStyle(fontWeight: FontWeight.w900)),
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle("Item Information"),
                const SizedBox(height: 16),
                
                _buildTextField(_nameCtrl, "Item Name", Icons.shopping_bag_outlined),
                const SizedBox(height: 16),

                // QUANTITY & UNIT ROW
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 3, child: _buildTextField(_qtyCtrl, "Qty", Icons.numbers_rounded, isNumber: true)),
                    const SizedBox(width: 12),
                    Expanded(flex: 2, child: _buildUnitDropdown()),
                  ],
                ),
                const SizedBox(height: 16),

                _buildSearchableDropdown(),

                if (_selectedCategory == 'Other') ...[
                  const SizedBox(height: 16),
                  _buildTextField(_otherCategoryCtrl, "Specify Category", Icons.edit_note_rounded),
                ],

                const SizedBox(height: 24),
                _buildSectionTitle("Expiry Details"),
                const SizedBox(height: 16),

                _buildDatePicker(primary),

                const SizedBox(height: 48),

                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Text("Add to Pantry", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title ?? '', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Colors.grey, letterSpacing: 1));
  }

  Widget _buildTextField(TextEditingController ctrl, String label, IconData icon, {bool isNumber = false}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: TextFormField(
        controller: ctrl,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        validator: (v) => (v == null || v.trim().isEmpty) ? "Required" : null,
        decoration: InputDecoration(
          labelText: label ?? '',
          prefixIcon: Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildUnitDropdown() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: DropdownButtonFormField<String>(
        value: _selectedUnit ?? 'pcs',
        items: AppConstants.filteredUnits.map((u) => DropdownMenuItem(value: u, child: Text(u ?? '', style: const TextStyle(fontSize: 14)))).toList(),
        onChanged: (v) {
          if (v == null) return;
          setState(() => _selectedUnit = v);
        },
        decoration: InputDecoration(
          labelText: "Unit",
          prefixIcon: Icon(Icons.scale_rounded, size: 20, color: Theme.of(context).colorScheme.primary),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildSearchableDropdown() {
    return GestureDetector(
      onTap: _showSearchableCategoryPicker,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Row(
          children: [
            Icon(AppConstants.getCategoryIcon(_selectedCategory), size: 20, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 12),
            Expanded(child: Text(_selectedCategory ?? 'General', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500))),
            const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  void _showSearchableCategoryPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _CategoryPickerSheet(
        initialCategory: _selectedCategory,
        onSelected: (cat) {
          setState(() {
            _selectedCategory = cat ?? 'General';
            _manualCategorySet = true;
          });
        },
      ),
    );
  }

  Widget _buildDatePicker(Color primary) {
    return InkWell(
      onTap: _pickDate,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade100),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Row(
          children: [
            Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: primary.withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: Icon(Icons.calendar_today_rounded, color: primary, size: 20)),
            const SizedBox(width: 16),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text("Expiry Date", style: TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold)),
              Text(_selectedDate == null ? "Select Date" : "${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}", style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15)),
            ]),
            const Spacer(),
            const Icon(Icons.chevron_right_rounded, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}

class _CategoryPickerSheet extends StatefulWidget {
  final String initialCategory;
  final ValueChanged<String?> onSelected;
  const _CategoryPickerSheet({required this.initialCategory, required this.onSelected});
  @override
  State<_CategoryPickerSheet> createState() => _CategoryPickerSheetState();
}

class _CategoryPickerSheetState extends State<_CategoryPickerSheet> {
  String _search = "";
  late List<String> _filtered;
  @override
  void initState() {
    super.initState();
    _filtered = AppConstants.filteredCategories;
  }
  void _filter(String v) {
    setState(() {
      _search = v;
      final query = (v ?? '').toLowerCase().trim();
      _filtered = AppConstants.filteredCategories.where((c) => (c ?? '').toLowerCase().contains(query)).toList();
    });
  }
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
      child: Column(children: [
        const SizedBox(height: 12),
        Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
        Padding(padding: const EdgeInsets.all(24), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text("Select Category", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
          const SizedBox(height: 16),
          TextField(onChanged: _filter, decoration: InputDecoration(hintText: "Search categories...", prefixIcon: const Icon(Icons.search_rounded), filled: true, fillColor: Colors.grey.shade50, border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none))),
        ])),
        Expanded(child: ListView.builder(padding: const EdgeInsets.symmetric(horizontal: 12), itemCount: _filtered.length, itemBuilder: (context, i) {
          final cat = _filtered[i];
          final isSelected = cat == widget.initialCategory;
          return ListTile(onTap: () { widget.onSelected(cat); Navigator.pop(context); }, leading: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: theme.colorScheme.primary.withOpacity(isSelected ? 0.1 : 0.05), borderRadius: BorderRadius.circular(10)), child: Icon(AppConstants.getCategoryIcon(cat), color: isSelected ? theme.colorScheme.primary : Colors.grey, size: 20)), title: Text(cat ?? 'General', style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, color: isSelected ? theme.colorScheme.primary : null)), trailing: isSelected ? Icon(Icons.check_circle_rounded, color: theme.colorScheme.primary) : null, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)));
        })),
      ]),
    );
  }
}