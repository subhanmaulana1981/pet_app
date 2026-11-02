
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
}
