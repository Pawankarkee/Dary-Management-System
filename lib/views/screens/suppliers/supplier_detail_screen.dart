import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../controllers/supplier_controller.dart';
import '../../../controllers/purchase_controller.dart';
import '../../../models/supplier_model.dart';
import '../../../config/theme/app_theme.dart';
import '../../../config/constants/app_constants.dart';
import '../../../utils/responsive.dart';
import 'add_supplier_screen.dart';

class SupplierDetailScreen extends StatefulWidget {
  final String supplierId;

  const SupplierDetailScreen({super.key, required this.supplierId});

  @override
  State<SupplierDetailScreen> createState() => _SupplierDetailScreenState();
}

class _SupplierDetailScreenState extends State<SupplierDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<PurchaseController>(context, listen: false).loadPurchases();
    });
  }

  @override
  Widget build(BuildContext context) {
    final supplierController = Provider.of<SupplierController>(context);
    final purchaseController = Provider.of<PurchaseController>(context);
    final supplier = supplierController.getSupplierById(widget.supplierId);

    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    if (supplier == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Supplier Details')),
        body: const Center(child: Text('Supplier not found')),
      );
    }

    final purchases = purchaseController.getPurchasesBySupplier(widget.supplierId);

    return Scaffold(
      backgroundColor: AppTheme.lightBackground,
      appBar: AppBar(
        title: const Text('Supplier Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddSupplierScreen(supplier: supplier),
                ),
              );
            },
            tooltip: 'Edit',
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _showDeleteDialog(context, supplier),
            tooltip: 'Delete',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(isMobile ? MobileSizes.spaceL : 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Supplier Header Card
            _buildHeaderCard(supplier, isMobile),

            SizedBox(height: isMobile ? MobileSizes.spaceL : 20),

            // Contact Information
            _buildContactCard(supplier, isMobile),

            SizedBox(height: isMobile ? MobileSizes.spaceL : 20),

            // Financial Summary
            _buildFinancialCard(supplier, purchases, isMobile),

            SizedBox(height: isMobile ? MobileSizes.spaceL : 20),

            // Purchase History
            _buildPurchaseHistory(purchases, isMobile),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard(SupplierModel supplier, bool isMobile) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(isMobile ? MobileSizes.cardPadding : 20),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _getSupplierTypeColor(supplier.supplierType).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getSupplierTypeIcon(supplier.supplierType),
                    size: isMobile ? 40 : 48,
                    color: _getSupplierTypeColor(supplier.supplierType),
                  ),
                ),
                SizedBox(width: isMobile ? MobileSizes.spaceM : 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        supplier.name,
                        style: TextStyle(
                          fontSize: isMobile ? MobileSizes.screenTitle : 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: isMobile ? MobileSizes.spaceXS : 6),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: _getSupplierTypeColor(supplier.supplierType).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              _getSupplierTypeLabel(supplier.supplierType),
                              style: TextStyle(
                                fontSize: isMobile ? MobileSizes.caption : 12,
                                color: _getSupplierTypeColor(supplier.supplierType),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          SizedBox(width: isMobile ? MobileSizes.spaceS : 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: supplier.isActive
                                  ? AppTheme.successColor.withOpacity(0.1)
                                  : Colors.grey.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              supplier.isActive ? 'Active' : 'Inactive',
                              style: TextStyle(
                                fontSize: isMobile ? MobileSizes.caption : 12,
                                color: supplier.isActive ? AppTheme.successColor : Colors.grey,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (supplier.notes != null && supplier.notes!.isNotEmpty) ...[
              SizedBox(height: isMobile ? MobileSizes.spaceM : 16),
              const Divider(),
              SizedBox(height: isMobile ? MobileSizes.spaceM : 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.note,
                    size: isMobile ? MobileSizes.iconSmall : 20,
                    color: Colors.grey,
                  ),
                  SizedBox(width: isMobile ? MobileSizes.spaceS : 8),
                  Expanded(
                    child: Text(
                      supplier.notes!,
                      style: TextStyle(
                        fontSize: isMobile ? MobileSizes.bodyMedium : 14,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildContactCard(SupplierModel supplier, bool isMobile) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(isMobile ? MobileSizes.cardPadding : 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Contact Information',
              style: TextStyle(
                fontSize: isMobile ? MobileSizes.sectionTitle : 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: isMobile ? MobileSizes.spaceM : 16),
            _buildInfoRow(Icons.person, 'Contact Person', supplier.contactPerson, isMobile),
            SizedBox(height: isMobile ? MobileSizes.spaceM : 12),
            _buildInfoRow(Icons.phone, 'Phone', supplier.phone, isMobile),
            if (supplier.email != null) ...[
              SizedBox(height: isMobile ? MobileSizes.spaceM : 12),
              _buildInfoRow(Icons.email, 'Email', supplier.email!, isMobile),
            ],
            SizedBox(height: isMobile ? MobileSizes.spaceM : 12),
            _buildInfoRow(Icons.location_on, 'Address', supplier.address, isMobile),
            if (supplier.gstin != null) ...[
              SizedBox(height: isMobile ? MobileSizes.spaceM : 12),
              _buildInfoRow(Icons.receipt_long, 'GSTIN', supplier.gstin!, isMobile),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFinancialCard(SupplierModel supplier, List purchases, bool isMobile) {
    final totalPurchases = purchases.fold<double>(
      0,
      (sum, purchase) => sum + purchase.totalAmount,
    );

    return Card(
      child: Padding(
        padding: EdgeInsets.all(isMobile ? MobileSizes.cardPadding : 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Financial Summary',
              style: TextStyle(
                fontSize: isMobile ? MobileSizes.sectionTitle : 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: isMobile ? MobileSizes.spaceM : 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatBox(
                    'Total Purchases',
                    '${AppConstants.RUPEE_SYMBOL}${totalPurchases.toStringAsFixed(0)}',
                    AppTheme.primaryColor,
                    isMobile,
                  ),
                ),
                SizedBox(width: isMobile ? MobileSizes.spaceM : 16),
                Expanded(
                  child: _buildStatBox(
                    'Outstanding',
                    '${AppConstants.RUPEE_SYMBOL}${supplier.currentBalance.toStringAsFixed(0)}',
                    supplier.currentBalance > 0 ? AppTheme.errorColor : AppTheme.successColor,
                    isMobile,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatBox(String label, String value, Color color, bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? MobileSizes.spaceM : 16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isMobile ? MobileSizes.caption : 12,
              color: Colors.grey.shade700,
            ),
          ),
          SizedBox(height: isMobile ? MobileSizes.spaceXS : 6),
          Text(
            value,
            style: TextStyle(
              fontSize: isMobile ? MobileSizes.bodyLarge : 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPurchaseHistory(List purchases, bool isMobile) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(isMobile ? MobileSizes.cardPadding : 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Purchase History',
                  style: TextStyle(
                    fontSize: isMobile ? MobileSizes.sectionTitle : 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${purchases.length} purchases',
                  style: TextStyle(
                    fontSize: isMobile ? MobileSizes.bodySmall : 13,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            SizedBox(height: isMobile ? MobileSizes.spaceM : 16),
            if (purchases.isEmpty)
              Center(
                child: Padding(
                  padding: EdgeInsets.all(isMobile ? MobileSizes.spaceXL : 32),
                  child: Text(
                    'No purchases yet',
                    style: TextStyle(
                      fontSize: isMobile ? MobileSizes.bodyMedium : 14,
                      color: Colors.grey,
                    ),
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: purchases.length > 5 ? 5 : purchases.length,
                separatorBuilder: (_, __) => Divider(height: isMobile ? 20 : 24),
                itemBuilder: (context, index) {
                  final purchase = purchases[index];
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(
                      Icons.shopping_bag,
                      color: AppTheme.primaryColor,
                      size: isMobile ? MobileSizes.iconMedium : 24,
                    ),
                    title: Text(
                      'Invoice: ${purchase.invoiceNumber}',
                      style: TextStyle(
                        fontSize: isMobile ? MobileSizes.bodyMedium : 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      DateFormat('MMM dd, yyyy').format(purchase.purchaseDate),
                      style: TextStyle(
                        fontSize: isMobile ? MobileSizes.bodySmall : 12,
                      ),
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${AppConstants.RUPEE_SYMBOL}${purchase.totalAmount.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontSize: isMobile ? MobileSizes.bodyMedium : 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (purchase.balanceAmount > 0)
                          Text(
                            'Due: ${AppConstants.RUPEE_SYMBOL}${purchase.balanceAmount.toStringAsFixed(0)}',
                            style: TextStyle(
                              fontSize: isMobile ? MobileSizes.caption : 11,
                              color: AppTheme.errorColor,
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            if (purchases.length > 5) ...[
              SizedBox(height: isMobile ? MobileSizes.spaceM : 12),
              TextButton(
                onPressed: () {
                  // TODO: Navigate to full purchase list filtered by this supplier
                },
                child: const Text('View All Purchases'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, bool isMobile) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: isMobile ? MobileSizes.iconSmall : 20,
          color: Colors.grey,
        ),
        SizedBox(width: isMobile ? MobileSizes.spaceM : 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: isMobile ? MobileSizes.caption : 12,
                  color: Colors.grey,
                ),
              ),
              SizedBox(height: isMobile ? 2 : 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: isMobile ? MobileSizes.bodyMedium : 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showDeleteDialog(BuildContext context, SupplierModel supplier) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Supplier'),
        content: Text('Are you sure you want to delete ${supplier.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              try {
                await Provider.of<SupplierController>(context, listen: false)
                    .deleteSupplier(supplier.id);
                if (context.mounted) {
                  Navigator.pop(context); // Close dialog
                  Navigator.pop(context); // Go back to list
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Supplier deleted successfully')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
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
