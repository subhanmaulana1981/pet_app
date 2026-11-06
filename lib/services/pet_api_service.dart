
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pet_app/models/pet.dart';

class PetApiService {
  // replace with your active ngrok url
  // (without trailing slash)
  static const String baseUrl = 'https://slacking-chummy-giblet.ngrok-free.dev';

  // headers required for ngrok and json endpoints
  static const Map<String, String> _headers = {
    'Content-Type': 'application/json; charset=UTF-8',
    'Accept': 'application/json',
    'ngrok-skip-browser-warning': 'true',
  };

  // 3. PATCH /api/pets/:id/favorite
  Future<Pet> toggleFavorite(String id) async {
    final uri = Uri.parse('$baseUrl/api/pets/$id/favorite');
    final response = await http.patch(
      uri,
      headers: _headers
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonBody = jsonDecode(response.body);
      final dynamic data = jsonBody['data'];

      return Pet.fromJson(data as Map<String, dynamic>);

    } else {
      throw Exception('failed to update favorite (status: ${response.statusCode})');
    }
  }

  // 2. POST /api/pets
  Future<Pet> createPet(Pet pet) async {
    final uri = Uri.parse('$baseUrl/api/pets');
    final response = await http.post(
      uri,
      headers: _headers,
      body: jsonEncode(pet.toJson()),
    );

    if (response.statusCode == 201) {
      final Map<String, dynamic> jsonBody = jsonDecode(response.body);
      final dynamic data = jsonBody['data'];

      return Pet.fromJson(data as Map<String, dynamic>);

    } else {
      throw Exception('failed to add pet (status: ${response.statusCode})');
    }
  }

  // 1. GET /api/pets
  Future<List<Pet>> getPets({String? species, String? search}) async {
    // base uri
    var uri = Uri.parse('$baseUrl/api/pets');

    /* query parameters */
    // build query parameter map dynamically
    final Map<String, String> queryParams = {};
    // attach query parameters
    // species and search
    if (species != null && species.isNotEmpty && species.toLowerCase() != 'all') {
      queryParams['species'] = species.toLowerCase();
    }
    if (search != null && search.trim().isNotEmpty) {
      queryParams['search'] = search.trim();
    }
    // attach query parameters if any exist
    if (queryParams.isNotEmpty) {
      uri = uri.replace(queryParameters: queryParams);
    }

    // response
    final response = await http.get(uri, headers: _headers);
    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonBody = jsonDecode(response.body);
      final List<dynamic> data = jsonBody['data'] as List<dynamic>;

      return data.map((item) {
        return Pet.fromJson(item as Map<String, dynamic>);
      }).toList();

    } else {
      throw Exception(
        'failed to fetch pets (status: ${response.statusCode})'
      );
    }
  }
}
