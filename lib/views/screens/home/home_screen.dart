import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../controllers/auth_controller.dart';
import '../../../controllers/milk_controller.dart';
import '../../../controllers/farmer_controller.dart';
import '../../../controllers/product_controller.dart';
import '../../../controllers/supplier_controller.dart';
import '../../../controllers/purchase_controller.dart';
import '../../../controllers/expense_controller.dart';
import '../../../controllers/staff_controller.dart';
import '../../../controllers/processing_controller.dart';
import '../../../controllers/sync_controller.dart';
import '../../../controllers/transaction_controller.dart';
import '../../../config/theme/app_theme.dart';
import '../../../config/routes/app_router.dart';
import '../../../config/constants/app_constants.dart';
import '../../../utils/formatters.dart';
import '../../../utils/responsive.dart';
import '../../../utils/demo_data_seeder.dart';
import '../../../services/demo_data_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SupplierController>().loadSuppliers();
      context.read<PurchaseController>().loadPurchases();
      context.read<ExpenseController>().loadExpenses();
      context.read<StaffController>().loadStaff();
      context.read<ProcessingController>().loadBatches();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authController = Provider.of<AuthController>(context);
    final milkController = Provider.of<MilkController>(context);
    final farmerController = Provider.of<FarmerController>(context);
    final productController = Provider.of<ProductController>(context);
    final supplierController = Provider.of<SupplierController>(context);
    final purchaseController = Provider.of<PurchaseController>(context);
    final expenseController = Provider.of<ExpenseController>(context);
    final staffController = Provider.of<StaffController>(context);
    final processingController = Provider.of<ProcessingController>(context);
    
  final theme = Theme.of(context);
  final colorScheme = theme.colorScheme;
  final todaySummary = milkController.getTodaySummary();
    final isMobile = Responsive.isMobile(context);
    final isTablet = Responsive.isTablet(context);
    
    final crossAxisCount = isMobile ? 2 : (isTablet ? 3 : 4);

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          await Future.wait([
            milkController.loadCollections(),
            farmerController.loadFarmers(),
            productController.loadProducts(),
          ]);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: Responsive.screenPadding(context).copyWith(
            top: isMobile ? 12 : 24,
            bottom: isMobile ? 80 : 24, // Extra bottom padding for FAB
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Section - Compact for mobile
              _buildWelcomeSection(context, authController),
              SizedBox(height: Responsive.spacingL(context)),

              // Today's Summary Cards - Redesigned for mobile
              _buildTodaySummary(context, todaySummary),
              SizedBox(height: Responsive.spacingXL(context)),

              // Quick Actions
              Text(
                'Quick Actions',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontSize: Responsive.heading3(context),
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: Responsive.spacingM(context)),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: isMobile ? 10 : 16,
                mainAxisSpacing: isMobile ? 10 : 16,
                childAspectRatio: isMobile ? 1.1 : 1.0,
                children: [
                  // Row 1
                  _buildQuickActionCard(
                    context,
                    icon: Icons.people,
                    title: 'Farmers',
                    subtitle: '${farmerController.farmers.length} registered',
                    color: const Color(0xFF9C27B0),
                    onTap: () => Navigator.pushNamed(context, AppRouter.farmers),
                  ),
                  _buildQuickActionCard(
                    context,
                    icon: Icons.account_balance_wallet,
                    title: 'Farmer Advance',
                    subtitle: 'Payments & loans',
                    color: const Color(0xFFE91E63),
                    onTap: () => Navigator.pushNamed(context, AppRouter.farmerAdvance),
                  ),
                  _buildQuickActionCard(
                    context,
                    icon: Icons.store_mall_directory,
                    title: 'Collection Center',
                    subtitle: 'Manage centers',
                    color: const Color(0xFF00BCD4),
                    onTap: () => Navigator.pushNamed(context, AppRouter.collectionCenter),
                  ),
                  _buildQuickActionCard(
                    context,
                    icon: Icons.water_drop,
                    title: 'Milk Collection',
                    subtitle: '${milkController.collections.length} collections',
                    color: AppTheme.primaryColor,
                    onTap: () => Navigator.pushNamed(context, AppRouter.milkCollections),
                  ),
                  
                  // Row 2
                  _buildQuickActionCard(
                    context,
                    icon: Icons.science,
                    title: 'SNF & Fat',
                    subtitle: 'Quality testing',
                    color: const Color(0xFF8E24AA),
                    onTap: () => Navigator.pushNamed(context, AppRouter.snfFatTesting),
                  ),
                  _buildQuickActionCard(
                    context,
                    icon: Icons.inventory_2,
                    title: 'Items',
                    subtitle: '${productController.products.length} items',
                    color: const Color(0xFF43A047),
                    onTap: () => Navigator.pushNamed(context, AppRouter.products),
                  ),
                  _buildQuickActionCard(
                    context,
                    icon: Icons.point_of_sale,
                    title: 'Sell Item',
                    subtitle: 'POS & Billing',
                    color: const Color(0xFFFF6F00),
                    onTap: () => Navigator.pushNamed(context, AppRouter.pos),
                  ),
                  _buildQuickActionCard(
                    context,
                    icon: Icons.category,
                    title: 'Products',
                    subtitle: 'Product catalog',
                    color: AppTheme.accentColor,
                    onTap: () => Navigator.pushNamed(context, AppRouter.products),
                  ),
                  
                  // Row 3
                  _buildQuickActionCard(
                    context,
                    icon: Icons.factory,
                    title: 'Production',
                    subtitle: '${processingController.batches.length} batches',
                    color: colorScheme.secondary,
                    onTap: () => Navigator.pushNamed(context, AppRouter.processingBatches),
                  ),
                  _buildQuickActionCard(
                    context,
                    icon: Icons.receipt_long,
                    title: 'Expenses',
                    subtitle: '${expenseController.expenses.length} records',
                    color: colorScheme.error,
                    onTap: () => Navigator.pushNamed(context, AppRouter.expenses),
                  ),
                  _buildQuickActionCard(
                    context,
                    icon: Icons.store,
                    title: 'Suppliers',
                    subtitle: '${supplierController.suppliers.length} suppliers',
                    color: const Color(0xFF5E35B1),
                    onTap: () => Navigator.pushNamed(context, AppRouter.suppliers),
                  ),
                  _buildQuickActionCard(
                    context,
                    icon: Icons.description,
                    title: 'Supplier Bills',
                    subtitle: 'Bill management',
                    color: const Color(0xFF1E88E5),
                    onTap: () => Navigator.pushNamed(context, AppRouter.supplierBills),
                  ),
                  
                  // Row 4
                  _buildQuickActionCard(
                    context,
                    icon: Icons.bar_chart,
                    title: 'Reports',
                    subtitle: 'Analytics & stats',
                    color: const Color(0xFF00897B),
                    onTap: () => Navigator.pushNamed(context, AppRouter.reports),
                  ),
                  _buildQuickActionCard(
                    context,
                    icon: Icons.account_balance,
                    title: 'Party Ledgers',
                    subtitle: 'Account statements',
                    color: const Color(0xFF6A1B9A),
                    onTap: () => Navigator.pushNamed(context, AppRouter.partyLedgers),
                  ),
                ],
              ),

              SizedBox(height: Responsive.spacingXL(context)),

              // Demo Data Helper Card (for testing)
              _buildDemoDataCard(context),

              SizedBox(height: Responsive.spacingXL(context)),

              // Alerts Section
              if (productController.lowStockProducts.isNotEmpty ||
                  productController.expiringProducts.isNotEmpty) ...[
                Text(
                  'Alerts',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontSize: Responsive.heading3(context),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: Responsive.spacingM(context)),
                if (productController.lowStockProducts.isNotEmpty)
                  _buildAlertCard(
                    context,
                    icon: Icons.inventory_2,
                    title: 'Low Stock Alert',
                    subtitle: '${productController.lowStockProducts.length} products running low',
                    color: AppTheme.warningColor,
                  ),
                if (productController.expiringProducts.isNotEmpty)
                  _buildAlertCard(
                    context,
                    icon: Icons.warning,
                    title: 'Expiring Products',
                    subtitle: '${productController.expiringProducts.length} products expiring soon',
                    color: AppTheme.errorColor,
                  ),
              ],
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, AppRouter.addMilkCollection),
        icon: const Icon(Icons.water_drop),
        label: const Text('Add Milk'),
      ),
    );
  }

  Widget _buildWelcomeSection(BuildContext context, AuthController authController) {
    final isMobile = Responsive.isMobile(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final mutedColor = theme.textTheme.bodySmall?.color?.withOpacity(0.7) ??
        colorScheme.onSurface.withOpacity(0.7);
    final hour = DateTime.now().hour;
    String greeting = 'Good Morning';
    if (hour >= 12 && hour < 17) greeting = 'Good Afternoon';
    if (hour >= 17) greeting = 'Good Evening';

    return Card(
      elevation: isMobile ? 1 : 2,
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 12 : 20),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$greeting,',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontSize: Responsive.bodyMedium(context),
                    ),
                  ),
                  SizedBox(height: isMobile ? 2 : 4),
                  Text(
                    authController.currentUser?.name ?? 'User',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: Responsive.heading3(context),
                    ),
                  ),
                  SizedBox(height: isMobile ? 4 : 8),
                  Text(
                    DateFormat('EEEE, MMMM d, y').format(DateTime.now()),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: mutedColor,
                      fontSize: Responsive.bodySmall(context),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              hour < 12 ? Icons.wb_sunny : (hour < 17 ? Icons.wb_cloudy : Icons.nightlight),
              size: isMobile ? 32 : 48,
              color: colorScheme.primary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTodaySummary(BuildContext context, Map<String, dynamic> summary) {
    final isMobile = Responsive.isMobile(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Today\'s Summary',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontSize: Responsive.heading3(context),
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: Responsive.spacingM(context)),
        if (isMobile)
          // Mobile: Compact 2-column grid layout
          Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildSummaryCard(
                      context,
                      icon: Icons.water_drop,
                      title: 'Total Milk',
                      value: '${summary['totalQuantity'].toStringAsFixed(1)} L',
                      color: AppTheme.primaryColor,
                      isCompact: true,
                    ),
                  ),
                  SizedBox(width: Responsive.spacingS(context)),
                  Expanded(
                    child: _buildSummaryCard(
                      context,
                      icon: Icons.payments_outlined,
                      title: 'Total Amount',
                      value: AppConstants.formatCurrency(summary['totalAmount']),
                      color: AppTheme.successColor,
                      isCompact: true,
                      leadingWidget: _buildCurrencyBadge(context, isCompact: true),
                    ),
                  ),
                ],
              ),
              SizedBox(height: Responsive.spacingS(context)),
              Row(
                children: [
                  Expanded(
                    child: _buildSummaryCard(
                      context,
                      icon: Icons.wb_sunny,
                      title: 'Morning',
                      value: '${summary['morningCount']}',
                      color: AppTheme.accentColor,
                      isCompact: true,
                    ),
                  ),
                  SizedBox(width: Responsive.spacingS(context)),
                  Expanded(
                    child: _buildSummaryCard(
                      context,
                      icon: Icons.nightlight,
                      title: 'Evening',
                      value: '${summary['eveningCount']}',
                      color: const Color(0xFF9C27B0),
                      isCompact: true,
                    ),
                  ),
                ],
              ),
            ],
          )
        else
          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  context,
                  icon: Icons.water_drop,
                  title: 'Total Milk',
                  value: '${summary['totalQuantity'].toStringAsFixed(1)} L',
                  color: AppTheme.primaryColor,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildSummaryCard(
                  context,
                  icon: Icons.payments_outlined,
                  title: 'Total Amount',
                  value: AppConstants.formatCurrency(summary['totalAmount']),
                  color: AppTheme.successColor,
                  leadingWidget: _buildCurrencyBadge(context, isCompact: false),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildSummaryCard(
                  context,
                  icon: Icons.wb_sunny,
                  title: 'Morning',
                  value: '${summary['morningCount']}',
                  color: AppTheme.accentColor,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildSummaryCard(
                  context,
                  icon: Icons.nightlight,
                  title: 'Evening',
                  value: '${summary['eveningCount']}',
                  color: const Color(0xFF9C27B0),
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildSummaryCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    required Color color,
    bool isCompact = false,
    Widget? leadingWidget,
  }) {
    final isMobile = Responsive.isMobile(context);
    final theme = Theme.of(context);
    final labelColor = theme.textTheme.bodySmall?.color?.withOpacity(0.7) ??
        theme.colorScheme.onSurface.withOpacity(0.7);
    final bool hasCustomLeading = leadingWidget != null;
    final double iconSize = isMobile
        ? (isCompact ? 20.0 : 24.0)
        : (isCompact ? 28.0 : 32.0);
    final Widget resolvedLeading = hasCustomLeading
        ? leadingWidget!
        : SizedBox(
            width: iconSize,
            height: iconSize,
            child: Center(
              child: Icon(
                icon,
                color: color,
                size: iconSize,
              ),
            ),
          );
    
    return Card(
      elevation: isMobile ? 1 : 2,
      child: Padding(
        padding: EdgeInsets.all(isMobile ? (isCompact ? 10 : 12) : (isCompact ? 16 : 20)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                resolvedLeading,
                const Spacer(),
              ],
            ),
            SizedBox(height: isMobile ? (isCompact ? 6 : 8) : (isCompact ? 8 : 12)),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: labelColor,
                fontSize: isMobile ? (isCompact ? 10 : 11) : (isCompact ? 12 : 13),
              ),
            ),
            SizedBox(height: isMobile ? 2 : 4),
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
                fontSize: isMobile ? (isCompact ? 16 : 18) : (isCompact ? 20 : 24),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrencyBadge(BuildContext context, {required bool isCompact}) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final background = colorScheme.primary.withOpacity(
      theme.brightness == Brightness.dark ? 0.28 : 0.14,
    );

    final primaryTextStyle = theme.textTheme.labelLarge?.copyWith(
          color: colorScheme.primary,
          fontWeight: FontWeight.w700,
          fontSize: isCompact ? 12 : 14,
        ) ??
        TextStyle(
          color: colorScheme.primary,
          fontWeight: FontWeight.w700,
          fontSize: isCompact ? 12 : 14,
        );

    final secondaryTextStyle = theme.textTheme.labelSmall?.copyWith(
          color: colorScheme.primary.withOpacity(0.85),
          fontWeight: FontWeight.w600,
          fontSize: isCompact ? 8 : 10,
          letterSpacing: 0.3,
        ) ??
        TextStyle(
          color: colorScheme.primary.withOpacity(0.85),
          fontWeight: FontWeight.w600,
          fontSize: isCompact ? 8 : 10,
          letterSpacing: 0.3,
        );

    return Container(
      decoration: BoxDecoration(
        color: background,
        shape: BoxShape.circle,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: isCompact ? 6 : 8,
        vertical: isCompact ? 4 : 6,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Rs', style: primaryTextStyle),
          Text('NPR', style: secondaryTextStyle),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    final isMobile = Responsive.isMobile(context);
    final theme = Theme.of(context);
    final mutedColor = theme.textTheme.bodySmall?.color?.withOpacity(0.65) ??
        theme.colorScheme.onSurface.withOpacity(0.6);
    final backgroundTint = color.withOpacity(theme.brightness == Brightness.dark ? 0.22 : 0.12);
    
    return Card(
      elevation: isMobile ? 1 : 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        child: Padding(
          padding: EdgeInsets.all(isMobile ? 12 : 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(isMobile ? 10 : 16),
                decoration: BoxDecoration(
                  color: backgroundTint,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: isMobile ? 24 : 32,
                ),
              ),
              SizedBox(height: isMobile ? 8 : 12),
              Text(
                title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: isMobile ? 13 : 14,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: isMobile ? 2 : 4),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: mutedColor,
                  fontSize: isMobile ? 10 : 12,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAlertCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    final isMobile = Responsive.isMobile(context);
    final theme = Theme.of(context);
    final backgroundTint = color.withOpacity(theme.brightness == Brightness.dark ? 0.18 : 0.12);
    final textColor = theme.textTheme.bodyMedium?.color ?? theme.colorScheme.onSurface;
    final subtitleColor = textColor.withOpacity(0.8);
    
    return Card(
      color: backgroundTint,
      elevation: isMobile ? 1 : 2,
      child: ListTile(
        dense: isMobile,
        contentPadding: EdgeInsets.symmetric(
          horizontal: isMobile ? 12 : 16,
          vertical: isMobile ? 4 : 8,
        ),
        leading: Icon(
          icon,
          color: color,
          size: isMobile ? 24 : 32,
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: isMobile ? 13 : 14,
            color: textColor,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: isMobile ? 11 : 12,
            color: subtitleColor,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: isMobile ? 14 : 16,
        ),
        onTap: () {
          // Navigate to products screen
          Navigator.pushNamed(context, AppRouter.products);
        },
      ),
    );
  }

  Widget _buildDemoDataCard(BuildContext context) {
    final isMobile = Responsive.isMobile(context);
    final farmerController = Provider.of<FarmerController>(context);
    // Check if we have more than 20 farmers (likely demo data)
    final hasDemoData = farmerController.farmers.length > 20;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final backgroundColor = hasDemoData
        ? colorScheme.secondaryContainer.withOpacity(theme.brightness == Brightness.dark ? 0.35 : 0.7)
        : colorScheme.primaryContainer.withOpacity(theme.brightness == Brightness.dark ? 0.35 : 0.7);
    final accentColor = hasDemoData ? colorScheme.secondary : colorScheme.primary;
    final textColor = theme.textTheme.bodyMedium?.color ?? colorScheme.onSurface;
    final errorColor = colorScheme.error;
    final errorBorderColor = errorColor.withOpacity(
      theme.brightness == Brightness.dark ? 0.45 : 0.35,
    );
    
    return Card(
      color: backgroundColor,
      elevation: isMobile ? 1 : 2,
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 12 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  hasDemoData ? Icons.check_circle : Icons.science,
                  color: accentColor,
                  size: isMobile ? 20 : 24,
                ),
                SizedBox(width: isMobile ? 8 : 12),
                Expanded(
                  child: Text(
                    hasDemoData ? 'Demo Data Loaded' : 'Demo Data for Testing',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontSize: isMobile ? 14 : 16,
                      fontWeight: FontWeight.bold,
                      color: accentColor,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: isMobile ? 8 : 12),
            Text(
              hasDemoData 
                  ? 'Demo data is currently loaded in your app. You can clear it anytime.'
                  : 'Load 50 demo farmers instantly (1-2 sec ⚡).',
              style: theme.textTheme.bodySmall?.copyWith(
                fontSize: isMobile ? 12 : 13,
                color: textColor.withOpacity(0.85),
              ),
            ),
            SizedBox(height: isMobile ? 8 : 12),
            Row(
              children: [
                if (!hasDemoData)
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => _buildLoadDemoDialog(context),
                        );
                      },
                      icon: Icon(
                        Icons.download,
                        size: isMobile ? 16 : 18,
                      ),
                      label: Text(
                        'Load Demo Data',
                        style: TextStyle(fontSize: isMobile ? 12 : 13),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accentColor,
                        foregroundColor: colorScheme.onPrimary,
                        padding: EdgeInsets.symmetric(
                          vertical: isMobile ? 8 : 12,
                        ),
                      ),
                    ),
                  ),
                if (hasDemoData)
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => _buildClearDemoDialog(context),
                        );
                      },
                      icon: Icon(
                        Icons.delete_outline,
                        size: isMobile ? 16 : 18,
                      ),
                      label: Text(
                        'Clear Demo Data',
                        style: TextStyle(fontSize: isMobile ? 12 : 13),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: errorColor,
                        side: BorderSide(color: errorBorderColor),
                        padding: EdgeInsets.symmetric(
                          vertical: isMobile ? 8 : 12,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadDemoDialog(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final primaryColor = colorScheme.primary;
    final infoContainerColor = colorScheme.primaryContainer.withOpacity(
      theme.brightness == Brightness.dark ? 0.35 : 0.6,
    );
    final highlightTextColor = theme.textTheme.bodySmall?.color?.withOpacity(0.85) ??
        colorScheme.onSurface.withOpacity(0.8);

    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.science, color: primaryColor),
          const SizedBox(width: 12),
          Text(
            'Load Demo Data',
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'This will create:',
            style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          _buildInfoRow(context, Icons.people, '50 demo farmers'),
          const SizedBox(height: 8),
          _buildInfoRow(context, Icons.water_drop, '~45 milk collections'),
          const SizedBox(height: 8),
          _buildInfoRow(context, Icons.calendar_today, '3 days of history'),
          const SizedBox(height: 8),
          _buildInfoRow(context, Icons.timer, '1-2 seconds ⚡⚡'),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: infoContainerColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: primaryColor, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Perfect for testing the responsive UI and performance!',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontSize: 12,
                      color: highlightTextColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton.icon(
          onPressed: () {
            Navigator.pop(context);
            final authController = Provider.of<AuthController>(context, listen: false);
            DemoDataService.loadDemoData(
              context: context,
              collectorId: authController.currentUser?.id ?? 'demo-collector',
              farmerCount: 50,
              daysBack: 3,
            );
          },
          icon: const Icon(Icons.download),
          label: const Text('Load Demo Data'),
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            foregroundColor: colorScheme.onPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildClearDemoDialog(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final warningColor = AppTheme.warningColor;
    final errorColor = colorScheme.error;
    final errorContainerColor = colorScheme.errorContainer.withOpacity(
      theme.brightness == Brightness.dark ? 0.35 : 0.6,
    );
    final warningTextColor = theme.textTheme.bodySmall?.color?.withOpacity(0.85) ??
        colorScheme.onSurface.withOpacity(0.8);

    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.warning, color: warningColor),
          const SizedBox(width: 12),
          Text(
            'Clear Demo Data',
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'This will remove all demo farmers and milk collections.',
            style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: errorContainerColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: errorColor, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Only demo data (starting with "demo_") will be removed.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontSize: 12,
                      color: warningTextColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton.icon(
          onPressed: () {
            Navigator.pop(context);
            DemoDataService.clearDemoData(context: context);
          },
          icon: const Icon(Icons.delete),
          label: const Text('Clear Demo Data'),
          style: ElevatedButton.styleFrom(
            backgroundColor: errorColor,
            foregroundColor: colorScheme.onError,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String text) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final iconColor = colorScheme.primary;
    final textStyle = theme.textTheme.bodySmall?.copyWith(
          fontSize: 13,
          color: theme.textTheme.bodySmall?.color ?? colorScheme.onSurface,
        ) ??
        TextStyle(
          fontSize: 13,
          color: colorScheme.onSurface,
        );

    return Row(
      children: [
        Icon(icon, size: 20, color: iconColor),
        const SizedBox(width: 12),
        Text(text, style: textStyle),
      ],
    );
  }

  Widget _buildDemoList(BuildContext context, List<String> items) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final bulletColor = colorScheme.primary;
    final textStyle = theme.textTheme.bodySmall?.copyWith(fontSize: 12) ??
        TextStyle(fontSize: 12, color: colorScheme.onSurface);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items.map((item) => Padding(
        padding: const EdgeInsets.only(left: 12, bottom: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('• ', style: TextStyle(fontSize: 12, color: bulletColor)),
            Expanded(
              child: Text(
                item,
                style: textStyle,
              ),
            ),
          ],
        ),
      )).toList(),
    );
  }
}
