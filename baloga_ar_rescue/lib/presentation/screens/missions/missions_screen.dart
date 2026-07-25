import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:baloga_ar_rescue/data/services/mission_service.dart';
import 'package:baloga_ar_rescue/core/theme/app_theme.dart';

final missionsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  return MissionService().getMissions();
});

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

  Future<void> _claimMission(int id) async {
    try {
      await MissionService().claimMission(id);
      ref.invalidate(missionsProvider);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🎉 Reward berhasil diklaim!', style: TextStyle(fontFamily: 'Outfit')),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal klaim: $e', style: const TextStyle(fontFamily: 'Outfit')), backgroundColor: AppColors.danger),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final missionsAsync = ref.watch(missionsProvider);

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Misi', style: TextStyle(fontFamily: 'Outfit', fontSize: 28, fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
                  Text('Selesaikan misi untuk XP & reward', style: TextStyle(fontFamily: 'Outfit', fontSize: 13, color: AppColors.textMuted)),
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(color: AppColors.bgCard, borderRadius: BorderRadius.circular(14)),
                    child: TabBar(
                      controller: _tabCtrl,
                      labelStyle: const TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.w700, fontSize: 13),
                      unselectedLabelStyle: const TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.w400, fontSize: 13),
                      labelColor: AppColors.primaryGlow,
                      unselectedLabelColor: AppColors.textMuted,
                      indicator: BoxDecoration(color: AppColors.primaryGlow.withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
                      dividerColor: Colors.transparent,
                      tabs: const [Tab(text: '📅 Harian'), Tab(text: '📆 Mingguan')],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            Expanded(
              child: missionsAsync.when(
                data: (missions) {
                  final daily = missions.where((m) => m['type'] == 'daily').toList();
                  final weekly = missions.where((m) => m['type'] == 'weekly').toList();
                  return TabBarView(
                    controller: _tabCtrl,
                    children: [
                      _MissionList(missions: daily, onClaim: _claimMission),
                      _MissionList(missions: weekly, onClaim: _claimMission),
                    ],
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(AppColors.primaryGlow))),
                error: (e, _) => Center(child: Text('Gagal memuat misi: $e', style: const TextStyle(fontFamily: 'Outfit', color: AppColors.danger))),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MissionList extends StatelessWidget {
  final List<Map<String, dynamic>> missions;
  final Future<void> Function(int) onClaim;

  const _MissionList({required this.missions, required this.onClaim});

  @override
  Widget build(BuildContext context) {
    if (missions.isEmpty) {
      return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.check_circle_outline, color: AppColors.primaryGlow, size: 52),
        const SizedBox(height: 12),
        Text('Semua misi selesai!', style: TextStyle(fontFamily: 'Outfit', fontSize: 16, color: AppColors.textMuted)),
      ]));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: missions.length,
      itemBuilder: (ctx, i) => _MissionCard(mission: missions[i], onClaim: onClaim),
    );
  }
}

class _MissionCard extends StatelessWidget {
  final Map<String, dynamic> mission;
  final Future<void> Function(int) onClaim;

  const _MissionCard({required this.mission, required this.onClaim});

  @override
  Widget build(BuildContext context) {
    final progress = (mission['current_progress'] as num? ?? 0).toInt();
    final target = (mission['target_count'] as num? ?? 1).toInt();
    final isCompleted = mission['is_completed'] == true;
    final canClaim = mission['can_claim'] == true;
    final pct = (progress / target).clamp(0.0, 1.0);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCompleted ? AppColors.success.withOpacity(0.4) : canClaim ? AppColors.accentGold.withOpacity(0.5) : AppColors.textMuted.withOpacity(0.15),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: AppColors.primaryGlow.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                child: Icon(isCompleted ? Icons.check_circle : Icons.assignment_outlined, color: isCompleted ? AppColors.success : AppColors.primaryGlow, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(mission['title'] ?? '', style: const TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.textPrimary)),
                    Text(mission['description'] ?? '', style: TextStyle(fontFamily: 'Outfit', fontSize: 12, color: AppColors.textMuted)),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: AppColors.accentGold.withOpacity(0.12), borderRadius: BorderRadius.circular(8)),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.bolt, color: AppColors.accentGold, size: 12),
                    const SizedBox(width: 2),
                    Text('+${mission['xp_reward']} XP', style: const TextStyle(fontFamily: 'Outfit', fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.accentGold)),
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
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: pct,
                    minHeight: 7,
                    backgroundColor: AppColors.bgSurface,
                    valueColor: AlwaysStoppedAnimation(pct >= 1.0 ? AppColors.success : AppColors.primaryGlow),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text('$progress/$target', style: const TextStyle(fontFamily: 'Outfit', fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
            ],
          ),

          if (canClaim) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => onClaim(mission['id']),
                icon: const Icon(Icons.card_giftcard, size: 16),
                label: const Text('Klaim Reward!', style: TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.w700, fontSize: 13)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accentGold,
                  foregroundColor: AppColors.bgDark,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
          ],

          if (isCompleted) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.check_circle, color: AppColors.success, size: 14),
                const SizedBox(width: 4),
                Text('Reward sudah diklaim', style: TextStyle(fontFamily: 'Outfit', fontSize: 12, color: AppColors.success)),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

