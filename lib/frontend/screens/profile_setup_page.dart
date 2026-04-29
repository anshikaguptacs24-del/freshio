import 'package:flutter/material.dart';
import 'package:freshio/core/theme/app_theme.dart';
import 'package:freshio/core/constants/app_constants.dart';
import 'package:freshio/frontend/navigation/main_navigation.dart';
import 'package:provider/provider.dart';
import 'package:freshio/providers/user_provider.dart';

class ProfileSetupPage extends StatefulWidget {
  const ProfileSetupPage({super.key});

  @override
  State<ProfileSetupPage> createState() => _ProfileSetupPageState();
}

class _ProfileSetupPageState extends State<ProfileSetupPage> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _ageCtrl = TextEditingController();
  final _householdCtrl = TextEditingController();
  final _otherDietCtrl = TextEditingController();

  String _diet = 'Vegetarian';
  String _storage = 'Fridge';
  bool _isSaving = false;
  int _currentStep = 0;

  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  final List<String> _storageOptions = ['Fridge', 'No Fridge', 'Both'];

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.05), end: Offset.zero).animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut));
    _animCtrl.forward();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _nameCtrl.text = context.read<UserProvider>().userName;
    });
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _ageCtrl.dispose();
    _householdCtrl.dispose();
    _otherDietCtrl.dispose();
    _animCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    final finalDiet = _diet == 'Other' ? _otherDietCtrl.text.trim() : _diet;
    
    await context.read<UserProvider>().completeProfile(
      name: _nameCtrl.text.trim(),
      age: _ageCtrl.text.trim(),
      diet: finalDiet,
      storage: _storage,
      householdSize: _householdCtrl.text.trim(),
    );

    if (!mounted) return;
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MainNavigation()));
  }

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.of(context).size;
    final hPad = screen.width * 0.06;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: SlideTransition(
            position: _slideAnim,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(hPad),
                _buildStepIndicator(hPad),
                Expanded(
                  child: Form(
                    key: _formKey,
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: EdgeInsets.fromLTRB(hPad, 20, hPad, 24),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: _currentStep == 0 ? _buildStep1() : _buildStep2(),
                      ),
                    ),
                  ),
                ),
                _buildBottomButtons(hPad),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(double hPad) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(hPad, 24, hPad, 28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.primary.withValues(alpha: 0.75)],
        ),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
        boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 8))],
      ),
      child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Welcome to Freshio!', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800)),
        SizedBox(height: 6),
        Text('Tell us a bit about yourself to get started 🌿', style: TextStyle(color: Colors.white70, fontSize: 14)),
      ]),
    );
  }

  Widget _buildStepIndicator(double hPad) {
    return Padding(
      padding: EdgeInsets.fromLTRB(hPad, 20, hPad, 10),
      child: Row(children: [
        _StepDot(active: _currentStep == 0, label: '1'),
        Expanded(child: Container(height: 2, margin: const EdgeInsets.symmetric(horizontal: 6), color: _currentStep >= 1 ? AppColors.primary : AppColors.primary.withValues(alpha: 0.2))),
        _StepDot(active: _currentStep == 1, label: '2'),
      ]),
    );
  }

  Widget _buildStep1() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _SectionLabel(label: 'Your Name', icon: Icons.person_outline_rounded),
      const SizedBox(height: 10),
      _InputCard(child: TextFormField(controller: _nameCtrl, decoration: const InputDecoration(hintText: 'e.g. Anshika', border: InputBorder.none, prefixIcon: Icon(Icons.badge_outlined, color: AppColors.primary)))),
      const SizedBox(height: 20),
      _SectionLabel(label: 'Your Age', icon: Icons.cake_outlined),
      const SizedBox(height: 10),
      _InputCard(child: TextFormField(controller: _ageCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(hintText: 'e.g. 22', border: InputBorder.none, prefixIcon: Icon(Icons.numbers_rounded, color: AppColors.primary)))),
      const SizedBox(height: 20),
      _SectionLabel(label: 'Household Size', icon: Icons.group_outlined),
      const SizedBox(height: 10),
      _InputCard(child: TextFormField(controller: _householdCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(hintText: 'e.g. 4', border: InputBorder.none, prefixIcon: Icon(Icons.home_outlined, color: AppColors.primary)))),
    ]);
  }

  Widget _buildStep2() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _SectionLabel(label: 'Diet Preference', icon: Icons.restaurant_menu_rounded),
      const SizedBox(height: 10),
      ...AppConstants.dietOptions.map((option) => _SelectionCard(
            label: option,
            icon: Icons.check_circle_outline,
            selected: _diet == option,
            onTap: () => setState(() => _diet = option),
          )),
      if (_diet == 'Other') ...[
        const SizedBox(height: 12),
        _InputCard(child: TextFormField(controller: _otherDietCtrl, decoration: const InputDecoration(hintText: 'Specify your diet...', border: InputBorder.none, contentPadding: EdgeInsets.symmetric(horizontal: 16)))),
      ],
      const SizedBox(height: 20),
      _SectionLabel(label: 'Storage Type', icon: Icons.kitchen_rounded),
      const SizedBox(height: 10),
      ..._storageOptions.map((option) => _SelectionCard(
            label: option,
            icon: Icons.kitchen_outlined,
            selected: _storage == option,
            onTap: () => setState(() => _storage = option),
          )),
    ]);
  }

  Widget _buildBottomButtons(double hPad) {
    return Padding(
      padding: EdgeInsets.fromLTRB(hPad, 12, hPad, 20),
      child: Row(children: [
        if (_currentStep == 1) ...[
          Expanded(child: OutlinedButton(onPressed: () => setState(() => _currentStep = 0), style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.primary), padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))), child: const Text('Back', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)))),
          const SizedBox(width: 12),
        ],
        Expanded(flex: 2, child: _AnimatedButton(label: _currentStep == 0 ? 'Continue →' : 'Complete Setup 🌿', isLoading: _isSaving, onTap: () => _currentStep == 0 ? setState(() => _currentStep = 1) : _save())),
      ]),
    );
  }
}

