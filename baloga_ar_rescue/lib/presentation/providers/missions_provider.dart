import 'package:flutter_riverpod/flutter_riverpod.dart';

class MissionModel {
  final int id;
  final String title;
  final String description;
  final String type; // 'daily' or 'weekly'
  final int targetCount;
  final int currentProgress;
  final int xpReward;
  final int pointsReward;
  final bool isCompleted;
  final bool canClaim;

  MissionModel({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.targetCount,
    required this.currentProgress,
    required this.xpReward,
    required this.pointsReward,
    required this.isCompleted,
    required this.canClaim,
  });

  MissionModel copyWith({
    int? currentProgress,
    bool? isCompleted,
    bool? canClaim,
  }) {
    return MissionModel(
      id: id,
      title: title,
      description: description,
      type: type,
      targetCount: targetCount,
      currentProgress: currentProgress ?? this.currentProgress,
      xpReward: xpReward,
      pointsReward: pointsReward,
      isCompleted: isCompleted ?? this.isCompleted,
      canClaim: canClaim ?? this.canClaim,
    );
  }
}

class MissionsNotifier extends StateNotifier<List<MissionModel>> {
  MissionsNotifier()
      : super([
          MissionModel(
            id: 1,
            title: 'Penyelamat Pertama Rozitech',
            description: 'Selamatkan 1 spesies hewan atau objek di kawasan Rozitech',
            type: 'daily',
            targetCount: 1,
            currentProgress: 1,
            xpReward: 100,
            pointsReward: 250,
            isCompleted: false,
            canClaim: true,
          ),
          MissionModel(
            id: 2,
            title: 'Pencinta Flora Baloga',
            description: 'Temukan 3 tumbuhan langka (Lidah Mertua, Bayam Duri, Saga Rambat)',
            type: 'daily',
            targetCount: 3,
            currentProgress: 2,
            xpReward: 250,
            pointsReward: 500,
            isCompleted: false,
            canClaim: false,
          ),
          MissionModel(
            id: 3,
            title: 'Master Ekosistem Rozitech',
            description: 'Selamatkan 10 spesies berbeda di sekitar lokasi Rozitech',
            type: 'weekly',
            targetCount: 10,
            currentProgress: 6,
            xpReward: 1000,
            pointsReward: 2000,
            isCompleted: false,
            canClaim: false,
          ),
          MissionModel(
            id: 4,
            title: 'Patroli Ranger Rutin',
            description: 'Lakukan pemindaian AR kamera 5 kali di area target',
            type: 'weekly',
            targetCount: 5,
            currentProgress: 5,
            xpReward: 500,
            pointsReward: 1000,
            isCompleted: false,
            canClaim: true,
          ),
        ]);

  // Permanently claim mission reward (ONLY ONCE per mission!)
  bool claimReward(int missionId) {
    bool claimed = false;
    final List<MissionModel> updatedList = [];

    for (final m in state) {
      if (m.id == missionId && m.canClaim && !m.isCompleted) {
        claimed = true;
        updatedList.add(m.copyWith(isCompleted: true, canClaim: false));
      } else {
        updatedList.add(m);
      }
    }

    if (claimed) {
      state = updatedList;
    }
    return claimed;
  }

  // Increment mission progress when user rescues a species
  void incrementCaptureProgress() {
    final List<MissionModel> updatedList = [];

    for (final m in state) {
      if (!m.isCompleted) {
        final newProgress = (m.currentProgress + 1).clamp(0, m.targetCount);
        final ready = newProgress >= m.targetCount;
        updatedList.add(m.copyWith(currentProgress: newProgress, canClaim: ready));
      } else {
        updatedList.add(m);
      }
    }

    state = updatedList;
  }
}

final missionsProvider = StateNotifierProvider<MissionsNotifier, List<MissionModel>>((ref) {
  return MissionsNotifier();
});
