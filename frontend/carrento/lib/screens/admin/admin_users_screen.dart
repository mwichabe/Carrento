import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../models/car_model.dart';
import '../../services/api_service.dart';
import '../../utils/app_theme.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  List<UserModel> _users = [];
  bool _loading = true;
  final _api = ApiService();
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers({String? search}) async {
    setState(() => _loading = true);
    try {
      final params = <String, dynamic>{'limit': '100'};
      if (search != null && search.isNotEmpty) params['search'] = search;
      final res = await _api.get('/admin/users', params: params);
      if (res.data['success']) {
        setState(() { _users = (res.data['data'] as List).map((e) => UserModel.fromJson(e)).toList(); _loading = false; });
      }
    } catch (_) { setState(() => _loading = false); }
  }

  Future<void> _updateRole(String userId, String role) async {
    try {
      await _api.put('/admin/users/$userId/role', data: {'role': role});
      await _loadUsers();
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Role updated to $role'), backgroundColor: AppColors.success));
    } catch (_) {}
  }

  Future<void> _toggleStatus(String userId) async {
    try {
      await _api.put('/admin/users/$userId/toggle-status');
      await _loadUsers();
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Users')),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
          child: TextField(
            controller: _searchCtrl,
            style: GoogleFonts.inter(color: AppColors.textPrimary),
            onChanged: (v) => _loadUsers(search: v),
            decoration: const InputDecoration(hintText: 'Search by name or email...', prefixIcon: Icon(Icons.search_rounded, color: AppColors.textMuted)),
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('${_users.length} users total', style: Theme.of(context).textTheme.bodySmall),
            Text('${_users.where((u) => u.isAdmin).length} admins', style: GoogleFonts.spaceGrotesk(color: AppColors.accent, fontWeight: FontWeight.w600, fontSize: 12)),
          ]),
        ),
        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator(color: AppColors.accent))
              : RefreshIndicator(
                  color: AppColors.accent,
                  backgroundColor: AppColors.card,
                  onRefresh: () async => _loadUsers(),
                  child: ListView.separated(
                    padding: const EdgeInsets.all(20),
                    itemCount: _users.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (_, i) => _UserCard(user: _users[i], onRoleChange: (r) => _updateRole(_users[i].id, r), onToggle: () => _toggleStatus(_users[i].id)),
                  ),
                ),
        ),
      ]),
    );
  }
}

class _UserCard extends StatelessWidget {
  final UserModel user;
  final void Function(String) onRoleChange;
  final VoidCallback onToggle;
  const _UserCard({required this.user, required this.onRoleChange, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('MMM d, yyyy');
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: user.isAdmin ? AppColors.accent.withOpacity(0.3) : AppColors.divider),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(color: user.isAdmin ? AppColors.accent : AppColors.cardLight, borderRadius: BorderRadius.circular(12)),
            child: Center(child: Text(user.name.isNotEmpty ? user.name[0].toUpperCase() : '?', style: GoogleFonts.spaceGrotesk(color: user.isAdmin ? AppColors.primary : AppColors.textPrimary, fontWeight: FontWeight.w800, fontSize: 18))),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(child: Text(user.name, style: Theme.of(context).textTheme.titleMedium, overflow: TextOverflow.ellipsis)),
              if (user.isAdmin) Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: AppColors.accent.withOpacity(0.15), borderRadius: BorderRadius.circular(5)),
                child: Text('Admin', style: GoogleFonts.spaceGrotesk(color: AppColors.accent, fontWeight: FontWeight.w700, fontSize: 10)),
              ),
            ]),
            Text(user.email, style: Theme.of(context).textTheme.bodySmall, overflow: TextOverflow.ellipsis),
          ])),
        ]),
        const SizedBox(height: 10),
        Row(children: [
          Icon(Icons.receipt_long_rounded, size: 13, color: AppColors.textMuted),
          const SizedBox(width: 4),
          Text('${user.totalBookings} bookings', style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(width: 14),
          Icon(Icons.calendar_today_rounded, size: 13, color: AppColors.textMuted),
          const SizedBox(width: 4),
          Text(user.createdAt.isNotEmpty ? fmt.format(DateTime.tryParse(user.createdAt) ?? DateTime.now()) : '—', style: Theme.of(context).textTheme.bodySmall),
          const Spacer(),
          Container(
            width: 8, height: 8,
            decoration: BoxDecoration(color: user.isActive ? AppColors.success : AppColors.error, shape: BoxShape.circle),
          ),
          const SizedBox(width: 4),
          Text(user.isActive ? 'Active' : 'Inactive', style: GoogleFonts.inter(color: user.isActive ? AppColors.success : AppColors.error, fontSize: 12, fontWeight: FontWeight.w500)),
        ]),
        const SizedBox(height: 10),
        Row(children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => onRoleChange(user.isAdmin ? 'user' : 'admin'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(0, 36),
                foregroundColor: user.isAdmin ? AppColors.warning : AppColors.accent,
                side: BorderSide(color: user.isAdmin ? AppColors.warning : AppColors.accent),
                padding: const EdgeInsets.symmetric(horizontal: 10),
                textStyle: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w600, fontSize: 12),
              ),
              child: Text(user.isAdmin ? 'Remove Admin' : 'Make Admin'),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: OutlinedButton(
              onPressed: onToggle,
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(0, 36),
                foregroundColor: user.isActive ? AppColors.error : AppColors.success,
                side: BorderSide(color: user.isActive ? AppColors.error : AppColors.success),
                padding: const EdgeInsets.symmetric(horizontal: 10),
                textStyle: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w600, fontSize: 12),
              ),
              child: Text(user.isActive ? 'Deactivate' : 'Activate'),
            ),
          ),
        ]),
      ]),
    );
  }
}
