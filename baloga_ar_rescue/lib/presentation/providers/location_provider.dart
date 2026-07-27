import 'dart:async';
import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:baloga_ar_rescue/data/models/spawn_point_model.dart';
import 'package:baloga_ar_rescue/data/models/species_model.dart';
import 'package:baloga_ar_rescue/data/services/location_service.dart';
import 'package:baloga_ar_rescue/core/constants/app_constants.dart';

final locationServiceProvider = Provider<LocationService>((ref) => LocationService());

// User GPS position state matching Flowchart
class LocationState {
  final Position? position;
  final bool isGpsEnabled;
  final bool hasPermission;
  final bool isInJatimPark;
  final bool isTestMode; // Mode uji coba untuk testing dari mana saja (e.g. Rozitech Office)
  final bool isLoading;
  final String? error;

  const LocationState({
    this.position,
    this.isGpsEnabled = true,
    this.hasPermission = true,
    this.isInJatimPark = true,
    this.isTestMode = true,
    this.isLoading = false,
    this.error,
  });

  LocationState copyWith({
    Position? position,
    bool? isGpsEnabled,
    bool? hasPermission,
    bool? isInJatimPark,
    bool? isTestMode,
    bool? isLoading,
    String? error,
  }) =>
      LocationState(
        position: position ?? this.position,
        isGpsEnabled: isGpsEnabled ?? this.isGpsEnabled,
        hasPermission: hasPermission ?? this.hasPermission,
        isInJatimPark: isInJatimPark ?? this.isInJatimPark,
        isTestMode: isTestMode ?? this.isTestMode,
        isLoading: isLoading ?? this.isLoading,
        error: error,
      );
}

class LocationNotifier extends StateNotifier<LocationState> {
  final LocationService _service;
  StreamSubscription<Position>? _positionSub;

  // Jatim Park / Baloga Center Coordinates
  static const double balogaLat = -7.892543;
  static const double balogaLng = 112.548972;
  static const double allowedRadiusMeters = 1500.0;

  LocationNotifier(this._service) : super(const LocationState());

  Future<void> init() async {
    state = state.copyWith(isLoading: true, error: null);
    await startTracking();
  }

  void toggleTestMode() {
    state = state.copyWith(isTestMode: !state.isTestMode);
  }

