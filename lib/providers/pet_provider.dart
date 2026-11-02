
import 'package:flutter/foundation.dart';
import 'package:pet_app/models/pet.dart';

/* kelas provider */
class PetProvider extends ChangeNotifier {
  /* properti */
  // private internal state
  final List<Pet> _pets = [
    const Pet(id: "1", name: "luna", species: "cat", isFavorite: false),
    const Pet(id: "2", name: "milo", species: "dog", isFavorite: true),
    const Pet(id: "3", name: "pip", species: "bird", isFavorite: false),
  ];

  /* metode */
  // public getter to expose an unmodifiable list
  List<Pet> get pets {
    return List.unmodifiable(_pets);
  }
  // public getter to count favorite
  int get favoriteCount {
    return _pets.where((p) {
      return p.isFavorite;
    }).length;
  }
  // business logic favorite
  void toggleFavorite(String petId) {
    final index = _pets.indexWhere((test) {
      return test.id == petId;
    });
    if (index != -1) {
      _pets[index] = _pets[index].copyWith(
        isFavorite: !_pets[index].isFavorite
      );
    }
    // key method: informs all active listeners to rebuild!
    notifyListeners();
  }
  // business logic adding the pet
  void addPet(Pet newPet) {
    _pets.add(newPet);
    notifyListeners();
  }
}
