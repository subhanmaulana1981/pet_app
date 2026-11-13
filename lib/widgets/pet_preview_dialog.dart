
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:pet_app/models/pet.dart';
import 'package:pet_app/providers/pet_provider.dart';
import 'package:pet_app/widgets/edit_pet_sheet.dart';
import 'package:provider/provider.dart';

class PetPreviewDialog extends StatelessWidget {
  /* properti */
  final Pet pet;

  /* konstruksi */
  const PetPreviewDialog({super.key, required this.pet});

  /* methods */
  // convenient static launcher
  static Future<void> show(BuildContext context, {required Pet pet}) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => PetPreviewDialog(pet: pet),
    );
  }

// color palette matching PetAvatar
  Color _getBackgroundColor(String species) {
    switch (species.toLowerCase().trim()) {
      case 'cat':
        return Colors.orange.shade400;
      case 'dog':
        return Colors.blue.shade500;
      case 'bird':
        return Colors.teal.shade500;
      case 'rabbit':
        return Colors.purple.shade400;
      case 'fish':
        return Colors.cyan.shade600;
      case 'poultry':
        return Colors.amber.shade700;
      case 'wild':
        return Colors.deepOrange.shade600;
      default:
        return Colors.indigo.shade400;
    }
  }

  // safe base64 decoder
  Uint8List? _getDecodedImage(String? base64Str) {
    if (base64Str == null || base64Str.trim().isEmpty) return null;
    try {
      final clean = base64Str.contains(',')
          ? base64Str.split(',').last.trim()
          : base64Str.trim();
      return base64Decode(clean);

    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    // watch provider so the heart icon immediately
    // reflects toggle changes
    final petProvider = context.watch<PetProvider>();
    final currentPet = petProvider.pets.firstWhere((p) {
      return p.id == pet.id;
    }, orElse: () {
      return pet;
    });

    final imageBytes = _getDecodedImage(currentPet.image);
    final hasImage = imageBytes != null;
    final trimmedName = currentPet.name.trim();

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: EdgeInsets.symmetric(horizontal: 32.0),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 320),
          child: Material(
            elevation: 12.0,
            borderRadius: BorderRadius.circular(16.0),
            clipBehavior: Clip.antiAlias,
            color: Theme.of(context).colorScheme.surface,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 1. whatsapp style square image area
                // with top header overlay
                AspectRatio(
                  aspectRatio: 1.0,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // background image or initial placeholder
                      InteractiveViewer(
                        minScale: 1.0,
                        maxScale: 3.5,
                        child: hasImage
                          ? Image.memory(
                              imageBytes,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                            )
                          : Container(
                              color: _getBackgroundColor(currentPet.species),
                              alignment: Alignment.center,
                              child: trimmedName.isNotEmpty
                                ? Text(
                                    trimmedName[0].toUpperCase(),
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 72.0
                                    ),
                                  )
                                : Icon(
                                    Icons.pets,
                                    color: Colors.white,
                                    size: 80.0,
                                  ),
                            )
                      ),

                      // top name bar overlay
                      // (like whatsapp)
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 10.0,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.black87,
                                Colors.transparent,
                              ],
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                currentPet.name,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18.0,
                                ),
                              ),

                              Text(
                                currentPet.species.toUpperCase(),
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12.0,
                                  letterSpacing: 1.1,
                                ),
                              ),
                            ],
                          ),
                        )
                      ),
                    ],
                  ),
                ),

                // 2. bottom action bar
                // whatsapp style
                Container(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  padding: EdgeInsets.symmetric(
                    horizontal: 8.0,
                    vertical: 4.0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // toggle favorite
                      IconButton(
                        tooltip: currentPet.isFavorite
                          ? 'remove from favorites'
                          : 'add to favorites',
                        onPressed: () async {
                          await context.read<PetProvider>().toggleFavorite(
                            currentPet.id
                          );
                        },
                        icon: Icon(
                          currentPet.isFavorite
                            ? Icons.favorite
                            : Icons.favorite_border,
                          color: currentPet.isFavorite
                            ? Colors.red
                            : null,
                        ),
                      ),

                      // info / edit pet
                      IconButton(
                        tooltip: 'pet details',
                        onPressed: () async {
                          // close dialog first,
                          // then open edit sheet
                          Navigator.pop(context);
                          EditPetSheet.show(
                            context,
                            pet: currentPet
                          );
                        },
                        icon: Icon(Icons.info_outline),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
