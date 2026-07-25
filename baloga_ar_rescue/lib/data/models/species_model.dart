class SpeciesModel {
  final int id;
  final String name;
  final String latinName;
  final String category;
  final String rarity;
  final String habitat;
  final String? food;
  final String ecologicalRole;
  final String conservationStatus;
  final String funFact;
  final String? model3dUrl;
  final String? thumbnailUrl;
  final int baseCp;
  final bool isDiscovered;

  SpeciesModel({
    required this.id,
    required this.name,
    required this.latinName,
    required this.category,
    required this.rarity,
    required this.habitat,
    this.food,
    required this.ecologicalRole,
    required this.conservationStatus,
    required this.funFact,
    this.model3dUrl,
    this.thumbnailUrl,
    required this.baseCp,
    required this.isDiscovered,
  });

  factory SpeciesModel.fromJson(Map<String, dynamic> json) => SpeciesModel(
        id: json['id'],
        name: json['name'],
        latinName: json['latin_name'],
        category: json['category'],
        rarity: json['rarity'],
        habitat: json['habitat'],
        food: json['food'],
        ecologicalRole: json['ecological_role'],
        conservationStatus: json['conservation_status'],
        funFact: json['fun_fact'],
        model3dUrl: json['model_3d_url'],
        thumbnailUrl: json['thumbnail_url'],
        baseCp: json['base_cp'] ?? 100,
        isDiscovered: json['is_discovered'] ?? false,
      );
}
