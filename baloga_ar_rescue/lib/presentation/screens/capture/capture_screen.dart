import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:baloga_ar_rescue/data/services/capture_service.dart';
import 'package:baloga_ar_rescue/core/theme/app_theme.dart';

// Flame game for capture scene
class CaptureGame extends FlameGame with PanDetector {
  final int spawnPointId;
  final double userLat;
  final double userLng;
  final int itemId;
  final String speciesName;
  final String rarity;
  final void Function(Map<String, dynamic>) onResult;

  late RectangleComponent monsterBounds;
  late CircleComponent ekoBall;
  Offset? _dragStart;
  bool _thrown = false;

  CaptureGame({
    required this.spawnPointId,
    required this.userLat,
    required this.userLng,
    required this.itemId,
    required this.speciesName,
    required this.rarity,
    required this.onResult,
  });

  @override
  Color backgroundColor() => AppColors.bgDark;

  @override
  Future<void> onLoad() async {
    // Monster silhouette (placeholder circle)
    final color = rarityColor(rarity);
    monsterBounds = RectangleComponent(
      position: Vector2(size.x / 2 - 70, size.y * 0.18),
      size: Vector2(140, 180),
      paint: Paint()..color = Colors.transparent,
    );

    final monsterGlow = CircleComponent(
      radius: 80,
      position: Vector2(size.x / 2, size.y * 0.3),
      anchor: Anchor.center,
      paint: Paint()..color = color.withOpacity(0.18),
    );

    final monsterIcon = CircleComponent(
      radius: 60,
      position: Vector2(size.x / 2, size.y * 0.3),
      anchor: Anchor.center,
      paint: Paint()..color = color.withOpacity(0.8),
    );

    // Bobbing idle animation
    monsterGlow.add(MoveEffect.by(
      Vector2(0, -14),
      EffectController(duration: 1.2, reverseDuration: 1.2, infinite: true, curve: Curves.easeInOut),
    ));
    monsterIcon.add(MoveEffect.by(
      Vector2(0, -14),
      EffectController(duration: 1.2, reverseDuration: 1.2, infinite: true, curve: Curves.easeInOut),
    ));

    // Eko-Sphere ball
    ekoBall = CircleComponent(
      radius: 26,
      position: Vector2(size.x / 2, size.y * 0.82),
      anchor: Anchor.center,
      paint: Paint()..color = AppColors.accentBlue,
    );
    ekoBall.add(CircleComponent(
      radius: 10,
      position: Vector2(8, 8),
      paint: Paint()..color = Colors.white.withOpacity(0.35),
    ));

    await addAll([monsterBounds, monsterGlow, monsterIcon, ekoBall]);
  }

  @override
  void onPanStart(DragStartInfo info) {
    if (_thrown) return;
    _dragStart = Offset(info.eventPosition.global.x, info.eventPosition.global.y);
  }

  @override
  void onPanEnd(DragEndInfo info) {
    if (_dragStart == null || _thrown) return;
    _thrown = true;

    final endX = ekoBall.position.x;
    final endY = ekoBall.position.y;
    final centerX = size.x / 2;
    final monsterY = size.y * 0.3;

    // Check if swipe trajectory hits monster bounding box
    final hitMonster = (endX - centerX).abs() < 80 && endY < monsterY + 100;

    if (hitMonster) {
      // Hit animation
      ekoBall.add(MoveEffect.to(
        Vector2(size.x / 2, size.y * 0.3),
        EffectController(duration: 0.4, curve: Curves.easeOut),
        onComplete: () {
          ekoBall.add(ScaleEffect.to(
            Vector2(0.1, 0.1),
            EffectController(duration: 0.3),
            onComplete: () => onResult({'hit': true}),
          ));
        },
      ));
    } else {
      // Miss animation
      ekoBall.add(MoveEffect.by(
        Vector2((Random().nextBool() ? 1 : -1) * 100, 80),
        EffectController(duration: 0.5, curve: Curves.easeIn),
        onComplete: () {
          ekoBall.position = Vector2(size.x / 2, size.y * 0.82);
          _thrown = false;
          _dragStart = null;
          ekoBall.scale = Vector2.all(1);
        },
      ));
    }
  }

  @override
  void onPanUpdate(DragUpdateInfo info) {
    if (_thrown) return;
    ekoBall.position = Vector2(info.eventPosition.global.x, info.eventPosition.global.y);
  }
}

// CaptureScreen widget
class CaptureScreen extends ConsumerStatefulWidget {
  final int spawnPointId;
  final Map<String, dynamic>? extra;

  const CaptureScreen({super.key, required this.spawnPointId, this.extra});

  @override
  ConsumerState<CaptureScreen> createState() => _CaptureScreenState();
}

