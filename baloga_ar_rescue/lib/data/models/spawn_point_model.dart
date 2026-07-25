import 'package:baloga_ar_rescue/data/models/species_model.dart';

class SpawnPointModel {
  final int id;
  final int speciesId;
  final double latitude;
  final double longitude;
  final bool active;
  final int respawnMinutes;
  final double? distanceMeters;
  final bool? isTappable;
  final SpeciesModel? species;

  SpawnPointModel({
    required this.id,
    required this.speciesId,
    required this.latitude,
    required this.longitude,
    required this.active,
    required this.respawnMinutes,
    this.distanceMeters,
    this.isTappable,
    this.species,
  });

  factory SpawnPointModel.fromJson(Map<String, dynamic> json) => SpawnPointModel(
        id: json['id'],
        speciesId: json['species_id'],
        latitude: (json['latitude'] as num).toDouble(),
        longitude: (json['longitude'] as num).toDouble(),
        active: json['active'] ?? true,
        respawnMinutes: json['respawn_minutes'] ?? 15,
        distanceMeters: (json['distance_meters'] as num?)?.toDouble(),
        isTappable: json['is_tappable'],
        species: json['species'] != null ? SpeciesModel.fromJson(json['species']) : null,
      );
}

