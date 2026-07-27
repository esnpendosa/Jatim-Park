import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:go_router/go_router.dart';
import 'package:baloga_ar_rescue/presentation/providers/auth_provider.dart';
import 'package:baloga_ar_rescue/presentation/providers/location_provider.dart';
import 'package:baloga_ar_rescue/data/models/spawn_point_model.dart';
import 'package:baloga_ar_rescue/core/theme/app_theme.dart';

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  final MapController _mapController = MapController();
  final LatLng _defaultBalogaPos = const LatLng(-7.892543, 112.548972);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initLocation();
    });
  }

  void _initLocation() async {
    await ref.read(locationProvider.notifier).init();
    final pos = ref.read(locationProvider).position;
    if (pos != null) {
      _mapController.move(LatLng(pos.latitude, pos.longitude), 17);
      ref.read(spawnPointsProvider.notifier).startAutoRefresh(pos.latitude, pos.longitude);
    } else {
      ref.read(spawnPointsProvider.notifier).startAutoRefresh(_defaultBalogaPos.latitude, _defaultBalogaPos.longitude);
    }
  }

  Color rarityColor(String rarity) {
    switch (rarity) {
      case 'legendary':
        return AppColors.rarityLegendary;
      case 'epic':
        return AppColors.rarityEpic;
      case 'rare':
        return AppColors.rarityRare;
      default:
        return AppColors.rarityCommon;
    }
  }

  @override
  Widget build(BuildContext context) {
    final locState = ref.watch(locationProvider);
    final spawnPointsAsync = ref.watch(spawnPointsProvider);
    final authState = ref.watch(authProvider);

    final userLatLng = locState.position != null
        ? LatLng(locState.position!.latitude, locState.position!.longitude)
        : _defaultBalogaPos;

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: Stack(
        children: [
          // OpenStreetMap Tile Layer
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: userLatLng,
              initialZoom: 16.5,
              maxZoom: 19.0,
              minZoom: 12.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.baloga.baloga_ar_rescue',
              ),

              // Spawn Points Layer
              spawnPointsAsync.when(
                data: (points) => MarkerLayer(
                  markers: points.map((sp) => _buildSpawnMarker(sp)).toList(),
                ),
                loading: () => const MarkerLayer(markers: []),
                error: (_, __) => const MarkerLayer(markers: []),
              ),

              // User Position Marker
              if (locState.position != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: userLatLng,
                      width: 48,
                      height: 48,
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primaryGlow.withValues(alpha: 0.25),
                          border: Border.all(color: AppColors.primaryGlow, width: 3),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primaryGlow.withValues(alpha: 0.6),
                              blurRadius: 16,
                              spreadRadius: 4,
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Icon(Icons.navigation, color: Colors.white, size: 22),
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),

          // Top Info Banner (Ranger & Status Mode Uji Coba)
          SafeArea(
            child: Positioned(
              top: 12,
              left: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.bgCard.withValues(alpha: 0.92),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.primaryGlow.withValues(alpha: 0.2)),
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
                            Text('Lv.${authState.user?.level ?? 1}     ${authState.user?.points ?? 0} pts',
                                style: const TextStyle(fontFamily: 'Outfit', color: AppColors.textMuted, fontSize: 11)),
                          ],
                        ),
                      ],
                    ),
                    const Spacer(),
                    // Area status badge (Bebas Radius Uji Coba)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.success.withValues(alpha: 0.5)),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.check_circle_rounded, color: AppColors.success, size: 12),
                          SizedBox(width: 4),
                          Text('Mode Uji Coba', style: TextStyle(fontFamily: 'Outfit', fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.success)),
                        ],
                      ),
                    ),
                  ],
                ),
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
                  color: AppColors.danger.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.danger.withValues(alpha: 0.5)),
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
    // Unlimited Testing Mode: All spawn points are 100% tappable regardless of distance
    const tappable = true;
    final rarity = sp.species?.rarity ?? 'common';
    final color = rarityColor(rarity);

    return Marker(
      point: LatLng(sp.latitude, sp.longitude),
      width: 56,
      height: 56,
      child: GestureDetector(
        onTap: () {
          context.go('/capture/${sp.id}', extra: {
            'species_name': sp.species?.name ?? 'Monster',
            'species_thumbnail': sp.species?.thumbnailUrl,
            'rarity': rarity,
            'item_id': 1,
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withValues(alpha: 0.25),
            border: Border.all(color: color, width: 2.5),
            boxShadow: [BoxShadow(color: color.withValues(alpha: 0.6), blurRadius: 14, spreadRadius: 3)],
          ),
          child: Icon(Icons.pets, color: color, size: 26),
        ),
      ),
    );
  }
}
