import 'car_model.dart';

class BookingModel {
  final String id;
  final dynamic user;
  final CarModel? car;
  final String carId;
  final DateTime startDate;
  final DateTime endDate;
  final int totalDays;
  final double totalPrice;
  final String status;
  final String pickupLocation;
  final String dropoffLocation;
  final String paymentStatus;
  final String notes;
  final String cancellationReason;
  final String createdAt;

  BookingModel({
    required this.id,
    required this.user,
    this.car,
    required this.carId,
    required this.startDate,
    required this.endDate,
    required this.totalDays,
    required this.totalPrice,
    required this.status,
    required this.pickupLocation,
    required this.dropoffLocation,
    required this.paymentStatus,
    required this.notes,
    required this.cancellationReason,
    required this.createdAt,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json['_id'] ?? '',
      user: json['user'],
      car: json['car'] is Map ? CarModel.fromJson(json['car']) : null,
      carId: json['car'] is Map ? json['car']['_id'] ?? '' : json['car'] ?? '',
      startDate: DateTime.tryParse(json['startDate'] ?? '') ?? DateTime.now(),
      endDate: DateTime.tryParse(json['endDate'] ?? '') ?? DateTime.now(),
      totalDays: json['totalDays'] ?? 1,
      totalPrice: (json['totalPrice'] ?? 0).toDouble(),
      status: json['status'] ?? 'pending',
      pickupLocation: json['pickupLocation'] ?? '',
      dropoffLocation: json['dropoffLocation'] ?? '',
      paymentStatus: json['paymentStatus'] ?? 'pending',
      notes: json['notes'] ?? '',
      cancellationReason: json['cancellationReason'] ?? '',
      createdAt: json['createdAt'] ?? '',
    );
  }

  String get statusLabel {
    switch (status) {
      case 'pending': return 'Pending';
      case 'confirmed': return 'Confirmed';
      case 'active': return 'Active';
      case 'completed': return 'Completed';
      case 'cancelled': return 'Cancelled';
      default: return status;
    }
  }
}
