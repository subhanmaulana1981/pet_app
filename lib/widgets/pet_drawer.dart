
import 'package:flutter/material.dart';
import 'package:pet_app/views/add_pet_page.dart';

class PetDrawer extends StatelessWidget {
  const PetDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // 1. header (brand or user info)
          // 2. navigation items
          // 3. optional settings / app info
        ],
      ),
    );
  }
}
