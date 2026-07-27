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
          ekoSpheres: 15,
          berries: 30,
          radars: 5,
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

  void addItems({int spheres = 0, int berries = 0, int radars = 0}) {
    state = state.copyWith(
      ekoSpheres: state.ekoSpheres + spheres,
      berries: state.berries + berries,
      radars: state.radars + radars,
    );
  }

  void addCapturedSpecies(SpeciesModel species) {
    // Add captured species and award +3 bonus Eko-Spheres & +5 bonus Berries for successful rescue!
    final updated = List<SpeciesModel>.from(state.capturedSpecies)..add(species);
    state = state.copyWith(
      capturedSpecies: updated,
      ekoSpheres: state.ekoSpheres + 3,
      berries: state.berries + 5,
    );
  }
}

final inventoryProvider = StateNotifierProvider<InventoryNotifier, InventoryState>((ref) {
  return InventoryNotifier();
});
