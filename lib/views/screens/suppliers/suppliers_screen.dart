import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../controllers/supplier_controller.dart';
import '../../../models/supplier_model.dart';
import '../../../config/theme/app_theme.dart';
import '../../../config/constants/app_constants.dart';
import '../../../utils/responsive.dart';
import '../../../config/routes/app_router.dart';

class SuppliersScreen extends StatefulWidget {
  const SuppliersScreen({super.key});

  @override
  State<SuppliersScreen> createState() => _SuppliersScreenState();
}

class _SuppliersScreenState extends State<SuppliersScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<SupplierController>(context, listen: false).loadSuppliers();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final supplierController = Provider.of<SupplierController>(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Suppliers'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
          tooltip: 'Back',
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.pushNamed(context, AppRouter.addSupplier);
            },
            tooltip: 'Add Supplier',
          ),
        ],
      ),
      backgroundColor: AppTheme.lightBackground,
      body: supplierController.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Search and Stats Header
                Container(
                  padding: EdgeInsets.all(isMobile ? MobileSizes.spaceL : 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Search Bar
                      TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Search by name, phone, or contact person...',
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: supplierController.searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    _searchController.clear();
                                    supplierController.clearSearch();
                                  },
                                )
                              : null,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onChanged: (value) => supplierController.searchSuppliers(value),
                      ),
                      
                      SizedBox(height: isMobile ? MobileSizes.spaceM : 16),

                      // Statistics Row
                      _buildStatisticsRow(supplierController, isMobile),
                    ],
                  ),
                ),

                // Suppliers List
                Expanded(
                  child: supplierController.suppliers.isEmpty
                      ? _buildEmptyState(isMobile)
                      : ListView.builder(
                          padding: EdgeInsets.all(isMobile ? MobileSizes.spaceL : 20),
                          itemCount: supplierController.suppliers.length,
                          itemBuilder: (context, index) {
                            final supplier = supplierController.suppliers[index];
                            return _buildSupplierCard(supplier, isMobile, context);
                          },
                        ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushNamed(context, AppRouter.addSupplier);
        },
        icon: const Icon(Icons.add),
        label: Text(isMobile ? 'Add' : 'Add Supplier'),
      ),
    );
  }

  Widget _buildStatisticsRow(SupplierController controller, bool isMobile) {
    final stats = controller.getSupplierStatistics();

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Total',
            stats['totalSuppliers'].toString(),
            Icons.people,
            AppTheme.primaryColor,
            isMobile,
          ),
        ),
        SizedBox(width: isMobile ? 8 : 12),
        Expanded(
          child: _buildStatCard(
            'Active',
            stats['activeSuppliers'].toString(),
            Icons.check_circle,
            AppTheme.successColor,
            isMobile,
          ),
        ),
        SizedBox(width: isMobile ? 8 : 12),
        Expanded(
          child: _buildStatCard(
            'Outstanding',
            '${AppConstants.RUPEE_SYMBOL}${stats['totalOutstanding'].toStringAsFixed(0)}',
            Icons.account_balance_wallet,
            AppTheme.errorColor,
            isMobile,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color, bool isMobile) {
    return Card(
      elevation: isMobile ? MobileSizes.cardElevation : 2,
      child: Padding(
        padding: EdgeInsets.all(isMobile ? MobileSizes.spaceM : 12),
        child: Column(
          children: [
            Icon(icon, color: color, size: isMobile ? MobileSizes.iconMedium : 24),
            SizedBox(height: isMobile ? MobileSizes.spaceXS : 4),
            Text(
              value,
              style: TextStyle(
                fontSize: isMobile ? MobileSizes.bodyMedium : 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: isMobile ? MobileSizes.caption : 11,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSupplierCard(SupplierModel supplier, bool isMobile, BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: isMobile ? MobileSizes.spaceM : 12),
      elevation: isMobile ? MobileSizes.cardElevation : 2,
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(
            context,
            AppRouter.supplierDetail,
            arguments: supplier.id,
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(isMobile ? MobileSizes.cardPadding : 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                children: [
                  // Supplier Type Icon
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _getSupplierTypeColor(supplier.supplierType).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getSupplierTypeIcon(supplier.supplierType),
                      color: _getSupplierTypeColor(supplier.supplierType),
                      size: isMobile ? MobileSizes.iconLarge : 28,
                    ),
                  ),
                  SizedBox(width: isMobile ? MobileSizes.spaceM : 12),
                  
                  // Supplier Name and Type
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          supplier.name,
                          style: TextStyle(
                            fontSize: isMobile ? MobileSizes.bodyLarge : 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: isMobile ? 2 : 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: _getSupplierTypeColor(supplier.supplierType).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                _getSupplierTypeLabel(supplier.supplierType),
                                style: TextStyle(
                                  fontSize: isMobile ? MobileSizes.caption : 10,
                                  color: _getSupplierTypeColor(supplier.supplierType),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            SizedBox(width: isMobile ? MobileSizes.spaceS : 8),
                            if (!supplier.isActive)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.grey.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'Inactive',
                                  style: TextStyle(
                                    fontSize: isMobile ? MobileSizes.caption : 10,
                                    color: Colors.grey,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Balance Badge
                  if (supplier.currentBalance > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppTheme.errorColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${AppConstants.RUPEE_SYMBOL}${supplier.currentBalance.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontSize: isMobile ? MobileSizes.bodySmall : 12,
                          color: AppTheme.errorColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),

              SizedBox(height: isMobile ? MobileSizes.spaceM : 12),
              const Divider(height: 1),
              SizedBox(height: isMobile ? MobileSizes.spaceM : 12),

              // Contact Details
              Row(
                children: [
                  Expanded(
                    child: _buildInfoRow(
                      Icons.person,
                      supplier.contactPerson,
                      isMobile,
                    ),
                  ),
                  SizedBox(width: isMobile ? MobileSizes.spaceM : 16),
                  Expanded(
                    child: _buildInfoRow(
                      Icons.phone,
                      supplier.phone,
                      isMobile,
                    ),
                  ),
                ],
              ),

              if (supplier.address.isNotEmpty) ...[
                SizedBox(height: isMobile ? MobileSizes.spaceS : 8),
                _buildInfoRow(
                  Icons.location_on,
                  supplier.address,
                  isMobile,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text, bool isMobile) {
    return Row(
      children: [
        Icon(
          icon,
          size: isMobile ? MobileSizes.iconSmall : 16,
          color: Colors.grey,
        ),
        SizedBox(width: isMobile ? MobileSizes.spaceXS : 6),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: isMobile ? MobileSizes.bodySmall : 13,
              color: Colors.grey.shade700,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(bool isMobile) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.store,
            size: isMobile ? 80 : 100,
            color: Colors.grey.shade300,
          ),
          SizedBox(height: isMobile ? MobileSizes.spaceL : 20),
          Text(
            'No Suppliers Yet',
            style: TextStyle(
              fontSize: isMobile ? MobileSizes.sectionTitle : 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade600,
            ),
          ),
          SizedBox(height: isMobile ? MobileSizes.spaceS : 8),
          Text(
            'Add your first supplier to get started',
            style: TextStyle(
              fontSize: isMobile ? MobileSizes.bodyMedium : 14,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getSupplierTypeIcon(SupplierType type) {
    switch (type) {
      case SupplierType.feed:
        return Icons.grass;
      case SupplierType.packaging:
        return Icons.inventory;
      case SupplierType.equipment:
        return Icons.build;
      case SupplierType.general:
        return Icons.store;
      case SupplierType.other:
        return Icons.category;
    }
  }

  Color _getSupplierTypeColor(SupplierType type) {
    switch (type) {
      case SupplierType.feed:
        return Colors.green;
      case SupplierType.packaging:
        return Colors.orange;
      case SupplierType.equipment:
        return Colors.blue;
      case SupplierType.general:
        return AppTheme.primaryColor;
      case SupplierType.other:
        return Colors.purple;
    }
  }

  String _getSupplierTypeLabel(SupplierType type) {
    switch (type) {
      case SupplierType.feed:
        return 'FEED';
      case SupplierType.packaging:
        return 'PACKAGING';
      case SupplierType.equipment:
        return 'EQUIPMENT';
      case SupplierType.general:
        return 'GENERAL';
      case SupplierType.other:
        return 'OTHER';
    }
  }
}
