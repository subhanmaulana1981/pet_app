
import 'package:flutter/material.dart';
import 'package:pet_app/models/pet.dart';
import 'package:pet_app/providers/pet_provider.dart';
import 'package:provider/provider.dart';

class AddPetPage extends StatefulWidget {
  const AddPetPage({super.key});

  @override
  State<AddPetPage> createState() => _AddPetPageState();
}

class _AddPetPageState extends State<AddPetPage> {
  bool _isSubmitting = false;
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  // species options available for selection
  final List<String> _speciesOptions = const [
    'cat',
    'dog',
    'bird',
    'rabbit',
    'poultry',
    'fish',
    'wild'
  ];
  String? _selectedSpecies;
  bool _isFavorite = false;

  @override
  void dispose() {
    // TODO: implement dispose
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _savePet() async {
    // 1. validate form fields
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    // 2. create new pet object
    // without manual id
    // database will generate id
    final newPet = Pet(
      id: '',
      name: _nameController.text.trim(),
      species: _selectedSpecies!,
      isFavorite: _isFavorite,
    );

    try {
      // 3. dispatch to petProvider using context.read()
      await context.read<PetProvider>().addPet(newPet);

      if (!mounted) return;

      // 4. show confirmation feedback
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${newPet.name} has been added!'),
          behavior: SnackBarBehavior.floating,
        ),
      );

      // 5. navigate back to homePage
      Navigator.of(context).pop();

    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('failed to add pet: $e'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red,
        ),
      );

    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('add new pet'),
        elevation: 16.0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // pet name input
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'pet name',
                  hintText: 'enter pet name',
                  prefixIcon: Icon(Icons.pets),
                  border: OutlineInputBorder(),
                ),
                textCapitalization: TextCapitalization.words,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'please enter a pet name!';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),

              // species dropDown
              DropdownButtonFormField(
                initialValue: _selectedSpecies,
                decoration: InputDecoration(
                  labelText: 'species',
                  hintText: 'select a species',
                  prefixIcon: Icon(Icons.category),
                  border: OutlineInputBorder(),
                ),
                items: _speciesOptions.map((species) {
                  return DropdownMenuItem<String>(
                    value: species,
                    child: Text(
                      species[0].toUpperCase() + species.substring(1)
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedSpecies = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'please select a species!';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),

              // favorite switch
              SwitchListTile(
                title: Text('favorite'),
                subtitle: Text('add this pet to favorites!'),
                value: _isFavorite,
                secondary: Icon(
                  _isFavorite ? Icons.favorite : Icons.favorite_border
                ),
                onChanged: (value) {
                  setState(() {
                    _isFavorite = value;
                  });
                },
                contentPadding: EdgeInsets.zero,
              ),
              SizedBox(height: 16.0),

              // save button
              FilledButton.icon(
                onPressed: _isSubmitting ? null : _savePet,
                icon: _isSubmitting
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Icon(Icons.check),
                label: Text(_isSubmitting ? 'saving..' : 'add pet'),
                style: FilledButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 14.0),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
