import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/car_provider.dart';
import '../../utils/app_theme.dart';
import '../../widgets/car_card.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final _searchCtrl = TextEditingController();
  String _sortBy = 'createdAt';
  String? _type;
  String? _fuel;
  String? _transmission;
  double _maxPrice = 1000;
  bool _availableOnly = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _search());
  }

  void _search() {
    final params = <String, dynamic>{'limit': '30', 'sortBy': _sortBy};
    if (_searchCtrl.text.isNotEmpty) params['search'] = _searchCtrl.text;
    if (_type != null) params['type'] = _type!;
    if (_fuel != null) params['fuel'] = _fuel!;
    if (_transmission != null) params['transmission'] = _transmission!;
    if (_availableOnly) params['available'] = 'true';
    params['maxPrice'] = _maxPrice.toStringAsFixed(0);
    context.read<CarProvider>().fetchCars(filters: params);
  }

  void _showFilters() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => _FilterSheet(
        type: _type, fuel: _fuel, transmission: _transmission,
        maxPrice: _maxPrice, availableOnly: _availableOnly,
        onApply: (t, f, tr, mp, av) {
          setState(() { _type = t; _fuel = f; _transmission = tr; _maxPrice = mp; _availableOnly = av; });
          _search();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
              child: Row(children: [
                Expanded(
                  child: TextField(
                    controller: _searchCtrl,
                    onSubmitted: (_) => _search(),
                    style: GoogleFonts.inter(color: AppColors.textPrimary),
                    decoration: InputDecoration(
                      hintText: 'Search brand, model...',
                      prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textMuted),
                      suffixIcon: _searchCtrl.text.isNotEmpty ? IconButton(icon: const Icon(Icons.clear_rounded, color: AppColors.textMuted), onPressed: () { _searchCtrl.clear(); _search(); }) : null,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: _showFilters,
                  child: Container(
                    width: 54, height: 54,
                    decoration: BoxDecoration(color: AppColors.accent, borderRadius: BorderRadius.circular(12)),
                    child: const Icon(Icons.tune_rounded, color: AppColors.primary),
                  ),
                ),
              ]),
            ),
            _buildSortBar(),
            Expanded(
              child: Consumer<CarProvider>(
                builder: (_, p, __) {
                  if (p.isLoading) return const Center(child: CircularProgressIndicator(color: AppColors.accent));
                  if (p.cars.isEmpty) return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    const Icon(Icons.car_crash_rounded, size: 64, color: AppColors.textMuted),
                    const SizedBox(height: 16),
                    Text('No cars found', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    Text('Try adjusting your filters', style: Theme.of(context).textTheme.bodyMedium),
                  ]));
                  return GridView.builder(
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 0.72, crossAxisSpacing: 12, mainAxisSpacing: 12),
                    itemCount: p.cars.length,
                    itemBuilder: (_, i) => CarCard(car: p.cars[i], onTap: () => context.push('/car/${p.cars[i].id}')),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSortBar() {
    final sorts = [('Latest', 'createdAt'), ('Price ↑', 'price_asc'), ('Price ↓', 'price_desc'), ('Rating', 'rating')];
    return SizedBox(
      height: 36,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        children: sorts.map((s) {
          final isSelected = _sortBy == s.$2;
          return GestureDetector(
            onTap: () { setState(() => _sortBy = s.$2); _search(); },
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.accent : AppColors.card,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: isSelected ? AppColors.accent : AppColors.divider),
              ),
              child: Text(s.$1, style: GoogleFonts.spaceGrotesk(color: isSelected ? AppColors.primary : AppColors.textSecondary, fontWeight: FontWeight.w600, fontSize: 12)),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _FilterSheet extends StatefulWidget {
  final String? type, fuel, transmission;
  final double maxPrice;
  final bool availableOnly;
  final Function(String?, String?, String?, double, bool) onApply;

  const _FilterSheet({this.type, this.fuel, this.transmission, required this.maxPrice, required this.availableOnly, required this.onApply});

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  late String? _type;
  late String? _fuel;
  late String? _transmission;
  late double _maxPrice;
  late bool _availableOnly;

  @override
  void initState() {
    super.initState();
    _type = widget.type; _fuel = widget.fuel; _transmission = widget.transmission;
    _maxPrice = widget.maxPrice; _availableOnly = widget.availableOnly;
  }

  Widget _chip(String label, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 8, bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.accent : AppColors.card,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: selected ? AppColors.accent : AppColors.divider),
        ),
        child: Text(label, style: GoogleFonts.spaceGrotesk(color: selected ? AppColors.primary : AppColors.textSecondary, fontWeight: FontWeight.w600, fontSize: 13)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.75, minChildSize: 0.5, maxChildSize: 0.9, expand: false,
      builder: (_, ctrl) => Padding(
        padding: const EdgeInsets.all(24),
        child: ListView(controller: ctrl, children: [
          Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.divider, borderRadius: BorderRadius.circular(2)))),
          const SizedBox(height: 20),
          Text('Filters', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 24),
          Text('Type', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 10),
          Wrap(children: ['Sedan', 'SUV', 'Sports', 'Supercar', 'Hatchback', 'Convertible'].map((t) => _chip(t, _type == t, () => setState(() => _type = _type == t ? null : t))).toList()),
          const SizedBox(height: 16),
          Text('Fuel', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 10),
          Wrap(children: ['Petrol', 'Diesel', 'Electric', 'Hybrid'].map((f) => _chip(f, _fuel == f, () => setState(() => _fuel = _fuel == f ? null : f))).toList()),
          const SizedBox(height: 16),
          Text('Transmission', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 10),
          Wrap(children: ['Automatic', 'Manual', 'CVT'].map((t) => _chip(t, _transmission == t, () => setState(() => _transmission = _transmission == t ? null : t))).toList()),
          const SizedBox(height: 16),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('Max Price/Day', style: Theme.of(context).textTheme.titleMedium),
            Text('\$${_maxPrice.toStringAsFixed(0)}', style: GoogleFonts.spaceGrotesk(color: AppColors.accent, fontWeight: FontWeight.w700, fontSize: 16)),
          ]),
          Slider(value: _maxPrice, min: 50, max: 1000, divisions: 19, activeColor: AppColors.accent, inactiveColor: AppColors.divider, onChanged: (v) => setState(() => _maxPrice = v)),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('Available Only', style: Theme.of(context).textTheme.titleMedium),
            Switch(value: _availableOnly, onChanged: (v) => setState(() => _availableOnly = v), activeColor: AppColors.accent),
          ]),
          const SizedBox(height: 24),
          ElevatedButton(onPressed: () { widget.onApply(_type, _fuel, _transmission, _maxPrice, _availableOnly); Navigator.pop(context); }, child: const Text('Apply Filters')),
          const SizedBox(height: 12),
          OutlinedButton(onPressed: () { setState(() { _type = null; _fuel = null; _transmission = null; _maxPrice = 1000; _availableOnly = true; }); }, child: const Text('Reset')),
        ]),
      ),
    );
  }
}
