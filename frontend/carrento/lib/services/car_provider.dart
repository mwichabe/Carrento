import 'package:flutter/material.dart';
import '../models/car_model.dart';
import '../models/booking_model.dart';
import '../services/api_service.dart';

class CarProvider extends ChangeNotifier {
  List<CarModel> _cars = [];
  List<BookingModel> _myBookings = [];
  bool _isLoading = false;
  String? _error;
  int _total = 0;
  final _api = ApiService();

  List<CarModel> get cars => _cars;
  List<BookingModel> get myBookings => _myBookings;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get total => _total;

  Future<void> fetchCars({Map<String, dynamic>? filters}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final res = await _api.get('/cars', params: filters);
      if (res.data['success']) {
        _cars = (res.data['data'] as List).map((e) => CarModel.fromJson(e)).toList();
        _total = res.data['total'] ?? _cars.length;
      }
    } catch (e) {
      _error = 'Failed to load cars.';
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<CarModel?> fetchCarById(String id) async {
    try {
      final res = await _api.get('/cars/$id');
      if (res.data['success']) return CarModel.fromJson(res.data['data']);
    } catch (_) {}
    return null;
  }

  Future<void> fetchMyBookings() async {
    try {
      final res = await _api.get('/bookings/my');
      if (res.data['success']) {
        _myBookings = (res.data['data'] as List).map((e) => BookingModel.fromJson(e)).toList();
        notifyListeners();
      }
    } catch (_) {}
  }

  Future<BookingModel?> createBooking(Map<String, dynamic> data) async {
    try {
      final res = await _api.post('/bookings', data: data);
      if (res.data['success']) {
        final booking = BookingModel.fromJson(res.data['data']);
        _myBookings.insert(0, booking);
        notifyListeners();
        return booking;
      }
    } catch (e) {
      _error = 'Failed to create booking.';
      notifyListeners();
    }
    return null;
  }

  Future<bool> cancelBooking(String bookingId, {String reason = ''}) async {
    try {
      final res = await _api.put('/bookings/$bookingId/cancel', data: {'reason': reason});
      if (res.data['success']) {
        final idx = _myBookings.indexWhere((b) => b.id == bookingId);
        if (idx != -1) {
          _myBookings[idx] = BookingModel.fromJson(res.data['data']);
          notifyListeners();
        }
        return true;
      }
    } catch (_) {}
    return false;
  }

  Future<CarModel?> adminCreateCar(Map<String, dynamic> data) async {
    try {
      final res = await _api.post('/cars', data: data);
      if (res.data['success']) {
        final car = CarModel.fromJson(res.data['data']);
        _cars.insert(0, car);
        notifyListeners();
        return car;
      }
    } catch (_) {}
    return null;
  }

  Future<bool> adminUpdateCar(String id, Map<String, dynamic> data) async {
    try {
      final res = await _api.put('/cars/$id', data: data);
      if (res.data['success']) {
        final idx = _cars.indexWhere((c) => c.id == id);
        if (idx != -1) { _cars[idx] = CarModel.fromJson(res.data['data']); notifyListeners(); }
        return true;
      }
    } catch (_) {}
    return false;
  }

  Future<bool> adminDeleteCar(String id) async {
    try {
      final res = await _api.delete('/cars/$id');
      if (res.data['success']) {
        _cars.removeWhere((c) => c.id == id);
        notifyListeners();
        return true;
      }
    } catch (_) {}
    return false;
  }
}
