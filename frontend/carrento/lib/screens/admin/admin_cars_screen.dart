import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/car_model.dart';
import '../../services/car_provider.dart';
import '../../utils/app_theme.dart';

class AdminCarsScreen extends StatefulWidget {
  const AdminCarsScreen({super.key});

  @override
  State<AdminCarsScreen> createState() => _AdminCarsScreenState();
}

class _AdminCarsScreenState extends State<AdminCarsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => context.read<CarProvider>().fetchCars(filters: {'limit': '50'}));
  }

  Future<void> _deleteCar(CarModel car) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Delete Car', style: Theme.of(context).textTheme.titleLarge),
        content: Text('Delete "${car.name}"? This action cannot be undone.', style: Theme.of(context).textTheme.bodyMedium),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text('Cancel', style: GoogleFonts.spaceGrotesk(color: AppColors.textSecondary))),
          TextButton(onPressed: () => Navigator.pop(context, true), child: Text('Delete', style: GoogleFonts.spaceGrotesk(color: AppColors.error, fontWeight: FontWeight.w700))),
        ],
      ),
    );
    if (confirm == true && mounted) {
      final ok = await context.read<CarProvider>().adminDeleteCar(car.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(ok ? '${car.name} deleted.' : 'Delete failed.'),
          backgroundColor: ok ? AppColors.success : AppColors.error,
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Cars'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: ElevatedButton.icon(
              onPressed: () => context.push('/admin/cars/new'),
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Add Car'),
              style: ElevatedButton.styleFrom(minimumSize: const Size(0, 38), padding: const EdgeInsets.symmetric(horizontal: 14)),
            ),
          ),
        ],
      ),
      body: Consumer<CarProvider>(
        builder: (_, p, __) {
          if (p.isLoading) return const Center(child: CircularProgressIndicator(color: AppColors.accent));
          if (p.cars.isEmpty) return Center(
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Icon(Icons.directions_car_rounded, size: 64, color: AppColors.textMuted),
              const SizedBox(height: 16),
              Text('No cars yet', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              ElevatedButton(onPressed: () => context.push('/admin/cars/new'), child: const Text('Add First Car')),
            ]),
          );
          return RefreshIndicator(
            color: AppColors.accent,
            backgroundColor: AppColors.card,
            onRefresh: () async => p.fetchCars(filters: {'limit': '50'}),
            child: ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: p.cars.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, i) => _AdminCarTile(
                car: p.cars[i],
                onEdit: () => context.push('/admin/cars/edit/${p.cars[i].id}'),
                onDelete: () => _deleteCar(p.cars[i]),
                onToggle: () async {
                  await p.adminUpdateCar(p.cars[i].id, {'available': !p.cars[i].available});
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

class _AdminCarTile extends StatelessWidget {
  final CarModel car;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onToggle;

  const _AdminCarTile({required this.car, required this.onEdit, required this.onDelete, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.divider)),
      child: Column(children: [
        ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          child: Stack(children: [
            CachedNetworkImage(imageUrl: car.imageUrl, height: 140, width: double.infinity, fit: BoxFit.cover,
              placeholder: (_, __) => Container(height: 140, color: AppColors.cardLight),
              errorWidget: (_, __, ___) => Container(height: 140, color: AppColors.cardLight, child: const Icon(Icons.directions_car_rounded, size: 40, color: AppColors.textMuted))),
            Positioned(top: 10, right: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(color: car.available ? AppColors.success.withOpacity(0.9) : AppColors.error.withOpacity(0.9), borderRadius: BorderRadius.circular(8)),
                child: Text(car.available ? 'Available' : 'Unavailable', style: GoogleFonts.spaceGrotesk(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 11)),
              ),
            ),
          ]),
        ),
        Padding(
          padding: const EdgeInsets.all(14),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Expanded(child: Text(car.name, style: Theme.of(context).textTheme.titleMedium, overflow: TextOverflow.ellipsis)),
              Text('\$${car.pricePerDay.toStringAsFixed(0)}/day', style: GoogleFonts.spaceGrotesk(color: AppColors.accent, fontWeight: FontWeight.w700, fontSize: 15)),
            ]),
            const SizedBox(height: 4),
            Text('${car.type} • ${car.transmission} • ${car.fuel}', style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_rounded, size: 15),
                  label: const Text('Edit'),
                  style: OutlinedButton.styleFrom(minimumSize: const Size(0, 38), padding: const EdgeInsets.symmetric(horizontal: 12)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onToggle,
                  icon: Icon(car.available ? Icons.block_rounded : Icons.check_circle_rounded, size: 15),
                  label: Text(car.available ? 'Disable' : 'Enable'),
                  style: OutlinedButton.styleFrom(minimumSize: const Size(0, 38), foregroundColor: car.available ? AppColors.warning : AppColors.success, side: BorderSide(color: car.available ? AppColors.warning : AppColors.success), padding: const EdgeInsets.symmetric(horizontal: 12)),
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton(
                onPressed: onDelete,
                style: OutlinedButton.styleFrom(minimumSize: const Size(38, 38), foregroundColor: AppColors.error, side: const BorderSide(color: AppColors.error), padding: EdgeInsets.zero),
                child: const Icon(Icons.delete_rounded, size: 18),
              ),
            ]),
          ]),
        ),
      ]),
    );
  }
}
