import 'dart:async';
import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:baloga_ar_rescue/data/models/spawn_point_model.dart';
import 'package:baloga_ar_rescue/data/services/location_service.dart';
import 'package:baloga_ar_rescue/core/constants/app_constants.dart';

final locationServiceProvider = Provider<LocationService>((ref) => LocationService());

// User GPS position
class LocationState {
  final Position? position;
  final bool isInArea;
  final bool isLoading;
  final String? error;

  const LocationState({this.position, this.isInArea = false, this.isLoading = false, this.error});

  LocationState copyWith({Position? position, bool? isInArea, bool? isLoading, String? error}) =>
      LocationState(
        position: position ?? this.position,
        isInArea: isInArea ?? this.isInArea,
        isLoading: isLoading ?? this.isLoading,
        error: error,
      );
}

class LocationNotifier extends StateNotifier<LocationState> {
  final LocationService _service;
  StreamSubscription<Position>? _positionSub;
  List<Map<String, dynamic>> _gameLocations = [];

  LocationNotifier(this._service) : super(const LocationState());

  Future<void> init() async {
    state = state.copyWith(isLoading: true);
    try {
      _gameLocations = await _service.getGameLocations();
      await _startTracking();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> _startTracking() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      state = state.copyWith(isLoading: false, error: 'GPS tidak aktif');
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever || permission == LocationPermission.denied) {
      state = state.copyWith(isLoading: false, error: 'Izin lokasi ditolak');
      return;
    }

    _positionSub = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5,
      ),
    ).listen((position) {
      final inArea = _checkInArea(position);
      state = state.copyWith(position: position, isInArea: inArea, isLoading: false);
    });
  }

  bool _checkInArea(Position pos) {
    if (_gameLocations.isEmpty) return true; // Dev mode: allow all
    for (final loc in _gameLocations) {
      final lat = (loc['latitude'] as num).toDouble();
      final lng = (loc['longitude'] as num).toDouble();
      final radius = (loc['radius_meters'] as num).toDouble();
      final dist = _haversineMeters(pos.latitude, pos.longitude, lat, lng);
      if (dist <= radius) return true;
    }
    return false;
  }

  double _haversineMeters(double lat1, double lon1, double lat2, double lon2) {
    const R = 6371000.0;
    final dLat = (lat2 - lat1) * pi / 180;
    final dLon = (lon2 - lon1) * pi / 180;
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1 * pi / 180) * cos(lat2 * pi / 180) * sin(dLon / 2) * sin(dLon / 2);
    return R * 2 * atan2(sqrt(a), sqrt(1 - a));
  }

  @override
  void dispose() {
    _positionSub?.cancel();
    super.dispose();
  }
}

final locationProvider = StateNotifierProvider<LocationNotifier, LocationState>(
  (ref) => LocationNotifier(ref.watch(locationServiceProvider)),
);

// Nearby spawn points
class SpawnPointsNotifier extends StateNotifier<AsyncValue<List<SpawnPointModel>>> {
  final LocationService _service;
  Timer? _refreshTimer;

  SpawnPointsNotifier(this._service) : super(const AsyncValue.loading());

  Future<void> refresh(double lat, double lng) async {
    state = const AsyncValue.loading();
    try {
      final points = await _service.getNearbySpawnPoints(lat, lng);
      state = AsyncValue.data(points);
    } catch (e, s) {
      state = AsyncValue.error(e, s);
    }
  }

  void startAutoRefresh(double lat, double lng) {
    _refreshTimer?.cancel();
    refresh(lat, lng);
    _refreshTimer = Timer.periodic(
      const Duration(seconds: AppConstants.locationUpdateIntervalSeconds),
      (_) => refresh(lat, lng),
    );
  }

  void stopAutoRefresh() {
    _refreshTimer?.cancel();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }
}

final spawnPointsProvider = StateNotifierProvider<SpawnPointsNotifier, AsyncValue<List<SpawnPointModel>>>(
  (ref) => SpawnPointsNotifier(ref.watch(locationServiceProvider)),
);

