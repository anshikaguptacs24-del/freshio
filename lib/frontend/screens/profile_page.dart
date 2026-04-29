import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:freshio/core/theme/app_theme.dart';
import 'package:freshio/core/constants/app_constants.dart';
import 'package:provider/provider.dart';
import 'package:freshio/providers/user_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'login_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> with SingleTickerProviderStateMixin {
  late AnimationController _avatarController;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _avatarController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _avatarController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      if (!mounted) return;
      context.read<UserProvider>().updateProfilePhoto(image.path);
    }
  }

  Future<void> _logout() async {
    await context.read<UserProvider>().logout();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  void _showEditProfileDialog(BuildContext context, UserProvider user) {
    final nameCtrl = TextEditingController(text: user.userName);
    final ageCtrl = TextEditingController(text: user.userAge);
    String diet = AppConstants.dietOptions.contains(user.userDiet) ? user.userDiet : 'Other';
    final otherDietCtrl = TextEditingController(text: diet == 'Other' ? user.userDiet : '');
    String storage = user.userStorage;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          title: const Text('Edit Profile', style: TextStyle(fontWeight: FontWeight.w900)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTextField(nameCtrl, 'Full Name', Icons.person_outline),
                _buildTextField(ageCtrl, 'Age', Icons.calendar_today_outlined, isNumber: true),
                _buildDietDropdown(
                  currentDiet: diet,
                  onChanged: (v) => setDialogState(() => diet = v!),
                  otherController: otherDietCtrl,
                ),
                const SizedBox(height: 16),
                _buildTextField(TextEditingController(text: storage), 'Storage Preference', Icons.kitchen_outlined, 
                  onChanged: (v) => storage = v),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                final finalDiet = diet == 'Other' ? otherDietCtrl.text : diet;
                user.completeProfile(
                  name: nameCtrl.text,
                  age: ageCtrl.text,
                  diet: finalDiet,
                  storage: storage,
                  householdSize: (user.familyMembers.length + 1).toString(),
                );
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Save Changes', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddMemberDialog(BuildContext context, {FamilyMember? existingMember}) {
    final nameCtrl = TextEditingController(text: existingMember?.name);
    final ageCtrl = TextEditingController(text: existingMember?.age);
    String diet = existingMember != null 
        ? (AppConstants.dietOptions.contains(existingMember.diet) ? existingMember.diet : 'Other')
        : 'Vegetarian';
    final otherDietCtrl = TextEditingController(text: (existingMember != null && diet == 'Other') ? existingMember.diet : '');
    final allergiesCtrl = TextEditingController(text: existingMember?.allergies.join(', '));
    final medicalCtrl = TextEditingController(text: existingMember?.medical);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          title: Text(existingMember == null ? 'Add Family Member' : 'Edit Member', style: const TextStyle(fontWeight: FontWeight.w900)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTextField(nameCtrl, 'Name', Icons.person_outline),
                _buildTextField(ageCtrl, 'Age', Icons.calendar_today_outlined, isNumber: true),
                _buildDietDropdown(
                  currentDiet: diet,
                  onChanged: (v) => setDialogState(() => diet = v!),
                  otherController: otherDietCtrl,
                ),
                _buildTextField(allergiesCtrl, 'Allergies (comma separated)', Icons.warning_amber_rounded),
                _buildTextField(medicalCtrl, 'Medical (optional)', Icons.medical_services_outlined),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                if (nameCtrl.text.isEmpty) return;
                final finalDiet = diet == 'Other' ? otherDietCtrl.text : diet;
                final member = FamilyMember(
                  id: existingMember?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                  name: nameCtrl.text,
                  age: ageCtrl.text,
                  diet: finalDiet,
                  allergies: allergiesCtrl.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
                  medical: medicalCtrl.text.isEmpty ? null : medicalCtrl.text,
                );
                if (existingMember == null) {
                  context.read<UserProvider>().addFamilyMember(member);
                } else {
                  context.read<UserProvider>().updateFamilyMember(member);
                }
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(existingMember == null ? 'Add' : 'Save', style: const TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildTextField(TextEditingController ctrl, String label, IconData icon, {bool isNumber = false, Function(String)? onChanged}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: ctrl,
        onChanged: onChanged,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, size: 20),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  static Widget _buildDietDropdown({required String currentDiet, required ValueChanged<String?> onChanged, required TextEditingController otherController}) {
    return Column(
      children: [
        DropdownButtonFormField<String>(
          value: currentDiet,
          items: AppConstants.dietOptions.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: onChanged,
          decoration: InputDecoration(
            labelText: 'Dietary Preference',
            prefixIcon: const Icon(Icons.restaurant_menu_rounded, size: 20),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
          ),
        ),
        if (currentDiet == 'Other') ...[
          const SizedBox(height: 12),
          TextField(
            controller: otherController,
            decoration: InputDecoration(
              labelText: 'Specify Diet',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // 👤 PROFILE HEADER
          SliverAppBar(
            expandedHeight: 260,
            pinned: true,
            backgroundColor: theme.colorScheme.primary,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [theme.colorScheme.primary, theme.colorScheme.primary.withOpacity(0.8)],
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 10),
                      _buildAvatar(userProvider, theme),
                      const SizedBox(height: 16),
                      Text(userProvider.userName, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900)),
                      Text(userProvider.userEmail, style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 14)),
                      const SizedBox(height: 12),
                      _EditButton(onTap: () => _showEditProfileDialog(context, userProvider)),
                    ],
                  ),
                ),
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.all(24),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // 👨‍👩‍👧‍👦 FAMILY MEMBERS
                _SectionTitle(title: 'Family Members', onAdd: () => _showAddMemberDialog(context)),
                const SizedBox(height: 16),
                if (userProvider.familyMembers.isEmpty)
                  _EmptyState(message: 'No members added yet', icon: Icons.group_add_outlined)
                else
                  ...userProvider.familyMembers.map((m) => _MemberCard(
                    member: m,
                    onEdit: () => _showAddMemberDialog(context, existingMember: m),
                    onDelete: () => userProvider.deleteFamilyMember(m.id),
                  )),

                const SizedBox(height: 32),
                
                // ⚙️ PREFERENCES
                const Text('Preferences', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: Colors.grey, letterSpacing: 1)),
                const SizedBox(height: 16),
                _InfoTile(label: 'My Diet', value: userProvider.userDiet, icon: Icons.restaurant_menu_rounded, color: AppConstants.getDietColor(userProvider.userDiet)),
                _InfoTile(label: 'Storage', value: userProvider.userStorage, icon: Icons.kitchen_rounded, color: Colors.orange),
                _InfoTile(label: 'Household Size', value: '${userProvider.familyMembers.length + 1} People', icon: Icons.house_rounded, color: Colors.blue),

                const SizedBox(height: 48),

                // 🚪 ACCOUNT
                _LogoutButton(onTap: _logout),
                const SizedBox(height: 80),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(UserProvider user, ThemeData theme) {
    return GestureDetector(
      onTap: _pickImage,
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          CircleAvatar(
            radius: 54,
            backgroundColor: Colors.white.withOpacity(0.2),
            child: CircleAvatar(
              radius: 50,
              backgroundColor: theme.colorScheme.secondary,
              backgroundImage: user.userPhoto != null ? FileImage(File(user.userPhoto!)) : null,
              child: user.userPhoto == null 
                  ? Text((user.userName != null && user.userName.isNotEmpty) ? user.userName[0].toUpperCase() : 'U', 
                      style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Colors.white))
                  : null,
            ),
          ),
          Container(
            padding: const EdgeInsets.all(6),
            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
            child: Icon(Icons.edit_rounded, size: 16, color: theme.colorScheme.primary),
          ),
        ],
      ),
    );
  }
}

class _EditButton extends StatelessWidget {
  final VoidCallback onTap;
  const _EditButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white24)),
        child: const Text('Edit Profile', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final VoidCallback onAdd;
  const _SectionTitle({required this.title, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: Colors.grey, letterSpacing: 1)),
        IconButton(icon: const Icon(Icons.add_circle_outline_rounded, color: Colors.grey, size: 20), onPressed: onAdd),
      ],
    );
  }
}

