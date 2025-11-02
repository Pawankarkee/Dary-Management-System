import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../controllers/purchase_controller.dart';
import '../../../controllers/supplier_controller.dart';
import '../../../models/purchase_model.dart';
import '../../../config/theme/app_theme.dart';
import '../../../config/constants/app_constants.dart';
import '../../../utils/responsive.dart';
import '../../../config/routes/app_router.dart';

class PurchasesScreen extends StatefulWidget {
  const PurchasesScreen({super.key});

  @override
  State<PurchasesScreen> createState() => _PurchasesScreenState();
}

class _PurchasesScreenState extends State<PurchasesScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<PurchaseController>(context, listen: false).loadPurchases();
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
    final purchaseController = Provider.of<PurchaseController>(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    return Scaffold(
      backgroundColor: AppTheme.lightBackground,
      body: purchaseController.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Header with Search and Filters
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
                          hintText: 'Search by invoice number or supplier...',
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: purchaseController.searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    _searchController.clear();
                                    purchaseController.clearFilters();
                                  },
                                )
                              : null,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onChanged: (value) => purchaseController.searchPurchases(value),
                      ),
                      
                      SizedBox(height: isMobile ? MobileSizes.spaceM : 16),

                      // Filters Row
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildFilterChip(
                              'All',
                              purchaseController.filterStatus == null &&
                                  purchaseController.filterPaymentStatus == null,
                              () => purchaseController.clearFilters(),
                              isMobile,
                            ),
                            SizedBox(width: isMobile ? MobileSizes.spaceS : 8),
                            _buildFilterChip(
                              'Pending',
                              purchaseController.filterStatus == PurchaseStatus.pending,
                              () => purchaseController.filterByStatus(PurchaseStatus.pending),
                              isMobile,
                            ),
                            SizedBox(width: isMobile ? MobileSizes.spaceS : 8),
                            _buildFilterChip(
                              'Received',
                              purchaseController.filterStatus == PurchaseStatus.received,
                              () => purchaseController.filterByStatus(PurchaseStatus.received),
                              isMobile,
                            ),
                            SizedBox(width: isMobile ? MobileSizes.spaceS : 8),
                            _buildFilterChip(
                              'Unpaid',
                              purchaseController.filterPaymentStatus == PaymentStatus.unpaid,
                              () => purchaseController.filterByPaymentStatus(PaymentStatus.unpaid),
                              isMobile,
                            ),
                            SizedBox(width: isMobile ? MobileSizes.spaceS : 8),
                            _buildFilterChip(
                              'Overdue',
                              false,
                              () {
                                // Show overdue purchases
                                purchaseController.clearFilters();
                              },
                              isMobile,
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: isMobile ? MobileSizes.spaceM : 16),

                      // Statistics Row
                      _buildStatisticsRow(purchaseController, isMobile),
                    ],
                  ),
                ),

                // Purchases List
                Expanded(
                  child: purchaseController.purchases.isEmpty
                      ? _buildEmptyState(isMobile)
                      : ListView.builder(
                          padding: EdgeInsets.all(isMobile ? MobileSizes.spaceL : 20),
                          itemCount: purchaseController.purchases.length,
                          itemBuilder: (context, index) {
                            final purchase = purchaseController.purchases[index];
                            return _buildPurchaseCard(purchase, isMobile, context);
                          },
                        ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushNamed(context, AppRouter.addPurchase);
        },
        icon: const Icon(Icons.add),
        label: Text(isMobile ? 'Add' : 'Add Purchase'),
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected, VoidCallback onTap, bool isMobile) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onTap(),
      selectedColor: AppTheme.primaryColor.withOpacity(0.2),
      checkmarkColor: AppTheme.primaryColor,
      labelStyle: TextStyle(
        fontSize: isMobile ? MobileSizes.caption : 12,
        color: isSelected ? AppTheme.primaryColor : Colors.grey.shade700,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  Widget _buildStatisticsRow(PurchaseController controller, bool isMobile) {
    final stats = controller.getPurchaseStatistics();

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Total',
            stats['totalPurchases'].toString(),
            Icons.shopping_bag,
            AppTheme.primaryColor,
            isMobile,
          ),
        ),
        SizedBox(width: isMobile ? 8 : 12),
        Expanded(
          child: _buildStatCard(
            'Amount',
            '${AppConstants.RUPEE_SYMBOL}${(stats['totalAmount'] as double).toStringAsFixed(0)}',
            Icons.currency_rupee,
            AppTheme.accentColor,
            isMobile,
          ),
        ),
        SizedBox(width: isMobile ? 8 : 12),
        Expanded(
          child: _buildStatCard(
            'Outstanding',
            '${AppConstants.RUPEE_SYMBOL}${(stats['totalOutstanding'] as double).toStringAsFixed(0)}',
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
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
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

  Widget _buildPurchaseCard(PurchaseModel purchase, bool isMobile, BuildContext context) {
    final isOverdue = purchase.dueDate.isBefore(DateTime.now()) &&
        (purchase.paymentStatus != PaymentStatus.paid);

    return Card(
      margin: EdgeInsets.only(bottom: isMobile ? MobileSizes.spaceM : 12),
      elevation: isMobile ? MobileSizes.cardElevation : 2,
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(
            context,
            AppRouter.purchaseDetail,
            arguments: purchase.id,
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
                  // Purchase Icon
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.shopping_bag,
                      color: AppTheme.primaryColor,
                      size: isMobile ? MobileSizes.iconLarge : 28,
                    ),
                  ),
                  SizedBox(width: isMobile ? MobileSizes.spaceM : 12),
                  
                  // Invoice and Supplier
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          purchase.invoiceNumber,
                          style: TextStyle(
                            fontSize: isMobile ? MobileSizes.bodyLarge : 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: isMobile ? 2 : 4),
                        Text(
                          purchase.supplierName,
                          style: TextStyle(
                            fontSize: isMobile ? MobileSizes.bodySmall : 13,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Amount
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${AppConstants.RUPEE_SYMBOL}${purchase.totalAmount.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontSize: isMobile ? MobileSizes.bodyLarge : 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      if (purchase.balanceAmount > 0)
                        Text(
                          'Due: ${AppConstants.RUPEE_SYMBOL}${purchase.balanceAmount.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontSize: isMobile ? MobileSizes.caption : 11,
                            color: isOverdue ? AppTheme.errorColor : Colors.orange,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                    ],
                  ),
                ],
              ),

              SizedBox(height: isMobile ? MobileSizes.spaceM : 12),
              const Divider(height: 1),
              SizedBox(height: isMobile ? MobileSizes.spaceM : 12),

              // Details Row
              Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: isMobile ? MobileSizes.iconSmall : 16,
                          color: Colors.grey,
                        ),
                        SizedBox(width: isMobile ? MobileSizes.spaceXS : 6),
                        Text(
                          DateFormat('MMM dd, yyyy').format(purchase.purchaseDate),
                          style: TextStyle(
                            fontSize: isMobile ? MobileSizes.bodySmall : 13,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Status Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor(purchase.status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _getStatusLabel(purchase.status),
                      style: TextStyle(
                        fontSize: isMobile ? MobileSizes.caption : 10,
                        color: _getStatusColor(purchase.status),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  SizedBox(width: isMobile ? MobileSizes.spaceS : 8),
                  
                  // Payment Status Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getPaymentStatusColor(purchase.paymentStatus).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _getPaymentStatusLabel(purchase.paymentStatus),
                      style: TextStyle(
                        fontSize: isMobile ? MobileSizes.caption : 10,
                        color: _getPaymentStatusColor(purchase.paymentStatus),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),

              // Items Preview
              if (purchase.items.isNotEmpty) ...[
                SizedBox(height: isMobile ? MobileSizes.spaceM : 12),
                Text(
                  '${purchase.items.length} item(s) - ${purchase.items.map((i) => i.itemName).take(2).join(", ")}${purchase.items.length > 2 ? "..." : ""}',
                  style: TextStyle(
                    fontSize: isMobile ? MobileSizes.bodySmall : 12,
                    color: Colors.grey.shade600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],

              // Overdue Warning
              if (isOverdue) ...[
                SizedBox(height: isMobile ? MobileSizes.spaceS : 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.errorColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.warning_amber,
                        size: isMobile ? MobileSizes.iconSmall : 16,
                        color: AppTheme.errorColor,
                      ),
                      SizedBox(width: isMobile ? MobileSizes.spaceXS : 6),
                      Text(
                        'Overdue - Due date: ${DateFormat('MMM dd').format(purchase.dueDate)}',
                        style: TextStyle(
                          fontSize: isMobile ? MobileSizes.caption : 11,
                          color: AppTheme.errorColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isMobile) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_bag_outlined,
            size: isMobile ? 80 : 100,
            color: Colors.grey.shade300,
          ),
          SizedBox(height: isMobile ? MobileSizes.spaceL : 20),
          Text(
            'No Purchases Yet',
            style: TextStyle(
              fontSize: isMobile ? MobileSizes.sectionTitle : 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade600,
            ),
          ),
          SizedBox(height: isMobile ? MobileSizes.spaceS : 8),
          Text(
            'Add your first purchase to get started',
            style: TextStyle(
              fontSize: isMobile ? MobileSizes.bodyMedium : 14,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(PurchaseStatus status) {
    switch (status) {
      case PurchaseStatus.pending:
        return Colors.orange;
      case PurchaseStatus.received:
        return AppTheme.successColor;
      case PurchaseStatus.cancelled:
        return Colors.red;
    }
  }

  String _getStatusLabel(PurchaseStatus status) {
    switch (status) {
      case PurchaseStatus.pending:
        return 'PENDING';
      case PurchaseStatus.received:
        return 'RECEIVED';
      case PurchaseStatus.cancelled:
        return 'CANCELLED';
    }
  }

  Color _getPaymentStatusColor(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.unpaid:
        return AppTheme.errorColor;
      case PaymentStatus.partial:
        return Colors.orange;
      case PaymentStatus.paid:
        return AppTheme.successColor;
    }
  }

  String _getPaymentStatusLabel(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.unpaid:
        return 'UNPAID';
      case PaymentStatus.partial:
        return 'PARTIAL';
      case PaymentStatus.paid:
        return 'PAID';
    }
  }
}
