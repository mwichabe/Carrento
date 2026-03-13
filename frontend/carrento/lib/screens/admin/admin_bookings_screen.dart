import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../models/booking_model.dart';
import '../../services/api_service.dart';
import '../../utils/app_theme.dart';

class AdminBookingsScreen extends StatefulWidget {
  const AdminBookingsScreen({super.key});

  @override
  State<AdminBookingsScreen> createState() => _AdminBookingsScreenState();
}

class _AdminBookingsScreenState extends State<AdminBookingsScreen> with SingleTickerProviderStateMixin {
  late TabController _tab;
  List<BookingModel> _bookings = [];
  bool _loading = true;
  final _api = ApiService();
  final _tabs = ['All', 'Pending', 'Confirmed', 'Active', 'Completed', 'Cancelled'];

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: _tabs.length, vsync: this);
    _loadBookings();
  }

  @override
  void dispose() { _tab.dispose(); super.dispose(); }

  Future<void> _loadBookings({String? status}) async {
    setState(() => _loading = true);
    try {
      final params = <String, dynamic>{'limit': '100'};
      if (status != null && status != 'All') params['status'] = status.toLowerCase();
      final res = await _api.get('/admin/bookings', params: params);
      if (res.data['success']) {
        setState(() { _bookings = (res.data['data'] as List).map((e) => BookingModel.fromJson(e)).toList(); _loading = false; });
      }
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  Future<void> _updateStatus(String bookingId, String status) async {
    try {
      await _api.put('/admin/bookings/$bookingId/status', data: {'status': status});
      await _loadBookings();
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Status updated to $status'), backgroundColor: AppColors.success));
    } catch (_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Update failed'), backgroundColor: AppColors.error));
    }
  }

  List<BookingModel> _filtered(String tab) {
    if (tab == 'All') return _bookings;
    return _bookings.where((b) => b.status.toLowerCase() == tab.toLowerCase()).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Bookings'),
        bottom: TabBar(
          controller: _tab,
          isScrollable: true,
          labelColor: AppColors.accent,
          unselectedLabelColor: AppColors.textMuted,
          indicatorColor: AppColors.accent,
          labelStyle: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w700, fontSize: 12),
          unselectedLabelStyle: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w500, fontSize: 12),
          tabs: _tabs.map((t) => Tab(text: t)).toList(),
          onTap: (i) => _loadBookings(status: _tabs[i]),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.accent))
          : TabBarView(
              controller: _tab,
              children: _tabs.map((tab) {
                final list = _filtered(tab);
                if (list.isEmpty) return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const Icon(Icons.receipt_long_rounded, size: 64, color: AppColors.textMuted),
                  const SizedBox(height: 16),
                  Text('No ${tab.toLowerCase()} bookings', style: Theme.of(context).textTheme.titleMedium),
                ]));
                return RefreshIndicator(
                  color: AppColors.accent,
                  backgroundColor: AppColors.card,
                  onRefresh: () async => _loadBookings(status: tab),
                  child: ListView.separated(
                    padding: const EdgeInsets.all(20),
                    itemCount: list.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (_, i) => _AdminBookingCard(booking: list[i], onStatusChange: (s) => _updateStatus(list[i].id, s)),
                  ),
                );
              }).toList(),
            ),
    );
  }
}

class _AdminBookingCard extends StatelessWidget {
  final BookingModel booking;
  final void Function(String) onStatusChange;
  const _AdminBookingCard({required this.booking, required this.onStatusChange});

  Color _statusColor(String status) {
    switch (status) {
      case 'confirmed': return AppColors.info;
      case 'active': return AppColors.success;
      case 'completed': return AppColors.textMuted;
      case 'cancelled': return AppColors.error;
      default: return AppColors.warning;
    }
  }

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('MMM d, yyyy');
    final user = booking.user is Map ? booking.user as Map : null;
    final car = booking.car;
    final statusColor = _statusColor(booking.status);

    return Container(
      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.divider)),
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(car?.name ?? 'Unknown Car', style: Theme.of(context).textTheme.titleMedium, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 2),
            Text(user?['name'] ?? 'Unknown User', style: Theme.of(context).textTheme.bodySmall),
          ])),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: statusColor.withOpacity(0.15), borderRadius: BorderRadius.circular(6)),
            child: Text(booking.statusLabel, style: GoogleFonts.spaceGrotesk(color: statusColor, fontWeight: FontWeight.w700, fontSize: 11)),
          ),
        ]),
        const SizedBox(height: 12),
        const Divider(color: AppColors.divider, height: 1),
        const SizedBox(height: 12),
        Row(children: [
          _infoItem(context, Icons.calendar_today_rounded, '${fmt.format(booking.startDate)} → ${fmt.format(booking.endDate)}'),
        ]),
        const SizedBox(height: 6),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          _infoItem(context, Icons.access_time_rounded, '${booking.totalDays} days'),
          Text('\$${booking.totalPrice.toStringAsFixed(0)}', style: GoogleFonts.spaceGrotesk(color: AppColors.accent, fontWeight: FontWeight.w800, fontSize: 16)),
        ]),
        const SizedBox(height: 12),
        if (!['completed', 'cancelled'].contains(booking.status))
          _StatusActions(booking: booking, onStatusChange: onStatusChange),
      ]),
    );
  }

  Widget _infoItem(BuildContext context, IconData icon, String text) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 14, color: AppColors.textMuted),
      const SizedBox(width: 6),
      Text(text, style: Theme.of(context).textTheme.bodySmall),
    ]);
  }
}

class _StatusActions extends StatelessWidget {
  final BookingModel booking;
  final void Function(String) onStatusChange;
  const _StatusActions({required this.booking, required this.onStatusChange});

  @override
  Widget build(BuildContext context) {
    final available = <String>[];
    switch (booking.status) {
      case 'pending': available.addAll(['confirmed', 'cancelled']); break;
      case 'confirmed': available.addAll(['active', 'cancelled']); break;
      case 'active': available.add('completed'); break;
    }

    final colors = {'confirmed': AppColors.info, 'active': AppColors.success, 'completed': AppColors.textSecondary, 'cancelled': AppColors.error};

    return Wrap(spacing: 8, children: available.map((s) => OutlinedButton(
      onPressed: () => onStatusChange(s),
      style: OutlinedButton.styleFrom(
        foregroundColor: colors[s] ?? AppColors.textPrimary,
        side: BorderSide(color: (colors[s] ?? AppColors.textPrimary).withOpacity(0.5)),
        minimumSize: const Size(0, 34),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        textStyle: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w600, fontSize: 12),
      ),
      child: Text(s[0].toUpperCase() + s.substring(1)),
    )).toList());
  }
}