class _MemberCard extends StatelessWidget {
  final FamilyMember member;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _MemberCard({required this.member, required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
        border: Border.all(color: theme.colorScheme.onSurface.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
            child: Text(member.name[0].toUpperCase(), style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(member.name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text('${member.age} yrs', style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.w600)),
                    const SizedBox(width: 8),
                    _DietChip(diet: member.diet),
                  ],
                ),
                if (member.allergies != null && member.allergies.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text('Allergies: ${member.allergies.join(", ")}', style: const TextStyle(color: Colors.redAccent, fontSize: 11, fontWeight: FontWeight.w600)),
                ],
              ],
            ),
          ),
          IconButton(icon: const Icon(Icons.edit_outlined, size: 20), onPressed: onEdit),
          IconButton(icon: const Icon(Icons.delete_outline_rounded, size: 20, color: Colors.redAccent), onPressed: () {
            showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text('Delete Member?'),
                content: Text('Are you sure you want to remove ${member.name}?'),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                  TextButton(onPressed: () { onDelete(); Navigator.pop(ctx); }, child: const Text('Delete', style: TextStyle(color: Colors.red))),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _DietChip extends StatelessWidget {
  final String diet;
  const _DietChip({required this.diet});

  @override
  Widget build(BuildContext context) {
    final color = AppConstants.getDietColor(diet);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
      child: Text(diet, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w900)),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _InfoTile({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.grey.shade100)),
      child: Row(
        children: [
          Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: color, size: 20)),
          const SizedBox(width: 16),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, style: const TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold)),
            Text(value, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
          ]),
        ],
      ),
    );
  }
}

class _LogoutButton extends StatelessWidget {
  final VoidCallback onTap;
  const _LogoutButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(color: Colors.red.withOpacity(0.05), borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.red.withOpacity(0.1))),
        child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.logout_rounded, color: Colors.redAccent, size: 20),
          SizedBox(width: 10),
          Text('Logout Account', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w900, fontSize: 16)),
        ]),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String message;
  final IconData icon;
  const _EmptyState({required this.message, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(color: Colors.grey.withOpacity(0.05), borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.grey.withOpacity(0.1), style: BorderStyle.none)),
      child: Column(children: [
        Icon(icon, size: 48, color: Colors.grey.shade300),
        const SizedBox(height: 12),
        Text(message, style: TextStyle(color: Colors.grey.shade400, fontWeight: FontWeight.bold)),
      ]),
    );
  }
}