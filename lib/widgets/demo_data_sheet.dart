
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pet_app/providers/pet_provider.dart';
import 'package:pet_app/widgets/confirm_dialog.dart';

class DemoDataSheet extends StatefulWidget {
  const DemoDataSheet({super.key});

  // convenient static launcher
  // matching your EditPetSheet pattern
  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      builder: (_) => DemoDataSheet(),
    );
  }

  @override
  State<DemoDataSheet> createState() => _DemoDataSheetState();
}

class _DemoDataSheetState extends State<DemoDataSheet> {
  bool _isProcessiong = false;

  Future<void> _executeAction({
    required String confirmTitle,
    required String confirmMessage,
    required String confirmLabel,
    required bool isDestructive,
    required String progressMessage,
    required String successMessage,
    required Future<void> Function() action,
  }) async {
      final confirmed = await ConfirmDialog.show(
        context,
        title: confirmTitle,
        message: confirmMessage,
        confirmLabel: confirmLabel,
        cancelLabel: 'cancel',
        isDestructive: isDestructive
      );
      if (!confirmed || !mounted) return;
      setState(() => _isProcessiong = true);

    // close the bottom sheet
    // so user returns to the catalog
    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            ),
            SizedBox(width: 14),

            Text(progressMessage),
          ],
        ),
        duration: Duration(seconds: 5),
        behavior: SnackBarBehavior.floating,
      ),
    );

    try {
      await action();

      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(successMessage),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('operation failed: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 12, 16, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // drag handle
          Container(
            width: 40,
            height: 4,
            margin: EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: colorScheme.outlineVariant,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // header
          Row(
            children: [
              Icon(
                Icons.auto_awesome_rounded,
                color: colorScheme.primary,
              ),
              SizedBox(width: 12),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'demo data tools',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  Text(
                    'manage test data and sample catalog',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.outline
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 16),
          Divider(),

          // 1. reset to default
          ListTile(
            enabled: !_isProcessiong,
            leading: CircleAvatar(
              backgroundColor: colorScheme.primaryContainer,
              child: Icon(
                Icons.restart_alt_rounded,
                color: colorScheme.primary,
              ),
            ),
            title: Text('reset to default catalog'),
            subtitle: Text('clears current data and '
                'loads 8 default pets'),
            onTap: () {
              _executeAction(
                confirmTitle: 'reset to default',
                confirmMessage: 'this will replace all existing pets with'
                    'the 8 default sample pets, continue?',
                confirmLabel: 'reset',
                isDestructive: false,
                progressMessage: 'resetting catalog..',
                successMessage: 'catalog reset to default sample pets!',
                action: () => context.read<PetProvider>().seedPets(clean: true),
              );
            },
          ),

          // 2. append sample pets
          ListTile(
            enabled: !_isProcessiong,
            leading: CircleAvatar(
              backgroundColor: colorScheme.secondaryContainer,
              child: Icon(
                Icons.playlist_add_rounded,
                color: colorScheme.secondary,
              ),
            ),
            title: Text('append sample pets'),
            subtitle: Text('adds 8 sample pets '
                'without deleting existing ones'),
            onTap: () {
              _executeAction(
                confirmTitle: 'append sample pets',
                confirmMessage: 'add 8 sample pets to your existing catalog?',
                confirmLabel: 'add sample',
                isDestructive: false,
                progressMessage: 'adding sample pets..',
                successMessage: '8 sample pets added!',
                action: () => context.read<PetProvider>().seedPets(
                  clean: false
                ),
              );
            },
          ),

          // 3. wipe all pets
          ListTile(
            enabled: !_isProcessiong,
            leading: CircleAvatar(
              backgroundColor: colorScheme.errorContainer,
              child: Icon(
                Icons.delete_sweep_outlined,
                color: colorScheme.error,
              ),
            ),
            title: Text(
              'clear all pets',
              style: TextStyle(color: colorScheme.error),
            ),
            subtitle: Text('wipes catalog to test empty state'),
            onTap: () {
              _executeAction(
                confirmTitle: 'clear all pets',
                confirmMessage: 'are you sure you want to delete all pets? '
                    'this cannot be undone!',
                confirmLabel: 'clear all',
                isDestructive: true,
                progressMessage: 'clearing catalog..',
                successMessage: 'all pets have been cleared!',
                action: () => context.read<PetProvider>().clearAllPets(),
              );
            },
          ),
        ],
      ),
    );
  }
}
