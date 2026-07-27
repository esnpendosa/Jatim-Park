import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:baloga_ar_rescue/presentation/providers/auth_provider.dart';
import 'package:baloga_ar_rescue/presentation/providers/missions_provider.dart';
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

  void _claimMission(MissionModel mission) {
    final notifier = ref.read(missionsProvider.notifier);
    final success = notifier.claimReward(mission.id);

    if (success) {
      ref.read(authProvider.notifier).addPointsAndXp(mission.pointsReward, mission.xpReward);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.primaryGlow,
          content: Text(
            'REWARD MISI DIKLAIM: +${mission.xpReward} XP & +${mission.pointsReward} Poin ditambahkan!',
            style: const TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppColors.danger,
          content: Text(
            'Reward misi ini sudah diklaim sebelumnya!',
            style: TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final allMissions = ref.watch(missionsProvider);
    final dailyMissions = allMissions.where((m) => m.type == 'daily').toList();
    final weeklyMissions = allMissions.where((m) => m.type == 'weekly').toList();

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
                    tabs: const [Tab(text: 'MISI HARIAN'), Tab(text: 'MISI MINGGUAN')],
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

class _MissionListView extends StatelessWidget {
  final List<MissionModel> missions;
  final void Function(MissionModel mission) onClaim;

  const _MissionListView({required this.missions, required this.onClaim});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: missions.length,
      itemBuilder: (ctx, i) {
        final mission = missions[i];
        final progress = mission.currentProgress;
        final target = mission.targetCount;
        final isCompleted = mission.isCompleted;
        final canClaim = mission.canClaim && !isCompleted;
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
                          mission.title,
                          style: const TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.w800, fontSize: 14, color: Colors.white),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          mission.description,
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
                        Text('+${mission.xpReward} XP', style: const TextStyle(fontFamily: 'Outfit', fontSize: 11, fontWeight: FontWeight.w900, color: AppColors.accentGold)),
                        Text('+${mission.pointsReward} Poin', style: const TextStyle(fontFamily: 'Outfit', fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.accentGold)),
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

              if (canClaim) ...[
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => onClaim(mission),
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
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGlow.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.primaryGlow.withValues(alpha: 0.3)),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle_rounded, color: AppColors.primaryGlow, size: 16),
                      SizedBox(width: 6),
                      Text(
                        'REWARD MISI SUDAH DIKLAIM (SELESAI)',
                        style: TextStyle(fontFamily: 'Outfit', fontSize: 11, fontWeight: FontWeight.w900, color: AppColors.primaryGlow),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
