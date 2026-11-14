
import 'package:flutter/material.dart';
import 'package:pet_app/views/add_pet_page.dart';
import 'package:pet_app/widgets/demo_data_sheet.dart';

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

          // 3. demo data tools
          ListTile(
            leading: Icon(
              Icons.auto_awesome_outlined,
              size: 48,
            ),
            title: Text('demo data tools'),
            subtitle: Text('seed or clean catalog data'),
            onTap: () {
              // close the drawer first
              Navigator.pop(context);
              // open the modal bottom sheet
              DemoDataSheet.show(context);
            },
          ),
          Divider(),
        ],
      ),
    );
  }
}
