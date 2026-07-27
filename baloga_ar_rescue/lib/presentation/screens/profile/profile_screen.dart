import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:baloga_ar_rescue/presentation/providers/auth_provider.dart';
import 'package:baloga_ar_rescue/data/models/user_model.dart';
import 'package:baloga_ar_rescue/core/theme/app_theme.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  void _showEditProfileModal(BuildContext context, WidgetRef ref, UserModel user) {
    final nameCtrl = TextEditingController(text: user.name);

    final avatarOptions = [
      'https://api.dicebear.com/7.x/bottts/svg?seed=Ranger',
      'https://api.dicebear.com/7.x/bottts/svg?seed=EcoHero',
      'https://api.dicebear.com/7.x/bottts/svg?seed=BalogaMaster',
      'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=200',
      'https://images.unsplash.com/photo-1570295999919-56ceb5ecca61?w=200',
      'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=200',
    ];

    String selectedAvatar = user.avatarUrl ?? avatarOptions[0];

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.bgCard,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctxState, setModalState) => Padding(
          padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Container(width: 44, height: 4, decoration: BoxDecoration(color: Colors.white30, borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 16),

              const Text(
                'EDIT PROFIL RANGER',
                style: TextStyle(fontFamily: 'Outfit', fontSize: 18, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 1.1),
              ),
              const SizedBox(height: 4),
              const Text(
                'Ubah nama tampilan & pilih avatar foto profil Ranger Anda',
                style: TextStyle(fontFamily: 'Outfit', fontSize: 12, color: AppColors.textMuted),
              ),
              const SizedBox(height: 16),

              // Name Field
              const Text('Nama Lengkap / Panggilan', style: TextStyle(fontFamily: 'Outfit', fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 6),
              TextField(
                controller: nameCtrl,
                style: const TextStyle(fontFamily: 'Outfit', color: Colors.white, fontSize: 14),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppColors.bgSurface,
                  hintText: 'Masukkan nama Ranger...',
                  hintStyle: const TextStyle(fontFamily: 'Outfit', color: AppColors.textMuted, fontSize: 13),
                  prefixIcon: const Icon(Icons.person, color: AppColors.primaryGlow),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 16),

              // Avatar Selection Grid
              const Text('Pilih Avatar Foto Profil', style: TextStyle(fontFamily: 'Outfit', fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 10),
              SizedBox(
                height: 70,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: avatarOptions.length,
                  itemBuilder: (c, i) {
                    final url = avatarOptions[i];
                    final isSel = selectedAvatar == url;

                    return GestureDetector(
                      onTap: () => setModalState(() => selectedAvatar = url),
                      child: Container(
                        margin: const EdgeInsets.only(right: 12),
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSel ? AppColors.primaryGlow : Colors.transparent,
                            width: 3,
                          ),
                        ),
                        child: CircleAvatar(
                          radius: 26,
                          backgroundColor: AppColors.bgSurface,
                          backgroundImage: NetworkImage(url),
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 20),

              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    final newName = nameCtrl.text.trim();
                    if (newName.isNotEmpty) {
                      ref.read(authProvider.notifier).updateProfile(name: newName, avatarUrl: selectedAvatar);
                      Navigator.pop(ctx);

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          backgroundColor: AppColors.primaryGlow,
                          content: Text(
                            '✅ Profil Ranger berhasil diperbarui!',
                            style: TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.save_rounded, size: 20),
                  label: const Text(
                    'SIMPAN PERUBAHAN',
                    style: TextStyle(fontFamily: 'Outfit', fontSize: 13, fontWeight: FontWeight.w900, letterSpacing: 1),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGlow,
                    foregroundColor: AppColors.bgDark,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.user ??
        UserModel(
          id: 1,
          name: 'Ranger Baloga',
          email: 'ranger@baloga.com',
          avatarUrl: 'https://api.dicebear.com/7.x/bottts/svg?seed=Ranger',
          level: 3,
          xp: 450,
          points: 1450,
          speciesFound: 6,
          badgesCount: 3,
        );

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        backgroundColor: AppColors.bgDark,
        elevation: 0,
        title: const Text(
          'PROFIL RANGER EKOLOGI',
          style: TextStyle(fontFamily: 'Outfit', fontSize: 18, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 1.2),
        ),
        actions: [
          IconButton(
            onPressed: () => _showEditProfileModal(context, ref, user),
            icon: const Icon(Icons.edit_note_rounded, color: AppColors.primaryGlow, size: 26),
            tooltip: 'Edit Profil',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 24),
        child: Column(
          children: [
            _ProfileHeaderCard(
              user: user,
              onEdit: () => _showEditProfileModal(context, ref, user),
              onLogout: () async {
                await ref.read(authProvider.notifier).logout();
                if (context.mounted) context.go('/login');
              },
            ),

            _StatsRow(user: user),

            _XpProgressSection(user: user),

            const SizedBox(height: 16),

            _BadgesGridSection(),
          ],
        ),
      ),
    );
  }
}

class _ProfileHeaderCard extends StatelessWidget {
  final UserModel user;
  final VoidCallback onEdit;
  final VoidCallback onLogout;

  const _ProfileHeaderCard({required this.user, required this.onEdit, required this.onLogout});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.primaryGlow.withValues(alpha: 0.4), width: 1.5),
        boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 15)],
      ),
      child: Column(
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: onEdit,
                child: Stack(
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.primaryGlow, width: 3),
                        boxShadow: [BoxShadow(color: AppColors.primaryGlow.withValues(alpha: 0.5), blurRadius: 16)],
                      ),
                      child: ClipOval(
                        child: user.avatarUrl != null && user.avatarUrl!.startsWith('http')
                            ? CachedNetworkImage(
                                imageUrl: user.avatarUrl!,
                                fit: BoxFit.cover,
                                placeholder: (c, u) => const Icon(Icons.person, color: AppColors.primaryGlow, size: 40),
                                errorWidget: (c, u, e) => const Icon(Icons.person, color: AppColors.primaryGlow, size: 40),
                              )
                            : const Icon(Icons.person, color: AppColors.primaryGlow, size: 40),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(color: AppColors.primaryGlow, shape: BoxShape.circle),
                        child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 12),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.name,
                      style: const TextStyle(fontFamily: 'Outfit', fontSize: 18, fontWeight: FontWeight.w900, color: Colors.white),
                    ),
                    Text(
                      user.email,
                      style: const TextStyle(fontFamily: 'Outfit', fontSize: 12, color: AppColors.textMuted),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primaryGlow,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'RANGER LV.${user.level}',
                        style: const TextStyle(fontFamily: 'Outfit', fontSize: 11, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 1.1),
                      ),
                    ),
                  ],
                ),
              ),

              IconButton(
                onPressed: onLogout,
                icon: const Icon(Icons.logout_rounded, color: AppColors.danger, size: 22),
                tooltip: 'Logout',
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Tombol Edit Profil Quick Bar
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onEdit,
              icon: const Icon(Icons.edit_rounded, size: 16, color: AppColors.primaryGlow),
              label: const Text(
                'EDIT PROFIL & FOTO AVATAR',
                style: TextStyle(fontFamily: 'Outfit', fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.primaryGlow, letterSpacing: 0.8),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.primaryGlow),
                padding: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
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
          _StatItemCard(icon: Icons.pets_rounded, label: 'Spesies', value: user.speciesFound.toString(), color: AppColors.primaryGlow),
          const SizedBox(width: 10),
          _StatItemCard(icon: Icons.monetization_on_rounded, label: 'Poin', value: user.points.toString(), color: AppColors.accentGold),
          const SizedBox(width: 10),
          _StatItemCard(icon: Icons.emoji_events_rounded, label: 'Badge', value: user.badgesCount.toString(), color: AppColors.accentPurple),
        ],
      ),
    );
  }
}

