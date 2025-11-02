import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../controllers/product_controller.dart';
import '../../../config/theme/app_theme.dart';
import '../../../models/product_model.dart';
import '../../../utils/responsive.dart';

class AddProductScreen extends StatefulWidget {
  final ProductModel? product;
  
  const AddProductScreen({super.key, this.product});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _purchasePriceController = TextEditingController();
  final _sellingPriceController = TextEditingController();
  final _currentStockController = TextEditingController();
  final _minStockController = TextEditingController();
  
  // Focus nodes for Enter key navigation
  final _nameFocusNode = FocusNode();
  final _purchasePriceFocusNode = FocusNode();
  final _sellingPriceFocusNode = FocusNode();
  final _currentStockFocusNode = FocusNode();
  final _minStockFocusNode = FocusNode();
  final _submitButtonFocusNode = FocusNode();
  
  ProductCategory _selectedCategory = ProductCategory.feed;
  ProductUnit _selectedUnit = ProductUnit.kg;
  DateTime? _expiryDate;
  bool _isActive = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.product != null) {
      _nameController.text = widget.product!.name;
      _purchasePriceController.text = widget.product!.purchasePrice.toString();
      _sellingPriceController.text = widget.product!.sellingPrice.toString();
      _currentStockController.text = widget.product!.currentStock.toString();
      _minStockController.text = widget.product!.minStockLevel.toString();
      _selectedCategory = widget.product!.category;
      _selectedUnit = widget.product!.unit;
      _expiryDate = widget.product!.expiryDate;
      _isActive = widget.product!.isActive;
    } else {
      // Default values
      _currentStockController.text = '0';
      _minStockController.text = '10';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _purchasePriceController.dispose();
    _sellingPriceController.dispose();
    _currentStockController.dispose();
    _minStockController.dispose();
    _nameFocusNode.dispose();
    _purchasePriceFocusNode.dispose();
    _sellingPriceFocusNode.dispose();
    _currentStockFocusNode.dispose();
    _minStockFocusNode.dispose();
    _submitButtonFocusNode.dispose();
    super.dispose();
  }

  Future<void> _selectExpiryDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _expiryDate ?? DateTime.now().add(const Duration(days: 365)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppTheme.primaryColor,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null) {
      setState(() => _expiryDate = picked);
    }
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final productController = Provider.of<ProductController>(context, listen: false);
      
      final product = ProductModel(
        id: widget.product?.id ?? '',
        name: _nameController.text.trim(),
        category: _selectedCategory,
        unit: _selectedUnit,
        purchasePrice: double.parse(_purchasePriceController.text.trim()),
        sellingPrice: double.parse(_sellingPriceController.text.trim()),
        currentStock: double.parse(_currentStockController.text.trim()),
        minStockLevel: double.parse(_minStockController.text.trim()),
        expiryDate: _expiryDate,
        isActive: _isActive,
        createdAt: widget.product?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      if (widget.product == null) {
        await productController.addProduct(product);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✅ ${product.name} added successfully!'),
              backgroundColor: AppTheme.successColor,
            ),
          );
        }
      } else {
        await productController.updateProduct(product);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✅ ${product.name} updated successfully!'),
              backgroundColor: AppTheme.successColor,
            ),
          );
        }
      }

      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.product != null;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;
    final isTablet = screenWidth >= 768 && screenWidth < 1024;
    final isDesktop = screenWidth >= 1024;

    return Scaffold(
      backgroundColor: AppTheme.lightBackground,
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(isMobile ? MobileSizes.spaceXL : 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.arrow_back,
                      size: isMobile ? MobileSizes.iconAppBar : 24,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      isEdit ? 'Edit Product' : 'Add New Product',
                      style: TextStyle(
                        fontSize: isMobile ? MobileSizes.screenTitle : 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: isMobile ? MobileSizes.spaceL : 24),

              // Product Name
              TextFormField(
                controller: _nameController,
                focusNode: _nameFocusNode,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  labelText: 'Product Name *',
                  hintText: 'e.g., Cattle Feed Premium',
                  prefixIcon: Icon(
                    Icons.shopping_bag,
                    size: isMobile ? MobileSizes.iconMedium : 20,
                  ),
                ),
                textCapitalization: TextCapitalization.words,
                onFieldSubmitted: (_) {
                  FocusScope.of(context).requestFocus(_purchasePriceFocusNode);
                },
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter product name';
                  }
                  if (value.trim().length < 3) {
                    return 'Name must be at least 3 characters';
                  }
                  return null;
                },
              ),

              SizedBox(height: isMobile ? MobileSizes.spaceM : 16),

              // Category and Unit - Responsive layout
              LayoutBuilder(
                builder: (context, constraints) {
                  final showRow = constraints.maxWidth >= 600;
                  
                  if (showRow) {
                    return Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<ProductCategory>(
                            value: _selectedCategory,
                            decoration: InputDecoration(
                              labelText: 'Category *',
                              prefixIcon: Icon(
                                Icons.category,
                                size: isMobile ? MobileSizes.iconMedium : 20,
                              ),
                            ),
                            items: ProductCategory.values.map((category) {
                              return DropdownMenuItem(
                                value: category,
                                child: Row(
                                  children: [
                                    Icon(_getCategoryIcon(category), size: 18),
                                    const SizedBox(width: 8),
                                    Text(_getCategoryName(category)),
                                  ],
                                ),
                              );
                            }).toList(),
                            onChanged: (value) {
                              if (value != null) {
                                setState(() => _selectedCategory = value);
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: DropdownButtonFormField<ProductUnit>(
                            value: _selectedUnit,
                            decoration: InputDecoration(
                              labelText: 'Unit *',
                              prefixIcon: Icon(
                                Icons.straighten,
                                size: isMobile ? MobileSizes.iconMedium : 20,
                              ),
                            ),
                            items: ProductUnit.values.map((unit) {
                              return DropdownMenuItem(
                                value: unit,
                                child: Text(_getUnitName(unit)),
                              );
                            }).toList(),
                            onChanged: (value) {
                              if (value != null) {
                                setState(() => _selectedUnit = value);
                              }
                            },
                          ),
                        ),
                      ],
                    );
                  } else {
                    return Column(
                      children: [
                        DropdownButtonFormField<ProductCategory>(
                          value: _selectedCategory,
                          decoration: InputDecoration(
                            labelText: 'Category *',
                            prefixIcon: Icon(
                              Icons.category,
                              size: MobileSizes.iconMedium,
                            ),
                          ),
                          items: ProductCategory.values.map((category) {
                            return DropdownMenuItem(
                              value: category,
                              child: Row(
                                children: [
                                  Icon(_getCategoryIcon(category), size: 18),
                                  const SizedBox(width: 8),
                                  Text(_getCategoryName(category)),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => _selectedCategory = value);
                            }
                          },
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<ProductUnit>(
                          value: _selectedUnit,
                          decoration: InputDecoration(
                            labelText: 'Unit *',
                            prefixIcon: Icon(
                              Icons.straighten,
                              size: MobileSizes.iconMedium,
                            ),
                          ),
                          items: ProductUnit.values.map((unit) {
                            return DropdownMenuItem(
                              value: unit,
                              child: Text(_getUnitName(unit)),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => _selectedUnit = value);
                            }
                          },
                        ),
                      ],
                    );
                  }
                },
              ),

              SizedBox(height: isMobile ? MobileSizes.spaceM : 16),

              // Purchase Price and Selling Price
              LayoutBuilder(
                builder: (context, constraints) {
                  final showRow = constraints.maxWidth >= 600;
                  
                  if (showRow) {
                    return Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _purchasePriceController,
                            focusNode: _purchasePriceFocusNode,
                            textInputAction: TextInputAction.next,
                            decoration: InputDecoration(
                              labelText: 'Purchase Price *',
                              hintText: '0.00',
                              prefixIcon: Icon(
                                Icons.currency_rupee,
                                size: isMobile ? MobileSizes.iconMedium : 20,
                              ),
                              prefixText: '₹ ',
                            ),
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                            ],
                            onFieldSubmitted: (_) {
                              FocusScope.of(context).requestFocus(_sellingPriceFocusNode);
                            },
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Required';
                              }
                              if (double.tryParse(value) == null) {
                                return 'Invalid number';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _sellingPriceController,
                            focusNode: _sellingPriceFocusNode,
                            textInputAction: TextInputAction.next,
                            decoration: InputDecoration(
                              labelText: 'Selling Price *',
                              hintText: '0.00',
                              prefixIcon: Icon(
                                Icons.sell,
                                size: isMobile ? MobileSizes.iconMedium : 20,
                              ),
                              prefixText: '₹ ',
                            ),
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                            ],
                            onFieldSubmitted: (_) {
                              FocusScope.of(context).requestFocus(_currentStockFocusNode);
                            },
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Required';
                              }
                              final price = double.tryParse(value);
                              if (price == null) {
                                return 'Invalid number';
                              }
                              final purchasePrice = double.tryParse(_purchasePriceController.text);
                              if (purchasePrice != null && price < purchasePrice) {
                                return 'Should be ≥ purchase price';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    );
                  } else {
                    return Column(
                      children: [
                        TextFormField(
                          controller: _purchasePriceController,
                          focusNode: _purchasePriceFocusNode,
                          textInputAction: TextInputAction.next,
                          decoration: InputDecoration(
                            labelText: 'Purchase Price *',
                            hintText: '0.00',
                            prefixIcon: Icon(
                              Icons.currency_rupee,
                              size: MobileSizes.iconMedium,
                            ),
                            prefixText: '₹ ',
                          ),
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                          ],
                          onFieldSubmitted: (_) {
                            FocusScope.of(context).requestFocus(_sellingPriceFocusNode);
                          },
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter purchase price';
                            }
                            if (double.tryParse(value) == null) {
                              return 'Invalid number';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _sellingPriceController,
                          focusNode: _sellingPriceFocusNode,
                          textInputAction: TextInputAction.next,
                          decoration: InputDecoration(
                            labelText: 'Selling Price *',
                            hintText: '0.00',
                            prefixIcon: Icon(
                              Icons.sell,
                              size: MobileSizes.iconMedium,
                            ),
                            prefixText: '₹ ',
                          ),
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                          ],
                          onFieldSubmitted: (_) {
                            FocusScope.of(context).requestFocus(_currentStockFocusNode);
                          },
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter selling price';
                            }
                            final price = double.tryParse(value);
                            if (price == null) {
                              return 'Invalid number';
                            }
                            final purchasePrice = double.tryParse(_purchasePriceController.text);
                            if (purchasePrice != null && price < purchasePrice) {
                              return 'Selling price should be ≥ purchase price';
                            }
                            return null;
                          },
                        ),
                      ],
                    );
                  }
                },
              ),

              SizedBox(height: isMobile ? MobileSizes.spaceM : 16),

              // Current Stock and Min Stock Level
              LayoutBuilder(
                builder: (context, constraints) {
                  final showRow = constraints.maxWidth >= 600;
                  
                  if (showRow) {
                    return Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _currentStockController,
                            focusNode: _currentStockFocusNode,
                            textInputAction: TextInputAction.next,
                            decoration: InputDecoration(
                              labelText: 'Current Stock *',
                              hintText: '0',
                              prefixIcon: Icon(
                                Icons.inventory,
                                size: isMobile ? MobileSizes.iconMedium : 20,
                              ),
                              suffixText: _getUnitName(_selectedUnit),
                            ),
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                            ],
                            onFieldSubmitted: (_) {
                              FocusScope.of(context).requestFocus(_minStockFocusNode);
                            },
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Required';
                              }
                              if (double.tryParse(value) == null) {
                                return 'Invalid';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _minStockController,
                            focusNode: _minStockFocusNode,
                            textInputAction: TextInputAction.next,
                            decoration: InputDecoration(
                              labelText: 'Min Stock Alert *',
                              hintText: '10',
                              prefixIcon: Icon(
                                Icons.warning_amber,
                                size: isMobile ? MobileSizes.iconMedium : 20,
                              ),
                              suffixText: _getUnitName(_selectedUnit),
                            ),
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                            ],
                            onFieldSubmitted: (_) {
                              FocusScope.of(context).requestFocus(_submitButtonFocusNode);
                            },
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Required';
                              }
                              if (double.tryParse(value) == null) {
                                return 'Invalid';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    );
                  } else {
                    return Column(
                      children: [
                        TextFormField(
                          controller: _currentStockController,
                          focusNode: _currentStockFocusNode,
                          textInputAction: TextInputAction.next,
                          decoration: InputDecoration(
                            labelText: 'Current Stock *',
                            hintText: '0',
                            prefixIcon: Icon(
                              Icons.inventory,
                              size: MobileSizes.iconMedium,
                            ),
                            suffixText: _getUnitName(_selectedUnit),
                          ),
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                          ],
                          onFieldSubmitted: (_) {
                            FocusScope.of(context).requestFocus(_minStockFocusNode);
                          },
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter current stock';
                            }
                            if (double.tryParse(value) == null) {
                              return 'Invalid number';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _minStockController,
                          focusNode: _minStockFocusNode,
                          textInputAction: TextInputAction.next,
                          decoration: InputDecoration(
                            labelText: 'Min Stock Alert Level *',
                            hintText: '10',
                            prefixIcon: Icon(
                              Icons.warning_amber,
                              size: MobileSizes.iconMedium,
                            ),
                            suffixText: _getUnitName(_selectedUnit),
                          ),
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                          ],
                          onFieldSubmitted: (_) {
                            FocusScope.of(context).requestFocus(_submitButtonFocusNode);
                          },
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter minimum stock level';
                            }
                            if (double.tryParse(value) == null) {
                              return 'Invalid number';
                            }
                            return null;
                          },
                        ),
                      ],
                    );
                  }
                },
              ),

              SizedBox(height: isMobile ? MobileSizes.spaceM : 16),

              // Expiry Date (Optional)
              InkWell(
                onTap: _selectExpiryDate,
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Expiry Date (Optional)',
                    prefixIcon: Icon(
                      Icons.calendar_today,
                      size: isMobile ? MobileSizes.iconMedium : 20,
                    ),
                    suffixIcon: _expiryDate != null
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 20),
                            onPressed: () => setState(() => _expiryDate = null),
                          )
                        : null,
                  ),
                  child: Text(
                    _expiryDate != null
                        ? '${_expiryDate!.day}/${_expiryDate!.month}/${_expiryDate!.year}'
                        : 'Tap to select date',
                    style: TextStyle(
                      color: _expiryDate != null ? null : Colors.grey.shade600,
                      fontSize: isMobile ? MobileSizes.bodyMedium : 14,
                    ),
                  ),
                ),
              ),

              SizedBox(height: isMobile ? MobileSizes.spaceL : 20),

              // Active Status
              SwitchListTile(
                title: Text(
                  'Active Status',
                  style: TextStyle(
                    fontSize: isMobile ? MobileSizes.bodyMedium : 14,
                  ),
                ),
                subtitle: Text(
                  _isActive ? 'Product is active' : 'Product is inactive',
                  style: TextStyle(
                    fontSize: isMobile ? MobileSizes.bodySmall : 13,
                  ),
                ),
                value: _isActive,
                onChanged: (value) {
                  setState(() => _isActive = value);
                },
                activeColor: AppTheme.successColor,
              ),

              SizedBox(height: isMobile ? MobileSizes.spaceXL : 32),

              // Save Button
              SizedBox(
                width: isDesktop ? 400 : double.infinity,
                child: Focus(
                  focusNode: _submitButtonFocusNode,
                  onKey: (node, event) {
                    if (event is RawKeyDownEvent && event.logicalKey == LogicalKeyboardKey.enter) {
                      if (!_isLoading) _saveProduct();
                      return KeyEventResult.handled;
                    }
                    return KeyEventResult.ignored;
                  },
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _saveProduct,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        vertical: isMobile ? MobileSizes.buttonHeight / 3 : 18,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(
                            isEdit ? 'Update Product' : 'Add Product',
                            style: TextStyle(
                              fontSize: isMobile ? MobileSizes.bodyLarge : 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ),

              SizedBox(height: isMobile ? MobileSizes.spaceL : 16),
            ],
          ),
        ),
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

  String _getUnitName(ProductUnit unit) {
    switch (unit) {
      case ProductUnit.kg:
        return 'kg';
      case ProductUnit.packet:
        return 'packet';
      case ProductUnit.piece:
        return 'piece';
      case ProductUnit.liter:
        return 'liter';
    }
  }
}
