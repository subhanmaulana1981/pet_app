
import 'package:flutter/material.dart';
import 'package:pet_app/providers/pet_provider.dart';
import 'package:pet_app/views/add_pet_page.dart';
import 'package:provider/provider.dart';

class MyHomePage extends StatelessWidget {
  const MyHomePage({
    super.key,
    required this.title
  });

  final String title;

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);
    final ColorScheme colorScheme = themeData.colorScheme;

    // context.watch: rebuilds this widget when petProvider notifies
    final petProvider = context.watch<PetProvider>();
    final pets = petProvider.pets;

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
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
      body: pets.isEmpty
        ? Center(child: const Text("no pets found!"))
        : ListView.builder(
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
