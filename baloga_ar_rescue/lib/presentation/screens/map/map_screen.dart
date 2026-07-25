import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:baloga_ar_rescue/presentation/providers/location_provider.dart';
import 'package:baloga_ar_rescue/presentation/providers/auth_provider.dart';
import 'package:baloga_ar_rescue/data/models/spawn_point_model.dart';
import 'package:baloga_ar_rescue/core/theme/app_theme.dart';

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  final MapController _mapController = MapController();
  bool _centered = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initMap();
    });
  }

  void _initMap() {
    final locState = ref.read(locationProvider);
    if (locState.position != null) {
      final lat = locState.position!.latitude;
      final lng = locState.position!.longitude;
      ref.read(spawnPointsProvider.notifier).startAutoRefresh(lat, lng);
    }
  }

  @override
  void dispose() {
    ref.read(spawnPointsProvider.notifier).stopAutoRefresh();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locState = ref.watch(locationProvider);
    final spawnAsync = ref.watch(spawnPointsProvider);
    final authState = ref.watch(authProvider);

    // Auto-center map on first fix
    if (locState.position != null && !_centered) {
      _centered = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        try {
          _mapController.move(LatLng(locState.position!.latitude, locState.position!.longitude), 17);
          ref.read(spawnPointsProvider.notifier).startAutoRefresh(locState.position!.latitude, locState.position!.longitude);
        } catch (_) {}
      });
    }

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: Stack(
        children: [
          // Flutter Map
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: locState.position != null
                  ? LatLng(locState.position!.latitude, locState.position!.longitude)
                  : const LatLng(-7.892543, 112.548972),
              initialZoom: 17,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.baloga.baloga_ar_rescue',
              ),

              // Spawn point markers
              MarkerLayer(
                markers: spawnAsync.when(
                  data: (points) => points.map((sp) => _buildSpawnMarker(sp)).toList(),
                  loading: () => [],
                  error: (_, __) => [],
                ),
              ),

              // User position marker
              if (locState.position != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: LatLng(locState.position!.latitude, locState.position!.longitude),
                      width: 60,
                      height: 60,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.accentBlue.withOpacity(0.15),
                              border: Border.all(color: AppColors.accentBlue.withOpacity(0.4), width: 1.5),
                            ),
                          ),
                          Container(
                            width: 18,
                            height: 18,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.accentBlue,
                              boxShadow: [BoxShadow(color: AppColors.accentBlue.withOpacity(0.6), blurRadius: 8, spreadRadius: 2)],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
            ],
          ),

          // Top bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Container(
                margin: const EdgeInsets.all(12),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.bgCard.withOpacity(0.92),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.primaryGlow.withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.eco_rounded, color: AppColors.primaryGlow, size: 22),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          authState.user?.name ?? 'Ranger',
                          style: const TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.w700, color: AppColors.textPrimary, fontSize: 14),
                        ),
                        Row(
                          children: [
                            const Icon(Icons.star, color: AppColors.accentGold, size: 12),
                            const SizedBox(width: 2),
                            Text('Lv.${authState.user?.level ?? 1}  •  ${authState.user?.points ?? 0} pts',
                                style: const TextStyle(fontFamily: 'Outfit', color: AppColors.textMuted, fontSize: 11)),
                          ],
                        ),
                      ],
                    ),
                    const Spacer(),
                    // Area status badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: locState.isInArea ? AppColors.success.withOpacity(0.15) : AppColors.danger.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: locState.isInArea ? AppColors.success.withOpacity(0.5) : AppColors.danger.withOpacity(0.5)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(locState.isInArea ? Icons.location_on : Icons.location_off, color: locState.isInArea ? AppColors.success : AppColors.danger, size: 12),
                          const SizedBox(width: 4),
                          Text(locState.isInArea ? 'Di Area' : 'Luar Area', style: TextStyle(fontFamily: 'Outfit', fontSize: 11, fontWeight: FontWeight.w600, color: locState.isInArea ? AppColors.success : AppColors.danger)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Out of area overlay
          if (!locState.isInArea && locState.position != null)
            Positioned(
              bottom: 100,
              left: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.bgCard.withOpacity(0.95),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.warning.withOpacity(0.5)),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.warning_amber_rounded, color: AppColors.warning, size: 28),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Silakan datang ke Area Baloga untuk mulai menangkap spesies!',
                        style: TextStyle(fontFamily: 'Outfit', fontSize: 13, color: AppColors.textPrimary),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // GPS loading indicator
          if (locState.isLoading)
            const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(AppColors.primaryGlow)),
                  SizedBox(height: 12),
                  Text('Mendeteksi lokasi...', style: TextStyle(fontFamily: 'Outfit', color: AppColors.textSecondary)),
                ],
              ),
            ),

          // GPS error
          if (locState.error != null)
            Positioned(
              bottom: 100,
              left: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.danger.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.danger.withOpacity(0.5)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.gps_off, color: AppColors.danger),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(locState.error!, style: const TextStyle(fontFamily: 'Outfit', color: AppColors.danger, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 4),
                          GestureDetector(
                            onTap: () => ref.read(locationProvider.notifier).init(),
                            child: const Text('Aktifkan GPS & coba lagi', style: TextStyle(fontFamily: 'Outfit', color: AppColors.accentBlue, fontSize: 12, decoration: TextDecoration.underline)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Re-center FAB
          Positioned(
            bottom: 90,
            right: 16,
            child: FloatingActionButton.small(
              backgroundColor: AppColors.bgCard,
              onPressed: () {
                if (locState.position != null) {
                  _mapController.move(LatLng(locState.position!.latitude, locState.position!.longitude), 17);
                }
              },
              child: const Icon(Icons.my_location, color: AppColors.primaryGlow),
            ),
          ),
        ],
      ),
    );
  }

  Marker _buildSpawnMarker(SpawnPointModel sp) {
    final tappable = sp.isTappable ?? false;
    final rarity = sp.species?.rarity ?? 'common';
    final color = rarityColor(rarity);

    return Marker(
      point: LatLng(sp.latitude, sp.longitude),
      width: 56,
      height: 56,
      child: GestureDetector(
        onTap: tappable
            ? () {
                context.go('/capture/${sp.id}', extra: {
                  'species_name': sp.species?.name ?? 'Monster',
                  'species_thumbnail': sp.species?.thumbnailUrl,
                  'rarity': rarity,
                  'item_id': 1,
                });
              }
            : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: tappable ? color.withOpacity(0.2) : AppColors.bgCard.withOpacity(0.5),
            border: Border.all(color: tappable ? color : color.withOpacity(0.3), width: tappable ? 2.5 : 1.5),
            boxShadow: tappable
                ? [BoxShadow(color: color.withOpacity(0.5), blurRadius: 12, spreadRadius: 2)]
                : [],
          ),
          child: Icon(Icons.pets, color: tappable ? color : color.withOpacity(0.4), size: tappable ? 26 : 20),
        ),
      ),
    );
  }
}