class _StepDot extends StatelessWidget {
  final bool active;
  final String label;
  const _StepDot({required this.active, required this.label});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32, height: 32,
      decoration: BoxDecoration(color: active ? AppColors.primary : AppColors.primary.withValues(alpha: 0.15), shape: BoxShape.circle),
      child: Center(child: Text(label, style: TextStyle(color: active ? Colors.white : AppColors.primary, fontWeight: FontWeight.bold))),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  final IconData icon;
  const _SectionLabel({required this.label, required this.icon});
  @override
  Widget build(BuildContext context) {
    return Row(children: [Icon(icon, size: 16, color: AppColors.primary), const SizedBox(width: 6), Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700))]);
  }
}

class _InputCard extends StatelessWidget {
  final Widget child;
  const _InputCard({required this.child});
  @override
  Widget build(BuildContext context) {
    return Container(padding: const EdgeInsets.symmetric(horizontal: 16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))]), child: child);
  }
}

class _SelectionCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  const _SelectionCard({required this.label, required this.icon, required this.selected, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: selected ? AppColors.primary.withValues(alpha: 0.05) : Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: selected ? AppColors.primary : Colors.transparent, width: 2)),
        child: Row(children: [Icon(icon, color: selected ? AppColors.primary : Colors.grey, size: 20), const SizedBox(width: 12), Expanded(child: Text(label, style: TextStyle(fontWeight: FontWeight.bold, color: selected ? AppColors.primary : Colors.black))), if (selected) const Icon(Icons.check_circle, color: AppColors.primary, size: 20)]),
      ),
    );
  }
}

class _AnimatedButton extends StatelessWidget {
  final String label;
  final bool isLoading;
  final VoidCallback onTap;
  const _AnimatedButton({required this.label, required this.isLoading, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 56,
        decoration: BoxDecoration(gradient: const LinearGradient(colors: [AppColors.primary, AppColors.secondary]), borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 4))]),
        child: Center(child: isLoading ? const CircularProgressIndicator(color: Colors.white) : Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16))),
      ),
    );
  }
}