  Future<void> startTracking() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      state = state.copyWith(
        isGpsEnabled: false,
        isLoading: false,
        error: 'GPS tidak aktif. Aktifkan GPS Anda di Pengaturan.',
      );
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever || permission == LocationPermission.denied) {
      state = state.copyWith(
        hasPermission: false,
        isLoading: false,
        error: 'Izin lokasi ditolak. Berikan izin lokasi untuk bermain.',
      );
      return;
    }

    state = state.copyWith(isGpsEnabled: true, hasPermission: true);

    _positionSub?.cancel();
    _positionSub = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 1, // Realtime update every 1 meter movement
      ),
    ).listen(
      (position) {
        final distToBaloga = calculateDistanceMeters(
          position.latitude,
          position.longitude,
          balogaLat,
          balogaLng,
        );

        final inJatimPark = distToBaloga <= allowedRadiusMeters;

        state = state.copyWith(
          position: position,
          isInJatimPark: inJatimPark,
          isLoading: false,
          error: null,
        );
      },
      onError: (err) {
        state = state.copyWith(isLoading: false, error: 'Gagal membaca GPS: $err');
      },
    );
  }

  // Haversine Distance Formula in Meters
  double calculateDistanceMeters(double lat1, double lon1, double lat2, double lon2) {
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

// Nearby spawn points provider with widened radial projection (10m - 30m offset so all 10 are visible)
class SpawnPointsNotifier extends StateNotifier<AsyncValue<List<SpawnPointModel>>> {
  final LocationService _service;
  Timer? _refreshTimer;
  double? _lastLat;
  double? _lastLng;

  SpawnPointsNotifier(this._service) : super(const AsyncValue.loading());

  Future<void> refresh(double lat, double lng) async {
    _lastLat = lat;
    _lastLng = lng;
    try {
      final points = await _service.getNearbySpawnPoints(lat, lng);

      if (points.isEmpty || _isFarFromPoints(points, lat, lng)) {
        final projectedPoints = _generateRozitechDatasetSpawnPoints(lat, lng);
        state = AsyncValue.data(projectedPoints);
      } else {
        state = AsyncValue.data(points);
      }
    } catch (e) {
      final fallbackPoints = _generateRozitechDatasetSpawnPoints(lat, lng);
      state = AsyncValue.data(fallbackPoints);
    }
  }

  bool _isFarFromPoints(List<SpawnPointModel> points, double userLat, double userLng) {
    for (final p in points) {
      final dLat = (p.latitude - userLat).abs();
      final dLng = (p.longitude - userLng).abs();
      if (dLat < 0.001 && dLng < 0.001) return false;
    }
    return true;
  }

  // Generate Rozitech Asset Dataset items spread neatly in 10m - 30m radius around user
  List<SpawnPointModel> _generateRozitechDatasetSpawnPoints(double userLat, double userLng) {
    final speciesList = [
      SpeciesModel(
        id: 1,
        name: 'Honda PCX 160',
        latinName: 'Motorcycle PCX 160cc',
        category: 'hewan',
        rarity: 'epic',
        habitat: 'Kawasan Rozitech Office',
        food: 'Pertamax Turbo',
        ecologicalRole: 'Kendaraan operasional utama Ranger Rozitech',
        conservationStatus: 'Aktif Beroperasi',
        baseCp: 1250,
        thumbnailUrl: 'assets/Honda PCX 160.jpg',
        funFact: 'Kendaraan matic premium armada survey lokasi Rozitech.',
        isDiscovered: true,
      ),
      SpeciesModel(
        id: 2,
        name: 'Sandal Selop Karet Pria',
        latinName: 'Footwear Rubber Craft',
        category: 'hewan',
        rarity: 'rare',
        habitat: 'Markas Ranger Rozitech',
        food: 'Karet Alam',
        ecologicalRole: 'Perlengkapan wajib jalan kaki Ranger',
        conservationStatus: 'Siap Pakai',
        baseCp: 650,
        thumbnailUrl: 'assets/Sandal Selop Karet Pria.jpg',
        funFact: 'Perlengkapan kaki tahan air buatan lokal untuk patroli lapangan.',
        isDiscovered: true,
      ),
      SpeciesModel(
        id: 3,
        name: 'Pohon Pisang',
        latinName: 'Musa paradisiaca',
        category: 'tumbuhan',
        rarity: 'common',
        habitat: 'Area Perkebunan Rozitech',
        food: 'Fotosintesis',
        ecologicalRole: 'Penyedia pangan dan penahan erosi tanah',
        conservationStatus: 'Melimpah (Least Concern)',
        baseCp: 450,
        thumbnailUrl: 'assets/Pohon Pisang.jpg',
        funFact: 'Tumbuhan terna raksasa yang daun dan buahnya bermanfaat bagi ekosistem.',
        isDiscovered: true,
      ),
      SpeciesModel(
        id: 4,
        name: 'Lidah Mertua',
        latinName: 'Sansevieria trifasciata',
        category: 'tumbuhan',
        rarity: 'rare',
        habitat: 'Taman Edelweis Rozitech',
        food: 'Fotosintesis',
        ecologicalRole: 'Pembersih dan pemurni polusi udara',
        conservationStatus: 'Dilindungi (Protected)',
        baseCp: 750,
        thumbnailUrl: 'assets/Lidah Mertua.jpg',
        funFact: 'Tanaman hias penghasil oksigen tinggi dan penyerap zat beracun.',
        isDiscovered: true,
      ),
      SpeciesModel(
        id: 5,
        name: 'Bayam Duri',
        latinName: 'Amaranthus spinosus',
        category: 'tumbuhan',
        rarity: 'common',
        habitat: 'Area Kebun Belakang',
        food: 'Fotosintesis',
        ecologicalRole: 'Tumbuhan obat alami ekosistem',
        conservationStatus: 'Melimpah',
        baseCp: 300,
        thumbnailUrl: 'assets/Bayam Duri.jpg',
        funFact: 'Tumbuhan obat tradisional dengan batang berduri khas.',
        isDiscovered: true,
      ),
      SpeciesModel(
        id: 6,
        name: 'Rumput Ekor Kucing',
        latinName: 'Typha latifolia',
        category: 'tumbuhan',
        rarity: 'common',
        habitat: 'Lahan Lembab Rozitech',
        food: 'Fotosintesis',
        ecologicalRole: 'Penjaga kelembaban tanah dan mikroba',
        conservationStatus: 'Aman',
        baseCp: 350,
        thumbnailUrl: 'assets/Rumput Ekor Kucing.jpg',
        funFact: 'Tumbuhan unik berbentuk seperti ekor kucing yang tumbuh di area lembab.',
        isDiscovered: true,
      ),
      SpeciesModel(
        id: 7,
        name: 'Saga Rambat',
        latinName: 'Abrus precatorius',
        category: 'tumbuhan',
        rarity: 'epic',
        habitat: 'Pagar Halaman Rozitech',
        food: 'Fotosintesis',
        ecologicalRole: 'Penutup tanah dan peneduh alami',
        conservationStatus: 'Langka (Rare)',
        baseCp: 950,
        thumbnailUrl: 'assets/Saga Rambat.jpg',
        funFact: 'Tumbuhan merambat dengan biji merah cantik yang khas.',
        isDiscovered: true,
      ),
      SpeciesModel(
        id: 8,
        name: 'Kudzu',
        latinName: 'Pueraria montana',
        category: 'tumbuhan',
        rarity: 'rare',
        habitat: 'Area Perbukitan',
        food: 'Fotosintesis',
        ecologicalRole: 'Penyerap nitrogen tanah',
        conservationStatus: 'Terjaga',
        baseCp: 850,
        thumbnailUrl: 'assets/Kudzu.jpg',
        funFact: 'Tanaman polong-polongan merambat dengan daya tumbuh cepat.',
        isDiscovered: true,
      ),
      SpeciesModel(
        id: 9,
        name: 'Daun Mangga',
        latinName: 'Mangifera indica',
        category: 'tumbuhan',
        rarity: 'common',
        habitat: 'Halaman Depan Rozitech',
        food: 'Fotosintesis',
        ecologicalRole: 'Peneduh dan produsen oksigen',
        conservationStatus: 'Aman',
        baseCp: 400,
        thumbnailUrl: 'assets/daun mangga.jpg',
        funFact: 'Daun pohon mangga kaya antioksidan alami.',
        isDiscovered: true,
      ),
      SpeciesModel(
        id: 10,
        name: 'Harimau Sumatra',
        latinName: 'Panthera tigris sumatrae',
        category: 'hewan',
        rarity: 'legendary',
        habitat: 'Hutan Hujan Sumatra',
        food: 'Karnivora (Rusa, Babi Hutan)',
        ecologicalRole: 'Predator puncak pengendali ekosistem hutan',
        conservationStatus: 'Kritis (Critically Endangered)',
        baseCp: 1500,
        thumbnailUrl: 'https://images.unsplash.com/photo-1561731216-c3a4d99437d5?w=500',
        funFact: 'Harimau Sumatra adalah subspesies harimau terkecil yang masih ada di dunia.',
        isDiscovered: true,
      ),
    ];

    // Widened Radial offsets (approx 12 to 28 meters away from user so all 10 are visible & spread out)
    // 0.00015 deg is ~16.5 meters!
    final offsets = [
      const [0.00015, 0.00018],   // ~20m North-East (PCX 160)
      const [-0.00018, 0.00014],  // ~18m South-East (Sandal Selop)
      const [0.00014, -0.00020],  // ~22m North-West (Pohon Pisang)
      const [-0.00020, -0.00016], // ~24m South-West (Lidah Mertua)
      const [0.00022, 0.00000],   // ~24m North (Bayam Duri)
      const [0.00000, -0.00022],  // ~24m West (Rumput Ekor Kucing)
      const [0.00020, -0.00012],  // ~20m North-West (Saga Rambat)
      const [-0.00012, 0.00020],  // ~20m South-East (Kudzu)
      const [0.00010, 0.00024],   // ~24m East (Daun Mangga)
      const [-0.00024, -0.00010], // ~24m South (Harimau Sumatra)
    ];

    final List<SpawnPointModel> result = [];
    for (int i = 0; i < speciesList.length; i++) {
      final off = offsets[i % offsets.length];
      result.add(
        SpawnPointModel(
          id: i + 100,
          speciesId: speciesList[i].id,
          latitude: userLat + off[0],
          longitude: userLng + off[1],
          active: true,
          respawnMinutes: 15,
          isTappable: true,
          species: speciesList[i],
        ),
      );
    }

    return result;
  }

  void startAutoRefresh(double lat, double lng) {
    _refreshTimer?.cancel();
    refresh(lat, lng);
    _refreshTimer = Timer.periodic(
      const Duration(seconds: 2), // Refresh every 2 seconds for immediate real-time sync
      (_) {
        if (_lastLat != null && _lastLng != null) {
          refresh(_lastLat!, _lastLng!);
        }
      },
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
