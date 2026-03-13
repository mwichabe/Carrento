import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../services/auth_provider.dart';
import '../../services/api_service.dart';
import '../../utils/app_theme.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  Map<String, dynamic>? _stats;
  bool _loading = true;
  final _api = ApiService();

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    try {
      final res = await _api.get('/admin/dashboard');
      if (res.data['success']) setState(() { _stats = res.data['data']; _loading = false; });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthProvider>().user;
    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.accent,
          backgroundColor: AppColors.card,
          onRefresh: _loadStats,
          child: CustomScrollView(slivers: [
            SliverToBoxAdapter(child: _buildHeader(user?.name ?? 'Admin')),
            if (_loading) SliverToBoxAdapter(child: SizedBox(height: 400, child: Center(child: CircularProgressIndicator(color: AppColors.accent))))
            else if (_stats != null) ...[
              SliverToBoxAdapter(child: _buildStatCards()),
              SliverToBoxAdapter(child: _buildQuickActions()),
              SliverToBoxAdapter(child: _buildRecentBookings()),
              SliverToBoxAdapter(child: _buildPopularCars()),
              const SliverToBoxAdapter(child: SizedBox(height: 20)),
            ],
          ]),
        ),
      ),
    );
  }

  Widget _buildHeader(String name) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Admin Panel', style: Theme.of(context).textTheme.bodyMedium),
          Text('Welcome, ${name.split(' ').first}', style: Theme.of(context).textTheme.headlineMedium),
        ]),
        GestureDetector(
          onTap: () => context.go('/profile'),
          child: Container(
            width: 46, height: 46,
            decoration: BoxDecoration(color: AppColors.accent, borderRadius: BorderRadius.circular(14)),
            child: Center(child: Text(name.isNotEmpty ? name[0].toUpperCase() : 'A', style: GoogleFonts.spaceGrotesk(color: AppColors.primary, fontWeight: FontWeight.w800, fontSize: 18))),
          ),
        ),
      ]),
    );
  }

  Widget _buildStatCards() {
    final stats = [
      ('Total Revenue', '\$${NumberFormat.compact().format(_stats!['totalRevenue'] ?? 0)}', Icons.monetization_on_rounded, AppColors.accent),
      ('Total Users', '${_stats!['totalUsers'] ?? 0}', Icons.people_rounded, AppColors.info),
      ('Total Cars', '${_stats!['totalCars'] ?? 0}', Icons.directions_car_rounded, AppColors.success),
      ('Total Bookings', '${_stats!['totalBookings'] ?? 0}', Icons.receipt_long_rounded, AppColors.warning),
      ('Available Cars', '${_stats!['availableCars'] ?? 0}', Icons.check_circle_rounded, AppColors.success),
      ('Pending', '${_stats!['pendingBookings'] ?? 0}', Icons.pending_rounded, AppColors.warning),
    ];
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      child: GridView.count(
        crossAxisCount: 2, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
        childAspectRatio: 1.6, crossAxisSpacing: 12, mainAxisSpacing: 12,
        children: stats.map((s) => Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(16)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Icon(s.$3, color: s.$4, size: 22),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(s.$1, style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: 2),
              Text(s.$2, style: GoogleFonts.spaceGrotesk(color: AppColors.textPrimary, fontWeight: FontWeight.w800, fontSize: 22)),
            ]),
          ]),
        )).toList(),
      ),
    );
  }

  Widget _buildQuickActions() {
    final actions = [
      (Icons.add_rounded, 'Add Car', () => context.go('/admin/cars/new')),
      (Icons.directions_car_rounded, 'Manage Cars', () => context.go('/admin/cars')),
      (Icons.receipt_long_rounded, 'Bookings', () => context.go('/admin/bookings')),
      (Icons.people_rounded, 'Users', () => context.go('/admin/users')),
    ];
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(padding: const EdgeInsets.fromLTRB(24, 24, 24, 12), child: Text('Quick Actions', style: Theme.of(context).textTheme.titleLarge)),
      SizedBox(
        height: 80,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          itemCount: actions.length,
          separatorBuilder: (_, __) => const SizedBox(width: 12),
          itemBuilder: (_, i) {
            final a = actions[i];
            return GestureDetector(
              onTap: a.$3,
              child: Container(
                width: 100, padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(14)),
                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(a.$1, color: AppColors.accent, size: 22),
                  const SizedBox(height: 6),
                  Text(a.$2, textAlign: TextAlign.center, style: GoogleFonts.spaceGrotesk(color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 12)),
                ]),
              ),
            );
          },
        ),
      ),
    ]);
  }

  Widget _buildRecentBookings() {
    final bookings = (_stats?['recentBookings'] as List?) ?? [];
    if (bookings.isEmpty) return const SizedBox();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('Recent Bookings', style: Theme.of(context).textTheme.titleLarge),
          GestureDetector(onTap: () => context.go('/admin/bookings'), child: Text('See All', style: GoogleFonts.spaceGrotesk(color: AppColors.accent, fontWeight: FontWeight.w600, fontSize: 13))),
        ]),
      ),
      ...bookings.take(3).map((b) {
        final user = b['user'];
        final car = b['car'];
        return Container(
          margin: const EdgeInsets.fromLTRB(24, 0, 24, 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(14)),
          child: Row(children: [
            Container(width: 44, height: 44, decoration: BoxDecoration(color: AppColors.cardLight, borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.receipt_long_rounded, color: AppColors.textMuted, size: 20)),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(user is Map ? user['name'] ?? '' : '', style: Theme.of(context).textTheme.titleSmall?.copyWith(color: AppColors.textPrimary)),
              Text(car is Map ? car['name'] ?? '' : '', style: Theme.of(context).textTheme.bodySmall),
            ])),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text('\$${b['totalPrice'] ?? 0}', style: GoogleFonts.spaceGrotesk(color: AppColors.accent, fontWeight: FontWeight.w700, fontSize: 14)),
              const SizedBox(height: 2),
              _StatusBadge(b['status'] ?? 'pending'),
            ]),
          ]),
        );
      }),
    ]);
  }

  Widget _buildPopularCars() {
    final cars = (_stats?['popularCars'] as List?) ?? [];
    if (cars.isEmpty) return const SizedBox();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(padding: const EdgeInsets.fromLTRB(24, 16, 24, 12), child: Text('Popular Cars', style: Theme.of(context).textTheme.titleLarge)),
      ...cars.map((item) {
        final car = item['car'];
        return Container(
          margin: const EdgeInsets.fromLTRB(24, 0, 24, 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(14)),
          child: Row(children: [
            Container(width: 44, height: 44, decoration: BoxDecoration(color: AppColors.cardLight, borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.directions_car_rounded, color: AppColors.textMuted, size: 22)),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(car['name'] ?? '', style: Theme.of(context).textTheme.titleSmall?.copyWith(color: AppColors.textPrimary)),
              Text('\$${car['pricePerDay']}/day', style: Theme.of(context).textTheme.bodySmall),
            ])),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: AppColors.accent.withOpacity(0.15), borderRadius: BorderRadius.circular(6)),
              child: Text('${item['count']} trips', style: GoogleFonts.spaceGrotesk(color: AppColors.accent, fontWeight: FontWeight.w700, fontSize: 12)),
            ),
          ]),
        );
      }),
    ]);
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge(this.status);

  Color get _color {
    switch (status) {
      case 'confirmed': return AppColors.info;
      case 'active': return AppColors.success;
      case 'completed': return AppColors.textMuted;
      case 'cancelled': return AppColors.error;
      default: return AppColors.warning;
    }
  }

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(color: _color.withOpacity(0.15), borderRadius: BorderRadius.circular(4)),
    child: Text(status, style: GoogleFonts.spaceGrotesk(color: _color, fontWeight: FontWeight.w700, fontSize: 10)),
  );
}
