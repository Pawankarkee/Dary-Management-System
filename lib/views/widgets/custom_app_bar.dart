import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/sync_controller.dart';
import '../../config/theme/app_theme.dart';

/// Custom responsive AppBar for the Dairy Management System
/// 
/// Features:
/// - Logo and app title
/// - Navigation icons: Dashboard, Reports, Photos
/// - Profile dropdown with Profile, Settings, Logout
/// - Sync status indicator
/// - Fully responsive (mobile, tablet, desktop)
/// - Material 3 design with tooltips
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback? onProfilePressed;
  final VoidCallback? onSettingsPressed;
  final VoidCallback? onLogoutPressed;
  final VoidCallback? onDashboardPressed;
  final VoidCallback? onReportsPressed;
  final VoidCallback? onPhotosPressed;
  
  const CustomAppBar({
    super.key,
    this.onProfilePressed,
    this.onSettingsPressed,
    this.onLogoutPressed,
    this.onDashboardPressed,
    this.onReportsPressed,
    this.onPhotosPressed,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final authController = Provider.of<AuthController>(context);
    final syncController = Provider.of<SyncController>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final isTablet = screenWidth >= 600 && screenWidth < 1024;

    return AppBar(
      elevation: 2,
      title: _buildTitle(context, isMobile),
      actions: [
        // Sync Status Indicator - Always visible
        _buildSyncIndicator(syncController, isDark),
        
        if (!isMobile) ...[
          const SizedBox(width: 8),
          
          // Dashboard Button (tablet and desktop)
          IconButton(
            onPressed: onDashboardPressed,
            icon: const Icon(Icons.dashboard),
            tooltip: 'Dashboard',
          ),
          
          // Reports Button (tablet and desktop)
          IconButton(
            onPressed: onReportsPressed,
            icon: const Icon(Icons.assessment),
            tooltip: 'Reports',
          ),
          
          // Photos Button - NEW FEATURE MOVED INTO APPBAR
          IconButton(
            onPressed: onPhotosPressed ?? () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Photos feature - Coming soon!'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            icon: const Icon(Icons.photo_library),
            tooltip: 'Photos - Analyze milk collection photos',
          ),
          
          const SizedBox(width: 8),
        ],
        
        // Profile Dropdown Menu
        _buildProfileMenu(context, authController, isDark, isMobile),
        
        SizedBox(width: isMobile ? 8 : 16),
      ],
    );
  }

  /// Build responsive title with logo
  Widget _buildTitle(BuildContext context, bool isMobile) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Logo
        Container(
          width: isMobile ? 35 : 40,
          height: isMobile ? 35 : 40,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryColor.withOpacity(0.2),
                blurRadius: 8,
                spreadRadius: 1,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              'assets/images/logo.jpg',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: AppTheme.primaryColor,
                  child: const Icon(Icons.water_drop, color: Colors.white),
                );
              },
            ),
          ),
        ),
        
        if (!isMobile) ...[
          const SizedBox(width: 12),
          Text(
            'Dairify',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: AppTheme.primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ],
    );
  }

  /// Build sync status indicator
  Widget _buildSyncIndicator(SyncController syncController, bool isDark) {
    return Tooltip(
      message: syncController.isOnline 
          ? 'Online - Last synced: ${syncController.getTimeSinceLastSync()}' 
          : 'Offline',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: syncController.isOnline
              ? AppTheme.successColor.withOpacity(0.1)
              : Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: syncController.isOnline
                ? AppTheme.successColor
                : Colors.grey,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (syncController.syncStatus == SyncStatus.syncing)
              SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    syncController.isOnline
                        ? AppTheme.successColor
                        : Colors.grey,
                  ),
                ),
              )
            else
              Icon(
                syncController.isOnline ? Icons.cloud_done : Icons.cloud_off,
                size: 16,
                color: syncController.isOnline
                    ? AppTheme.successColor
                    : Colors.grey,
              ),
            const SizedBox(width: 6),
            Text(
              syncController.isOnline ? 'Online' : 'Offline',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: syncController.isOnline
                    ? AppTheme.successColor
                    : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build profile dropdown menu
  Widget _buildProfileMenu(
    BuildContext context,
    AuthController authController,
    bool isDark,
    bool isMobile,
  ) {
    return PopupMenuButton<String>(
      offset: const Offset(0, 50),
      icon: CircleAvatar(
        radius: isMobile ? 16 : 18,
        backgroundColor: AppTheme.primaryColor,
        child: Text(
          authController.currentUser?.name.substring(0, 1).toUpperCase() ?? 'U',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: isMobile ? 14 : 16,
          ),
        ),
      ),
      tooltip: 'Profile Menu',
      onSelected: (value) {
        switch (value) {
          case 'profile':
            onProfilePressed?.call();
            break;
          case 'settings':
            onSettingsPressed?.call();
            break;
          case 'logout':
            onLogoutPressed?.call();
            break;
        }
      },
      itemBuilder: (context) => [
        // User Info Header
        PopupMenuItem(
          enabled: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                authController.currentUser?.name ?? 'User',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppTheme.primaryColor.withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      authController.currentUser?.isAdmin ?? false
                          ? 'Admin'
                          : 'Collector',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const PopupMenuDivider(),
        
        // Profile Option
        const PopupMenuItem(
          value: 'profile',
          child: Row(
            children: [
              Icon(Icons.person, size: 20),
              SizedBox(width: 12),
              Text('Profile'),
            ],
          ),
        ),
        
        // Settings Option
        const PopupMenuItem(
          value: 'settings',
          child: Row(
            children: [
              Icon(Icons.settings, size: 20),
              SizedBox(width: 12),
              Text('Settings'),
            ],
          ),
        ),
        
        const PopupMenuDivider(),
        
        // Logout Option
        const PopupMenuItem(
          value: 'logout',
          child: Row(
            children: [
              Icon(Icons.logout, size: 20, color: Colors.red),
              SizedBox(width: 12),
              Text('Logout', style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
      ],
    );
  }
}
