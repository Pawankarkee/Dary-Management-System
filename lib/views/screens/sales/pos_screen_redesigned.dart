import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../controllers/sales_controller.dart';
import '../../../controllers/product_controller.dart';
import '../../../controllers/farmer_controller.dart';
import '../../../config/theme/app_theme.dart';
import '../../../models/sale_model.dart';
import '../../../models/product_model.dart';
import '../../../utils/responsive.dart';
import '../../../config/constants/app_constants.dart';

/// Redesigned POS Screen with improved UX
/// Features:
/// - Back navigation from cart
/// - Better mobile-responsive layout
/// - Improved product selection
/// - Enhanced cart management
/// - Quick category filters
/// - Barcode scanner support
class POSScreenRedesigned extends StatefulWidget {
  const POSScreenRedesigned({super.key});

  @override
  State<POSScreenRedesigned> createState() => _POSScreenRedesignedState();
}

class _POSScreenRedesignedState extends State<POSScreenRedesigned> {
  final List<CartItem> _cartItems = [];
  final _searchController = TextEditingController();
  final _discountController = TextEditingController();
  final _barcodeController = TextEditingController();
  
  String? _selectedFarmerId;
  String? _selectedFarmerName;
  PaymentMethod _paymentMethod = PaymentMethod.cash;
  double _discount = 0.0;
  bool _isProcessing = false;
  bool _showCart = false; // For mobile toggle between product list and cart
  String _selectedCategory = 'All';

  @override
  void dispose() {
    _searchController.dispose();
    _discountController.dispose();
    _barcodeController.dispose();
    super.dispose();
  }

  double get _subtotal => _cartItems.fold(0.0, (sum, item) => sum + item.total);
  double get _total => _subtotal - _discount;

  void _addToCart(ProductModel product) {
    final existingIndex = _cartItems.indexWhere((item) => item.productId == product.id);
    
    if (existingIndex >= 0) {
      setState(() {
        _cartItems[existingIndex].quantity += 1;
      });
    } else {
      setState(() {
        _cartItems.add(CartItem(
          productId: product.id,
          productName: product.name,
          rate: product.sellingPrice,
          quantity: 1,
        ));
      });
    }

    // Auto-show cart on mobile after adding item
    if (MediaQuery.of(context).size.width < 768) {
      setState(() => _showCart = true);
    }
  }

  void _removeFromCart(int index) {
    setState(() {
      _cartItems.removeAt(index);
    });
  }

  void _updateQuantity(int index, double quantity) {
    if (quantity <= 0) {
      _removeFromCart(index);
    } else {
      setState(() {
        _cartItems[index].quantity = quantity;
      });
    }
  }

