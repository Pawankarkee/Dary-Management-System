import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../controllers/theme_controller.dart';
import '../../../controllers/sync_controller.dart';
import '../../../controllers/auth_controller.dart';
import '../../../config/theme/app_theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
  final themeController = Provider.of<ThemeController>(context);
  final syncController = Provider.of<SyncController>(context);
  final authController = Provider.of<AuthController>(context);

    return Scaffold(
      body: ListView(
        children: [
          const SizedBox(height: 16),
          
          // Appearance Section
          _buildSectionHeader(context, 'Appearance'),
          SwitchListTile(
            title: const Text('Dark Mode'),
            subtitle: const Text('Enable dark theme'),
            value: themeController.isDarkMode,
            onChanged: (_) => themeController.toggleTheme(),
            secondary: Icon(
              themeController.isDarkMode ? Icons.dark_mode : Icons.light_mode,
            ),
          ),

          const Divider(),

          // Security Section
          _buildSectionHeader(context, 'Security'),
          FutureBuilder<bool>(
            future: authController.checkBiometricAvailability(),
            builder: (context, snapshot) {
              final available = snapshot.data ?? false;
              return SwitchListTile(
                title: const Text('Use fingerprint (biometric)'),
                subtitle: Text(available
                    ? 'Unlock app with fingerprint or face'
                    : 'Biometric not available on this device'),
                value: authController.isBiometricEnabled && available,
                onChanged: available
                    ? (val) async {
                        if (val) {
                          // Enable biometric after a quick test authenticate
                          final ok = await authController.loginWithBiometric(rememberMe: authController.rememberMe);
                          if (ok) {
                            await authController.setBiometric(true);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Biometric login enabled')),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Biometric authentication failed')),
                            );
                          }
                        } else {
                          await authController.setBiometric(false);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Biometric login disabled')),
                          );
                        }
                      }
                    : null,
                secondary: const Icon(Icons.fingerprint),
              );
            },
          ),

          // Sync Section
          _buildSectionHeader(context, 'Sync'),
          ListTile(
            leading: const Icon(Icons.sync),
            title: const Text('Sync Now'),
            subtitle: Text('Last synced: ${syncController.getTimeSinceLastSync()}'),
            trailing: syncController.syncStatus == SyncStatus.syncing
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Icon(
                    syncController.isOnline ? Icons.cloud_done : Icons.cloud_off,
                    color: syncController.isOnline
                        ? AppTheme.successColor
                        : Colors.grey,
                  ),
            onTap: syncController.isOnline
                ? () => syncController.syncNow()
                : null,
          ),
          ListTile(
            leading: const Icon(Icons.download),
            title: const Text('Fetch from mock server'),
            subtitle: const Text('Pull updates from in-app mock server'),
            onTap: () {
              // start fetch in background and notify user
              syncController.fetchUpdates();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Fetching updates from mock server...')),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.cloud_queue),
            title: const Text('Pending Sync'),
            subtitle: Text('${syncController.pendingSyncCount} items waiting to sync'),
          ),

          const Divider(),

          // About Section
          _buildSectionHeader(context, 'About'),
          const ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('Version'),
            subtitle: Text('1.0.0'),
          ),
          const ListTile(
            leading: Icon(Icons.description),
            title: Text('License'),
            subtitle: Text('MIT License'),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          color: AppTheme.primaryColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
