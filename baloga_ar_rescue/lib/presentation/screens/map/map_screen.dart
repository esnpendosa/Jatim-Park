import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:baloga_ar_rescue/presentation/providers/auth_provider.dart';
import 'package:baloga_ar_rescue/presentation/providers/location_provider.dart';
import 'package:baloga_ar_rescue/data/models/spawn_point_model.dart';
import 'package:baloga_ar_rescue/core/theme/app_theme.dart';

enum MapStyle { street, satellite, dark }

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> with SingleTickerProviderStateMixin {
  final MapController _mapController = MapController();
  final LatLng _defaultBalogaPos = const LatLng(-7.892543, 112.548972);
  MapStyle _currentStyle = MapStyle.street;
  late AnimationController _pulseController;
  SpawnPointModel? _selectedTargetMonster;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initLocation();
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _initLocation() {
    ref.read(locationProvider.notifier).init();
    final pos = ref.read(locationProvider).position;
    final target = pos != null ? LatLng(pos.latitude, pos.longitude) : _defaultBalogaPos;
    ref.read(spawnPointsProvider.notifier).startAutoRefresh(target.latitude, target.longitude);
  }

  String getTileUrl() {
    switch (_currentStyle) {
      case MapStyle.satellite:
        return 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}';
      case MapStyle.dark:
        return 'https://a.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}.png';
      case MapStyle.street:
      default:
        return 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
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

  Widget _buildSpeciesImageWidget(String? url, Color color, {double size = 26}) {
    if (url != null && url.startsWith('assets/')) {
      return Image.asset(url, fit: BoxFit.cover);
    }
    return CachedNetworkImage(
      imageUrl: url ?? '',
      fit: BoxFit.cover,
      placeholder: (c, u) => Icon(Icons.pets, color: color, size: size),
      errorWidget: (c, u, e) => Icon(Icons.pets, color: color, size: size),
    );
  }

  void _showStreetViewLandmarkModal(SpawnPointModel sp, double distanceMeters, bool canCapture) {
    setState(() => _selectedTargetMonster = sp);

    final species = sp.species;
    final rarity = species?.rarity ?? 'common';
    final color = rarityColor(rarity);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: const BoxDecoration(
          color: AppColors.bgDark,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          boxShadow: [BoxShadow(color: Colors.black87, blurRadius: 25)],
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 44,
              height: 4,
              decoration: BoxDecoration(color: Colors.white30, borderRadius: BorderRadius.circular(2)),
            ),

            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      children: [
                        Container(
                          height: 200,
                          width: double.infinity,
                          decoration: const BoxDecoration(
                            color: AppColors.bgCard,
                          ),
                          child: _buildSpeciesImageWidget(species?.thumbnailUrl, color, size: 50),
                        ),
                        Container(
                          height: 200,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.black45,
                                AppColors.bgDark.withValues(alpha: 0.95),
                              ],
                            ),
                          ),
                        ),
                        Positioned(
                          top: 14,
                          left: 16,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.25),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: color),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.streetview_rounded, color: color, size: 16),
                                const SizedBox(width: 6),
                                Text(
                                  'LANDMARK STREET VIEW',
                                  style: TextStyle(fontFamily: 'Outfit', color: color, fontSize: 11, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 12,
                          left: 20,
                          child: Row(
                            children: [
                              Container(
                                width: 68,
                                height: 68,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.bgCard,
                                  border: Border.all(color: color, width: 3),
                                  boxShadow: [BoxShadow(color: color.withValues(alpha: 0.5), blurRadius: 15)],
                                ),
                                child: ClipOval(
                                  child: _buildSpeciesImageWidget(species?.thumbnailUrl, color, size: 30),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    species?.name ?? 'Monster Baloga',
                                    style: const TextStyle(fontFamily: 'Outfit', fontSize: 20, fontWeight: FontWeight.w900, color: Colors.white),
                                  ),
                                  Text(
                                    species?.latinName ?? 'Species',
                                    style: const TextStyle(fontFamily: 'Outfit', fontSize: 13, fontStyle: FontStyle.italic, color: AppColors.textMuted),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildStatItem('Rarity', rarity.toUpperCase(), color),
                              _buildStatItem('Base CP', '${species?.baseCp ?? 500} CP', AppColors.accentGold),
                              _buildStatItem('Jarak Realtime', '${distanceMeters.round()} Meter', canCapture ? AppColors.primaryGlow : AppColors.danger),
                            ],
                          ),
                          const SizedBox(height: 18),

                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: canCapture ? AppColors.primaryGlow.withValues(alpha: 0.15) : AppColors.danger.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: canCapture ? AppColors.primaryGlow : AppColors.danger),
                            ),
                            child: Row(
                              children: [
                                Icon(canCapture ? Icons.check_circle_rounded : Icons.lock_clock_rounded, color: canCapture ? AppColors.primaryGlow : AppColors.danger, size: 22),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        canCapture ? 'STATUS: BISA DITANGKAP (< 10 METER)' : 'STATUS: MONSTER TERLALU JAUH',
                                        style: TextStyle(fontFamily: 'Outfit', fontSize: 12, fontWeight: FontWeight.w900, color: canCapture ? AppColors.primaryGlow : AppColors.danger),
                                      ),
                                      Text(
                                        canCapture
                                            ? 'Anda berada di dalam radius tangkap 10 meter. Tekan tombol di bawah untuk masuk mode AR!'
                                            : 'Dekati lokasi monster hingga jarak kurang dari 10 meter untuk dapat menangkapnya.',
                                        style: const TextStyle(fontFamily: 'Outfit', fontSize: 11, color: AppColors.textSecondary),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),

                          const Text('Fakta & Peran Ekologi:', style: TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.bold, color: AppColors.textPrimary, fontSize: 14)),
                          const SizedBox(height: 6),
                          Text(
                            species?.funFact ?? 'Spesies langka yang dilindungi di kawasan Baloga.',
                            style: const TextStyle(fontFamily: 'Outfit', color: AppColors.textSecondary, fontSize: 13, height: 1.4),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: canCapture
                      ? () {
                          Navigator.pop(ctx);
                          context.go('/capture/${sp.id}', extra: {
                            'species_id': species?.id,
                            'species_name': species?.name ?? 'Monster',
                            'species_latin': species?.latinName,
                            'species_thumbnail': species?.thumbnailUrl,
                            'species_fact': species?.funFact,
                            'base_cp': species?.baseCp ?? 500,
                            'rarity': rarity,
                            'item_id': 1,
                            'distance_meters': distanceMeters.round(),
                          });
                        }
                      : () {
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Jarak Anda ${distanceMeters.round()}m. Dekati monster hingga < 10m atau aktifkan Mode Uji Coba!'),
                              backgroundColor: AppColors.danger,
                            ),
                          );
                        },
                  icon: Icon(canCapture ? Icons.center_focus_strong : Icons.lock, size: 22),
                  label: Text(
                    canCapture ? 'TANGKAP SPESIES SEKARANG' : 'DEKATI MONSTER (< 10M)',
                    style: const TextStyle(fontFamily: 'Outfit', fontSize: 15, fontWeight: FontWeight.w900, letterSpacing: 1.5),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: canCapture ? AppColors.primaryLight : Colors.grey.shade700,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: canCapture ? 8 : 0,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text(label, style: const TextStyle(fontFamily: 'Outfit', fontSize: 10, color: AppColors.textMuted)),
          const SizedBox(height: 2),
          Text(value, style: TextStyle(fontFamily: 'Outfit', fontSize: 13, fontWeight: FontWeight.w800, color: color)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final locState = ref.watch(locationProvider);
    final locNotifier = ref.read(locationProvider.notifier);
    final spawnPointsAsync = ref.watch(spawnPointsProvider);
    final authState = ref.watch(authProvider);

    final userLatLng = locState.position != null
        ? LatLng(locState.position!.latitude, locState.position!.longitude)
        : _defaultBalogaPos;

    final headingDeg = locState.position?.heading ?? 0.0;
    final headingRad = headingDeg * pi / 180.0;

    // Trigger realtime refresh whenever user position changes
    ref.listen<LocationState>(locationProvider, (previous, next) {
      if (next.position != null) {
        ref.read(spawnPointsProvider.notifier).refresh(
              next.position!.latitude,
              next.position!.longitude,
            );
      }
    });

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: Stack(
        children: [
          // 1. FREE MAP CANVAS
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: userLatLng,
              initialZoom: 18.0,
              maxZoom: 19.5,
              minZoom: 12.0,
            ),
            children: [
              TileLayer(
                urlTemplate: getTileUrl(),
                userAgentPackageName: 'com.baloga.baloga_ar_rescue',
              ),

              // REALTIME ROUTE POLYLINE PATH TO TARGET MONSTER (Google Maps Style)
              spawnPointsAsync.when(
                data: (points) {
                  if (points.isEmpty) return const SizedBox.shrink();
                  final target = _selectedTargetMonster ?? points.first;
                  final targetLatLng = LatLng(target.latitude, target.longitude);

                  return PolylineLayer(
                    polylines: [
                      Polyline(
                        points: [userLatLng, targetLatLng],
                        strokeWidth: 4.5,
                        color: AppColors.primaryGlow,
                        borderStrokeWidth: 2.0,
                        borderColor: Colors.black.withValues(alpha: 0.6),
                      ),
                    ],
                  );
                },
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),

              // Animated Glowing Radar Pulse Ring
              MarkerLayer(
                markers: [
                  Marker(
                    point: userLatLng,
                    width: 280,
                    height: 280,
                    child: AnimatedBuilder(
                      animation: _pulseController,
                      builder: (ctx, child) {
                        return Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.primaryGlow.withValues(alpha: 0.6 - (_pulseController.value * 0.4)),
                              width: 3 + (_pulseController.value * 8),
                            ),
                            color: AppColors.primaryGlow.withValues(alpha: 0.18 - (_pulseController.value * 0.12)),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),

              // Monster Spawn Markers (Supporting Rozitech Asset Dataset)
              spawnPointsAsync.when(
                data: (points) {
                  final markers = points.map((sp) {
                    final dist = locNotifier.calculateDistanceMeters(
                      userLatLng.latitude,
                      userLatLng.longitude,
                      sp.latitude,
                      sp.longitude,
                    );
                    final canCapture = locState.isTestMode || dist <= 10.0;
                    return _buildMockupCreatureMarker(sp, dist, canCapture);
                  }).toList();

                  return MarkerLayer(markers: markers);
                },
                loading: () => const MarkerLayer(markers: []),
                error: (_, __) => const MarkerLayer(markers: []),
              ),

              // USER REALTIME NAVIGATION ARROW MARKER (Rotates with Device Compass Heading)
              MarkerLayer(
                markers: [
                  Marker(
                    point: userLatLng,
                    width: 48,
                    height: 48,
                    child: Transform.rotate(
                      angle: headingRad,
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.accentBlue,
                          border: Border.all(color: Colors.white, width: 3),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.accentBlue.withValues(alpha: 0.8),
                              blurRadius: 20,
                              spreadRadius: 6,
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Icon(Icons.navigation_rounded, color: Colors.white, size: 24),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          // 2. BANNERS & NOTICES
          SafeArea(
            child: Column(
              children: [
                // Top Header Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Row(
                    children: [
                      // Ranger Avatar
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.bgDark.withValues(alpha: 0.95),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: AppColors.primaryGlow.withValues(alpha: 0.4)),
                          boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 10)],
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 16,
                              backgroundColor: AppColors.primaryGlow,
                              child: ClipOval(
                                child: authState.user?.avatarUrl != null
                                    ? CachedNetworkImage(imageUrl: authState.user!.avatarUrl!, width: 32, height: 32, fit: BoxFit.cover)
                                    : const Icon(Icons.person, size: 20, color: Colors.white),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text('Peta BALOGA', style: TextStyle(fontFamily: 'Outfit', fontSize: 10, color: AppColors.textMuted, fontWeight: FontWeight.bold)),
                                Text(
                                  authState.user?.name ?? 'Ranger',
                                  style: const TextStyle(fontFamily: 'Outfit', fontSize: 13, color: Colors.white, fontWeight: FontWeight.w800),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const Spacer(),

                      // Points Counter Pill
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.bgDark.withValues(alpha: 0.95),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.accentGold.withValues(alpha: 0.6)),
                          boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 10)],
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.monetization_on, color: AppColors.accentGold, size: 18),
                            const SizedBox(width: 6),
                            Text(
                              '${authState.user?.points ?? 2450}',
                              style: const TextStyle(fontFamily: 'Outfit', fontSize: 14, fontWeight: FontWeight.w900, color: AppColors.accentGold),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // GPS Warning Banner
                if (!locState.isGpsEnabled || !locState.hasPermission || locState.error != null)
                  Container(
                    margin: const EdgeInsets.only(left: 12, right: 76, top: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.danger.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 10)],
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.location_off_rounded, color: Colors.white, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            locState.error ?? 'Aktifkan GPS Anda!',
                            style: const TextStyle(fontFamily: 'Outfit', fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () => locNotifier.startTracking(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: AppColors.danger,
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: const Text('AKTIFKAN', style: TextStyle(fontFamily: 'Outfit', fontSize: 10, fontWeight: FontWeight.w900)),
                        ),
                      ],
                    ),
                  ),

                // Outside Area Notice (Constrained to avoid overlapping right drawer)
                if (!locState.isInJatimPark && locState.isGpsEnabled)
                  Container(
                    margin: const EdgeInsets.only(left: 12, right: 76, top: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.bgDark.withValues(alpha: 0.95),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.accentGold.withValues(alpha: 0.6)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_rounded, color: AppColors.accentGold, size: 18),
                        const SizedBox(width: 6),
                        const Expanded(
                          child: Text(
                            'Area Rozitech (Mode Uji Coba)',
                            style: TextStyle(fontFamily: 'Outfit', fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => locNotifier.toggleTestMode(),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                            decoration: BoxDecoration(
                              color: locState.isTestMode ? AppColors.primaryGlow : Colors.grey.shade800,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              locState.isTestMode ? 'TEST: ON' : 'TEST: OFF',
                              style: const TextStyle(fontFamily: 'Outfit', fontSize: 9, fontWeight: FontWeight.w900, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),

          // 3. SLEEK RIGHT ACTION DRAWER
          Positioned(
            top: 90,
            right: 12,
            child: Column(
              children: [
                _buildSleekActionBtn(Icons.radar_rounded, 'Radar', AppColors.primaryGlow, () {
                  _mapController.move(userLatLng, 18.0);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Radar Ekologi Aktif: Memindai spesies di sekitar'), duration: Duration(seconds: 1)),
                  );
                }),
                _buildSleekActionBtn(Icons.assignment_turned_in_rounded, 'Misi', AppColors.accentGold, () {
                  context.go('/missions');
                }),
                _buildSleekActionBtn(Icons.menu_book_rounded, 'Katalog', AppColors.accentBlue, () {
                  context.go('/encyclopedia');
                }),
                _buildSleekActionBtn(Icons.storefront_rounded, 'Toko', AppColors.rarityLegendary, () {
                  context.go('/inventory');
                }),
                _buildSleekActionBtn(Icons.emoji_events_rounded, 'Peringkat', AppColors.accentPurple, () {
                  context.go('/profile');
                }),
                _buildSleekActionBtn(
                  _currentStyle == MapStyle.satellite ? Icons.satellite_alt_rounded : Icons.map_rounded,
                  'Tile',
                  AppColors.textSecondary,
                  () {
                    setState(() {
                      if (_currentStyle == MapStyle.street) {
                        _currentStyle = MapStyle.satellite;
                      } else if (_currentStyle == MapStyle.satellite) {
                        _currentStyle = MapStyle.dark;
                      } else {
                        _currentStyle = MapStyle.street;
                      }
                    });
                  },
                ),
                _buildSleekActionBtn(Icons.my_location_rounded, 'Lokasi', AppColors.primaryGlow, () {
                  _mapController.move(userLatLng, 18.0);
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSleekActionBtn(IconData icon, String label, Color color, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 58,
          padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 4),
          decoration: BoxDecoration(
            color: const Color(0xFF122018).withValues(alpha: 0.95),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color.withValues(alpha: 0.45), width: 1.2),
            boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 8, offset: Offset(0, 3))],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(height: 3),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 9.5,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Marker _buildMockupCreatureMarker(SpawnPointModel sp, double distanceMeters, bool canCapture) {
    final species = sp.species;
    final rarity = species?.rarity ?? 'common';
    final color = rarityColor(rarity);

    return Marker(
      point: LatLng(sp.latitude, sp.longitude),
      width: 72,
      height: 72,
      child: GestureDetector(
        onTap: () => _showStreetViewLandmarkModal(sp, distanceMeters, canCapture),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.bgDark,
                border: Border.all(color: canCapture ? color : Colors.grey, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: (canCapture ? color : Colors.grey).withValues(alpha: 0.7),
                    blurRadius: canCapture ? 16 : 4,
                    spreadRadius: canCapture ? 4 : 1,
                  ),
                ],
              ),
              child: ClipOval(
                child: ColorFiltered(
                  colorFilter: canCapture
                      ? const ColorFilter.mode(Colors.transparent, BlendMode.dst)
                      : const ColorFilter.mode(Colors.grey, BlendMode.saturation),
                  child: _buildSpeciesImageWidget(species?.thumbnailUrl, color, size: 26),
                ),
              ),
            ),

            // Distance Badge
            Positioned(
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: canCapture ? AppColors.primaryGlow : Colors.black87,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white, width: 1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (!canCapture) ...[
                      const Icon(Icons.lock, color: Colors.white, size: 9),
                      const SizedBox(width: 2),
                    ],
                    Text(
                      canCapture ? '<10m' : '${distanceMeters.round()}m',
                      style: const TextStyle(fontFamily: 'Outfit', fontSize: 9, fontWeight: FontWeight.w900, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
