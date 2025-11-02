import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/auth_controller.dart';
import '../../config/theme/app_theme.dart';
import '../../config/routes/app_router.dart';

class MobileDrawer extends StatelessWidget {
  const MobileDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Provider.of<AuthController>(context);
    final user = authController.currentUser;

    return Drawer(
      child: Column(
        children: [
          // User Profile Header
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.primaryColor,
                  AppTheme.primaryColor.withOpacity(0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                user?.name.substring(0, 1).toUpperCase() ?? 'U',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
            ),
            accountName: Text(
              user?.name ?? 'User',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            accountEmail: Text(
              user?.role.toString().split('.').last.toUpperCase() ?? 'USER',
              style: const TextStyle(
                fontSize: 14,
              ),
            ),
          ),

          // Navigation Items
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildDrawerItem(
                  context,
                  icon: Icons.dashboard,
                  title: 'Dashboard',
                  route: AppRouter.home,
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.people,
                  title: 'Farmers',
                  route: AppRouter.farmers,
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.water_drop,
                  title: 'Milk Collection',
                  route: AppRouter.milkCollection,
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.inventory,
                  title: 'Products',
                  route: AppRouter.products,
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.assessment,
                  title: 'Reports',
                  route: AppRouter.reports,
                ),
                const Divider(),
                _buildDrawerItem(
                  context,
                  icon: Icons.settings,
                  title: 'Settings',
                  route: AppRouter.settingsRoute,
                ),
              ],
            ),
          ),

          // Logout at bottom
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text(
              'Logout',
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.w600,
              ),
            ),
            onTap: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Logout'),
                  content: const Text('Are you sure you want to logout?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      child: const Text('Logout'),
                    ),
                  ],
                ),
              );

              if (confirmed == true && context.mounted) {
                await authController.logout();
                if (context.mounted) {
                  Navigator.of(context).pushReplacementNamed(AppRouter.login);
                }
              }
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String route,
  }) {
    final currentRoute = ModalRoute.of(context)?.settings.name;
    final isActive = currentRoute == route;

    return ListTile(
      leading: Icon(
        icon,
        color: isActive ? AppTheme.primaryColor : Colors.grey[700],
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
          color: isActive ? AppTheme.primaryColor : Colors.grey[900],
        ),
      ),
      selected: isActive,
      selectedTileColor: AppTheme.primaryColor.withOpacity(0.1),
      onTap: () {
        Navigator.pop(context); // Close drawer
        if (!isActive) {
          Navigator.pushReplacementNamed(context, route);
        }
      },
    );
  }
}
