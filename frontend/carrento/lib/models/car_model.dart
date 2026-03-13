class CarModel {
  final String id;
  final String name;
  final String brand;
  final String model;
  final int year;
  final String type;
  final String transmission;
  final String fuel;
  final int seats;
  final double pricePerDay;
  final String location;
  final bool available;
  final List<String> features;
  final List<String> images;
  final double rating;
  final int totalRatings;
  final String description;
  final String mileage;
  final bool insurance;

  CarModel({
    required this.id,
    required this.name,
    required this.brand,
    required this.model,
    required this.year,
    required this.type,
    required this.transmission,
    required this.fuel,
    required this.seats,
    required this.pricePerDay,
    required this.location,
    required this.available,
    required this.features,
    required this.images,
    required this.rating,
    required this.totalRatings,
    required this.description,
    required this.mileage,
    required this.insurance,
  });

  factory CarModel.fromJson(Map<String, dynamic> json) {
    return CarModel(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      brand: json['brand'] ?? '',
      model: json['model'] ?? '',
      year: json['year'] ?? 2023,
      type: json['type'] ?? '',
      transmission: json['transmission'] ?? '',
      fuel: json['fuel'] ?? '',
      seats: json['seats'] ?? 5,
      pricePerDay: (json['pricePerDay'] ?? 0).toDouble(),
      location: json['location'] ?? '',
      available: json['available'] ?? true,
      features: List<String>.from(json['features'] ?? []),
      images: List<String>.from(json['images'] ?? []),
      rating: (json['rating'] ?? 0).toDouble(),
      totalRatings: json['totalRatings'] ?? 0,
      description: json['description'] ?? '',
      mileage: json['mileage'] ?? 'Unlimited',
      insurance: json['insurance'] ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name, 'brand': brand, 'model': model, 'year': year,
        'type': type, 'transmission': transmission, 'fuel': fuel,
        'seats': seats, 'pricePerDay': pricePerDay, 'location': location,
        'available': available, 'features': features, 'images': images,
        'description': description, 'mileage': mileage, 'insurance': insurance,
      };

  String get imageUrl => images.isNotEmpty ? images.first : 'https://images.unsplash.com/photo-1503376780353-7e6692767b70?w=800';
}

class UserModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String avatar;
  final String role;
  final String licenseNumber;
  final String address;
  final bool isActive;
  final int totalBookings;
  final String createdAt;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.avatar,
    required this.role,
    required this.licenseNumber,
    required this.address,
    required this.isActive,
    required this.totalBookings,
    required this.createdAt,
  });

  bool get isAdmin => role == 'admin';

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      avatar: json['avatar'] ?? '',
      role: json['role'] ?? 'user',
      licenseNumber: json['licenseNumber'] ?? '',
      address: json['address'] ?? '',
      isActive: json['isActive'] ?? true,
      totalBookings: json['totalBookings'] ?? 0,
      createdAt: json['createdAt'] ?? '',
    );
  }
}
