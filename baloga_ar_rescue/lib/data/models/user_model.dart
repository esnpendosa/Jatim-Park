class UserModel {
  final int id;
  final String name;
  final String email;
  final String? avatarUrl;
  final int level;
  final int xp;
  final int points;
  final int speciesFound;
  final int badgesCount;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.avatarUrl,
    required this.level,
    required this.xp,
    required this.points,
    required this.speciesFound,
    required this.badgesCount,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id'],
        name: json['name'],
        email: json['email'],
        avatarUrl: json['avatar_url'],
        level: json['level'] ?? 1,
        xp: json['xp'] ?? 0,
        points: json['points'] ?? 0,
        speciesFound: json['species_found'] ?? 0,
        badgesCount: json['badges_count'] ?? 0,
      );

  UserModel copyWith({
    int? id,
    String? name,
    String? email,
    String? avatarUrl,
    int? level,
    int? xp,
    int? points,
    int? speciesFound,
    int? badgesCount,
  }) =>
      UserModel(
        id: id ?? this.id,
        name: name ?? this.name,
        email: email ?? this.email,
        avatarUrl: avatarUrl ?? this.avatarUrl,
        level: level ?? this.level,
        xp: xp ?? this.xp,
        points: points ?? this.points,
        speciesFound: speciesFound ?? this.speciesFound,
        badgesCount: badgesCount ?? this.badgesCount,
      );
}
