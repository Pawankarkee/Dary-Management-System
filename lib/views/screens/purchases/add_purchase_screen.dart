import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../controllers/purchase_controller.dart';
import '../../../controllers/supplier_controller.dart';
import '../../../models/purchase_model.dart';
import '../../../models/supplier_model.dart';
import '../../../config/theme/app_theme.dart';
import '../../../config/constants/app_constants.dart';
import '../../../utils/responsive.dart';

class AddPurchaseScreen extends StatefulWidget {
  final PurchaseModel? purchase;

  const AddPurchaseScreen({super.key, this.purchase});

  @override
  State<AddPurchaseScreen> createState() => _AddPurchaseScreenState();
}

class _AddPurchaseScreenState extends State<AddPurchaseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _invoiceController = TextEditingController();
  final _taxController = TextEditingController(text: '0');
  final _otherChargesController = TextEditingController(text: '0');
  final _discountController = TextEditingController(text: '0');
  final _notesController = TextEditingController();

  SupplierModel? _selectedSupplier;
  DateTime _purchaseDate = DateTime.now();
  DateTime _dueDate = DateTime.now().add(const Duration(days: 30));
  List<PurchaseItemModel> _items = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.purchase != null) {
      _populateFields(widget.purchase!);
    }
  }

  void _populateFields(PurchaseModel purchase) {
    _invoiceController.text = purchase.invoiceNumber;
    _purchaseDate = purchase.purchaseDate;
    _dueDate = purchase.dueDate;
    _taxController.text = purchase.taxAmount.toString();
    _otherChargesController.text = purchase.otherCharges.toString();
    _discountController.text = purchase.discount.toString();
    _notesController.text = purchase.notes ?? '';
    _items = List.from(purchase.items);
  }

  @override
  void dispose() {
    _invoiceController.dispose();
    _taxController.dispose();
    _otherChargesController.dispose();
    _discountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  double _calculateSubtotal() {
    return _items.fold(0, (sum, item) => sum + item.amount);
  }

  double _calculateTotal() {
    final subtotal = _calculateSubtotal();
    final tax = double.tryParse(_taxController.text) ?? 0;
    final otherCharges = double.tryParse(_otherChargesController.text) ?? 0;
    final discount = double.tryParse(_discountController.text) ?? 0;
    return subtotal + tax + otherCharges - discount;
  }

  Future<void> _savePurchase() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_selectedSupplier == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a supplier')),
      );
      return;
    }

    if (_items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one item')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final purchaseController = Provider.of<PurchaseController>(context, listen: false);
      final supplierController = Provider.of<SupplierController>(context, listen: false);

      final subtotal = _calculateSubtotal();
      final total = _calculateTotal();

      final purchase = PurchaseModel(
        id: widget.purchase?.id ?? PurchaseModel.generateId(),
        supplierId: _selectedSupplier!.id,
        supplierName: _selectedSupplier!.name,
        invoiceNumber: _invoiceController.text.trim(),
        purchaseDate: _purchaseDate,
        dueDate: _dueDate,
        items: _items,
        subtotal: subtotal,
        taxAmount: double.tryParse(_taxController.text) ?? 0,
        otherCharges: double.tryParse(_otherChargesController.text) ?? 0,
        discount: double.tryParse(_discountController.text) ?? 0,
        totalAmount: total,
        paidAmount: 0,
        balanceAmount: total,
        status: PurchaseStatus.pending,
        paymentStatus: PaymentStatus.unpaid,
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
        createdAt: widget.purchase?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      if (widget.purchase != null) {
        await purchaseController.updatePurchase(purchase);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Purchase updated successfully')),
          );
        }
      } else {
        await purchaseController.addPurchase(purchase, supplierController);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Purchase added successfully')),
          );
        }
      }

      if (mounted) Navigator.pop(context);
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  void _addItem() {
    showDialog(
      context: context,
      builder: (context) => _ItemDialog(
        onSave: (item) {
          setState(() => _items.add(item));
        },
      ),
    );
  }

  void _editItem(int index) {
    showDialog(
      context: context,
      builder: (context) => _ItemDialog(
        item: _items[index],
        onSave: (item) {
          setState(() => _items[index] = item);
        },
      ),
    );
  }

  void _removeItem(int index) {
    setState(() => _items.removeAt(index));
  }

  @override
  Widget build(BuildContext context) {
    final supplierController = Provider.of<SupplierController>(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    return Scaffold(
      backgroundColor: AppTheme.lightBackground,
      appBar: AppBar(
        title: Text(widget.purchase != null ? 'Edit Purchase' : 'Add Purchase'),
        actions: [
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: _savePurchase,
              tooltip: 'Save',
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(isMobile ? MobileSizes.spaceL : 24),
          children: [
            // Supplier Selection
            Card(
              child: Padding(
                padding: EdgeInsets.all(isMobile ? MobileSizes.cardPadding : 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Supplier Information',
                      style: TextStyle(
                        fontSize: isMobile ? MobileSizes.sectionTitle : 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: isMobile ? MobileSizes.spaceM : 16),
                    DropdownButtonFormField<SupplierModel>(
                      value: _selectedSupplier,
                      decoration: const InputDecoration(
                        labelText: 'Select Supplier *',
                        prefixIcon: Icon(Icons.store),
                      ),
                      items: supplierController.activeSuppliers.map((supplier) {
                        return DropdownMenuItem(
                          value: supplier,
                          child: Text(supplier.name),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() => _selectedSupplier = value);
                      },
                      validator: (value) {
                        if (value == null) return 'Please select a supplier';
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: isMobile ? MobileSizes.spaceL : 20),

            // Invoice Details
            Card(
              child: Padding(
                padding: EdgeInsets.all(isMobile ? MobileSizes.cardPadding : 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Invoice Details',
                      style: TextStyle(
                        fontSize: isMobile ? MobileSizes.sectionTitle : 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: isMobile ? MobileSizes.spaceM : 16),
                    TextFormField(
                      controller: _invoiceController,
                      decoration: const InputDecoration(
                        labelText: 'Invoice Number *',
                        prefixIcon: Icon(Icons.receipt),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter invoice number';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: isMobile ? MobileSizes.spaceM : 16),
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              final date = await showDatePicker(
                                context: context,
                                initialDate: _purchaseDate,
                                firstDate: DateTime(2020),
                                lastDate: DateTime.now(),
                              );
                              if (date != null) {
                                setState(() => _purchaseDate = date);
                              }
                            },
                            child: InputDecorator(
                              decoration: const InputDecoration(
                                labelText: 'Purchase Date',
                                prefixIcon: Icon(Icons.calendar_today),
                              ),
                              child: Text(
                                DateFormat('MMM dd, yyyy').format(_purchaseDate),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: isMobile ? MobileSizes.spaceM : 16),
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              final date = await showDatePicker(
                                context: context,
                                initialDate: _dueDate,
                                firstDate: _purchaseDate,
                                lastDate: DateTime.now().add(const Duration(days: 365)),
                              );
                              if (date != null) {
                                setState(() => _dueDate = date);
                              }
                            },
                            child: InputDecorator(
                              decoration: const InputDecoration(
                                labelText: 'Due Date',
                                prefixIcon: Icon(Icons.event),
                              ),
                              child: Text(
                                DateFormat('MMM dd, yyyy').format(_dueDate),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: isMobile ? MobileSizes.spaceL : 20),

            // Items Section
            Card(
              child: Padding(
                padding: EdgeInsets.all(isMobile ? MobileSizes.cardPadding : 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Items',
                          style: TextStyle(
                            fontSize: isMobile ? MobileSizes.sectionTitle : 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextButton.icon(
                          onPressed: _addItem,
                          icon: const Icon(Icons.add),
                          label: const Text('Add Item'),
                        ),
                      ],
                    ),
                    SizedBox(height: isMobile ? MobileSizes.spaceM : 16),
                    if (_items.isEmpty)
                      Center(
                        child: Padding(
                          padding: EdgeInsets.all(isMobile ? MobileSizes.spaceXL : 32),
                          child: Text(
                            'No items added yet',
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
                        itemCount: _items.length,
                        separatorBuilder: (_, __) => const Divider(),
                        itemBuilder: (context, index) {
                          final item = _items[index];
                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(
                              item.itemName,
                              style: TextStyle(
                                fontSize: isMobile ? MobileSizes.bodyMedium : 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Text(
                              '${item.quantity} ${item.unit} × ${AppConstants.RUPEE_SYMBOL}${item.rate.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: isMobile ? MobileSizes.bodySmall : 12,
                              ),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '${AppConstants.RUPEE_SYMBOL}${item.amount.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    fontSize: isMobile ? MobileSizes.bodyMedium : 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.edit, size: 20),
                                  onPressed: () => _editItem(index),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                                  onPressed: () => _removeItem(index),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),
            ),

            SizedBox(height: isMobile ? MobileSizes.spaceL : 20),

            // Calculations
            Card(
              child: Padding(
                padding: EdgeInsets.all(isMobile ? MobileSizes.cardPadding : 16),
                child: Column(
                  children: [
                    _buildCalculationRow('Subtotal', _calculateSubtotal(), isMobile),
                    SizedBox(height: isMobile ? MobileSizes.spaceM : 12),
                    TextFormField(
                      controller: _taxController,
                      decoration: InputDecoration(
                        labelText: 'Tax Amount',
                        prefixText: AppConstants.RUPEE_SYMBOL,
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (_) => setState(() {}),
                    ),
                    SizedBox(height: isMobile ? MobileSizes.spaceM : 12),
                    TextFormField(
                      controller: _otherChargesController,
                      decoration: InputDecoration(
                        labelText: 'Other Charges',
                        prefixText: AppConstants.RUPEE_SYMBOL,
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (_) => setState(() {}),
                    ),
                    SizedBox(height: isMobile ? MobileSizes.spaceM : 12),
                    TextFormField(
                      controller: _discountController,
                      decoration: InputDecoration(
                        labelText: 'Discount',
                        prefixText: AppConstants.RUPEE_SYMBOL,
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (_) => setState(() {}),
                    ),
                    SizedBox(height: isMobile ? MobileSizes.spaceM : 16),
                    const Divider(thickness: 2),
                    SizedBox(height: isMobile ? MobileSizes.spaceM : 12),
                    _buildCalculationRow('Total Amount', _calculateTotal(), isMobile, isTotal: true),
                  ],
                ),
              ),
            ),

            SizedBox(height: isMobile ? MobileSizes.spaceL : 20),

            // Notes
            Card(
              child: Padding(
                padding: EdgeInsets.all(isMobile ? MobileSizes.cardPadding : 16),
                child: TextFormField(
                  controller: _notesController,
                  decoration: const InputDecoration(
                    labelText: 'Notes (Optional)',
                    hintText: 'Any additional information...',
                  ),
                  maxLines: 3,
                ),
              ),
            ),

            SizedBox(height: isMobile ? MobileSizes.spaceXL : 32),

            // Save Button
            ElevatedButton(
              onPressed: _isLoading ? null : _savePurchase,
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(
                  vertical: isMobile ? MobileSizes.spaceM : 16,
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(
                      widget.purchase != null ? 'Update Purchase' : 'Add Purchase',
                      style: TextStyle(
                        fontSize: isMobile ? MobileSizes.bodyMedium : 16,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalculationRow(String label, double amount, bool isMobile, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isMobile ? MobileSizes.bodyMedium : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: isTotal ? AppTheme.primaryColor : Colors.grey.shade700,
          ),
        ),
        Text(
          '${AppConstants.RUPEE_SYMBOL}${amount.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: isMobile ? (isTotal ? MobileSizes.bodyLarge : MobileSizes.bodyMedium) : (isTotal ? 18 : 14),
            fontWeight: FontWeight.bold,
            color: isTotal ? AppTheme.primaryColor : Colors.black87,
          ),
        ),
      ],
    );
  }
}

// Item Dialog
class _ItemDialog extends StatefulWidget {
  final PurchaseItemModel? item;
  final Function(PurchaseItemModel) onSave;

  const _ItemDialog({this.item, required this.onSave});

  @override
  State<_ItemDialog> createState() => _ItemDialogState();
}

class _ItemDialogState extends State<_ItemDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _quantityController = TextEditingController();
  final _unitController = TextEditingController(text: 'Kg');
  final _rateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.item != null) {
      _nameController.text = widget.item!.itemName;
      _descriptionController.text = widget.item!.description;
      _quantityController.text = widget.item!.quantity.toString();
      _unitController.text = widget.item!.unit;
      _rateController.text = widget.item!.rate.toString();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _quantityController.dispose();
    _unitController.dispose();
    _rateController.dispose();
    super.dispose();
  }

  double _calculateAmount() {
    final quantity = double.tryParse(_quantityController.text) ?? 0;
    final rate = double.tryParse(_rateController.text) ?? 0;
    return quantity * rate;
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final item = PurchaseItemModel(
      itemName: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      quantity: double.parse(_quantityController.text),
      unit: _unitController.text.trim(),
      rate: double.parse(_rateController.text),
      amount: _calculateAmount(),
    );

    widget.onSave(item);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.item != null ? 'Edit Item' : 'Add Item'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Item Name *',
                  prefixIcon: Icon(Icons.inventory),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter item name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description (Optional)',
                  prefixIcon: Icon(Icons.note),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _quantityController,
                      decoration: const InputDecoration(
                        labelText: 'Quantity *',
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (_) => setState(() {}),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Required';
                        }
                        if (double.tryParse(value) == null || double.parse(value) <= 0) {
                          return 'Invalid';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _unitController,
                      decoration: const InputDecoration(
                        labelText: 'Unit *',
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Required';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _rateController,
                decoration: InputDecoration(
                  labelText: 'Rate per Unit *',
                  prefixText: AppConstants.RUPEE_SYMBOL,
                ),
                keyboardType: TextInputType.number,
                onChanged: (_) => setState(() {}),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter rate';
                  }
                  if (double.tryParse(value) == null || double.parse(value) <= 0) {
                    return 'Invalid rate';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Amount:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '${AppConstants.RUPEE_SYMBOL}${_calculateAmount().toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _save,
          child: const Text('Save'),
        ),
      ],
    );
  }
}
