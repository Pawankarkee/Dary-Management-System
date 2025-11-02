import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../controllers/supplier_controller.dart';
import '../../../models/supplier_model.dart';
import '../../../config/theme/app_theme.dart';
import '../../../utils/responsive.dart';

class AddSupplierScreen extends StatefulWidget {
  final SupplierModel? supplier;

  const AddSupplierScreen({super.key, this.supplier});

  @override
  State<AddSupplierScreen> createState() => _AddSupplierScreenState();
}

class _AddSupplierScreenState extends State<AddSupplierScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _contactPersonController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _gstinController = TextEditingController();
  final _openingBalanceController = TextEditingController(text: '0');
  final _notesController = TextEditingController();

  SupplierType _selectedType = SupplierType.general;
  bool _isActive = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.supplier != null) {
      _populateFields(widget.supplier!);
    }
  }

  void _populateFields(SupplierModel supplier) {
    _nameController.text = supplier.name;
    _contactPersonController.text = supplier.contactPerson;
    _phoneController.text = supplier.phone;
    _emailController.text = supplier.email ?? '';
    _addressController.text = supplier.address;
    _gstinController.text = supplier.gstin ?? '';
    _openingBalanceController.text = supplier.openingBalance.toString();
    _notesController.text = supplier.notes ?? '';
    _selectedType = supplier.supplierType;
    _isActive = supplier.isActive;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _contactPersonController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _gstinController.dispose();
    _openingBalanceController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _saveSupplier() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final supplierController = Provider.of<SupplierController>(context, listen: false);

      final supplier = SupplierModel(
        id: widget.supplier?.id ?? SupplierModel.generateId(),
        name: _nameController.text.trim(),
        contactPerson: _contactPersonController.text.trim(),
        phone: _phoneController.text.trim(),
        email: _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
        address: _addressController.text.trim(),
        gstin: _gstinController.text.trim().isEmpty ? null : _gstinController.text.trim(),
        supplierType: _selectedType,
        openingBalance: double.tryParse(_openingBalanceController.text) ?? 0.0,
        currentBalance: widget.supplier?.currentBalance ?? double.tryParse(_openingBalanceController.text) ?? 0.0,
        isActive: _isActive,
        createdAt: widget.supplier?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      );

      if (widget.supplier != null) {
        await supplierController.updateSupplier(supplier);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Supplier updated successfully')),
          );
        }
      } else {
        await supplierController.addSupplier(supplier);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Supplier added successfully')),
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

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    return Scaffold(
      backgroundColor: AppTheme.lightBackground,
      appBar: AppBar(
        title: Text(widget.supplier != null ? 'Edit Supplier' : 'Add Supplier'),
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
              onPressed: _saveSupplier,
              tooltip: 'Save',
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(isMobile ? MobileSizes.spaceL : 24),
          children: [
            // Basic Information Section
            Text(
              'Basic Information',
              style: TextStyle(
                fontSize: isMobile ? MobileSizes.sectionTitle : 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: isMobile ? MobileSizes.spaceM : 16),

            Card(
              child: Padding(
                padding: EdgeInsets.all(isMobile ? MobileSizes.cardPadding : 16),
                child: Column(
                  children: [
                    // Supplier Name
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Supplier Name *',
                        prefixIcon: Icon(Icons.store),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter supplier name';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: isMobile ? MobileSizes.spaceM : 16),

                    // Supplier Type
                    DropdownButtonFormField<SupplierType>(
                      value: _selectedType,
                      decoration: const InputDecoration(
                        labelText: 'Supplier Type *',
                        prefixIcon: Icon(Icons.category),
                      ),
                      items: SupplierType.values.map((type) {
                        return DropdownMenuItem(
                          value: type,
                          child: Text(_getSupplierTypeLabel(type)),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _selectedType = value);
                        }
                      },
                    ),
                    SizedBox(height: isMobile ? MobileSizes.spaceM : 16),

                    // Active Status
                    SwitchListTile(
                      title: const Text('Active'),
                      subtitle: Text(_isActive ? 'Supplier is active' : 'Supplier is inactive'),
                      value: _isActive,
                      onChanged: (value) {
                        setState(() => _isActive = value);
                      },
                      contentPadding: EdgeInsets.zero,
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: isMobile ? MobileSizes.spaceL : 24),

            // Contact Information Section
            Text(
              'Contact Information',
              style: TextStyle(
                fontSize: isMobile ? MobileSizes.sectionTitle : 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: isMobile ? MobileSizes.spaceM : 16),

            Card(
              child: Padding(
                padding: EdgeInsets.all(isMobile ? MobileSizes.cardPadding : 16),
                child: Column(
                  children: [
                    // Contact Person
                    TextFormField(
                      controller: _contactPersonController,
                      decoration: const InputDecoration(
                        labelText: 'Contact Person *',
                        prefixIcon: Icon(Icons.person),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter contact person name';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: isMobile ? MobileSizes.spaceM : 16),

                    // Phone
                    TextFormField(
                      controller: _phoneController,
                      decoration: const InputDecoration(
                        labelText: 'Phone Number *',
                        prefixIcon: Icon(Icons.phone),
                      ),
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter phone number';
                        }
                        if (value.length < 10) {
                          return 'Please enter valid phone number';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: isMobile ? MobileSizes.spaceM : 16),

                    // Email
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email (Optional)',
                        prefixIcon: Icon(Icons.email),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value != null && value.isNotEmpty) {
                          if (!value.contains('@')) {
                            return 'Please enter valid email';
                          }
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: isMobile ? MobileSizes.spaceM : 16),

                    // Address
                    TextFormField(
                      controller: _addressController,
                      decoration: const InputDecoration(
                        labelText: 'Address *',
                        prefixIcon: Icon(Icons.location_on),
                      ),
                      maxLines: 2,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter address';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: isMobile ? MobileSizes.spaceL : 24),

            // Financial Information Section
            Text(
              'Financial Information',
              style: TextStyle(
                fontSize: isMobile ? MobileSizes.sectionTitle : 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: isMobile ? MobileSizes.spaceM : 16),

            Card(
              child: Padding(
                padding: EdgeInsets.all(isMobile ? MobileSizes.cardPadding : 16),
                child: Column(
                  children: [
                    // GSTIN
                    TextFormField(
                      controller: _gstinController,
                      decoration: const InputDecoration(
                        labelText: 'GSTIN (Optional)',
                        prefixIcon: Icon(Icons.receipt_long),
                        hintText: 'e.g., 27AABCU9603R1ZX',
                      ),
                      textCapitalization: TextCapitalization.characters,
                    ),
                    SizedBox(height: isMobile ? MobileSizes.spaceM : 16),

                    // Opening Balance
                    TextFormField(
                      controller: _openingBalanceController,
                      decoration: const InputDecoration(
                        labelText: 'Opening Balance',
                        prefixIcon: Icon(Icons.account_balance_wallet),
                        hintText: '0.00',
                      ),
                      keyboardType: TextInputType.number,
                      enabled: widget.supplier == null,
                      validator: (value) {
                        if (value != null && value.isNotEmpty) {
                          if (double.tryParse(value) == null) {
                            return 'Please enter valid amount';
                          }
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: isMobile ? MobileSizes.spaceL : 24),

            // Additional Information Section
            Text(
              'Additional Information',
              style: TextStyle(
                fontSize: isMobile ? MobileSizes.sectionTitle : 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: isMobile ? MobileSizes.spaceM : 16),

            Card(
              child: Padding(
                padding: EdgeInsets.all(isMobile ? MobileSizes.cardPadding : 16),
                child: TextFormField(
                  controller: _notesController,
                  decoration: const InputDecoration(
                    labelText: 'Notes (Optional)',
                    prefixIcon: Icon(Icons.note),
                    hintText: 'Any additional information...',
                  ),
                  maxLines: 3,
                ),
              ),
            ),

            SizedBox(height: isMobile ? MobileSizes.spaceXL : 32),

            // Save Button
            ElevatedButton(
              onPressed: _isLoading ? null : _saveSupplier,
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
                      widget.supplier != null ? 'Update Supplier' : 'Add Supplier',
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

  String _getSupplierTypeLabel(SupplierType type) {
    switch (type) {
      case SupplierType.feed:
        return 'Feed Supplier';
      case SupplierType.packaging:
        return 'Packaging Supplier';
      case SupplierType.equipment:
        return 'Equipment Supplier';
      case SupplierType.general:
        return 'General Supplier';
      case SupplierType.other:
        return 'Other';
    }
  }
}
