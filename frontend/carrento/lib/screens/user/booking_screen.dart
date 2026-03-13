import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../models/car_model.dart';
import '../../services/car_provider.dart';
import '../../utils/app_theme.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';

class BookingScreen extends StatefulWidget {
  final String carId;
  const BookingScreen({super.key, required this.carId});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  CarModel? _car;
  DateTime? _startDate;
  DateTime? _endDate;
  final _pickupCtrl = TextEditingController();
  final _dropoffCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  bool _loading = false;
  int _step = 0;

  @override
  void initState() {
    super.initState();
    _loadCar();
  }

  Future<void> _loadCar() async {
    final car = await context.read<CarProvider>().fetchCarById(widget.carId);
    if (mounted) setState(() => _car = car);
  }

  int get _totalDays {
    if (_startDate == null || _endDate == null) return 0;
    return _endDate!.difference(_startDate!).inDays;
  }

  double get _totalPrice => _totalDays * (_car?.pricePerDay ?? 0);

  Future<void> _book() async {
    if (_car == null || _startDate == null || _endDate == null) return;
    if (_pickupCtrl.text.isEmpty || _dropoffCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill all required fields'), backgroundColor: AppColors.error));
      return;
    }
    setState(() => _loading = true);
    final booking = await context.read<CarProvider>().createBooking({
      'carId': widget.carId,
      'startDate': _startDate!.toIso8601String(),
      'endDate': _endDate!.toIso8601String(),
      'pickupLocation': _pickupCtrl.text,
      'dropoffLocation': _dropoffCtrl.text,
      'notes': _notesCtrl.text,
    });
    setState(() => _loading = false);
    if (!mounted) return;
    if (booking != null) {
      _showSuccess();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Booking failed. Try again.'), backgroundColor: AppColors.error));
    }
  }

