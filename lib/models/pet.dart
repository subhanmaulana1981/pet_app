
/* kelas pet */
class Pet {

  /* properties */
  final String id;
  final String name;
  final String species;
  final bool isFavorite;
  final String? image;

  /* konstruksi */
  const Pet({
    required this.id,
    required this.name,
    required this.species,
    this.isFavorite = false,
    this.image
  });

  /* metode */
  // copyWith
  Pet copyWith({
    String? id,
    String? name,
    String? species,
    bool? isFavorite,
    String? image,
  }) {
    return Pet(
      id: id ?? this.id,
      name: name ?? this.name,
      species: species ?? this.species,
      isFavorite: isFavorite ?? this.isFavorite,
      image: image ?? this.image
    );
  }

  // factory constructor to deserialize api response
  factory Pet.fromJson(Map<String, dynamic> json) {
    return Pet(
      id: json['id'] ?? json['id'] ?? '',
      name: json['name'] as String? ?? '',
      species: json['species'] as String? ?? '',
      isFavorite: json['isFavorite'] as bool? ?? false,
      image: json['image'] as String?
    );
  }

  // serialize to json for post / put payloads
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'species': species,
      'isFavorite': isFavorite,
      if (image != null) 'image': image
    };
  }
}
