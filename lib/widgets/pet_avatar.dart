
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:pet_app/models/pet.dart';

class PetAvatar extends StatelessWidget {
  /* properti */
  final Pet pet;
  final double radius;

  /* konstruksi */
  const PetAvatar({
    super.key,
    required this.pet,
    this.radius = 24.0
  });

  /* methods */
  // 1. color palette: species or name-based
  Color _getBackgroundColor() {
    switch (pet.species.toLowerCase().trim()) {
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

  // 2. safe base64 decoder
  Uint8List? _getDecodedImage() {
    if (pet.image == null || pet.image!.trim().isEmpty) return null;
    try {
      final clean = pet.image!.contains(',')
          ? pet.image!.split(',').last.trim()
          : pet.image!.trim();
      return base64Decode(clean);

    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final imageBytes = _getDecodedImage();
    final hasImage = imageBytes != null;
    final trimmedName = pet.name.trim();

    return CircleAvatar(
      radius: radius,
      backgroundColor: hasImage? Colors.transparent : _getBackgroundColor(),
      backgroundImage: hasImage ? MemoryImage(imageBytes) : null,
      child: hasImage
        ? null
        : (trimmedName.isNotEmpty
            ? Text(
                trimmedName[0].toUpperCase(),
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: radius * 0.9,
                ),
              )
            : Icon(
                Icons.pets,
                color: Colors.white,
                size: radius * 1.1,
              )
          ),
    );
  }
}