class _StatItemCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatItemCard({required this.icon, required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.35), width: 1.2),
          boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 8)],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 6),
            Text(value, style: TextStyle(fontFamily: 'Outfit', fontSize: 20, fontWeight: FontWeight.w900, color: color)),
            Text(label, style: const TextStyle(fontFamily: 'Outfit', fontSize: 11, color: AppColors.textMuted)),
          ],
        ),
      ),
    );
  }
}

class _XpProgressSection extends StatelessWidget {
  final UserModel user;
  const _XpProgressSection({required this.user});

  @override
  Widget build(BuildContext context) {
    final xpForNext = (user.level * 250);
    final pct = (user.xp / xpForNext).clamp(0.0, 1.0);

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.accentGold.withValues(alpha: 0.4), width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('PROGRESS RANGER XP', style: TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.w800, fontSize: 13, color: Colors.white)),
              Text('${user.xp} / $xpForNext XP', style: const TextStyle(fontFamily: 'Outfit', fontSize: 12, fontWeight: FontWeight.w900, color: AppColors.accentGold)),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: pct,
              minHeight: 10,
              backgroundColor: AppColors.bgSurface,
              valueColor: const AlwaysStoppedAnimation(AppColors.accentGold),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${((1 - pct) * xpForNext).round()} XP lagi untuk naik ke Ranger Lv.${user.level + 1}',
            style: const TextStyle(fontFamily: 'Outfit', fontSize: 11, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}

class _BadgesGridSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final badges = [
      {'icon': Icons.eco_rounded, 'name': 'Penyelamat Muda', 'desc': 'Menangkap spesies pertama', 'color': AppColors.primaryGlow, 'unlocked': true},
      {'icon': Icons.pets_rounded, 'name': 'Pelindung Satwa', 'desc': 'Menangkap 5 spesies hewan', 'color': AppColors.accentBlue, 'unlocked': true},
      {'icon': Icons.local_florist_rounded, 'name': 'Botanis Baloga', 'desc': 'Menangkap 5 flora langka', 'color': AppColors.primaryLight, 'unlocked': true},
      {'icon': Icons.stars_rounded, 'name': 'Master Rozitech', 'desc': 'Menyelamatkan 10 spesies', 'color': AppColors.accentGold, 'unlocked': true},
      {'icon': Icons.military_tech_rounded, 'name': 'Pilihan Utama', 'desc': 'Meraih 5000 Poin Ranger', 'color': AppColors.accentPurple, 'unlocked': true},
      {'icon': Icons.radar_rounded, 'name': 'Pakar Ekologi', 'desc': 'Melakukan 20 scan AR', 'color': AppColors.rarityLegendary, 'unlocked': true},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'KOLEKSI BADGE EKOLOGI',
            style: TextStyle(fontFamily: 'Outfit', fontSize: 15, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 1.1),
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.85,
            ),
            itemCount: badges.length,
            itemBuilder: (ctx, i) {
              final b = badges[i];
              final color = b['color'] as Color;
              final unlocked = b['unlocked'] as bool;

              return Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: unlocked ? color.withValues(alpha: 0.12) : AppColors.bgSurface.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: unlocked ? color.withValues(alpha: 0.5) : AppColors.textMuted.withValues(alpha: 0.2),
                    width: 1.2,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(b['icon'] as IconData, color: unlocked ? color : Colors.grey, size: 32),
                    const SizedBox(height: 6),
                    Text(
                      b['name'] as String,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'Outfit',
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: unlocked ? color : Colors.grey,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
