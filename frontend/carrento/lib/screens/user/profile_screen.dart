import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/auth_provider.dart';
import '../../utils/app_theme.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _licenseCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  bool _editing = false;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().user;
    if (user != null) {
      _nameCtrl.text = user.name;
      _phoneCtrl.text = user.phone;
      _licenseCtrl.text = user.licenseNumber;
      _addressCtrl.text = user.address;
    }
  }

  Future<void> _save() async {
    final ok = await context.read<AuthProvider>().updateProfile({'name': _nameCtrl.text, 'phone': _phoneCtrl.text, 'licenseNumber': _licenseCtrl.text, 'address': _addressCtrl.text});
    if (mounted) {
      setState(() => _editing = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(ok ? 'Profile updated!' : 'Update failed'), backgroundColor: ok ? AppColors.success : AppColors.error));
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    if (user == null) return const Scaffold(body: Center(child: CircularProgressIndicator(color: AppColors.accent)));

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _buildHeader(user.name, user.email, user.isAdmin)),
            SliverToBoxAdapter(child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                if (user.isAdmin) _buildAdminBanner(),
                _buildStatsRow(user.totalBookings),
                const SizedBox(height: 24),
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text('Personal Info', style: Theme.of(context).textTheme.titleLarge),
                  GestureDetector(
                    onTap: () => setState(() => _editing = !_editing),
                    child: Text(_editing ? 'Cancel' : 'Edit', style: GoogleFonts.spaceGrotesk(color: AppColors.accent, fontWeight: FontWeight.w600)),
                  ),
                ]),
                const SizedBox(height: 16),
                AppTextField(controller: _nameCtrl, label: 'Full Name', prefixIcon: Icons.person_outlined, enabled: _editing),
                const SizedBox(height: 12),
                AppTextField(controller: _phoneCtrl, label: 'Phone', keyboardType: TextInputType.phone, prefixIcon: Icons.phone_outlined, enabled: _editing),
                const SizedBox(height: 12),
                AppTextField(controller: _licenseCtrl, label: 'License Number', prefixIcon: Icons.credit_card_rounded, enabled: _editing),
                const SizedBox(height: 12),
                AppTextField(controller: _addressCtrl, label: 'Address', prefixIcon: Icons.home_outlined, enabled: _editing),
                if (_editing) ...[const SizedBox(height: 20), AppButton(label: 'Save Changes', onTap: _save)],
                const SizedBox(height: 24),
                _buildMenuItems(context, user.isAdmin),
                const SizedBox(height: 24),
              ]),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(String name, String email, bool isAdmin) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),
      child: Column(children: [
        Container(
          width: 80, height: 80,
          decoration: BoxDecoration(color: AppColors.accent, borderRadius: BorderRadius.circular(24)),
          child: Center(child: Text(name.isNotEmpty ? name[0].toUpperCase() : 'U', style: GoogleFonts.spaceGrotesk(color: AppColors.primary, fontSize: 32, fontWeight: FontWeight.w800))),
        ),
        const SizedBox(height: 14),
        Text(name, style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 4),
        Text(email, style: Theme.of(context).textTheme.bodyMedium),
      ]),
    );
  }

  Widget _buildAdminBanner() {
    return GestureDetector(
      onTap: () => context.push('/admin'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: AppColors.accent, borderRadius: BorderRadius.circular(14)),
        child: Row(children: [
          const Icon(Icons.admin_panel_settings_rounded, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Admin Dashboard', style: GoogleFonts.spaceGrotesk(color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 15)),
            Text('Manage cars, users and bookings', style: GoogleFonts.inter(color: AppColors.primary.withOpacity(0.7), fontSize: 12)),
          ])),
          const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.primary, size: 16),
        ]),
      ),
    );
  }

  Widget _buildStatsRow(int bookings) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(14)),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
        _stat('$bookings', 'Total Bookings'),
        Container(width: 1, height: 36, color: AppColors.divider),
        _stat('4.8', 'Avg Rating'),
        Container(width: 1, height: 36, color: AppColors.divider),
        _stat('Member', 'Status'),
      ]),
    );
  }

  Widget _stat(String value, String label) => Column(children: [
    Text(value, style: GoogleFonts.spaceGrotesk(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 16)),
    const SizedBox(height: 4),
    Text(label, style: Theme.of(context).textTheme.bodySmall),
  ]);

  Widget _buildMenuItems(BuildContext context, bool isAdmin) {
    final items = [
      if (isAdmin) (Icons.dashboard_rounded, 'Admin Dashboard', () => context.push('/admin'), AppColors.accent),
      (Icons.receipt_long_rounded, 'My Bookings', () => context.go('/bookings'), AppColors.textPrimary),
      (Icons.lock_outlined, 'Change Password', () {}, AppColors.textPrimary),
      (Icons.help_outline_rounded, 'Help & Support', () {}, AppColors.textPrimary),
      (Icons.logout_rounded, 'Sign Out', () async { await context.read<AuthProvider>().logout(); if (context.mounted) context.go('/login'); }, AppColors.error),
    ];

    return Column(
      children: items.map((item) => _MenuItem(icon: item.$1, label: item.$2, onTap: item.$3, color: item.$4)).toList(),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;
  const _MenuItem({required this.icon, required this.label, required this.onTap, required this.color});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 2),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
        child: Row(children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 16),
          Expanded(child: Text(label, style: GoogleFonts.spaceGrotesk(color: color, fontWeight: FontWeight.w500, fontSize: 15))),
          Icon(Icons.arrow_forward_ios_rounded, color: AppColors.textMuted, size: 14),
        ]),
      ),
    );
  }
}
