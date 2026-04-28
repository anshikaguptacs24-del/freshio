import 'package:flutter/material.dart';
import 'package:freshio/core/theme/app_theme.dart';
import 'package:freshio/frontend/navigation/main_navigation.dart';
import 'package:shared_preferences/shared_preferences.dart';

//////////////////////////////////////////////////////////////
// 👤 PROFILE SETUP PAGE — First-time onboarding
//////////////////////////////////////////////////////////////

class ProfileSetupPage extends StatefulWidget {
  const ProfileSetupPage({super.key});

  @override
  State<ProfileSetupPage> createState() => _ProfileSetupPageState();
}

class _ProfileSetupPageState extends State<ProfileSetupPage>
    with SingleTickerProviderStateMixin {

  final _formKey       = GlobalKey<FormState>();
  final _nameCtrl      = TextEditingController();
  final _ageCtrl       = TextEditingController();
  final _householdCtrl = TextEditingController();

  String _diet        = 'Vegetarian';
  String _storage     = 'Fridge';
  bool   _isSaving    = false;
  int    _currentStep = 0;  // 0 = personal, 1 = preferences

  late AnimationController _animCtrl;
  late Animation<double>   _fadeAnim;
  late Animation<Offset>   _slideAnim;

  final List<String> _dietOptions    = ['Vegetarian', 'Non-Vegetarian', 'Vegan'];
  final List<String> _storageOptions = ['Fridge', 'No Fridge', 'Both'];

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnim  = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut));
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _ageCtrl.dispose();
    _householdCtrl.dispose();
    _animCtrl.dispose();
    super.dispose();
  }

  //////////////////////////////////////////////////////////////
  // SAVE & NAVIGATE
  //////////////////////////////////////////////////////////////

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name',       _nameCtrl.text.trim());
    await prefs.setString('user_age',        _ageCtrl.text.trim());
    await prefs.setString('user_diet',       _diet);
    await prefs.setString('user_storage',    _storage);
    await prefs.setString('user_household',  _householdCtrl.text.trim());
    await prefs.setBool('is_new_user',       false);

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, a, __) => const MainNavigation(),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  //////////////////////////////////////////////////////////////
  // UI
  //////////////////////////////////////////////////////////////

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.of(context).size;
    final hPad   = screen.width * 0.06;

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

                //////////////////////////////////////////////
                // HEADER
                //////////////////////////////////////////////

                Container(
                  width: double.infinity,
                  padding: EdgeInsets.fromLTRB(hPad, 24, hPad, 28),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.primary,
                        AppColors.primary.withValues(alpha: 0.75),
                      ],
                    ),
                    borderRadius: const BorderRadius.vertical(
                        bottom: Radius.circular(32)),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(Icons.eco_rounded,
                            color: Colors.white, size: 28),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Welcome to Freshio!',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Tell us a bit about yourself to get started 🌿',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),

                //////////////////////////////////////////////
                // STEP INDICATOR
                //////////////////////////////////////////////

                Padding(
                  padding: EdgeInsets.fromLTRB(hPad, 20, hPad, 0),
                  child: Row(
                    children: [
                      _StepDot(active: _currentStep == 0, label: '1'),
                      Expanded(
                        child: Container(
                          height: 2,
                          margin: const EdgeInsets.symmetric(horizontal: 6),
                          color: _currentStep >= 1
                              ? AppColors.primary
                              : AppColors.primary.withValues(alpha: 0.2),
                        ),
                      ),
                      _StepDot(active: _currentStep == 1, label: '2'),
                    ],
                  ),
                ),

                const SizedBox(height: 6),

                Padding(
                  padding: EdgeInsets.symmetric(horizontal: hPad),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Personal Info',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: _currentStep == 0
                              ? AppColors.primary
                              : AppColors.textMuted,
                        ),
                      ),
                      Text(
                        'Preferences',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: _currentStep == 1
                              ? AppColors.primary
                              : AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),

                //////////////////////////////////////////////
                // FORM
                //////////////////////////////////////////////

                Expanded(
                  child: Form(
                    key: _formKey,
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: EdgeInsets.fromLTRB(hPad, 20, hPad, 24),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        transitionBuilder: (child, anim) =>
                            FadeTransition(opacity: anim, child: child),
                        child: _currentStep == 0
                            ? _buildStep1(key: const ValueKey(0))
                            : _buildStep2(key: const ValueKey(1)),
                      ),
                    ),
                  ),
                ),

                //////////////////////////////////////////////
                // BOTTOM BUTTONS
                //////////////////////////////////////////////

                _buildBottomButtons(hPad),
              ],
            ),
          ),
        ),
      ),
    );
  }

  //////////////////////////////////////////////////////////////
  // STEP 1 — Personal Info
  //////////////////////////////////////////////////////////////

  Widget _buildStep1({Key? key}) {
    return Column(
      key: key,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionLabel(label: 'Your Name', icon: Icons.person_outline_rounded),
        const SizedBox(height: 10),
        _InputCard(
          child: TextFormField(
            controller: _nameCtrl,
            decoration: const InputDecoration(
              hintText: 'e.g. Anshika',
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              prefixIcon: Icon(Icons.badge_outlined, color: AppColors.primary),
            ),
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Please enter your name' : null,
            textCapitalization: TextCapitalization.words,
          ),
        ),

        const SizedBox(height: 20),

        _SectionLabel(label: 'Your Age', icon: Icons.cake_outlined),
        const SizedBox(height: 10),
        _InputCard(
          child: TextFormField(
            controller: _ageCtrl,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              hintText: 'e.g. 22',
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              prefixIcon: Icon(Icons.numbers_rounded, color: AppColors.primary),
            ),
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Please enter your age';
              final n = int.tryParse(v.trim());
              if (n == null || n < 1 || n > 120) return 'Enter a valid age';
              return null;
            },
          ),
        ),

        const SizedBox(height: 20),

        _SectionLabel(
            label: 'Household Size (optional)',
            icon: Icons.group_outlined),
        const SizedBox(height: 10),
        _InputCard(
          child: TextFormField(
            controller: _householdCtrl,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              hintText: 'Number of people in household',
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              prefixIcon: Icon(Icons.home_outlined, color: AppColors.primary),
            ),
          ),
        ),
      ],
    );
  }

  //////////////////////////////////////////////////////////////
  // STEP 2 — Preferences
  //////////////////////////////////////////////////////////////

  Widget _buildStep2({Key? key}) {
    return Column(
      key: key,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionLabel(
            label: 'Diet Preference', icon: Icons.restaurant_menu_rounded),
        const SizedBox(height: 10),
        ..._dietOptions.map((option) => _SelectionCard(
              label: option,
              icon: _dietIcon(option),
              selected: _diet == option,
              onTap: () => setState(() => _diet = option),
            )),

        const SizedBox(height: 20),

        _SectionLabel(
            label: 'Storage Type', icon: Icons.kitchen_rounded),
        const SizedBox(height: 10),
        ..._storageOptions.map((option) => _SelectionCard(
              label: option,
              icon: _storageIcon(option),
              selected: _storage == option,
              onTap: () => setState(() => _storage = option),
            )),
      ],
    );
  }

  //////////////////////////////////////////////////////////////
  // BOTTOM NAVIGATION BUTTONS
  //////////////////////////////////////////////////////////////

  Widget _buildBottomButtons(double hPad) {
    return Container(
      padding: EdgeInsets.fromLTRB(hPad, 12, hPad, 20),
      decoration: BoxDecoration(
        color: AppColors.background,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          if (_currentStep == 1) ...[
            Expanded(
              flex: 1,
              child: OutlinedButton(
                onPressed: () => setState(() => _currentStep = 0),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.primary),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text(
                  'Back',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            flex: 2,
            child: _AnimatedButton(
              label: _currentStep == 0 ? 'Continue →' : 'Get Started 🌿',
              isLoading: _isSaving,
              onTap: () {
                if (_currentStep == 0) {
                  // Validate step 1 fields
                  if (_formKey.currentState!.validate()) {
                    setState(() => _currentStep = 1);
                    _animCtrl.reset();
                    _animCtrl.forward();
                  }
                } else {
                  _save();
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  //////////////////////////////////////////////////////////////
  // HELPERS
  //////////////////////////////////////////////////////////////

  IconData _dietIcon(String diet) {
    switch (diet) {
      case 'Vegetarian':     return Icons.eco_rounded;
      case 'Non-Vegetarian': return Icons.set_meal_rounded;
      default:               return Icons.local_florist_rounded;
    }
  }

  IconData _storageIcon(String s) {
    switch (s) {
      case 'Fridge':    return Icons.kitchen_rounded;
      case 'No Fridge': return Icons.countertops_rounded;
      default:          return Icons.all_inbox_rounded;
    }
  }
}

//////////////////////////////////////////////////////////////
// STEP DOT
//////////////////////////////////////////////////////////////

class _StepDot extends StatelessWidget {
  final bool   active;
  final String label;

  const _StepDot({required this.active, required this.label});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: active ? AppColors.primary : AppColors.primary.withValues(alpha: 0.15),
        shape: BoxShape.circle,
        boxShadow: active
            ? [BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.4),
                blurRadius: 10,
              )]
            : [],
      ),
      child: Center(
        child: Text(
          label,
          style: TextStyle(
            color: active ? Colors.white : AppColors.primary,
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}

//////////////////////////////////////////////////////////////
// SECTION LABEL
//////////////////////////////////////////////////////////////

class _SectionLabel extends StatelessWidget {
  final String   label;
  final IconData icon;

  const _SectionLabel({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.primary),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.textDark,
          ),
        ),
      ],
    );
  }
}

//////////////////////////////////////////////////////////////
// INPUT CARD WRAPPER
//////////////////////////////////////////////////////////////

class _InputCard extends StatelessWidget {
  final Widget child;

  const _InputCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

//////////////////////////////////////////////////////////////
// SELECTION CARD (for diet & storage)
//////////////////////////////////////////////////////////////

class _SelectionCard extends StatelessWidget {
  final String   label;
  final IconData icon;
  final bool     selected;
  final VoidCallback onTap;

  const _SelectionCard({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary.withValues(alpha: 0.08)
              : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected
                ? AppColors.primary
                : Colors.transparent,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: selected
                  ? AppColors.primary.withValues(alpha: 0.15)
                  : Colors.black.withValues(alpha: 0.04),
              blurRadius: selected ? 12 : 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: selected
                    ? AppColors.primary.withValues(alpha: 0.15)
                    : AppColors.background,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: selected ? AppColors.primary : AppColors.textMuted,
                size: 18,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: selected ? AppColors.primary : AppColors.textDark,
                ),
              ),
            ),
            if (selected)
              const Icon(Icons.check_circle_rounded,
                  color: AppColors.primary, size: 20),
          ],
        ),
      ),
    );
  }
}

//////////////////////////////////////////////////////////////
// ANIMATED BUTTON
//////////////////////////////////////////////////////////////

class _AnimatedButton extends StatefulWidget {
  final String label;
  final bool isLoading;
  final VoidCallback onTap;

  const _AnimatedButton({
    required this.label,
    required this.isLoading,
    required this.onTap,
  });

  @override
  State<_AnimatedButton> createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<_AnimatedButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 130),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primary, AppColors.secondary],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.4),
                blurRadius: 14,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Center(
            child: widget.isLoading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2.5),
                  )
                : Text(
                    widget.label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
