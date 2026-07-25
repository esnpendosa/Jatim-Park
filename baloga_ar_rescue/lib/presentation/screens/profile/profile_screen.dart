import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:baloga_ar_rescue/presentation/providers/auth_provider.dart';
import 'package:baloga_ar_rescue/data/models/user_model.dart';
import 'package:baloga_ar_rescue/core/theme/app_theme.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.user;

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: SafeArea(
        child: user == null
            ? const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(AppColors.primaryGlow)))
            : CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(child: _ProfileHeader(user: user, onLogout: () => _logout(context, ref))),
                  SliverToBoxAdapter(child: _StatsRow(user: user)),
                  SliverToBoxAdapter(child: _XpSection(user: user)),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                    sliver: SliverToBoxAdapter(child: _BadgesSection()),
                  ),
                ],
              ),
      ),
    );
  }

  Future<void> _logout(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.bgCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Keluar?', style: TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        content: const Text('Kamu yakin ingin keluar dari Baloga AR Rescue?', style: TextStyle(fontFamily: 'Outfit', color: AppColors.textSecondary)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal', style: TextStyle(fontFamily: 'Outfit', color: AppColors.textMuted))),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            child: const Text('Keluar', style: TextStyle(fontFamily: 'Outfit')),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(authProvider.notifier).logout();
      if (context.mounted) Navigator.of(context).pushNamedAndRemoveUntil('/login', (r) => false);
    }
  }
}

class _ProfileHeader extends StatelessWidget {
  final UserModel user;
  final VoidCallback onLogout;
  const _ProfileHeader({required this.user, required this.onLogout});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.bgCard, AppColors.bgSurface],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primaryGlow.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primaryGlow, width: 2.5),
              boxShadow: [BoxShadow(color: AppColors.primaryGlow.withOpacity(0.3), blurRadius: 16)],
            ),
            child: ClipOval(
              child: user.avatarUrl != null && user.avatarUrl!.startsWith('http')
                  ? Image.network(user.avatarUrl!, fit: BoxFit.cover, errorBuilder: (c, e, s) => const Icon(Icons.person, color: AppColors.primaryGlow, size: 40))
                  : const Icon(Icons.person, color: AppColors.primaryGlow, size: 40),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user.name, style: const TextStyle(fontFamily: 'Outfit', fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                Text(user.email, style: TextStyle(fontFamily: 'Outfit', fontSize: 12, color: AppColors.textMuted)),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [AppColors.primary, AppColors.primaryLight]),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text('RANGER LV.${user.level}', style: const TextStyle(fontFamily: 'Outfit', fontSize: 11, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: 1)),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onLogout,
            icon: const Icon(Icons.logout, color: AppColors.textMuted, size: 20),
            tooltip: 'Logout',
          ),
        ],
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  final UserModel user;
  const _StatsRow({required this.user});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          _StatCard(icon: Icons.eco, label: 'Spesies', value: user.speciesFound.toString(), color: AppColors.primaryGlow),
          const SizedBox(width: 10),
          _StatCard(icon: Icons.stars, label: 'Poin', value: user.points.toString(), color: AppColors.accentGold),
          const SizedBox(width: 10),
          _StatCard(icon: Icons.emoji_events, label: 'Badge', value: user.badgesCount.toString(), color: AppColors.accentPurple),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  const _StatCard({required this.icon, required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.25)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 6),
            Text(value, style: TextStyle(fontFamily: 'Outfit', fontSize: 20, fontWeight: FontWeight.w900, color: color)),
            Text(label, style: TextStyle(fontFamily: 'Outfit', fontSize: 11, color: AppColors.textMuted)),
          ],
        ),
      ),
    );
  }
}

class _XpSection extends StatelessWidget {
  final UserModel user;
  const _XpSection({required this.user});

  @override
  Widget build(BuildContext context) {
    final xpForNext = (user.level * 200);
    final pct = (user.xp / xpForNext).clamp(0.0, 1.0);

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.accentGold.withOpacity(0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Progress XP', style: TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.textPrimary)),
              Text('${user.xp} / $xpForNext XP', style: const TextStyle(fontFamily: 'Outfit', fontSize: 12, color: AppColors.accentGold)),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: pct,
              minHeight: 10,
              backgroundColor: AppColors.bgSurface,
              valueColor: const AlwaysStoppedAnimation(AppColors.accentGold),
            ),
          ),
          const SizedBox(height: 6),
          Text('${((1 - pct) * xpForNext).round()} XP lagi menuju Lv.${user.level + 1}',
              style: TextStyle(fontFamily: 'Outfit', fontSize: 11, color: AppColors.textMuted)),
        ],
      ),
    );
  }
}

class _BadgesSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final badges = [
      {'icon': Icons.eco, 'name': 'Penyelamat Muda', 'color': AppColors.primaryGlow},
      {'icon': Icons.pets, 'name': 'Pelindung Satwa', 'color': AppColors.accentBlue},
      {'icon': Icons.local_florist, 'name': 'Botanis Baloga', 'color': AppColors.primaryLight},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 16),
          child: Text('Badge Terkini', style: TextStyle(fontFamily: 'Outfit', fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
        ),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, mainAxisSpacing: 10, crossAxisSpacing: 10, childAspectRatio: 0.9),
          itemCount: badges.length,
          itemBuilder: (ctx, i) {
            final b = badges[i];
            final color = b['color'] as Color;
            return Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: color.withOpacity(0.3)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(b['icon'] as IconData, color: color, size: 32),
                  const SizedBox(height: 6),
                  Text(b['name'] as String, textAlign: TextAlign.center, maxLines: 2,
                      style: TextStyle(fontFamily: 'Outfit', fontSize: 10, fontWeight: FontWeight.w600, color: color)),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

