import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../controllers/product_controller.dart';
import '../../../config/theme/app_theme.dart';
import '../../../models/product_model.dart';
import '../../../utils/responsive.dart';
import 'add_product_screen.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  final _searchController = TextEditingController();
  ProductCategory? _selectedFilter;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Filter by Category',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilterChip(
                  label: const Text('All'),
                  selected: _selectedFilter == null,
                  onSelected: (selected) {
                    setState(() => _selectedFilter = null);
                    context.read<ProductController>().setFilter(null);
                    Navigator.pop(context);
                  },
                ),
                ...ProductCategory.values.map((category) {
                  return FilterChip(
                    label: Text(_getCategoryName(category)),
                    selected: _selectedFilter == category,
                    avatar: Icon(
                      _getCategoryIcon(category),
                      size: 18,
                    ),
                    onSelected: (selected) {
                      setState(() => _selectedFilter = category);
                      context.read<ProductController>().setFilter(category);
                      Navigator.pop(context);
                    },
                  );
                }),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
          tooltip: 'Back',
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddProductScreen()),
              );
            },
            tooltip: 'Add Product',
          ),
        ],
      ),
      backgroundColor: AppTheme.lightBackground,
      body: Column(
        children: [
          // Search and Filter Bar
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
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Search products by name...',
                          hintStyle: TextStyle(
                            fontSize: isMobile ? MobileSizes.bodyMedium : 14,
                          ),
                          prefixIcon: Icon(
                            Icons.search,
                            color: AppTheme.primaryColor,
                            size: isMobile ? MobileSizes.iconMedium : 20,
                          ),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: Icon(
                                    Icons.clear,
                                    size: isMobile ? MobileSizes.iconSmall : 18,
                                  ),
                                  onPressed: () {
                                    _searchController.clear();
                                    context.read<ProductController>().searchProducts('');
                                  },
                                )
                              : null,
                          filled: true,
                          fillColor: Colors.grey.shade50,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: AppTheme.primaryColor,
                              width: 2,
                            ),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: isMobile ? MobileSizes.fieldPaddingH : 16,
                            vertical: isMobile ? MobileSizes.fieldPaddingV : 12,
                          ),
                        ),
                        onChanged: (value) {
                          context.read<ProductController>().searchProducts(value);
                        },
                      ),
                    ),
                    SizedBox(width: isMobile ? MobileSizes.spaceS : 12),
                    IconButton(
                      icon: Badge(
                        label: Text(_selectedFilter != null ? '1' : ''),
                        isLabelVisible: _selectedFilter != null,
                        child: Icon(
                          Icons.filter_list,
                          size: isMobile ? MobileSizes.iconLarge : 24,
                        ),
                      ),
                      onPressed: _showFilterSheet,
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.grey.shade100,
                        padding: EdgeInsets.all(isMobile ? 10 : 12),
                      ),
                    ),
                  ],
                ),
                
                // Quick stats
                Consumer<ProductController>(
                  builder: (context, controller, child) {
                    final totalProducts = controller.products.length;
                    final lowStock = controller.lowStockProducts.length;
                    final expiring = controller.expiringProducts.length;

                    return Padding(
                      padding: EdgeInsets.only(top: isMobile ? MobileSizes.spaceM : 12),
                      child: Row(
                        children: [
                          _buildStatChip(
                            icon: Icons.inventory_2,
                            label: '$totalProducts Products',
                            color: AppTheme.primaryColor,
                            isMobile: isMobile,
                          ),
                          if (lowStock > 0) ...[
                            SizedBox(width: isMobile ? MobileSizes.spaceS : 8),
                            _buildStatChip(
                              icon: Icons.warning_amber,
                              label: '$lowStock Low Stock',
                              color: Colors.orange,
                              isMobile: isMobile,
                            ),
                          ],
                          if (expiring > 0) ...[
                            SizedBox(width: isMobile ? MobileSizes.spaceS : 8),
                            _buildStatChip(
                              icon: Icons.access_time,
                              label: '$expiring Expiring',
                              color: Colors.red,
                              isMobile: isMobile,
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          // Products List
          Expanded(
            child: Consumer<ProductController>(
              builder: (context, controller, child) {
                if (controller.isLoading) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (controller.products.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _searchController.text.isNotEmpty || _selectedFilter != null
                              ? Icons.search_off
                              : Icons.inventory_2_outlined,
                          size: isMobile ? 64 : 80,
                          color: Colors.grey.shade400,
                        ),
                        SizedBox(height: isMobile ? MobileSizes.spaceL : 20),
                        Text(
                          _searchController.text.isNotEmpty || _selectedFilter != null
                              ? 'No products found'
                              : 'No products yet',
                          style: TextStyle(
                            fontSize: isMobile ? MobileSizes.bodyLarge : 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        SizedBox(height: isMobile ? MobileSizes.spaceS : 8),
                        Text(
                          _searchController.text.isNotEmpty || _selectedFilter != null
                              ? 'Try adjusting your search or filters'
                              : 'Add your first product to get started',
                          style: TextStyle(
                            fontSize: isMobile ? MobileSizes.bodySmall : 13,
                            color: Colors.grey.shade600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: controller.loadProducts,
                  child: ListView.separated(
                    padding: EdgeInsets.all(isMobile ? MobileSizes.spaceL : 20),
                    itemCount: controller.products.length,
                    separatorBuilder: (context, index) => SizedBox(
                      height: isMobile ? MobileSizes.spaceM : 12,
                    ),
                    itemBuilder: (context, index) {
                      final product = controller.products[index];
                      return _ProductCard(
                        product: product,
                        isMobile: isMobile,
                        onTap: () => _navigateToEdit(product),
                        onDelete: () => _confirmDelete(product),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToAdd,
        icon: Icon(
          Icons.add,
          size: isMobile ? MobileSizes.iconMedium : 20,
        ),
        label: Text(
          'Add Product',
          style: TextStyle(
            fontSize: isMobile ? MobileSizes.bodyMedium : 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: AppTheme.primaryColor,
      ),
    );
  }

  Widget _buildStatChip({
    required IconData icon,
    required String label,
    required Color color,
    required bool isMobile,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? MobileSizes.spaceS : 10,
        vertical: isMobile ? MobileSizes.spaceXS : 6,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: isMobile ? MobileSizes.iconSmall : 16,
            color: color,
          ),
          SizedBox(width: isMobile ? MobileSizes.spaceXS : 4),
          Text(
            label,
            style: TextStyle(
              fontSize: isMobile ? MobileSizes.bodySmall : 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToAdd() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddProductScreen(),
      ),
    );
  }

  void _navigateToEdit(ProductModel product) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddProductScreen(product: product),
      ),
    );
  }

  void _confirmDelete(ProductModel product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Product'),
        content: Text('Are you sure you want to delete "${product.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await context.read<ProductController>().deleteProduct(product.id);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('✅ ${product.name} deleted'),
                    backgroundColor: AppTheme.successColor,
                  ),
                );
              }
            },
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.errorColor,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(ProductCategory category) {
    switch (category) {
      case ProductCategory.feed:
        return Icons.grass;
      case ProductCategory.medicine:
        return Icons.medication;
      case ProductCategory.salt:
        return Icons.grain;
      case ProductCategory.mineral:
        return Icons.science;
      case ProductCategory.other:
        return Icons.category;
    }
  }

  String _getCategoryName(ProductCategory category) {
    switch (category) {
      case ProductCategory.feed:
        return 'Feed';
      case ProductCategory.medicine:
        return 'Medicine';
      case ProductCategory.salt:
        return 'Salt';
      case ProductCategory.mineral:
        return 'Mineral';
      case ProductCategory.other:
        return 'Other';
    }
  }
}

class _ProductCard extends StatelessWidget {
  final ProductModel product;
  final bool isMobile;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _ProductCard({
    required this.product,
    required this.isMobile,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final profit = product.sellingPrice - product.purchasePrice;
    final profitPercent = (profit / product.purchasePrice * 100);

    return Card(
      elevation: isMobile ? MobileSizes.cardElevation : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          isMobile ? MobileSizes.cardRadius : 12,
        ),
        side: BorderSide(
          color: product.isLowStock
              ? Colors.orange.withOpacity(0.3)
              : (product.isExpired
                  ? Colors.red.withOpacity(0.3)
                  : Colors.transparent),
          width: 2,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(
          isMobile ? MobileSizes.cardRadius : 12,
        ),
        child: Padding(
          padding: EdgeInsets.all(isMobile ? MobileSizes.cardPadding : 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Category Icon
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _getCategoryColor().withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getCategoryIcon(),
                      size: isMobile ? MobileSizes.iconLarge : 24,
                      color: _getCategoryColor(),
                    ),
                  ),
                  SizedBox(width: isMobile ? MobileSizes.spaceM : 12),
                  
                  // Product Name and Category
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.name,
                          style: TextStyle(
                            fontSize: isMobile ? MobileSizes.cardTitle : 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: isMobile ? MobileSizes.spaceXS : 4),
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: isMobile ? 6 : 8,
                                vertical: isMobile ? 2 : 3,
                              ),
                              decoration: BoxDecoration(
                                color: _getCategoryColor().withOpacity(0.15),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                product.categoryDisplay,
                                style: TextStyle(
                                  fontSize: isMobile ? MobileSizes.caption : 11,
                                  fontWeight: FontWeight.w600,
                                  color: _getCategoryColor(),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  // Delete Button
                  IconButton(
                    icon: Icon(
                      Icons.delete_outline,
                      size: isMobile ? MobileSizes.iconMedium : 20,
                      color: AppTheme.errorColor,
                    ),
                    onPressed: onDelete,
                  ),
                ],
              ),
              
              SizedBox(height: isMobile ? MobileSizes.spaceM : 12),
              
              // Price and Stock Info
              Row(
                children: [
                  Expanded(
                    child: _InfoItem(
                      icon: Icons.shopping_cart,
                      label: 'Buy',
                      value: '₹${product.purchasePrice.toStringAsFixed(2)}',
                      isMobile: isMobile,
                    ),
                  ),
                  Expanded(
                    child: _InfoItem(
                      icon: Icons.sell,
                      label: 'Sell',
                      value: '₹${product.sellingPrice.toStringAsFixed(2)}',
                      isMobile: isMobile,
                    ),
                  ),
                  Expanded(
                    child: _InfoItem(
                      icon: Icons.trending_up,
                      label: 'Profit',
                      value: '₹${profit.toStringAsFixed(2)}',
                      valueColor: profit > 0 ? AppTheme.successColor : Colors.grey,
                      isMobile: isMobile,
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: isMobile ? MobileSizes.spaceM : 12),
              
              // Stock Status
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.all(isMobile ? 8 : 10),
                      decoration: BoxDecoration(
                        color: product.isLowStock
                            ? Colors.orange.withOpacity(0.1)
                            : AppTheme.successColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.inventory,
                                size: isMobile ? MobileSizes.iconSmall : 16,
                                color: product.isLowStock
                                    ? Colors.orange
                                    : AppTheme.successColor,
                              ),
                              SizedBox(width: isMobile ? MobileSizes.spaceXS : 6),
                              Text(
                                'Stock:',
                                style: TextStyle(
                                  fontSize: isMobile ? MobileSizes.bodySmall : 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            '${product.currentStock} ${product.unitDisplay}',
                            style: TextStyle(
                              fontSize: isMobile ? MobileSizes.bodySmall : 12,
                              fontWeight: FontWeight.bold,
                              color: product.isLowStock
                                  ? Colors.orange
                                  : AppTheme.successColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              
              // Expiry Date Warning
              if (product.isExpiringSoon || product.isExpired) ...[
                SizedBox(height: isMobile ? MobileSizes.spaceS : 8),
                Container(
                  padding: EdgeInsets.all(isMobile ? 6 : 8),
                  decoration: BoxDecoration(
                    color: product.isExpired
                        ? Colors.red.withOpacity(0.1)
                        : Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        product.isExpired ? Icons.error : Icons.warning_amber,
                        size: isMobile ? MobileSizes.iconSmall : 14,
                        color: product.isExpired ? Colors.red : Colors.orange,
                      ),
                      SizedBox(width: isMobile ? MobileSizes.spaceXS : 6),
                      Expanded(
                        child: Text(
                          product.isExpired
                              ? 'Expired on ${_formatDate(product.expiryDate!)}'
                              : 'Expires on ${_formatDate(product.expiryDate!)}',
                          style: TextStyle(
                            fontSize: isMobile ? MobileSizes.caption : 11,
                            fontWeight: FontWeight.w600,
                            color: product.isExpired ? Colors.red : Colors.orange,
                          ),
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

  IconData _getCategoryIcon() {
    switch (product.category) {
      case ProductCategory.feed:
        return Icons.grass;
      case ProductCategory.medicine:
        return Icons.medication;
      case ProductCategory.salt:
        return Icons.grain;
      case ProductCategory.mineral:
        return Icons.science;
      case ProductCategory.other:
        return Icons.category;
    }
  }

  Color _getCategoryColor() {
    switch (product.category) {
      case ProductCategory.feed:
        return Colors.green;
      case ProductCategory.medicine:
        return Colors.blue;
      case ProductCategory.salt:
        return Colors.purple;
      case ProductCategory.mineral:
        return Colors.orange;
      case ProductCategory.other:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;
  final bool isMobile;

  const _InfoItem({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(
          icon,
          size: isMobile ? MobileSizes.iconSmall : 16,
          color: Colors.grey.shade600,
        ),
        SizedBox(height: isMobile ? MobileSizes.spaceXS : 4),
        Text(
          label,
          style: TextStyle(
            fontSize: isMobile ? MobileSizes.caption : 11,
            color: Colors.grey.shade600,
          ),
        ),
        SizedBox(height: isMobile ? 2 : 2),
        Text(
          value,
          style: TextStyle(
            fontSize: isMobile ? MobileSizes.bodySmall : 12,
            fontWeight: FontWeight.bold,
            color: valueColor ?? Colors.black87,
          ),
        ),
      ],
    );
  }
}
