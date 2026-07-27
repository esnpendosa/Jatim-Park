import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:baloga_ar_rescue/data/models/species_model.dart';

class InventoryState {
  final int ekoSpheres;
  final int berries;
  final int radars;
  final List<SpeciesModel> capturedSpecies;

  InventoryState({
    required this.ekoSpheres,
    required this.berries,
    required this.radars,
    required this.capturedSpecies,
  });

  InventoryState copyWith({
    int? ekoSpheres,
    int? berries,
    int? radars,
    List<SpeciesModel>? capturedSpecies,
  }) {
    return InventoryState(
      ekoSpheres: ekoSpheres ?? this.ekoSpheres,
      berries: berries ?? this.berries,
      radars: radars ?? this.radars,
      capturedSpecies: capturedSpecies ?? this.capturedSpecies,
    );
  }
}

class InventoryNotifier extends StateNotifier<InventoryState> {
  InventoryNotifier()
      : super(InventoryState(
          ekoSpheres: 12,
          berries: 25,
          radars: 3,
          capturedSpecies: [
            SpeciesModel(
              id: 2,
              name: 'Sandal Selop Karet Pria',
              latinName: 'Footwear Rubber Craft',
              category: 'hewan',
              rarity: 'rare',
              habitat: 'Markas Ranger Rozitech',
              food: 'Karet Alam',
              ecologicalRole: 'Perlengkapan wajib jalan kaki Ranger',
              conservationStatus: 'Siap Pakai',
              baseCp: 650,
              thumbnailUrl: 'assets/Sandal Selop Karet Pria.jpg',
              funFact: 'Perlengkapan kaki tahan air buatan lokal untuk patroli lapangan.',
              isDiscovered: true,
            ),
            SpeciesModel(
              id: 1,
              name: 'Honda PCX 160',
              latinName: 'Motorcycle PCX 160cc',
              category: 'hewan',
              rarity: 'epic',
              habitat: 'Kawasan Rozitech Office',
              food: 'Pertamax Turbo',
              ecologicalRole: 'Kendaraan operasional utama Ranger Rozitech',
              conservationStatus: 'Aktif Beroperasi',
              baseCp: 1250,
              thumbnailUrl: 'assets/Honda PCX 160.jpg',
              funFact: 'Kendaraan matic premium armada survey lokasi Rozitech.',
              isDiscovered: true,
            ),
          ],
        ));

  bool useEkoSphere() {
    if (state.ekoSpheres > 0) {
      state = state.copyWith(ekoSpheres: state.ekoSpheres - 1);
      return true;
    }
    return false;
  }

  bool useBerry() {
    if (state.berries > 0) {
      state = state.copyWith(berries: state.berries - 1);
      return true;
    }
    return false;
  }

  void addCapturedSpecies(SpeciesModel species) {
    final updated = List<SpeciesModel>.from(state.capturedSpecies)..add(species);
    state = state.copyWith(capturedSpecies: updated);
  }
}

final inventoryProvider = StateNotifierProvider<InventoryNotifier, InventoryState>((ref) {
  return InventoryNotifier();
});