  void _showSuccess() {
    showDialog(
      context: context, barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 70, height: 70, decoration: BoxDecoration(color: AppColors.success.withOpacity(0.15), shape: BoxShape.circle),
            child: const Icon(Icons.check_rounded, color: AppColors.success, size: 36)),
          const SizedBox(height: 20),
          Text('Booking Confirmed!', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text('Your booking is pending confirmation. We\'ll notify you shortly.', textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.5)),
          const SizedBox(height: 24),
          ElevatedButton(onPressed: () { Navigator.pop(context); context.go('/bookings'); }, child: const Text('View My Bookings')),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_car == null) return Scaffold(body: Center(child: CircularProgressIndicator(color: AppColors.accent)));
    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Car'),
        leading: IconButton(icon: const Icon(Icons.arrow_back_rounded), onPressed: () => context.pop()),
      ),
      body: Column(children: [
        _buildStepIndicator(),
        Expanded(child: _step == 0 ? _buildCalendarStep() : _buildDetailsStep()),
      ]),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildStepIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(children: [0, 1].map((i) {
        final active = _step >= i;
        return Expanded(child: Row(children: [
          Container(width: 28, height: 28, decoration: BoxDecoration(color: active ? AppColors.accent : AppColors.card, shape: BoxShape.circle, border: Border.all(color: active ? AppColors.accent : AppColors.divider)),
            child: Center(child: Text('${i + 1}', style: GoogleFonts.spaceGrotesk(color: active ? AppColors.primary : AppColors.textMuted, fontWeight: FontWeight.w700, fontSize: 13)))),
          if (i < 1) Expanded(child: Container(height: 2, color: _step > i ? AppColors.accent : AppColors.divider, margin: const EdgeInsets.symmetric(horizontal: 8))),
        ]));
      }).toList()),
    );
  }

  Widget _buildCalendarStep() {
    final fmt = DateFormat('MMM d');
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _buildCarSummary(),
        const SizedBox(height: 20),
        Text('Select Dates', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 4),
        Text('Choose your pickup and return dates', style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 16),
        TableCalendar(
          firstDay: DateTime.now(),
          lastDay: DateTime.now().add(const Duration(days: 365)),
          focusedDay: _startDate ?? DateTime.now(),
          calendarStyle: CalendarStyle(
            defaultTextStyle: GoogleFonts.inter(color: AppColors.textPrimary),
            weekendTextStyle: GoogleFonts.inter(color: AppColors.textSecondary),
            outsideTextStyle: GoogleFonts.inter(color: AppColors.textMuted),
            selectedDecoration: const BoxDecoration(color: AppColors.accent, shape: BoxShape.circle),
            selectedTextStyle: GoogleFonts.inter(color: AppColors.primary, fontWeight: FontWeight.w700),
            rangeHighlightColor: AppColors.accent.withOpacity(0.15),
            rangeStartDecoration: const BoxDecoration(color: AppColors.accent, shape: BoxShape.circle),
            rangeEndDecoration: const BoxDecoration(color: AppColors.accent, shape: BoxShape.circle),
            todayDecoration: BoxDecoration(color: AppColors.accent.withOpacity(0.3), shape: BoxShape.circle),
            todayTextStyle: GoogleFonts.inter(color: AppColors.accent, fontWeight: FontWeight.w600),
          ),
          headerStyle: HeaderStyle(
            formatButtonVisible: false, titleCentered: true,
            titleTextStyle: GoogleFonts.spaceGrotesk(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 16),
            leftChevronIcon: const Icon(Icons.chevron_left_rounded, color: AppColors.textPrimary),
            rightChevronIcon: const Icon(Icons.chevron_right_rounded, color: AppColors.textPrimary),
          ),
          daysOfWeekStyle: DaysOfWeekStyle(weekdayStyle: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 12), weekendStyle: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 12)),
          rangeStartDay: _startDate,
          rangeEndDay: _endDate,
          rangeSelectionMode: RangeSelectionMode.toggledOn,
          onRangeSelected: (start, end, _) => setState(() { _startDate = start; _endDate = end; }),
        ),
        if (_startDate != null && _endDate != null) ...[
          const SizedBox(height: 20),
          Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(14)),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
              _dateChip('Pickup', fmt.format(_startDate!)),
              Container(width: 1, height: 40, color: AppColors.divider),
              _dateChip('Return', fmt.format(_endDate!)),
              Container(width: 1, height: 40, color: AppColors.divider),
              _dateChip('Days', '$_totalDays'),
            ])),
        ],
        const SizedBox(height: 24),
      ]),
    );
  }

  Widget _buildCarSummary() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(14)),
      child: Row(children: [
        ClipRRect(borderRadius: BorderRadius.circular(10), child: Image.network(_car!.imageUrl, width: 70, height: 50, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(width: 70, height: 50, color: AppColors.cardLight, child: const Icon(Icons.directions_car_rounded, color: AppColors.textMuted)))),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(_car!.name, style: Theme.of(context).textTheme.titleMedium),
          Text('${_car!.type} • ${_car!.transmission}', style: Theme.of(context).textTheme.bodySmall),
        ])),
        Text('\$${_car!.pricePerDay.toStringAsFixed(0)}/day', style: GoogleFonts.spaceGrotesk(color: AppColors.accent, fontWeight: FontWeight.w700)),
      ]),
    );
  }

  Widget _dateChip(String label, String value) {
    return Column(children: [
      Text(value, style: GoogleFonts.spaceGrotesk(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 15)),
      const SizedBox(height: 4),
      Text(label, style: Theme.of(context).textTheme.bodySmall),
    ]);
  }

  Widget _buildDetailsStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Booking Details', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 4),
        Text('Fill in the pickup & dropoff information', style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 24),
        AppTextField(controller: _pickupCtrl, label: 'Pickup Location', hint: 'Enter pickup address', prefixIcon: Icons.location_on_rounded),
        const SizedBox(height: 16),
        AppTextField(controller: _dropoffCtrl, label: 'Dropoff Location', hint: 'Enter dropoff address', prefixIcon: Icons.location_off_rounded),
        const SizedBox(height: 16),
        AppTextField(controller: _notesCtrl, label: 'Special Notes (optional)', hint: 'Any special requests...', maxLines: 3, prefixIcon: Icons.note_outlined),
        const SizedBox(height: 24),
        _buildPriceSummary(),
      ]),
    );
  }

  Widget _buildPriceSummary() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(16)),
      child: Column(children: [
        _priceRow('Daily Rate', '\$${_car!.pricePerDay.toStringAsFixed(0)}/day'),
        const SizedBox(height: 8),
        _priceRow('Duration', '$_totalDays days'),
        const Divider(height: 20),
        _priceRow('Total', '\$${_totalPrice.toStringAsFixed(0)}', isTotal: true),
      ]),
    );
  }

  Widget _priceRow(String label, String value, {bool isTotal = false}) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(label, style: isTotal ? Theme.of(context).textTheme.titleMedium : Theme.of(context).textTheme.bodyMedium),
      Text(value, style: isTotal ? GoogleFonts.spaceGrotesk(color: AppColors.accent, fontWeight: FontWeight.w800, fontSize: 20) : GoogleFonts.spaceGrotesk(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
    ]);
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      decoration: const BoxDecoration(color: AppColors.surface, border: Border(top: BorderSide(color: AppColors.divider))),
      child: _step == 0
          ? AppButton(label: 'Continue', onTap: _startDate != null && _endDate != null && _totalDays >= 1 ? () => setState(() => _step = 1) : null)
          : Row(children: [
              OutlinedButton(onPressed: () => setState(() => _step = 0), style: OutlinedButton.styleFrom(minimumSize: const Size(80, 56)), child: const Text('Back')),
              const SizedBox(width: 12),
              Expanded(child: AppButton(label: 'Confirm Booking', isLoading: _loading, onTap: _book)),
            ]),
    );
  }
}
