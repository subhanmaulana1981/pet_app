
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
      body: Builder(
        builder: (context) {
          if (petProvider.isLoading && pets.isEmpty) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

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

          if (pets.isEmpty) {
            return const Center(
              child: Text('no pets found!'),
            );
          }

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
                    onPressed: () {
                      context.read<PetProvider>().toggleFavorite(pet.id);
                    },
                    icon: Icon(
                      pet.isFavorite ? Icons.favorite : Icons.favorite_border,
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
