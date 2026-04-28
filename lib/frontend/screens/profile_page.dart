import 'package:flutter/material.dart';
import 'package:freshio/core/theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_page.dart';

//////////////////////////////////////////////////////////////
// 👤 PROFILE PAGE — LIVE FROM SHARED PREFS
//////////////////////////////////////////////////////////////

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String _name     = '';
  String _email    = '';
  String _diet     = '';
  String _storage  = '';
  String _age      = '';
  String _household = '';

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _name      = prefs.getString('user_name')      ?? 'User';
      _email     = prefs.getString('user_email')     ?? 'user@freshio.app';
      _diet      = prefs.getString('user_diet')      ?? '';
      _storage   = prefs.getString('user_storage')   ?? '';
      _age       = prefs.getString('user_age')       ?? '';
      _household = prefs.getString('user_household') ?? '';
    });
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_name');
    await prefs.remove('user_email');

    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      PageRouteBuilder(
        pageBuilder: (_, a, __) => const LoginPage(),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.of(context).size;
    // Derive initials from name
    final initials = _name.isNotEmpty
        ? _name.trim().split(' ').map((w) => w[0].toUpperCase()).take(2).join()
        : 'U';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [

              ////////////////////////////////////////////////
              // HEADER GRADIENT
              ////////////////////////////////////////////////

              Container(
                width: double.infinity,
                padding: EdgeInsets.fromLTRB(
                    0, screen.height * 0.04, 0, 32),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primary,
                      AppColors.primary.withValues(alpha: 0.7),
                    ],
                  ),
                  borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(36)),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // avatar with glow
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.white.withValues(alpha: 0.35),
                            blurRadius: 20,
                            spreadRadius: 4,
                          ),
                        ],
                      ),
                      child: CircleAvatar(
                        radius: screen.width * 0.12,
                        backgroundColor: Colors.white.withValues(alpha: 0.25),
                        child: Text(
                          initials,
                          style: TextStyle(
                            fontSize: screen.width * 0.09,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      _name.isNotEmpty ? _name : 'User',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _email,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),

              ////////////////////////////////////////////////
              // SETTINGS TILES
              ////////////////////////////////////////////////

              Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: screen.width * 0.05, vertical: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // ── PROFILE INFO ────────────────────────────
                    if (_diet.isNotEmpty || _age.isNotEmpty) ...[
                      const Text(
                        'My Profile',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 14),

                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.07),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            if (_age.isNotEmpty)
                              _InfoRow(Icons.cake_outlined,      'Age',          _age,       AppColors.primary),
                            if (_diet.isNotEmpty)
                              _InfoRow(Icons.restaurant_menu_rounded, 'Diet',   _diet,      AppColors.secondary),
                            if (_storage.isNotEmpty)
                              _InfoRow(Icons.kitchen_rounded,    'Storage',      _storage,   AppColors.expiring),
                            if (_household.isNotEmpty)
                              _InfoRow(Icons.group_outlined,     'Household',    '$_household people', AppColors.fresh),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),
                    ],

                    // ── SETTINGS ────────────────────────────────
                    const Text(
                      'Settings',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 14),

                    _SettingsTile(
                      icon: Icons.notifications_outlined,
                      label: 'Notifications',
                      color: AppColors.primary,
                    ),
                    _SettingsTile(
                      icon: Icons.lock_outline_rounded,
                      label: 'Privacy & Security',
                      color: AppColors.secondary,
                    ),
                    _SettingsTile(
                      icon: Icons.help_outline_rounded,
                      label: 'Help & Support',
                      color: AppColors.expiring,
                    ),
                    _SettingsTile(
                      icon: Icons.info_outline_rounded,
                      label: 'About Freshio',
                      color: AppColors.textMuted,
                    ),

                    const SizedBox(height: 28),

                    const Text(
                      'Account',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 14),

                    // LOGOUT
                    GestureDetector(
                      onTap: _logout,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.danger.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: AppColors.danger.withValues(alpha: 0.25),
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment:
                              MainAxisAlignment.center,
                          children: [
                            Icon(Icons.logout_rounded,
                                color: AppColors.danger, size: 20),
                            SizedBox(width: 10),
                            Text(
                              'Sign Out',
                              style: TextStyle(
                                color: AppColors.danger,
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    Center(
                      child: Text(
                        'Freshio v1.0.0 · Made with 🌿',
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

//////////////////////////////////////////////////////////////
// SETTINGS TILE
//////////////////////////////////////////////////////////////

class _SettingsTile extends StatefulWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _SettingsTile({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  State<_SettingsTile> createState() => _SettingsTileState();
}

class _SettingsTileState extends State<_SettingsTile> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 120),
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: widget.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(widget.icon, color: widget.color, size: 18),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  widget.label,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                  ),
                ),
              ),
              const Icon(Icons.chevron_right_rounded,
                  color: AppColors.textMuted),
            ],
          ),
        ),
      ),
    );
  }
}

//////////////////////////////////////////////////////////////
// INFO ROW (profile data display)
//////////////////////////////////////////////////////////////

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String   label;
  final String   value;
  final Color    color;

  const _InfoRow(this.icon, this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 10),
          Text(label,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textMuted,
                fontWeight: FontWeight.w500,
              )),
          const Spacer(),
          Text(value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              )),
        ],
      ),
    );
  }
}