import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../../controllers/farmer_controller.dart';
import '../../../config/theme/app_theme.dart';
import '../../../models/farmer_model.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class AddFarmerScreen extends StatefulWidget {
  final FarmerModel? farmer;
  
  const AddFarmerScreen({super.key, this.farmer});

  @override
  State<AddFarmerScreen> createState() => _AddFarmerScreenState();
}

class _AddFarmerScreenState extends State<AddFarmerScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _notesController = TextEditingController();
  
  // Focus nodes for Enter key navigation
  final _nameFocusNode = FocusNode();
  final _phoneFocusNode = FocusNode();
  final _addressFocusNode = FocusNode();
  final _submitButtonFocusNode = FocusNode();
  
  MilkType _selectedMilkType = MilkType.cow;
  bool _isActive = true;
  File? _selectedImage;
  bool _isLoading = false;
  String? _phoneValidationMessage;

  @override
  void initState() {
    super.initState();
    if (widget.farmer != null) {
      _nameController.text = widget.farmer!.name;
      _phoneController.text = widget.farmer!.phone ?? '';
  _addressController.text = widget.farmer!.address ?? '';
      _selectedMilkType = widget.farmer!.milkType;
      _isActive = widget.farmer!.isActive;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
  _addressController.dispose();
    _notesController.dispose();
    _nameFocusNode.dispose();
    _phoneFocusNode.dispose();
    _addressFocusNode.dispose();
    _submitButtonFocusNode.dispose();
    super.dispose();
  }

  void _checkPhoneAvailability(String phone) {
    if (phone.length != 10) {
      setState(() => _phoneValidationMessage = null);
      return;
    }

    final farmerController = Provider.of<FarmerController>(context, listen: false);
    final allFarmers = farmerController.getAllFarmers();
    final existingFarmer = allFarmers.firstWhere(
      (farmer) {
        if (widget.farmer != null && farmer.id == widget.farmer!.id) {
          return false;
        }
        return farmer.phone == phone;
      },
      orElse: () => FarmerModel(
        id: '',
        name: '',
        milkType: MilkType.cow,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );

    setState(() {
      if (existingFarmer.id.isNotEmpty) {
        _phoneValidationMessage = '❌ Already registered to ${existingFarmer.name}';
      } else {
        _phoneValidationMessage = '✅ Available';
      }
    });
  }

  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking image: $e')),
        );
      }
    }
  }

  Future<void> _saveFarmer() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final farmerController = Provider.of<FarmerController>(context, listen: false);
      String? savedPhotoPath;
      if (_selectedImage != null) {
        try {
          final appDir = await getApplicationDocumentsDirectory();
          final filename = 'farmer_${DateTime.now().millisecondsSinceEpoch}${p.extension(_selectedImage!.path)}';
          final savedFile = await _selectedImage!.copy(p.join(appDir.path, filename));
          savedPhotoPath = savedFile.path;
        } catch (e) {
          // fallback to original path if copy fails
          savedPhotoPath = _selectedImage!.path;
        }
      }

      if (widget.farmer != null) {
        // Update existing farmer
        final updatedFarmer = widget.farmer!.copyWith(
          name: _nameController.text.trim(),
          phone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
          address: _addressController.text.trim().isEmpty ? null : _addressController.text.trim(),
          village: widget.farmer!.village,
          milkType: _selectedMilkType,
          isActive: _isActive,
          photoPath: savedPhotoPath ?? widget.farmer!.photoPath,
          updatedAt: DateTime.now(),
        );
        await farmerController.updateFarmer(updatedFarmer);
      } else {
        // Add new farmer
        await farmerController.addFarmer(
          name: _nameController.text.trim(),
          village: null,
          address: _addressController.text.trim().isEmpty ? null : _addressController.text.trim(),
          phone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
          milkType: _selectedMilkType,
          photoPath: savedPhotoPath,
        );
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.farmer != null
                  ? 'Farmer updated successfully'
                  : 'Farmer added successfully',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving farmer: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.farmer != null;
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 600;
    final isDesktop = screenWidth >= 1024;
    
    // Responsive padding and sizing
    final horizontalPadding = isDesktop ? 32.0 : (isTablet ? 24.0 : 16.0);
    final verticalPadding = isDesktop ? 24.0 : (isTablet ? 20.0 : 16.0);
    final avatarRadius = isTablet ? 70.0 : 60.0;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Farmer' : 'Add Farmer'),
        actions: [
          if (isEdit)
            IconButton(
              icon: Icon(_isActive ? Icons.check_circle : Icons.block),
              onPressed: () {
                setState(() => _isActive = !_isActive);
              },
              tooltip: _isActive ? 'Active' : 'Inactive',
            ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: isDesktop ? 1000 : double.infinity,
          ),
          child: Form(
            key: _formKey,
            child: ListView(
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: verticalPadding,
              ),
              children: [
                // Photo Section
                Center(
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: avatarRadius,
                        backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
              backgroundImage: _selectedImage != null
                ? FileImage(_selectedImage!)
                : (widget.farmer?.photoPath != null
                  ? (widget.farmer!.photoPath!.startsWith('http')
                    ? NetworkImage(widget.farmer!.photoPath!)
                    : FileImage(File(widget.farmer!.photoPath!)) as ImageProvider)
                  : null),
                        child: _selectedImage == null && widget.farmer?.photoPath == null
                            ? Icon(
                                Icons.person,
                                size: avatarRadius,
                                color: AppTheme.primaryColor,
                              )
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: CircleAvatar(
                          radius: isTablet ? 24 : 20,
                          backgroundColor: AppTheme.primaryColor,
                          child: IconButton(
                            icon: Icon(
                              Icons.camera_alt, 
                              size: isTablet ? 24 : 20, 
                              color: Colors.white,
                            ),
                            onPressed: _pickImage,
                            padding: EdgeInsets.zero,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Name
                TextFormField(
                  controller: _nameController,
                  focusNode: _nameFocusNode,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Name *',
                    hintText: 'Enter farmer name',
                    prefixIcon: Icon(Icons.person),
                  ),
                  textCapitalization: TextCapitalization.words,
                  onFieldSubmitted: (_) {
                    FocusScope.of(context).requestFocus(_phoneFocusNode);
                  },
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter farmer name';
                    }
                    if (value.trim().length < 3) {
                      return 'Name must be at least 3 characters';
                    }
                    return null;
                  },
                ),

            const SizedBox(height: 16),

            // Phone
            TextFormField(
              controller: _phoneController,
              focusNode: _phoneFocusNode,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: 'Phone *',
                hintText: 'Enter phone number',
                prefixIcon: const Icon(Icons.phone),
                helperText: _phoneValidationMessage ?? 'Each farmer must have a unique phone number',
                helperStyle: TextStyle(
                  color: _phoneValidationMessage?.startsWith('✅') == true
                      ? AppTheme.successColor
                      : (_phoneValidationMessage?.startsWith('❌') == true
                          ? AppTheme.errorColor
                          : null),
                  fontWeight: _phoneValidationMessage != null ? FontWeight.bold : null,
                ),
                suffixIcon: _phoneController.text.length == 10
                    ? Icon(
                        _phoneValidationMessage?.startsWith('✅') == true
                            ? Icons.check_circle
                            : Icons.error,
                        color: _phoneValidationMessage?.startsWith('✅') == true
                            ? AppTheme.successColor
                            : AppTheme.errorColor,
                      )
                    : null,
              ),
              keyboardType: TextInputType.phone,
              onFieldSubmitted: (_) {
                    FocusScope.of(context).requestFocus(_addressFocusNode);
              },
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(10),
              ],
              onChanged: (value) {
                _checkPhoneAvailability(value.trim());
              },
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter phone number';
                }
                if (value.trim().length != 10) {
                  return 'Phone number must be 10 digits';
                }
                
                // Check for duplicate phone number
                final farmerController = Provider.of<FarmerController>(context, listen: false);
                final allFarmers = farmerController.getAllFarmers();
                final phoneExists = allFarmers.any((farmer) {
                  // Skip checking against the current farmer being edited
                  if (widget.farmer != null && farmer.id == widget.farmer!.id) {
                    return false;
                  }
                  return farmer.phone == value.trim();
                });
                
                if (phoneExists) {
                  return 'This phone number is already registered';
                }
                
                return null;
              },
            ),

            const SizedBox(height: 16),

            // Address
            TextFormField(
              controller: _addressController,
              focusNode: _addressFocusNode,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Address',
                hintText: 'Enter full address',
                prefixIcon: Icon(Icons.location_on),
              ),
              textCapitalization: TextCapitalization.words,
              maxLines: 2,
              onFieldSubmitted: (_) {
                FocusScope.of(context).requestFocus(_submitButtonFocusNode);
              },
            ),

            const SizedBox(height: 16),

            // Milk Type (with keyboard navigation)
            DropdownButtonFormField<MilkType>(
              value: _selectedMilkType,
              decoration: const InputDecoration(
                labelText: 'Milk Type *',
                prefixIcon: Icon(Icons.water_drop),
              ),
              items: MilkType.values.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type.toString().split('.').last.toUpperCase()),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedMilkType = value);
                  // After selection, move to submit button
                  Future.microtask(() {
                    FocusScope.of(context).requestFocus(_submitButtonFocusNode);
                  });
                }
              },
            ),

            const SizedBox(height: 24),

            // Active Status
            SwitchListTile(
              title: const Text('Active Status'),
              subtitle: Text(_isActive ? 'Farmer is active' : 'Farmer is inactive'),
              value: _isActive,
              onChanged: (value) {
                setState(() => _isActive = value);
              },
              activeColor: AppTheme.successColor,
            ),

            const SizedBox(height: 32),

            // Save Button - Responsive width (focusable)
            SizedBox(
              width: isDesktop ? 400 : double.infinity,
              child: Focus(
                focusNode: _submitButtonFocusNode,
                onKey: (node, event) {
                  if (event is RawKeyDownEvent && event.logicalKey == LogicalKeyboardKey.enter) {
                    if (!_isLoading) _saveFarmer();
                    return KeyEventResult.handled;
                  }
                  return KeyEventResult.ignored;
                },
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveFarmer,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                      vertical: isTablet ? 18 : 16,
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
                          isEdit ? 'Update Farmer' : 'Add Farmer',
                          style: TextStyle(fontSize: isTablet ? 18 : 16),
                        ),
                ),
              ),
            ),

            SizedBox(height: isTablet ? 24 : 16),
          ],
        ),
          ),
        ),
      ),
    );
  }
}
