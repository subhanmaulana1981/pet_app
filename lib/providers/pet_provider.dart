
import 'package:flutter/foundation.dart';
import 'package:pet_app/models/pet.dart';
import 'package:pet_app/services/pet_api_service.dart';

/* kelas provider */
class PetProvider extends ChangeNotifier {
  /* properti(es) */
  // online service
  final PetApiService _apiService;
  // loading
  bool _isLoading = false;
  // error message
  String? _errorMesage;
  // private internal state
  List<Pet> _pets = [];
  // track currently active species filter
  String _selectedSpecies = 'all';
  // track currently active search query
  String _searchQuery = '';

  /* konstruksi */
  // dependency injection
  PetProvider({
    PetApiService? apiService
  }) : _apiService = apiService ?? PetApiService();

  /* metode */
  // getter for current search query
  String get searchQuery {
    return _searchQuery;
  }
  // getter for ui chips to know which one is selected
  String get selectedSpecies {
    return _selectedSpecies;
  }
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
  // getting loading
  bool get isLoading {
    return _isLoading;
  }
  // getting error message
  String? get errorMessage {
    return _errorMesage;
  }

  /* business logics */
  // 10. clear all pets from database
  Future<void> clearAllPets() async {
    _isLoading = true;
    _errorMesage = null;
    notifyListeners();

    try {
      await _apiService.clearAllPets();
      _pets = [];

    } catch (e) {
      _errorMesage = e.toString();
      rethrow;

    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 9. seed sample pets (reset or append)
  Future<void> seedPets({bool clean = false}) async {
    _isLoading = true;
    _errorMesage = null;
    notifyListeners();

    try {
      await _apiService.seedPets(clean: clean);
      await loadPets();

    } catch (e) {
      _errorMesage = e.toString();
      rethrow;

    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 8. delete pet via api with optimistic rollback
  Future<void> deletePet(String petId) async {
    final index = _pets.indexWhere((p) {
      return p.id == petId;
    });

    // 1. optimistic removal
    final removedPet = _pets.removeAt(index);
    notifyListeners();

    try {
      // 2. call backend
      await _apiService.deletePet(petId);

    } catch (e) {
      // 3. rollback if backend failed
      _pets.insert(index, removedPet);
      _errorMesage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  // 7. update existing pet via api
  Future<void> updatePet(String petId, Pet updatedData) async {
    _isLoading = true;
    _errorMesage = null;
    notifyListeners();

    try {
      final savedPet = await _apiService.updatePet(petId, updatedData);

      // find index of the pet and replace it
      final index = _pets.indexWhere((p) {
        return p.id ==petId;
      });
      if (index != -1) {
        _pets[index] = savedPet;
      }

    } catch (e) {
      _errorMesage = e.toString();
      rethrow;

    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  // 6. quick helper to clear search
  Future<void> clearSearch() async {
    _searchQuery = '';
    await loadPets();
  }
  // 5. called when user submits the search bar
  Future<void> searchPets(String query) async {
    _searchQuery = query.trim();
    await loadPets();
  }
  // 4. called when user taps a filter chip
  Future<void> filterBySpecies(String species) async {
    // avoid duplicate fetch
    if (_selectedSpecies == species) {
      return;
    }
    _selectedSpecies = species;
    await loadPets();
  }

  // 3. toggle favorite with optimistic update and rollback
  Future<void> toggleFavorite(String petId) async {
    final index = _pets.indexWhere((test) {
      return test.id == petId;
    });
    if (index == -1) return;

    // 1. optimistic update: flip immediately in ui
    final originalPet = _pets[index];
    _pets[index] = originalPet.copyWith(
      isFavorite: !originalPet.isFavorite
    );
    // key method: informs all active listeners to rebuild!
    notifyListeners();

    try {
      // 2. call the backend
      final updatedPet = await _apiService.toggleFavorite(petId);
      // sync with response data from server
      _pets[index] = updatedPet;
      notifyListeners();

    } catch (e) {
      // 3. rollback if the network request fails
      _pets[index] = originalPet;
      _errorMesage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  // 2. adding the pet via api
  Future<void> addPet(Pet newPet) async {
    _isLoading = true;
    _errorMesage = null;
    notifyListeners();

    try {
      final savedPet = await _apiService.createPet(newPet);
      // add to the top of the list
      _pets.insert(0, savedPet);

    } catch (e) {
      _errorMesage = e.toString();
      // rethrow so the ui can catch
      // and show an error snackBar
      rethrow;

    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 1. fetch all pets from api
  Future<void> loadPets() async {
    _isLoading = true;
    _errorMesage = null;
    notifyListeners();

    try {
      _pets = await _apiService.getPets(
        species: _selectedSpecies,
        search: _searchQuery,
      );

    } catch(e) {
      _errorMesage = e.toString();

    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
