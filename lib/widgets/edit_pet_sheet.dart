import 'package:flutter/material.dart';
import 'package:pet_app/models/pet.dart';
import 'package:pet_app/providers/pet_provider.dart';
import 'package:provider/provider.dart';

class EditPetSheet extends StatefulWidget {
  final Pet pet;

  const EditPetSheet({super.key, required this.pet});

  // convenient static launcher
  static Future<void> show(BuildContext context, {required Pet pet}) {
    return showModalBottomSheet(
      context: context,
      // allows sheet to adjust for keyboard
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20)
        ),
      ),
      builder: (_) {
        return EditPetSheet(pet: pet);
      },
    );
  }

  @override
  State<EditPetSheet> createState() => _EditPetSheetState();
}

class _EditPetSheetState extends State<EditPetSheet> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

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

  late final TextEditingController _nameController;
  String? _selectedSpecies;
  bool _isFavorite = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _nameController = TextEditingController(text: widget.pet.name);
    _selectedSpecies = widget.pet.species;
    _isFavorite = widget.pet.isFavorite;
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _editPet() async {
    // 1. validate form fields
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    // 2. prepare edited pet object
    final editedPet = Pet(
      id: widget.pet.id,
      name: _nameController.text.trim(),
      species: _selectedSpecies!,
      isFavorite: _isFavorite,
      image: widget.pet.image,
    );

    // 3. dispatch to petProvider using context.read()
    try {
      await context.read<PetProvider>().updatePet(
        widget.pet.id,
        editedPet,
      );

      // 4. show confirmation feedback
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${editedPet.name} has been updated!'),
          behavior: SnackBarBehavior.floating,
        ),
      );

      // 5. navigate back to homePage
      Navigator.of(context).pop();

    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('failed to update pet: $e'),
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
    return Padding(
      padding: EdgeInsets.only(
        left: 16.0,
        right: 16.0,
        top: 16.0,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16.0
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. title | header
              Text(
                'edit pet',
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              SizedBox(height: 16.0),
              // 2. name field
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
              // 3. species dropdown
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
              // 4. favorite switch
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
              // 5. submit button
              FilledButton.icon(
                onPressed: _isSubmitting ? null : _editPet,
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
                label: Text(_isSubmitting ? 'updating..' : 'update pet'),
                style: FilledButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 14.0),
                ),
              ),
            ],
          )
        ),
      ),
    );
  }
}
