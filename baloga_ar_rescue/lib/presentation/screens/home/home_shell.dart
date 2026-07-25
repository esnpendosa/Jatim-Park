import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:baloga_ar_rescue/core/theme/app_theme.dart';

class HomeShell extends StatelessWidget {
  final Widget child;
  const HomeShell({super.key, required this.child});

  int _getIndex(BuildContext context) {
    final loc = GoRouterState.of(context).uri.path;
    if (loc.startsWith('/map')) return 0;
    if (loc.startsWith('/encyclopedia')) return 1;
    if (loc.startsWith('/missions')) return 2;
    if (loc.startsWith('/inventory')) return 3;
    if (loc.startsWith('/profile')) return 4;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final idx = _getIndex(context);
    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          border: Border(top: BorderSide(color: AppColors.primaryGlow.withOpacity(0.15), width: 1)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.4), blurRadius: 20, offset: const Offset(0, -5))],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavItem(icon: Icons.map_outlined, activeIcon: Icons.map, label: 'Peta', index: 0, current: idx, onTap: () => context.go('/map')),
                _NavItem(icon: Icons.menu_book_outlined, activeIcon: Icons.menu_book, label: 'Ensiklopedia', index: 1, current: idx, onTap: () => context.go('/encyclopedia')),
                _NavItem(icon: Icons.emoji_events_outlined, activeIcon: Icons.emoji_events, label: 'Misi', index: 2, current: idx, onTap: () => context.go('/missions')),
                _NavItem(icon: Icons.inventory_2_outlined, activeIcon: Icons.inventory_2, label: 'Inventori', index: 3, current: idx, onTap: () => context.go('/inventory')),
                _NavItem(icon: Icons.person_outline, activeIcon: Icons.person, label: 'Profil', index: 4, current: idx, onTap: () => context.go('/profile')),
              ],
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

  const _NavItem({required this.icon, required this.activeIcon, required this.label, required this.index, required this.current, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isActive = index == current;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primaryGlow.withOpacity(0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(isActive ? activeIcon : icon, color: isActive ? AppColors.primaryGlow : AppColors.textMuted, size: 22),
            const SizedBox(height: 3),
            Text(label, style: TextStyle(fontFamily: 'Outfit', fontSize: 10, fontWeight: isActive ? FontWeight.w700 : FontWeight.w400, color: isActive ? AppColors.primaryGlow : AppColors.textMuted)),
          ],
        ),
      ),
    );
  }
}

