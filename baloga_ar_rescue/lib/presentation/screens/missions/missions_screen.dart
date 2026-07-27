import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:baloga_ar_rescue/presentation/providers/auth_provider.dart';
import 'package:baloga_ar_rescue/core/theme/app_theme.dart';

class MissionsScreen extends ConsumerStatefulWidget {
  const MissionsScreen({super.key});

  @override
  ConsumerState<MissionsScreen> createState() => _MissionsScreenState();
}

class _MissionsScreenState extends ConsumerState<MissionsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  void _claimMission(int id, int xpReward, int pointsReward) {
    ref.read(authProvider.notifier).addPointsAndXp(pointsReward, xpReward);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.primaryGlow,
        content: Text(
          '🎉 REWARD DIKLAIM SINKRON! +$xpReward XP & +$pointsReward Poin berhasil ditambahkan!',
          style: const TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final missionsList = [
      {
        'id': 1,
        'title': 'Penyelamat Pertama Rozitech',
        'description': 'Selamatkan 1 spesies hewan atau objek di kawasan Rozitech',
        'type': 'daily',
        'target_count': 1,
        'current_progress': 1,
        'xp_reward': 100,
        'points_reward': 250,
        'is_completed': false,
        'can_claim': true,
      },
      {
        'id': 2,
        'title': 'Pencinta Flora Baloga',
        'description': 'Temukan 3 tumbuhan langka (Lidah Mertua, Bayam Duri, Saga Rambat)',
        'type': 'daily',
        'target_count': 3,
        'current_progress': 2,
        'xp_reward': 250,
        'points_reward': 500,
        'is_completed': false,
        'can_claim': false,
      },
      {
        'id': 3,
        'title': 'Master Ekosistem Rozitech',
        'description': 'Selamatkan 10 spesies berbeda di sekitar lokasi Rozitech',
        'type': 'weekly',
        'target_count': 10,
        'current_progress': 6,
        'xp_reward': 1000,
        'points_reward': 2000,
        'is_completed': false,
        'can_claim': false,
      },
      {
        'id': 4,
        'title': 'Patroli Ranger Rutin',
        'description': 'Lakukan pemindaian AR kamera 5 kali di area target',
        'type': 'weekly',
        'target_count': 5,
        'current_progress': 5,
        'xp_reward': 500,
        'points_reward': 1000,
        'is_completed': false,
        'can_claim': true,
      },
    ];

    final dailyMissions = missionsList.where((m) => m['type'] == 'daily').toList();
    final weeklyMissions = missionsList.where((m) => m['type'] == 'weekly').toList();

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        backgroundColor: AppColors.bgDark,
        elevation: 0,
        title: const Text(
          'MISI RANGER EKOLOGI',
          style: TextStyle(fontFamily: 'Outfit', fontSize: 18, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 1.2),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Selesaikan misi harian & mingguan untuk mendapatkan XP dan Poin!',
                  style: TextStyle(fontFamily: 'Outfit', fontSize: 13, color: AppColors.textMuted),
                ),
                const SizedBox(height: 14),
                Container(
                  decoration: BoxDecoration(color: AppColors.bgCard, borderRadius: BorderRadius.circular(14)),
                  child: TabBar(
                    controller: _tabCtrl,
                    labelStyle: const TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.w800, fontSize: 13),
                    unselectedLabelStyle: const TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.w500, fontSize: 13),
                    labelColor: AppColors.primaryGlow,
                    unselectedLabelColor: AppColors.textMuted,
                    indicator: BoxDecoration(color: AppColors.primaryGlow.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10)),
                    dividerColor: Colors.transparent,
                    tabs: const [Tab(text: '📅 MISI HARIAN'), Tab(text: '📆 MISI MINGGUAN')],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          Expanded(
            child: TabBarView(
              controller: _tabCtrl,
              children: [
                _MissionListView(missions: dailyMissions, onClaim: _claimMission),
                _MissionListView(missions: weeklyMissions, onClaim: _claimMission),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MissionListView extends StatefulWidget {
  final List<Map<String, dynamic>> missions;
  final void Function(int id, int xp, int points) onClaim;

  const _MissionListView({required this.missions, required this.onClaim});

  @override
  State<_MissionListView> createState() => _MissionListViewState();
}

class _MissionListViewState extends State<_MissionListView> {
  late List<Map<String, dynamic>> _list;

  @override
  void initState() {
    super.initState();
    _list = List.from(widget.missions);
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _list.length,
      itemBuilder: (ctx, i) {
        final mission = _list[i];
        final progress = (mission['current_progress'] as int);
        final target = (mission['target_count'] as int);
        final isCompleted = mission['is_completed'] == true;
        final canClaim = mission['can_claim'] == true;
        final pct = (progress / target).clamp(0.0, 1.0);

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.bgCard,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isCompleted
                  ? AppColors.primaryGlow
                  : canClaim
                      ? AppColors.accentGold
                      : AppColors.textMuted.withValues(alpha: 0.2),
              width: 1.5,
            ),
            boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 8)],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isCompleted ? AppColors.primaryGlow.withValues(alpha: 0.2) : AppColors.accentGold.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      isCompleted ? Icons.check_circle_rounded : Icons.assignment_outlined,
                      color: isCompleted ? AppColors.primaryGlow : AppColors.accentGold,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          mission['title'] as String,
                          style: const TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.w800, fontSize: 14, color: Colors.white),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          mission['description'] as String,
                          style: const TextStyle(fontFamily: 'Outfit', fontSize: 11, color: AppColors.textMuted),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: AppColors.accentGold.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
                    child: Column(
                      children: [
                        Text('+${mission['xp_reward']} XP', style: const TextStyle(fontFamily: 'Outfit', fontSize: 11, fontWeight: FontWeight.w900, color: AppColors.accentGold)),
                        Text('+${mission['points_reward']} Poin', style: const TextStyle(fontFamily: 'Outfit', fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.accentGold)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Progress bar
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: pct,
                        minHeight: 8,
                        backgroundColor: AppColors.bgSurface,
                        valueColor: AlwaysStoppedAnimation(pct >= 1.0 ? AppColors.primaryGlow : AppColors.accentGold),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    '$progress/$target',
                    style: const TextStyle(fontFamily: 'Outfit', fontSize: 12, fontWeight: FontWeight.w900, color: Colors.white),
                  ),
                ],
              ),

              if (canClaim && !isCompleted) ...[
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        _list[i]['can_claim'] = false;
                        _list[i]['is_completed'] = true;
                      });
                      widget.onClaim(
                        mission['id'] as int,
                        mission['xp_reward'] as int,
                        mission['points_reward'] as int,
                      );
                    },
                    icon: const Icon(Icons.card_giftcard_rounded, size: 18),
                    label: const Text(
                      'KLAIM REWARD SEKARANG!',
                      style: TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 1.1),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accentGold,
                      foregroundColor: AppColors.bgDark,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 4,
                    ),
                  ),
                ),
              ],

              if (isCompleted) ...[
                const SizedBox(height: 10),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle_rounded, color: AppColors.primaryGlow, size: 16),
                    SizedBox(width: 6),
                    Text(
                      'REWARD MISI SUDAH DIKLAIM',
                      style: TextStyle(fontFamily: 'Outfit', fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primaryGlow),
                    ),
                  ],
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
