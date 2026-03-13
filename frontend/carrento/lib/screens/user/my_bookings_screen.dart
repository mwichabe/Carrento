import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../models/booking_model.dart';
import '../../services/car_provider.dart';
import '../../utils/app_theme.dart';

class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen> with SingleTickerProviderStateMixin {
  late TabController _tab;
  final _tabs = ['All', 'Pending', 'Active', 'Completed', 'Cancelled'];

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: _tabs.length, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) => context.read<CarProvider>().fetchMyBookings());
  }

  @override
  void dispose() { _tab.dispose(); super.dispose(); }

  List<BookingModel> _filtered(List<BookingModel> all, String filter) {
    if (filter == 'All') return all;
    return all.where((b) => b.status.toLowerCase() == filter.toLowerCase()).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Bookings'),
        bottom: TabBar(
          controller: _tab,
          isScrollable: true,
          labelColor: AppColors.accent,
          unselectedLabelColor: AppColors.textMuted,
          indicatorColor: AppColors.accent,
          labelStyle: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w700, fontSize: 13),
          unselectedLabelStyle: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w500, fontSize: 13),
          tabs: _tabs.map((t) => Tab(text: t)).toList(),
        ),
      ),
      body: Consumer<CarProvider>(
        builder: (_, p, __) => TabBarView(
          controller: _tab,
          children: _tabs.map((tab) {
            final bookings = _filtered(p.myBookings, tab);
            if (bookings.isEmpty) return _buildEmpty(tab);
            return RefreshIndicator(
              color: AppColors.accent,
              backgroundColor: AppColors.card,
              onRefresh: () async => p.fetchMyBookings(),
              child: ListView.separated(
                padding: const EdgeInsets.all(20),
                itemCount: bookings.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (_, i) => _BookingCard(booking: bookings[i], onCancel: () => _cancelBooking(bookings[i].id)),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildEmpty(String tab) {
    return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(Icons.receipt_long_rounded, size: 64, color: AppColors.textMuted),
      const SizedBox(height: 16),
      Text('No ${tab == 'All' ? '' : tab.toLowerCase()} bookings', style: Theme.of(context).textTheme.titleMedium),
      const SizedBox(height: 8),
      Text('Your bookings will appear here', style: Theme.of(context).textTheme.bodyMedium),
    ]));
  }

  Future<void> _cancelBooking(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Cancel Booking', style: Theme.of(context).textTheme.titleLarge),
        content: Text('Are you sure you want to cancel this booking?', style: Theme.of(context).textTheme.bodyMedium),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text('No', style: GoogleFonts.spaceGrotesk(color: AppColors.textSecondary))),
          TextButton(onPressed: () => Navigator.pop(context, true), child: Text('Cancel Booking', style: GoogleFonts.spaceGrotesk(color: AppColors.error, fontWeight: FontWeight.w700))),
        ],
      ),
    );
    if (confirm == true && mounted) {
      await context.read<CarProvider>().cancelBooking(id);
    }
  }
}

class _BookingCard extends StatelessWidget {
  final BookingModel booking;
  final VoidCallback onCancel;
  const _BookingCard({required this.booking, required this.onCancel});

  Color get _statusColor {
    switch (booking.status) {
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
    final car = booking.car;
    return Container(
      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.divider)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        if (car != null)
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Image.network(car.imageUrl, height: 140, width: double.infinity, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(height: 140, color: AppColors.cardLight)),
          ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Expanded(child: Text(car?.name ?? 'Unknown Car', style: Theme.of(context).textTheme.titleMedium, overflow: TextOverflow.ellipsis)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: _statusColor.withOpacity(0.15), borderRadius: BorderRadius.circular(6)),
                child: Text(booking.statusLabel, style: GoogleFonts.spaceGrotesk(color: _statusColor, fontWeight: FontWeight.w700, fontSize: 12)),
              ),
            ]),
            const SizedBox(height: 12),
            Row(children: [
              const Icon(Icons.calendar_today_rounded, size: 14, color: AppColors.textMuted),
              const SizedBox(width: 6),
              Text('${fmt.format(booking.startDate)} → ${fmt.format(booking.endDate)}', style: Theme.of(context).textTheme.bodySmall),
            ]),
            const SizedBox(height: 6),
            Row(children: [
              const Icon(Icons.access_time_rounded, size: 14, color: AppColors.textMuted),
              const SizedBox(width: 6),
              Text('${booking.totalDays} days', style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(width: 16),
              const Icon(Icons.attach_money_rounded, size: 14, color: AppColors.textMuted),
              Text('\$${booking.totalPrice.toStringAsFixed(0)} total', style: Theme.of(context).textTheme.bodySmall),
            ]),
            if (['pending', 'confirmed'].contains(booking.status)) ...[
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: onCancel,
                  style: OutlinedButton.styleFrom(foregroundColor: AppColors.error, side: const BorderSide(color: AppColors.error), minimumSize: const Size(0, 42)),
                  child: Text('Cancel Booking', style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ]),
        ),
      ]),
    );
  }
}
