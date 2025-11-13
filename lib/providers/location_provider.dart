import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:math';

class LocationProvider extends ChangeNotifier {
  // Office location coordinates
  static const double officeLat = -7.2780695;
  static const double officeLng = 112.7884398;
  static const double allowedRadius = 100; // meters

  Position? _currentPosition;
  bool _isLocationLoading = false;
  String? _locationError;
  double? _distanceFromOffice;
  bool _isWithinOfficeRadius = false;

  // Getters
  Position? get currentPosition => _currentPosition;
  bool get isLocationLoading => _isLocationLoading;
  String? get locationError => _locationError;
  double? get distanceFromOffice => _distanceFromOffice;
  bool get isWithinOfficeRadius => _isWithinOfficeRadius;

  // Calculate distance between two coordinates using Haversine formula
  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const p = 0.017453292519943295; // Math.PI / 180
    final a = 0.5 -
        cos((lat2 - lat1) * p) / 2 +
        cos(lat1 * p) *
            cos(lat2 * p) *
            (1 - cos((lon2 - lon1) * p)) /
            2;
    return 12742000 * asin(sqrt(a)); // 2 * R * asin(sqrt(a)) where R = 6371 km
  }

  // Request location permission
  Future<bool> requestLocationPermission() async {
    try {
      final permission = await Geolocator.checkPermission();
      
      if (permission == LocationPermission.denied) {
        final newPermission = await Geolocator.requestPermission();
        return newPermission == LocationPermission.whileInUse ||
            newPermission == LocationPermission.always;
      } else if (permission == LocationPermission.deniedForever) {
        // Permission denied forever, open app settings
        await Geolocator.openAppSettings();
        return false;
      }
      
      return permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always;
    } catch (e) {
      print('[v0] Error requesting location permission: ${e.toString()}');
      _locationError = 'Gagal meminta izin lokasi: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  // Get current location
  Future<bool> getCurrentLocation() async {
    _isLocationLoading = true;
    _locationError = null;
    notifyListeners();

    try {
      // Check if location services are enabled
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _locationError = 'Layanan lokasi tidak diaktifkan. Silakan aktifkan GPS.';
        _isLocationLoading = false;
        notifyListeners();
        return false;
      }

      // Request permission if needed
      final hasPermission = await requestLocationPermission();
      if (!hasPermission) {
        _locationError = 'Izin lokasi ditolak. Tidak dapat melakukan absensi.';
        _isLocationLoading = false;
        notifyListeners();
        return false;
      }

      // Get current position
      _currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      print('[v0] Current position: ${_currentPosition!.latitude}, ${_currentPosition!.longitude}');

      // Calculate distance from office
      _distanceFromOffice = _calculateDistance(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
        officeLat,
        officeLng,
      );

      print('[v0] Distance from office: $_distanceFromOffice meters');

      // Check if within office radius
      _isWithinOfficeRadius = _distanceFromOffice! <= allowedRadius;

      _locationError = null;
      _isLocationLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      print('[v0] Error getting current location: ${e.toString()}');
      _locationError = 'Gagal mendapatkan lokasi: ${e.toString()}';
      _isLocationLoading = false;
      notifyListeners();
      return false;
    }
  }

  void clearLocationError() {
    _locationError = null;
    notifyListeners();
  }
}
