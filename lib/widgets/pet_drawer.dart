
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
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
            ),
            currentAccountPicture: CircleAvatar(
              backgroundImage: AssetImage('assets/images/subhanmaulana_profile_small.png'),
            ),
            currentAccountPictureSize: Size(64, 64),
            accountName: Text(
              'subhan maulana',
              style: theme.textTheme.titleLarge,
            ),
            accountEmail: Text(
              'SubhanMaulana1981@gmail.com',
              style: theme.textTheme.bodyMedium,
            ),
          ),
          /*DrawerHeader(
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: colorScheme.primary,
                  child: Image.asset(
                    'assets/images/subhanmaulana_profile_small.png',
                    fit: BoxFit.contain,
                  ),
                ),
                SizedBox(height: 12),

                Text(
                  'pet manager',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
                Text(
                  'care and tracking',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onPrimaryContainer.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),*/
          // 2. navigation items
          ListTile(
            leading: Icon(
              Icons.add_circle_outline,
              size: 48,
            ),
            title: Text('add new pet'),
            onTap: () {
              // close the drawer
              Navigator.pop(context);
              // navigate to add pet page
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddPetPage(),
                ),
              );
            },
          ),
          Divider(),
          // 3. optional settings / app info
          ListTile(
            leading: Icon(
              Icons.info_outline,
              size: 48,
            ),
            title: Text('about'),
            onTap: () {
              Navigator.pop(context);
              showAboutDialog(
                context: context,
                applicationName: 'pet manager',
                applicationVersion: '1.0.0',
                applicationIcon: Icon(
                  Icons.pets,
                  size: 72,
                ),
              );
            },
          ),
          Divider(),
        ],
      ),
    );
  }
}
