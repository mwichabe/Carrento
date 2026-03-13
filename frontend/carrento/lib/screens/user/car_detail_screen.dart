import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../../models/car_model.dart';
import '../../services/car_provider.dart';
import '../../utils/app_theme.dart';
import 'package:provider/provider.dart';

class CarDetailScreen extends StatefulWidget {
  final String carId;
  const CarDetailScreen({super.key, required this.carId});

  @override
  State<CarDetailScreen> createState() => _CarDetailScreenState();
}

class _CarDetailScreenState extends State<CarDetailScreen> {
  CarModel? _car;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final car = await context.read<CarProvider>().fetchCarById(widget.carId);
    if (mounted) setState(() { _car = car; _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return Scaffold(body: Center(child: CircularProgressIndicator(color: AppColors.accent)));
    if (_car == null) return Scaffold(body: Center(child: Text('Car not found', style: Theme.of(context).textTheme.titleMedium)));

    final car = _car!;
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: AppColors.primary,
            leading: GestureDetector(
              onTap: () => context.pop(),
              child: Container(margin: const EdgeInsets.all(8), decoration: BoxDecoration(color: AppColors.card.withOpacity(0.8), borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.arrow_back_rounded)),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: CachedNetworkImage(
                imageUrl: car.imageUrl,
                fit: BoxFit.cover,
                placeholder: (_, __) => Container(color: AppColors.card),
                errorWidget: (_, __, ___) => Container(color: AppColors.card, child: const Icon(Icons.directions_car_rounded, size: 80, color: AppColors.textMuted)),
              ),
            ),
          ),
          SliverToBoxAdapter(child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, crossAxisAlignment: CrossAxisAlignment.start, children: [
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(car.name, style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: 4),
                  Text('${car.brand} • ${car.year}', style: Theme.of(context).textTheme.bodyMedium),
                ])),
                Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  Text('\$${car.pricePerDay.toStringAsFixed(0)}', style: GoogleFonts.spaceGrotesk(color: AppColors.accent, fontSize: 28, fontWeight: FontWeight.w800)),
                  Text('/day', style: Theme.of(context).textTheme.bodySmall),
                ]),
              ]),
              const SizedBox(height: 12),
              Row(children: [
                RatingBarIndicator(rating: car.rating, itemSize: 18, itemBuilder: (_, __) => const Icon(Icons.star_rounded, color: AppColors.accent), unratedColor: AppColors.divider),
                const SizedBox(width: 8),
                Text('${car.rating} (${car.totalRatings} reviews)', style: Theme.of(context).textTheme.bodySmall),
              ]),
              const SizedBox(height: 20),
              _buildSpecGrid(car),
              const SizedBox(height: 24),
              Text('About', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 10),
              Text(car.description, style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.6)),
              const SizedBox(height: 24),
              Text('Features', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              Wrap(spacing: 8, runSpacing: 8, children: car.features.map((f) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.divider)),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.check_circle_rounded, size: 14, color: AppColors.accent),
                  const SizedBox(width: 6),
                  Text(f, style: GoogleFonts.inter(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w500)),
                ]),
              )).toList()),
              const SizedBox(height: 100),
            ]),
          )),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        decoration: BoxDecoration(color: AppColors.surface, border: const Border(top: BorderSide(color: AppColors.divider))),
        child: Row(children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Total per day', style: Theme.of(context).textTheme.bodySmall),
            Text('\$${car.pricePerDay.toStringAsFixed(0)}', style: GoogleFonts.spaceGrotesk(color: AppColors.accent, fontSize: 24, fontWeight: FontWeight.w800)),
          ]),
          const SizedBox(width: 16),
          Expanded(child: ElevatedButton(
            onPressed: car.available ? () => context.push('/book/${car.id}') : null,
            style: ElevatedButton.styleFrom(backgroundColor: car.available ? AppColors.accent : AppColors.textMuted),
            child: Text(car.available ? 'Book Now' : 'Not Available'),
          )),
        ]),
      ),
    );
  }

  Widget _buildSpecGrid(CarModel car) {
    final specs = [
      (Icons.settings_rounded, car.transmission, 'Transmission'),
      (Icons.local_gas_station_rounded, car.fuel, 'Fuel Type'),
      (Icons.event_seat_rounded, '${car.seats} Seats', 'Capacity'),
      (Icons.speed_rounded, car.mileage, 'Mileage'),
    ];
    return GridView.count(
      crossAxisCount: 2, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 2.5, crossAxisSpacing: 12, mainAxisSpacing: 12,
      children: specs.map((s) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(12)),
        child: Row(children: [
          Icon(s.$1, color: AppColors.accent, size: 20),
          const SizedBox(width: 10),
          Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
            Text(s.$2, style: GoogleFonts.spaceGrotesk(color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 13)),
            Text(s.$3, style: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 11)),
          ]),
        ]),
      )).toList(),
    );
  }
}
