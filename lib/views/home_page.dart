
import 'package:flutter/material.dart';
import 'package:pet_app/providers/pet_provider.dart';
import 'package:pet_app/views/add_pet_page.dart';
import 'package:provider/provider.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({
    super.key,
    required this.title
  });

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  static const List<String> _speciesList = [
    'all',
    'cat',
    'dog',
    'rabbit',
    'bird',
    'fish',
    'poultry',
    'wild',
  ];

  Widget _buildSpeciesFilter(BuildContext context, PetProvider provider) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 8.0
      ),
      child: Row(
        children: _speciesList.map((species) {
          final isSelected = provider.selectedSpecies == species;
          final label = species[0].toUpperCase() + species.substring(1);

          return Padding(
            padding: EdgeInsets.only(right: 8.0),
            child: ChoiceChip(
              label: Text(label),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  context.read<PetProvider>().filterBySpecies(species);
                }
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    // load pets on page load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PetProvider>().loadPets();
    });
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);
    final ColorScheme colorScheme = themeData.colorScheme;

    // context.watch: rebuilds this widget when petProvider notifies
    final petProvider = context.watch<PetProvider>();
    final pets = petProvider.pets;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: Text(
                "Favorites: ${petProvider.favoriteCount}",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
        elevation: 16.0,
        titleTextStyle: Theme.of(context).textTheme.titleLarge,
      ),
      body: Column(
        children: [
          // 1. the filter chips (pinned at top)
          _buildSpeciesFilter(context, petProvider),

          // 2. the dynamic list (takes remaining height)
          Expanded(
            child: Builder(
              builder: (context) {
                // loading
                if (petProvider.isLoading && pets.isEmpty) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }

                // error message
                if (petProvider.errorMessage != null && pets.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("error: ${petProvider.errorMessage}"),
                        SizedBox(height: 8.0),

                        ElevatedButton(
                          onPressed: () {
                            context.read<PetProvider>().loadPets();
                          },
                          child: Text("retry")
                        ),
                      ],
                    ),
                  );
                }

                // pets empty
                if (pets.isEmpty) {
                  return const Center(
                    child: Text('no pets found!'),
                  );
                }

                // list of pets
                return RefreshIndicator(
                  onRefresh: context.read<PetProvider>().loadPets,
                  child: ListView.builder(
                    itemCount: pets.length,
                    itemBuilder: (context, index) {
                      final pet = pets[index];
                      return ListTile(
                        leading: CircleAvatar(
                            child: Text(pet.species.substring(0, 1).toUpperCase())
                        ),
                        title: Text(pet.name),
                        subtitle: Text(pet.species),
                        trailing: IconButton(
                          onPressed: () async {
                            try {
                              await context
                                  .read<PetProvider>()
                                  .toggleFavorite(pet.id);

                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('failed to update favorite: $e'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            }
                          },
                          icon: Icon(
                            pet.isFavorite
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: pet.isFavorite ? Colors.red : null,
                          ),
                        ),
                        tileColor: (index.isEven)
                            ? null
                            : colorScheme.surfaceContainerHigh,
                      );
                  }),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) {
                return AddPetPage();
              }
            ),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
