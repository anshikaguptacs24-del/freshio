import 'package:flutter/material.dart';
import 'package:freshio/core/theme/app_theme.dart';
import 'package:freshio/core/constants/app_constants.dart';
import 'package:freshio/frontend/navigation/main_navigation.dart';
import 'package:provider/provider.dart';
import 'package:freshio/providers/user_provider.dart';

class CreateAccountPage extends StatefulWidget {
  const CreateAccountPage({super.key});

  @override
  State<CreateAccountPage> createState() => _CreateAccountPageState();
}

class _CreateAccountPageState extends State<CreateAccountPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _householdCtrl = TextEditingController();
  
  String _diet = 'Vegetarian';
  String _storage = 'Fridge';
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final user = context.read<UserProvider>();
    _nameCtrl.text = user.userName;
    _emailCtrl.text = user.userEmail;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _householdCtrl.dispose();
    super.dispose();
  }

  Future<void> _complete(bool isSkip) async {
    if (!isSkip && !_formKey.currentState!.validate()) return;
    
    setState(() => _isSaving = true);
    
    if (!isSkip) {
      await context.read<UserProvider>().completeProfile(
        name: _nameCtrl.text.trim(),
        age: "25", // Default or omitted in this view
        diet: _diet,
        storage: _storage,
        householdSize: _householdCtrl.text.trim().isEmpty ? "1" : _householdCtrl.text.trim(),
      );
    }

    if (!mounted) return;
    
    // Navigate to main app
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const MainNavigation()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 🌿 HEADER SECTION
            Container(
              width: double.infinity,
              height: size.height * 0.3,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [theme.colorScheme.primary, theme.colorScheme.primary.withOpacity(0.8)],
                ),
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(40)),
                boxShadow: [
                  BoxShadow(color: theme.colorScheme.primary.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10)),
                ],
              ),
              child: SafeArea(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
                      child: const Icon(Icons.eco_rounded, color: Colors.white, size: 48),
                    ),
                    const SizedBox(height: 20),
                    const Text('Welcome to Freshio 🌿', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 8),
                    const Text('Let’s set up your kitchen in seconds', style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    _buildSectionTitle('Basic Information'),
                    const SizedBox(height: 16),
                    _buildTextField(_nameCtrl, 'Full Name', Icons.person_outline_rounded, (v) => v!.isEmpty ? 'Please enter your name' : null),
                    const SizedBox(height: 12),
                    _buildTextField(_emailCtrl, 'Email Address', Icons.email_outlined, (v) => v!.isEmpty ? 'Email is required' : null),
                    
                    const SizedBox(height: 24),
                    _buildSectionTitle('Kitchen Preferences'),
                    const SizedBox(height: 16),
                    _buildDropdown('Dietary Preference', Icons.restaurant_menu_rounded, _diet, AppConstants.dietOptions, (v) => setState(() => _diet = v!)),
                    const SizedBox(height: 12),
                    _buildDropdown('Storage Type', Icons.kitchen_outlined, _storage, ['Fridge', 'No Fridge', 'Both'], (v) => setState(() => _storage = v!)),
                    const SizedBox(height: 12),
                    _buildTextField(_householdCtrl, 'Household Size', Icons.groups_3_outlined, null, isNumber: true, hint: 'Number of people'),

                    const SizedBox(height: 40),
                    
                    // 🚀 PRIMARY BUTTON
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : () => _complete(false),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 4,
                          shadowColor: theme.colorScheme.primary.withOpacity(0.4),
                        ),
                        child: _isSaving 
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('Get Started', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // ⏭ SKIP OPTION
                    Center(
                      child: TextButton(
                        onPressed: _isSaving ? null : () => _complete(true),
                        child: Text('Skip for now', style: TextStyle(color: Colors.grey.shade500, fontWeight: FontWeight.w600)),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Colors.grey, letterSpacing: 1));
  }

  Widget _buildTextField(TextEditingController ctrl, String label, IconData icon, String? Function(String?)? validator, {bool isNumber = false, String? hint}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: TextFormField(
        controller: ctrl,
        validator: validator,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon, size: 20, color: AppColors.primary),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildDropdown(String label, IconData icon, String value, List<String> options, ValueChanged<String?> onChanged) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: DropdownButtonFormField<String>(
        value: value,
        items: options.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, size: 20, color: AppColors.primary),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }
}
