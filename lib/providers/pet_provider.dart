
import 'package:flutter/foundation.dart';
import 'package:pet_app/models/pet.dart';
import 'package:pet_app/services/pet_api_service.dart';

/* kelas provider */
class PetProvider extends ChangeNotifier {
  /* properti(es) */
  // online service
  final PetApiService _apiService;
  bool _isLoading = false;
  String? _errorMesage;

  // konstruksi
  // dependency injection
  PetProvider({
    PetApiService? apiService
  }) : _apiService = apiService ?? PetApiService();

  // private internal state
  List<Pet> _pets = [];

  /* metode */
  // public getters to expose an unmodifiable list
  List<Pet> get pets {
    return List.unmodifiable(_pets);
  }
  // public getter to count favorite
  int get favoriteCount {
    return _pets.where((p) {
      return p.isFavorite;
    }).length;
  }
  // loading
  bool get isLoading {
    return _isLoading;
  }
  // error message
  String? get errorMessage {
    return _errorMesage;
  }

  /* business logics */
  // 1. fetch all pets from api
  Future<void> loadPets() async {
    _isLoading = true;
    _errorMesage = null;
    notifyListeners();

    try {
      _pets = await _apiService.getPets();

    } catch(e) {
      _errorMesage = e.toString();

    } finally {
      _isLoading = false;
      notifyListeners();
    }
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
