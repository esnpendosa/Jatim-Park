import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:baloga_ar_rescue/presentation/providers/location_provider.dart';
import 'package:baloga_ar_rescue/core/theme/app_theme.dart';

class HomeShell extends ConsumerWidget {
  final Widget child;
  const HomeShell({super.key, required this.child});

  int _getIndex(BuildContext context) {
    final loc = GoRouterState.of(context).uri.path;
    if (loc.startsWith('/map')) return 0;
    if (loc.startsWith('/inventory')) return 1;
    if (loc.startsWith('/capture')) return 2;
    if (loc.startsWith('/missions')) return 3;
    if (loc.startsWith('/profile')) return 4;
    return 0;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final idx = _getIndex(context);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (idx != 0) {
          // System back button returns to Beranda / Peta (/map) instead of exiting app!
          context.go('/map');
        } else {
          if (context.canPop()) {
            context.pop();
          }
        }
      },
      child: Scaffold(
        body: child,
        bottomNavigationBar: Container(
          height: 76,
          decoration: BoxDecoration(
            color: const Color(0xFF0A1810),
            border: Border(top: BorderSide(color: AppColors.primaryGlow.withValues(alpha: 0.25), width: 1.5)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.6),
                blurRadius: 25,
                offset: const Offset(0, -8),
              ),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  // 1. Beranda / Peta
                  _NavItem(
                    icon: Icons.home_filled,
                    activeIcon: Icons.home_filled,
                    label: 'Beranda',
                    index: 0,
                    current: idx,
                    onTap: () => context.go('/map'),
                  ),

                  // 2. Inventori
                  _NavItem(
                    icon: Icons.inventory_2_outlined,
                    activeIcon: Icons.inventory_2,
                    label: 'Inventori',
                    index: 1,
                    current: idx,
                    onTap: () => context.go('/inventory'),
                  ),

                  // 3. CENTER BIG GLOWING SCAN BUTTON (Auto-detects nearest species in real-time)
                  GestureDetector(
                    onTap: () {
                      final spawnPointsAsync = ref.read(spawnPointsProvider);
                      final points = spawnPointsAsync.asData?.value ?? [];
                      final nearestSp = points.isNotEmpty ? points.first : null;
                      final species = nearestSp?.species;

                      context.go('/capture/${nearestSp?.id ?? 101}', extra: {
                        'species_id': species?.id ?? 2,
                        'species_name': species?.name ?? 'Sandal Selop Karet Pria',
                        'species_latin': species?.latinName ?? 'Footwear Rubber Craft',
                        'species_thumbnail': species?.thumbnailUrl ?? 'assets/Sandal Selop Karet Pria.jpg',
                        'species_fact': species?.funFact ?? 'Perlengkapan kaki tahan air buatan lokal untuk patroli lapangan.',
                        'base_cp': species?.baseCp ?? 650,
                        'rarity': species?.rarity ?? 'rare',
                        'item_id': 1,
                      });
                    },
                    child: Container(
                      transform: Matrix4.translationValues(0, -10, 0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 54,
                            height: 54,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(
                                colors: [AppColors.primaryLight, AppColors.primaryGlow],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              border: Border.all(color: Colors.white.withValues(alpha: 0.9), width: 2.5),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primaryGlow.withValues(alpha: 0.7),
                                  blurRadius: 18,
                                  spreadRadius: 3,
                                ),
                              ],
                            ),
                            child: const Center(
                              child: Icon(Icons.qr_code_scanner_rounded, color: Colors.white, size: 28),
                            ),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'Scan',
                            style: TextStyle(
                              fontFamily: 'Outfit',
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              color: AppColors.primaryGlow,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // 4. Misi
                  _NavItem(
                    icon: Icons.assignment_outlined,
                    activeIcon: Icons.assignment_turned_in,
                    label: 'Misi',
                    index: 3,
                    current: idx,
                    onTap: () => context.go('/missions'),
                  ),

                  // 5. Profil
                  _NavItem(
                    icon: Icons.person_outline,
                    activeIcon: Icons.person,
                    label: 'Profil',
                    index: 4,
                    current: idx,
                    onTap: () => context.go('/profile'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final int index;
  final int current;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.index,
    required this.current,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = index == current;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isActive ? activeIcon : icon,
              color: isActive ? AppColors.primaryGlow : AppColors.textMuted,
              size: 22,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Outfit',
                fontSize: 10,
                fontWeight: isActive ? FontWeight.w800 : FontWeight.w500,
                color: isActive ? AppColors.primaryGlow : AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
