import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/car_model.dart';
import '../utils/app_theme.dart';

class CarCard extends StatelessWidget {
  final CarModel car;
  final VoidCallback onTap;

  const CarCard({super.key, required this.car, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.divider),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 5,
              child: Stack(children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: CachedNetworkImage(
                    imageUrl: car.imageUrl,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(color: AppColors.cardLight, child: const Center(child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.accent))),
                    errorWidget: (_, __, ___) => Container(color: AppColors.cardLight, child: const Icon(Icons.directions_car_rounded, size: 32, color: AppColors.textMuted)),
                  ),
                ),
                if (!car.available)
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                      child: Container(
                        color: AppColors.primary.withOpacity(0.6),
                        child: Center(child: Text('Unavailable', style: GoogleFonts.spaceGrotesk(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12))),
                      ),
                    ),
                  ),
                Positioned(top: 8, right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.85), borderRadius: BorderRadius.circular(6)),
                    child: Text(car.type, style: GoogleFonts.spaceGrotesk(color: AppColors.textSecondary, fontWeight: FontWeight.w600, fontSize: 10)),
                  ),
                ),
              ]),
            ),
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(car.name, style: GoogleFonts.spaceGrotesk(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
                    Text('${car.brand} • ${car.year}', style: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 11)),
                    Row(children: [
                      const Icon(Icons.star_rounded, color: AppColors.accent, size: 13),
                      const SizedBox(width: 3),
                      Text('${car.rating}', style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.w500)),
                      const Spacer(),
                      Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                        Text('\$${car.pricePerDay.toStringAsFixed(0)}', style: GoogleFonts.spaceGrotesk(color: AppColors.accent, fontWeight: FontWeight.w800, fontSize: 14)),
                        Text('/d', style: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 10)),
                      ]),
                    ]),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