  Future<void> _processSale() async {
    if (_cartItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ Cart is empty'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isProcessing = true);

    try {
      final salesController = Provider.of<SalesController>(context, listen: false);
      final productController = Provider.of<ProductController>(context, listen: false);

      final items = _cartItems.map((item) => SaleItemModel(
        productId: item.productId,
        productName: item.productName,
        quantity: item.quantity,
        rate: item.rate,
        amount: item.total,
      )).toList();

      final success = await salesController.addSale(
        items: items,
        paymentMethod: _paymentMethod,
        farmerId: _selectedFarmerId,
        farmerName: _selectedFarmerName,
        discount: _discount,
        productController: productController,
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Sale completed! Total: ${AppConstants.RUPEE_SYMBOL}${_total.toStringAsFixed(2)}'),
            backgroundColor: AppTheme.successColor,
            duration: const Duration(seconds: 3),
          ),
        );

        // Clear cart and reset
        setState(() {
          _cartItems.clear();
          _selectedFarmerId = null;
          _selectedFarmerName = null;
          _discount = 0.0;
          _discountController.clear();
          _showCart = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;
    final productController = Provider.of<ProductController>(context);

    return Scaffold(
      backgroundColor: AppTheme.lightBackground,
      appBar: AppBar(
        elevation: 0,
        title: Row(
          children: [
            Icon(Icons.point_of_sale, size: 24),
            SizedBox(width: 8),
            Text(
              'Point of Sale',
              style: TextStyle(
                fontSize: isMobile ? 18 : 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          // Cart badge for mobile
          if (isMobile)
            Stack(
              alignment: Alignment.center,
              children: [
                IconButton(
                  icon: Icon(Icons.shopping_cart),
                  onPressed: () {
                    setState(() => _showCart = !_showCart);
                  },
                ),
                if (_cartItems.isNotEmpty)
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      constraints: BoxConstraints(
                        minWidth: 20,
                        minHeight: 20,
                      ),
                      child: Text(
                        '${_cartItems.length}',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
        ],
      ),
      body: isMobile
          ? _buildMobileLayout(productController, isMobile)
          : _buildDesktopLayout(productController, isMobile),
    );
  }

  Widget _buildMobileLayout(ProductController productController, bool isMobile) {
    return _showCart
        ? _buildCartSection(productController, isMobile, isFullScreen: true)
        : _buildProductSelectionSection(productController, isMobile);
  }

  Widget _buildDesktopLayout(ProductController productController, bool isMobile) {
    return Row(
      children: [
        // Product Selection (Left Side)
        Expanded(
          flex: 2,
          child: _buildProductSelectionSection(productController, isMobile),
        ),

        // Cart & Checkout (Right Side)
        Container(
          width: 400,
          child: _buildCartSection(productController, isMobile, isFullScreen: false),
        ),
      ],
    );
  }

  Widget _buildProductSelectionSection(ProductController productController, bool isMobile) {
    final categories = ['All', 'Milk', 'Dairy', 'Beverages', 'Sweets', 'Others'];
    
    return Column(
      children: [
        // Search and Barcode Scanner
        Container(
          padding: EdgeInsets.all(isMobile ? 12 : 16),
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
              // Search bar
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search products...',
                  prefixIcon: Icon(Icons.search, size: isMobile ? 20 : 24),
                  suffixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_searchController.text.isNotEmpty)
                        IconButton(
                          icon: Icon(Icons.clear, size: 20),
                          onPressed: () {
                            _searchController.clear();
                            productController.searchProducts('');
                          },
                        ),
                      IconButton(
                        icon: Icon(Icons.qr_code_scanner, size: 20),
                        onPressed: () => _showBarcodeDialog(),
                        tooltip: 'Scan barcode',
                      ),
                    ],
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: isMobile ? 12 : 14,
                  ),
                ),
                onChanged: (value) {
                  productController.searchProducts(value);
                },
              ),
              
              SizedBox(height: 12),
              
              // Category filters
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: categories.map((category) {
                    final isSelected = _selectedCategory == category;
                    return Padding(
                      padding: EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(category),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() => _selectedCategory = category);
                        },
                        backgroundColor: Colors.grey.shade100,
                        selectedColor: AppTheme.primaryColor.withOpacity(0.2),
                        checkmarkColor: AppTheme.primaryColor,
                        labelStyle: TextStyle(
                          color: isSelected ? AppTheme.primaryColor : Colors.black87,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          fontSize: isMobile ? 12 : 14,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),

        // Product Grid
        Expanded(
          child: productController.products.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.inventory_2, size: 64, color: Colors.grey.shade300),
                      SizedBox(height: 16),
                      Text(
                        'No products available',
                        style: TextStyle(
                          fontSize: isMobile ? 14 : 16,
                          color: Colors.grey,
                        ),
                      ),
                      SizedBox(height: 8),
                      TextButton.icon(
                        icon: Icon(Icons.add),
                        label: Text('Add Product'),
                        onPressed: () {
                          Navigator.pushNamed(context, '/add-product');
                        },
                      ),
                    ],
                  ),
                )
              : GridView.builder(
                  padding: EdgeInsets.all(isMobile ? 12 : 16),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: isMobile ? 2 : 3,
                    crossAxisSpacing: isMobile ? 10 : 16,
                    mainAxisSpacing: isMobile ? 10 : 16,
                    childAspectRatio: 0.75,
                  ),
                  itemCount: productController.products.length,
                  itemBuilder: (context, index) {
                    final product = productController.products[index];
                    final inCart = _cartItems.any((item) => item.productId == product.id);
                    
                    return _buildProductCard(product, isMobile, inCart);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildProductCard(ProductModel product, bool isMobile, bool inCart) {
    final isLowStock = product.currentStock < 10;
    
    return Card(
      elevation: inCart ? 4 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: inCart
            ? BorderSide(color: AppTheme.primaryColor, width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: () => _addToCart(product),
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image / Icon
            Container(
              height: isMobile ? 80 : 100,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
              ),
              child: Center(
                child: Icon(
                  Icons.inventory_2,
                  size: isMobile ? 40 : 50,
                  color: AppTheme.primaryColor,
                ),
              ),
            ),
            
            // Product Info
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(isMobile ? 8 : 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: TextStyle(
                        fontSize: isMobile ? 13 : 15,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4),
                    Text(
                      product.category.toString().split('.').last,
                      style: TextStyle(
                        fontSize: isMobile ? 11 : 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${AppConstants.RUPEE_SYMBOL}${product.sellingPrice.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: isMobile ? 14 : 16,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: isLowStock ? Colors.red.shade50 : Colors.green.shade50,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '${product.currentStock.toInt()}',
                            style: TextStyle(
                              fontSize: isMobile ? 10 : 11,
                              color: isLowStock ? Colors.red : Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            // Add to Cart Button
            if (inCart)
              Container(
                padding: EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor,
                  borderRadius: BorderRadius.vertical(bottom: Radius.circular(12)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check, color: Colors.white, size: 16),
                    SizedBox(width: 4),
                    Text(
                      'In Cart',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isMobile ? 11 : 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCartSection(ProductController productController, bool isMobile, {required bool isFullScreen}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: isFullScreen
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(-2, 0),
                ),
              ],
      ),
      child: Column(
        children: [
          // Cart Header with Back Button
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                if (isFullScreen && isMobile)
                  IconButton(
                    icon: Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () {
                      setState(() => _showCart = false);
                    },
                  ),
                Icon(Icons.shopping_cart, color: Colors.white, size: 24),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Cart (${_cartItems.length} items)',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isMobile ? 16 : 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (_cartItems.isNotEmpty)
                  IconButton(
                    icon: Icon(Icons.delete_sweep, color: Colors.white),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text('Clear Cart?'),
                          content: Text('Remove all items from cart?'),
                          actions: [
                            TextButton(
                              child: Text('Cancel'),
                              onPressed: () => Navigator.pop(context),
                            ),
                            ElevatedButton(
                              child: Text('Clear'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                              ),
                              onPressed: () {
                                setState(() => _cartItems.clear());
                                Navigator.pop(context);
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),

          // Cart Items
          Expanded(
            child: _cartItems.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.shopping_cart_outlined,
                          size: isMobile ? 64 : 80,
                          color: Colors.grey.shade300,
                        ),
                        SizedBox(height: 20),
                        Text(
                          'Cart is empty',
                          style: TextStyle(
                            fontSize: isMobile ? 16 : 18,
                            color: Colors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Add products to get started',
                          style: TextStyle(
                            fontSize: isMobile ? 13 : 14,
                            color: Colors.grey.shade500,
                          ),
                        ),
                        if (isFullScreen && isMobile) ...[
                          SizedBox(height: 24),
                          ElevatedButton.icon(
                            icon: Icon(Icons.shopping_bag),
                            label: Text('Browse Products'),
                            onPressed: () {
                              setState(() => _showCart = false);
                            },
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            ),
                          ),
                        ],
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: EdgeInsets.all(12),
                    itemCount: _cartItems.length,
                    separatorBuilder: (_, __) => Divider(height: 20),
                    itemBuilder: (context, index) {
                      final item = _cartItems[index];
                      return _buildCartItemTile(item, index, isMobile);
                    },
                  ),
          ),

          // Checkout Section
          if (_cartItems.isNotEmpty)
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                border: Border(
                  top: BorderSide(color: Colors.grey.shade300),
                ),
              ),
              child: Column(
                children: [
                  // Discount
                  TextField(
                    controller: _discountController,
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: 'Discount',
                      prefixText: '${AppConstants.RUPEE_SYMBOL} ',
                      suffixIcon: IconButton(
                        icon: Icon(Icons.check_circle),
                        onPressed: () {
                          setState(() {
                            _discount = double.tryParse(_discountController.text) ?? 0.0;
                          });
                        },
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _discount = double.tryParse(value) ?? 0.0;
                      });
                    },
                  ),

                  SizedBox(height: 12),

                  // Payment Method
                  DropdownButtonFormField<PaymentMethod>(
                    value: _paymentMethod,
                    decoration: InputDecoration(
                      labelText: 'Payment Method',
                      prefixIcon: Icon(Icons.payment),
                    ),
                    items: PaymentMethod.values.map((method) {
                      return DropdownMenuItem(
                        value: method,
                        child: Text(_paymentMethodName(method)),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _paymentMethod = value);
                      }
                    },
                  ),

                  SizedBox(height: 16),

                  // Totals
                  _buildTotalRow('Subtotal:', _subtotal, isMobile),
                  if (_discount > 0) ...[
                    SizedBox(height: 8),
                    _buildTotalRow('Discount:', -_discount, isMobile, color: Colors.red),
                  ],
                  Divider(height: 20, thickness: 1.5),
                  _buildTotalRow(
                    'Total:',
                    _total,
                    isMobile,
                    isBold: true,
                    fontSize: isMobile ? 18 : 20,
                    color: AppTheme.primaryColor,
                  ),

                  SizedBox(height: 16),

                  // Checkout Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isProcessing ? null : _processSale,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.successColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isProcessing
                          ? SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.check_circle, size: 24),
                                SizedBox(width: 8),
                                Text(
                                  'Complete Sale',
                                  style: TextStyle(
                                    fontSize: isMobile ? 16 : 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCartItemTile(CartItem item, int index, bool isMobile) {
    // Compact design for mobile, regular for desktop
    return Container(
      padding: EdgeInsets.all(isMobile ? 8 : 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(isMobile ? 6 : 8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          // Product name and price (compact)
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  item.productName,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: isMobile ? 13 : 15,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 2),
                Text(
                  '${AppConstants.RUPEE_SYMBOL}${item.rate.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: isMobile ? 11 : 13,
                  ),
                ),
              ],
            ),
          ),
          
          SizedBox(width: 8),
          
          // Quantity controls (compact)
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300, width: 1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                InkWell(
                  onTap: () => _updateQuantity(index, item.quantity - 1),
                  child: Padding(
                    padding: EdgeInsets.all(isMobile ? 6 : 8),
                    child: Icon(Icons.remove, size: isMobile ? 14 : 16),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: isMobile ? 8 : 10),
                  child: Text(
                    '${item.quantity}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: isMobile ? 13 : 15,
                    ),
                  ),
                ),
                InkWell(
                  onTap: () => _updateQuantity(index, item.quantity + 1),
                  child: Padding(
                    padding: EdgeInsets.all(isMobile ? 6 : 8),
                    child: Icon(Icons.add, size: isMobile ? 14 : 16),
                  ),
                ),
              ],
            ),
          ),
          
          SizedBox(width: 8),
          
          // Item total (compact)
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${AppConstants.RUPEE_SYMBOL}${item.total.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: isMobile ? 14 : 16,
                    color: AppTheme.primaryColor,
                  ),
                ),
                SizedBox(height: 2),
                InkWell(
                  onTap: () => _removeFromCart(index),
                  child: Padding(
                    padding: EdgeInsets.all(4),
                    child: Icon(
                      Icons.delete_outline,
                      color: Colors.red.shade400,
                      size: isMobile ? 16 : 18,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalRow(String label, double amount, bool isMobile, {
    bool isBold = false,
    double? fontSize,
    Color? color,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: fontSize ?? (isMobile ? 14 : 15),
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: color,
          ),
        ),
        Text(
          '${AppConstants.RUPEE_SYMBOL}${amount.abs().toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: fontSize ?? (isMobile ? 14 : 15),
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: color,
          ),
        ),
      ],
    );
  }

  String _paymentMethodName(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.cash:
        return 'Cash';
      case PaymentMethod.upi:
        return 'UPI';
      case PaymentMethod.card:
        return 'Card';
      case PaymentMethod.cheque:
        return 'Cheque';
      case PaymentMethod.credit:
        return 'Credit';
    }
  }

  void _showBarcodeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Scan/Enter Barcode'),
        content: TextField(
          controller: _barcodeController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Enter barcode',
            prefixIcon: Icon(Icons.qr_code),
          ),
          onSubmitted: (value) {
            // TODO: Search product by barcode
            Navigator.pop(context);
          },
        ),
        actions: [
          TextButton(
            child: Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            child: Text('Search'),
            onPressed: () {
              // TODO: Search product by barcode
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}

class CartItem {
  final String productId;
  final String productName;
  final double rate;
  double quantity;

  CartItem({
    required this.productId,
    required this.productName,
    required this.rate,
    required this.quantity,
  });

  double get total => rate * quantity;
}
