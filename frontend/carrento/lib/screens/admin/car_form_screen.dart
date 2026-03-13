import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/car_model.dart';
import '../../services/car_provider.dart';
import '../../utils/app_theme.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';

class CarFormScreen extends StatefulWidget {
  final String? carId;
  const CarFormScreen({super.key, this.carId});

  @override
  State<CarFormScreen> createState() => _CarFormScreenState();
}

class _CarFormScreenState extends State<CarFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _brandCtrl = TextEditingController();
  final _modelCtrl = TextEditingController();
  final _yearCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _imageCtrl = TextEditingController();
  final _featuresCtrl = TextEditingController();

  String _type = 'Sedan';
  String _transmission = 'Automatic';
  String _fuel = 'Petrol';
  int _seats = 5;
  bool _available = true;
  bool _loading = false;
  CarModel? _editCar;

  final _types = ['Sedan', 'SUV', 'Sports', 'Supercar', 'Hatchback', 'Convertible', 'Truck', 'Van'];
  final _transmissions = ['Automatic', 'Manual', 'CVT'];
  final _fuels = ['Petrol', 'Diesel', 'Electric', 'Hybrid'];

  @override
  void initState() {
    super.initState();
    if (widget.carId != null) _loadCar();
  }

  Future<void> _loadCar() async {
    setState(() => _loading = true);
    final car = await context.read<CarProvider>().fetchCarById(widget.carId!);
    if (car != null && mounted) {
      setState(() {
        _editCar = car;
        _nameCtrl.text = car.name;
        _brandCtrl.text = car.brand;
        _modelCtrl.text = car.model;
        _yearCtrl.text = car.year.toString();
        _priceCtrl.text = car.pricePerDay.toString();
        _locationCtrl.text = car.location;
        _descCtrl.text = car.description;
        _imageCtrl.text = car.images.isNotEmpty ? car.images.first : '';
        _featuresCtrl.text = car.features.join(', ');
        _type = car.type;
        _transmission = car.transmission;
        _fuel = car.fuel;
        _seats = car.seats;
        _available = car.available;
        _loading = false;
      });
    } else {
      setState(() => _loading = false);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    final features = _featuresCtrl.text.split(',').map((f) => f.trim()).where((f) => f.isNotEmpty).toList();
    final images = _imageCtrl.text.isNotEmpty ? [_imageCtrl.text.trim()] : [];

    final data = {
      'name': _nameCtrl.text.trim(),
      'brand': _brandCtrl.text.trim(),
      'model': _modelCtrl.text.trim(),
      'year': int.tryParse(_yearCtrl.text) ?? 2023,
      'pricePerDay': double.tryParse(_priceCtrl.text) ?? 0,
      'location': _locationCtrl.text.trim(),
      'description': _descCtrl.text.trim(),
      'type': _type,
      'transmission': _transmission,
      'fuel': _fuel,
      'seats': _seats,
      'available': _available,
      'features': features,
      'images': images,
    };

    bool ok;
    if (_editCar != null) {
      ok = await context.read<CarProvider>().adminUpdateCar(_editCar!.id, data);
    } else {
      final car = await context.read<CarProvider>().adminCreateCar(data);
      ok = car != null;
    }

    setState(() => _loading = false);
    if (!mounted) return;
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_editCar != null ? 'Car updated!' : 'Car added!'), backgroundColor: AppColors.success));
      context.pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to save car.'), backgroundColor: AppColors.error));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.carId != null ? 'Edit Car' : 'Add New Car'),
        leading: IconButton(icon: const Icon(Icons.arrow_back_rounded), onPressed: () => context.pop()),
      ),
      body: _loading && _editCar == null && widget.carId != null
          ? const Center(child: CircularProgressIndicator(color: AppColors.accent))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  _section('Basic Information'),
                  AppTextField(controller: _nameCtrl, label: 'Car Name', hint: 'e.g. Tesla Model S', prefixIcon: Icons.directions_car_rounded, validator: (v) => v!.isEmpty ? 'Required' : null),
                  const SizedBox(height: 12),
                  Row(children: [
                    Expanded(child: AppTextField(controller: _brandCtrl, label: 'Brand', hint: 'Tesla', validator: (v) => v!.isEmpty ? 'Required' : null)),
                    const SizedBox(width: 12),
                    Expanded(child: AppTextField(controller: _modelCtrl, label: 'Model', hint: 'Model S', validator: (v) => v!.isEmpty ? 'Required' : null)),
                  ]),
                  const SizedBox(height: 12),
                  Row(children: [
                    Expanded(child: AppTextField(controller: _yearCtrl, label: 'Year', hint: '2023', keyboardType: TextInputType.number, validator: (v) => v!.isEmpty ? 'Required' : null)),
                    const SizedBox(width: 12),
                    Expanded(child: AppTextField(controller: _priceCtrl, label: 'Price/Day (\$)', hint: '150', keyboardType: TextInputType.number, validator: (v) => v!.isEmpty ? 'Required' : null)),
                  ]),
                  const SizedBox(height: 12),
                  AppTextField(controller: _locationCtrl, label: 'Location', hint: 'New York', prefixIcon: Icons.location_on_rounded, validator: (v) => v!.isEmpty ? 'Required' : null),
                  const SizedBox(height: 20),
                  _section('Specifications'),
                  _dropdownField('Type', _type, _types, (v) => setState(() => _type = v!)),
                  const SizedBox(height: 12),
                  _dropdownField('Transmission', _transmission, _transmissions, (v) => setState(() => _transmission = v!)),
                  const SizedBox(height: 12),
                  _dropdownField('Fuel Type', _fuel, _fuels, (v) => setState(() => _fuel = v!)),
                  const SizedBox(height: 12),
                  _seatsSelector(),
                  const SizedBox(height: 20),
                  _section('Media & Details'),
                  AppTextField(controller: _imageCtrl, label: 'Image URL', hint: 'https://...', prefixIcon: Icons.image_outlined),
                  const SizedBox(height: 12),
                  AppTextField(controller: _featuresCtrl, label: 'Features (comma separated)', hint: 'Autopilot, Heated Seats, WiFi', maxLines: 2),
                  const SizedBox(height: 12),
                  AppTextField(controller: _descCtrl, label: 'Description', hint: 'Describe the car...', maxLines: 4),
                  const SizedBox(height: 16),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text('Available for Booking', style: Theme.of(context).textTheme.titleMedium),
                    Switch(value: _available, onChanged: (v) => setState(() => _available = v), activeColor: AppColors.accent),
                  ]),
                  const SizedBox(height: 28),
                  AppButton(label: widget.carId != null ? 'Update Car' : 'Add Car', isLoading: _loading, onTap: _save),
                  const SizedBox(height: 24),
                ]),
              ),
            ),
    );
  }

  Widget _section(String title) => Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: Text(title, style: Theme.of(context).textTheme.titleLarge),
  );

  Widget _dropdownField(String label, String value, List<String> items, ValueChanged<String?> onChanged) {
    return DropdownButtonFormField<String>(
      value: value,
      onChanged: onChanged,
      items: items.map((i) => DropdownMenuItem(value: i, child: Text(i, style: GoogleFonts.inter(color: AppColors.textPrimary)))).toList(),
      decoration: InputDecoration(labelText: label),
      dropdownColor: AppColors.card,
      style: GoogleFonts.inter(color: AppColors.textPrimary),
    );
  }

  Widget _seatsSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.divider)),
      child: Row(children: [
        const Icon(Icons.event_seat_rounded, color: AppColors.textMuted, size: 20),
        const SizedBox(width: 12),
        Expanded(child: Text('Seats', style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 14))),
        Row(children: [2, 4, 5, 7, 8].map((s) {
          final sel = _seats == s;
          return GestureDetector(
            onTap: () => setState(() => _seats = s),
            child: Container(
              width: 36, height: 36, margin: const EdgeInsets.only(left: 6),
              decoration: BoxDecoration(color: sel ? AppColors.accent : AppColors.cardLight, borderRadius: BorderRadius.circular(8)),
              child: Center(child: Text('$s', style: GoogleFonts.spaceGrotesk(color: sel ? AppColors.primary : AppColors.textSecondary, fontWeight: FontWeight.w700, fontSize: 13))),
            ),
          );
        }).toList()),
      ]),
    );
  }
}