class _CaptureScreenState extends ConsumerState<CaptureScreen> {
  bool _isProcessing = false;
  String? _resultMessage;
  bool? _success;
  Map<String, dynamic>? _resultData;

  Future<void> _onBallHit() async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);

    try {
      final svc = CaptureService();
      final result = await svc.attemptCapture(
        spawnPointId: widget.spawnPointId,
        lat: -7.892543, // actual GPS in production from locationProvider
        lng: 112.548972,
        itemId: widget.extra?['item_id'] ?? 1,
      );

      setState(() {
        _success = result['success'] == true;
        _resultMessage = result['message'];
        _resultData = result;
        _isProcessing = false;
      });
    } catch (e) {
      setState(() {
        _success = false;
        _resultMessage = 'Terjadi kesalahan koneksi. Coba lagi.';
        _isProcessing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final speciesName = widget.extra?['species_name'] ?? 'Monster';
    final rarity = widget.extra?['rarity'] ?? 'common';
    final rarColor = rarityColor(rarity);

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: Stack(
        children: [
          // Game canvas
          if (_resultMessage == null)
            GameWidget(
              game: CaptureGame(
                spawnPointId: widget.spawnPointId,
                userLat: -7.892543,
                userLng: 112.548972,
                itemId: widget.extra?['item_id'] ?? 1,
                speciesName: speciesName,
                rarity: rarity,
                onResult: (r) {
                  if (r['hit'] == true) _onBallHit();
                },
              ),
            ),

          // HUD overlay
          if (_resultMessage == null)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => context.go('/map'),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(color: AppColors.bgCard.withOpacity(0.8), shape: BoxShape.circle),
                          child: const Icon(Icons.close, color: AppColors.textPrimary, size: 20),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(speciesName, style: const TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.w800, color: AppColors.textPrimary, fontSize: 18)),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(color: rarColor.withOpacity(0.2), borderRadius: BorderRadius.circular(6)),
                            child: Text(rarity.toUpperCase(), style: TextStyle(fontFamily: 'Outfit', fontSize: 10, fontWeight: FontWeight.w700, color: rarColor)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // Instructions at bottom
          if (_resultMessage == null)
            Positioned(
              bottom: 36,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.bgCard.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const Text(
                    '🌀 Swipe Eko-Sphere ke arah monster!',
                    style: TextStyle(fontFamily: 'Outfit', fontSize: 13, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),

          // Processing indicator
          if (_isProcessing)
            Container(
              color: Colors.black54,
              child: const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(AppColors.primaryGlow))),
            ),

          // Result modal
          if (_resultMessage != null)
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    (_success == true ? AppColors.primary : AppColors.danger).withOpacity(0.3),
                    AppColors.bgDark,
                  ],
                ),
              ),
              child: SafeArea(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Result icon
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: (_success == true ? AppColors.success : AppColors.danger).withOpacity(0.2),
                            border: Border.all(color: _success == true ? AppColors.success : AppColors.danger, width: 2),
                          ),
                          child: Icon(_success == true ? Icons.check_circle_outline : Icons.cancel_outlined, size: 52, color: _success == true ? AppColors.success : AppColors.danger),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          _success == true ? 'BERHASIL!' : 'GAGAL!',
                          style: TextStyle(
                            fontFamily: 'Outfit',
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                            color: _success == true ? AppColors.success : AppColors.danger,
                            letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(_resultMessage ?? '', textAlign: TextAlign.center, style: const TextStyle(fontFamily: 'Outfit', fontSize: 15, color: AppColors.textPrimary)),

                        // XP & Points earned
                        if (_success == true && _resultData != null) ...[
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _statChip(Icons.bolt, '+${_resultData!['earned_xp']} XP', AppColors.accentGold),
                              const SizedBox(width: 12),
                              _statChip(Icons.stars, '+${_resultData!['earned_points']} Pts', AppColors.primaryGlow),
                            ],
                          ),
                          if (_resultData!['is_new_species'] == true) ...[
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: AppColors.accentPurple.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.accentPurple.withOpacity(0.5)),
                              ),
                              child: const Text('✨ Spesies Baru Ditemukan!', style: TextStyle(fontFamily: 'Outfit', color: AppColors.accentPurple, fontWeight: FontWeight.w700)),
                            ),
                          ],
                        ],

                        const SizedBox(height: 32),
                        ElevatedButton.icon(
                          onPressed: () => context.go('/map'),
                          icon: const Icon(Icons.map),
                          label: const Text('Kembali ke Peta', style: TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.w700)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryLight,
                            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _statChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(fontFamily: 'Outfit', color: color, fontWeight: FontWeight.w700, fontSize: 14)),
        ],
      ),
    );
  }
}

