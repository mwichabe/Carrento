import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/auth_provider.dart';
import '../../services/car_provider.dart';
import '../../utils/app_theme.dart';
import '../../widgets/car_card.dart';
import '../../widgets/section_header.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _categories = ['All', 'Sedan', 'SUV', 'Sports', 'Supercar', 'Electric'];
  String _selected = 'All';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetchCars());
  }

  void _fetchCars() {
    final filters = <String, dynamic>{'available': 'true', 'limit': '20'};
    if (_selected != 'All') filters['type'] = _selected;
    context.read<CarProvider>().fetchCars(filters: filters);
  }

  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthProvider>().user;
    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.accent,
          backgroundColor: AppColors.card,
          onRefresh: () async => _fetchCars(),
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _buildHeader(user?.name ?? '')),
              SliverToBoxAdapter(child: _buildSearchBar()),
              SliverToBoxAdapter(child: _buildFeaturedBanner()),
              SliverToBoxAdapter(child: _buildCategories()),
              SliverToBoxAdapter(child: SectionHeader(title: 'Available Cars', onSeeAll: () => context.go('/explore'))),
              _buildCarGrid(),
              const SliverToBoxAdapter(child: SizedBox(height: 20)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(String name) {
    final first = name.split(' ').first;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Hello, $first 👋', style: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 14)),
            const SizedBox(height: 4),
            Text('Find your ride', style: Theme.of(context).textTheme.headlineMedium),
          ]),
          GestureDetector(
            onTap: () => context.go('/profile'),
            child: Container(
              width: 46, height: 46,
              decoration: BoxDecoration(color: AppColors.accent, borderRadius: BorderRadius.circular(14)),
              child: Center(child: Text(name.isNotEmpty ? name[0].toUpperCase() : 'U', style: GoogleFonts.spaceGrotesk(color: AppColors.primary, fontWeight: FontWeight.w800, fontSize: 18))),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return GestureDetector(
      onTap: () => context.go('/explore'),
      child: Container(
        margin: const EdgeInsets.fromLTRB(24, 20, 24, 0),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.divider)),
        child: Row(children: [
          const Icon(Icons.search_rounded, color: AppColors.textMuted, size: 22),
          const SizedBox(width: 12),
          Text('Search cars, brands...', style: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 15)),
          const Spacer(),
          Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: AppColors.accent, borderRadius: BorderRadius.circular(8)),
            child: const Icon(Icons.tune_rounded, color: AppColors.primary, size: 16)),
        ]),
      ),
    );
  }

  Widget _buildFeaturedBanner() {
    return Container(
      margin: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.accent,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('20% OFF', style: GoogleFonts.spaceGrotesk(color: AppColors.primary, fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: -1)),
              const SizedBox(height: 4),
              Text('On your first booking\nUse code: FIRST20', style: GoogleFonts.inter(color: AppColors.primary.withOpacity(0.7), fontSize: 13, height: 1.5)),
              const SizedBox(height: 14),
              GestureDetector(
                onTap: () => context.go('/explore'),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(8)),
                  child: Text('Book Now', style: GoogleFonts.spaceGrotesk(color: AppColors.accent, fontWeight: FontWeight.w700, fontSize: 13)),
                ),
              ),
            ]),
          ),
          const Icon(Icons.directions_car_filled_rounded, size: 90, color: AppColors.primary),
        ],
      ),
    );
  }

  Widget _buildCategories() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Categories'),
        SizedBox(
          height: 44,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            itemCount: _categories.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, i) {
              final cat = _categories[i];
              final isSelected = cat == _selected;
              return GestureDetector(
                onTap: () { setState(() => _selected = cat); _fetchCars(); },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.accent : AppColors.card,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: isSelected ? AppColors.accent : AppColors.divider),
                  ),
                  child: Text(cat, style: GoogleFonts.spaceGrotesk(color: isSelected ? AppColors.primary : AppColors.textSecondary, fontWeight: FontWeight.w600, fontSize: 13)),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCarGrid() {
    return Consumer<CarProvider>(
      builder: (_, provider, __) {
        if (provider.isLoading) {
          return SliverToBoxAdapter(child: SizedBox(height: 300, child: Center(child: CircularProgressIndicator(color: AppColors.accent))));
        }
        if (provider.cars.isEmpty) {
          return SliverToBoxAdapter(child: SizedBox(height: 200, child: Center(child: Text('No cars found', style: Theme.of(context).textTheme.bodyMedium))));
        }
        return SliverPadding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 0.72, crossAxisSpacing: 12, mainAxisSpacing: 12),
            delegate: SliverChildBuilderDelegate(
              (_, i) => CarCard(car: provider.cars[i], onTap: () => context.push('/car/${provider.cars[i].id}')),
              childCount: provider.cars.length,
            ),
          ),
        );
      },
    );
  }
}
