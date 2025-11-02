import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/theme_controller.dart';
import '../../controllers/sync_controller.dart';
import '../../controllers/milk_controller.dart';
import '../../config/theme/app_theme.dart';
import '../../utils/responsive.dart';
import '../screens/home/home_screen.dart';
import '../screens/farmers/farmers_screen.dart';
import '../screens/milk/milk_collection_screen.dart';
import '../screens/products/products_screen.dart';
import '../screens/sales/pos_screen_redesigned.dart';
import '../screens/reports/reports_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/mobile_drawer.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _selectedIndex = 0;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _selectedIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _onNavItemTapped(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  final List<Widget> _screens = [
    const HomeScreen(),
    const FarmersScreen(),
    const MilkCollectionScreen(),
    const ProductsScreen(),
    const POSScreenRedesigned(),
    const ReportsScreen(),
    const SettingsScreen(),
  ];

  final List<NavigationItem> _navItems = [
    NavigationItem(
      icon: Icons.home_outlined,
      selectedIcon: Icons.home,
      label: 'Home',
    ),
    NavigationItem(
      icon: Icons.people_outline,
      selectedIcon: Icons.people,
      label: 'Farmers',
    ),
    NavigationItem(
      icon: Icons.water_drop_outlined,
      selectedIcon: Icons.water_drop,
      label: 'Milk',
    ),
    NavigationItem(
      icon: Icons.inventory_2_outlined,
      selectedIcon: Icons.inventory_2,
      label: 'Products',
    ),
    NavigationItem(
      icon: Icons.point_of_sale_outlined,
      selectedIcon: Icons.point_of_sale,
      label: 'Sales',
    ),
    NavigationItem(
      icon: Icons.assessment_outlined,
      selectedIcon: Icons.assessment,
      label: 'Reports',
    ),
    NavigationItem(
      icon: Icons.settings_outlined,
      selectedIcon: Icons.settings,
      label: 'Settings',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);
    final isTablet = Responsive.isTablet(context);
    final isDesktop = Responsive.isDesktop(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themeController = Provider.of<ThemeController>(context);
    final authController = Provider.of<AuthController>(context);
    final syncController = Provider.of<SyncController>(context);

    return Scaffold(
      appBar: isMobile
          ? AppBar(
              title: Text(_navItems[_selectedIndex].label),
              leading: Builder(
                builder: (context) => IconButton(
                  icon: const Icon(Icons.menu),
                  onPressed: () => Scaffold.of(context).openDrawer(),
                  tooltip: 'Menu',
                ),
              ),
              actions: [
                // Theme toggle on mobile
                IconButton(
                  icon: Icon(
                    isDark ? Icons.light_mode : Icons.dark_mode,
                  ),
                  onPressed: () => themeController.toggleTheme(),
                  tooltip: isDark ? 'Light Mode' : 'Dark Mode',
                ),
                // Sync status on mobile
                if (syncController.syncStatus == SyncStatus.syncing)
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                else
                  IconButton(
                    icon: const Icon(Icons.sync),
                    onPressed: () async {
                      // TODO: Implement sync when available
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Sync feature coming soon')),
                      );
                    },
                    tooltip: 'Sync Data',
                  ),
              ],
            )
          : CustomAppBar(
              onDashboardPressed: () => _onNavItemTapped(0),
              onReportsPressed: () => _onNavItemTapped(5),
              onPhotosPressed: () {
                // TODO: Navigate to photos screen when implemented
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Photos feature - Coming soon!'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              onProfilePressed: () {
                // TODO: Navigate to profile screen when implemented
              },
              onSettingsPressed: () => _onNavItemTapped(6),
              onLogoutPressed: _showLogoutDialog,
            ),
      drawer: isMobile ? const MobileDrawer() : null,
      body: Row(
        children: [
          // Side Navigation (for desktop)
          if (isDesktop)
            _buildSideNavigation(isDark, authController, syncController, themeController),
          
          // Main Content with PageView for swipe navigation
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: _onPageChanged,
              physics: isMobile 
                  ? const BouncingScrollPhysics() // Enable swipe on mobile
                  : const NeverScrollableScrollPhysics(), // Disable swipe on desktop
              children: _screens,
            ),
          ),
        ],
      ),
      bottomNavigationBar: isMobile
          ? _buildBottomNavigation()
          : null,
    );
  }

  Widget _buildSideNavigation(
    bool isDark,
    AuthController authController,
    SyncController syncController,
    ThemeController themeController,
  ) {
    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurface : AppTheme.lightSurface,
        border: Border(
          right: BorderSide(
            color: isDark ? Colors.white10 : Colors.black12,
          ),
        ),
      ),
      child: Column(
        children: [
          // Logo Header
          Container(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryColor.withOpacity(0.2),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      'assets/images/logo.jpg',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Dairify',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Navigation Items
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: _navItems.length,
              itemBuilder: (context, index) {
                final item = _navItems[index];
                final isSelected = _selectedIndex == index;

                return Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  child: ListTile(
                    leading: Icon(
                      isSelected ? item.selectedIcon : item.icon,
                      color: isSelected ? AppTheme.primaryColor : null,
                    ),
                    title: Text(
                      item.label,
                      style: TextStyle(
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        color: isSelected ? AppTheme.primaryColor : null,
                      ),
                    ),
                    selected: isSelected,
                    selectedTileColor: AppTheme.primaryColor.withOpacity(0.1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    onTap: () {
                      _onNavItemTapped(index);
                    },
                  ),
                );
              },
            ),
          ),

          const Divider(height: 1),

          // Sync Status & Actions
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Sync Status - Simple inline version for sidebar
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: syncController.isOnline
                        ? AppTheme.successColor.withOpacity(0.1)
                        : Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: syncController.isOnline
                          ? AppTheme.successColor
                          : Colors.grey,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        syncController.isOnline ? Icons.cloud_done : Icons.cloud_off,
                        color: syncController.isOnline
                            ? AppTheme.successColor
                            : Colors.grey,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              syncController.isOnline ? 'Online' : 'Offline',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: syncController.isOnline
                                    ? AppTheme.successColor
                                    : Colors.grey,
                              ),
                            ),
                            Text(
                              'Last synced: ${syncController.getTimeSinceLastSync()}',
                              style: const TextStyle(fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                      if (syncController.syncStatus == SyncStatus.syncing)
                        const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                
                // User Info & Logout
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppTheme.primaryColor,
                    child: Text(
                      authController.currentUser?.name.substring(0, 1).toUpperCase() ?? 'U',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(authController.currentUser?.name ?? ''),
                  subtitle: Text(
                    authController.currentUser?.isAdmin ?? false ? 'Admin' : 'Collector',
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.logout),
                    onPressed: _showLogoutDialog,
                    tooltip: 'Logout',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      // Hide labels under icons to avoid duplicate text with AppBar title on mobile
      showSelectedLabels: false,
      showUnselectedLabels: false,
      selectedFontSize: 12,
      unselectedFontSize: 11,
      selectedItemColor: AppTheme.primaryColor,
      unselectedItemColor: Colors.grey,
      currentIndex: _selectedIndex,
      onTap: _onNavItemTapped,
      items: _navItems.map((item) {
        final isSelected = _selectedIndex == _navItems.indexOf(item);
        return BottomNavigationBarItem(
          icon: Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Icon(
              isSelected ? item.selectedIcon : item.icon,
              size: 24,
            ),
          ),
          label: item.label,
        );
      }).toList(),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final authController = Provider.of<AuthController>(context, listen: false);
              await authController.logout();
              if (!mounted) return;
              Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}

class NavigationItem {
  final IconData icon;
  final IconData selectedIcon;
  final String label;

  NavigationItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });
}
