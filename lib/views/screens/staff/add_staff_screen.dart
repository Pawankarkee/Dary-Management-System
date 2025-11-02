import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../controllers/staff_controller.dart';
import '../../../models/staff_model.dart';

class AddStaffScreen extends StatefulWidget {
  final StaffModel? staff;

  const AddStaffScreen({Key? key, this.staff}) : super(key: key);

  @override
  State<AddStaffScreen> createState() => _AddStaffScreenState();
}

class _AddStaffScreenState extends State<AddStaffScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _addressController;
  late TextEditingController _departmentController;
  late TextEditingController _salaryController;
  late TextEditingController _aadharController;
  late TextEditingController _panController;
  late TextEditingController _accountNumberController;
  late TextEditingController _ifscController;
  late TextEditingController _emergencyContactController;
  late TextEditingController _notesController;

  StaffRole _selectedRole = StaffRole.staff;
  DateTime _joiningDate = DateTime.now();
  bool _isActive = true;
  List<String> _selectedPermissions = [];

  @override
  void initState() {
    super.initState();
    
    if (widget.staff != null) {
      final staff = widget.staff!;
      _nameController = TextEditingController(text: staff.name);
      _phoneController = TextEditingController(text: staff.phone);
      _emailController = TextEditingController(text: staff.email ?? '');
      _addressController = TextEditingController(text: staff.address ?? '');
      _departmentController = TextEditingController(text: staff.department ?? '');
      _salaryController = TextEditingController(text: staff.salary.toString());
      _aadharController = TextEditingController(text: staff.aadharNumber ?? '');
      _panController = TextEditingController(text: staff.panNumber ?? '');
      _accountNumberController = TextEditingController(text: staff.bankAccountNumber ?? '');
      _ifscController = TextEditingController(text: staff.ifscCode ?? '');
      _emergencyContactController = TextEditingController(text: staff.emergencyContact ?? '');
      _notesController = TextEditingController(text: staff.notes ?? '');
      _selectedRole = staff.role;
      _joiningDate = staff.joiningDate;
      _isActive = staff.isActive;
      _selectedPermissions = List.from(staff.permissions);
    } else {
      _nameController = TextEditingController();
      _phoneController = TextEditingController();
      _emailController = TextEditingController();
      _addressController = TextEditingController();
      _departmentController = TextEditingController();
      _salaryController = TextEditingController();
      _aadharController = TextEditingController();
      _panController = TextEditingController();
      _accountNumberController = TextEditingController();
      _ifscController = TextEditingController();
      _emergencyContactController = TextEditingController();
      _notesController = TextEditingController();
      _selectedPermissions = StaffPermissions.getDefaultPermissions(_selectedRole);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _departmentController.dispose();
    _salaryController.dispose();
    _aadharController.dispose();
    _panController.dispose();
    _accountNumberController.dispose();
    _ifscController.dispose();
    _emergencyContactController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.staff == null ? 'Add Staff' : 'Edit Staff'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildBasicInfoSection(),
            const SizedBox(height: 24),
            _buildRoleSection(),
            const SizedBox(height: 24),
            _buildContactSection(),
            const SizedBox(height: 24),
            _buildEmploymentSection(),
            const SizedBox(height: 24),
            _buildDocumentsSection(),
            const SizedBox(height: 24),
            _buildBankingSection(),
            const SizedBox(height: 24),
            _buildPermissionsSection(),
            const SizedBox(height: 24),
            _buildAdditionalInfoSection(),
            const SizedBox(height: 32),
            _buildSaveButton(),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicInfoSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Basic Information',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Full Name *',
                hintText: 'Enter full name',
                prefixIcon: Icon(Icons.person),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Active Status',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
                Switch(
                  value: _isActive,
                  onChanged: (value) {
                    setState(() {
                      _isActive = value;
                    });
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Role & Department',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<StaffRole>(
              value: _selectedRole,
              decoration: const InputDecoration(
                labelText: 'Role *',
                prefixIcon: Icon(Icons.badge),
              ),
              items: StaffRole.values.map((role) {
                return DropdownMenuItem(
                  value: role,
                  child: Text(_getRoleLabel(role)),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedRole = value;
                    // Update permissions based on role
                    _selectedPermissions = StaffPermissions.getDefaultPermissions(value);
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _departmentController,
              decoration: const InputDecoration(
                labelText: 'Department',
                hintText: 'Enter department',
                prefixIcon: Icon(Icons.business),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Contact Information',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: 'Phone Number *',
                hintText: 'Enter phone number',
                prefixIcon: Icon(Icons.phone),
              ),
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter phone number';
                }
                if (value.length != 10) {
                  return 'Phone number must be 10 digits';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                hintText: 'Enter email address',
                prefixIcon: Icon(Icons.email),
              ),
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value != null && value.isNotEmpty) {
                  if (!value.contains('@')) {
                    return 'Please enter a valid email';
                  }
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _addressController,
              decoration: const InputDecoration(
                labelText: 'Address',
                hintText: 'Enter full address',
                prefixIcon: Icon(Icons.location_on),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _emergencyContactController,
              decoration: const InputDecoration(
                labelText: 'Emergency Contact',
                hintText: 'Enter emergency contact number',
                prefixIcon: Icon(Icons.emergency),
              ),
              keyboardType: TextInputType.phone,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmploymentSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Employment Details',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _joiningDate,
                  firstDate: DateTime(2000),
                  lastDate: DateTime.now(),
                );
                if (date != null) {
                  setState(() {
                    _joiningDate = date;
                  });
                }
              },
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Joining Date *',
                  prefixIcon: Icon(Icons.calendar_today),
                ),
                child: Text(
                  DateFormat('MMM d, y').format(_joiningDate),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _salaryController,
              decoration: const InputDecoration(
                labelText: 'Monthly Salary *',
                hintText: 'Enter monthly salary',
                prefixIcon: Icon(Icons.currency_rupee),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter salary';
                }
                if (double.tryParse(value) == null) {
                  return 'Please enter a valid number';
                }
                if (double.parse(value) <= 0) {
                  return 'Salary must be greater than 0';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Documents',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _aadharController,
              decoration: const InputDecoration(
                labelText: 'Aadhar Number',
                hintText: 'Enter 12-digit Aadhar number',
                prefixIcon: Icon(Icons.credit_card),
              ),
              keyboardType: TextInputType.number,
              maxLength: 12,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _panController,
              decoration: const InputDecoration(
                labelText: 'PAN Number',
                hintText: 'Enter PAN number',
                prefixIcon: Icon(Icons.account_balance_wallet),
              ),
              maxLength: 10,
              textCapitalization: TextCapitalization.characters,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBankingSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Banking Details',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _accountNumberController,
              decoration: const InputDecoration(
                labelText: 'Bank Account Number',
                hintText: 'Enter account number',
                prefixIcon: Icon(Icons.account_balance),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _ifscController,
              decoration: const InputDecoration(
                labelText: 'IFSC Code',
                hintText: 'Enter IFSC code',
                prefixIcon: Icon(Icons.code),
              ),
              textCapitalization: TextCapitalization.characters,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPermissionsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Permissions',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _selectedPermissions = StaffPermissions.getDefaultPermissions(_selectedRole);
                    });
                  },
                  child: const Text('Reset to Default'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Selected: ${_selectedPermissions.length} permissions',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),
            _buildPermissionGroup('Farmers', [
              StaffPermissions.viewFarmers,
              StaffPermissions.addFarmers,
              StaffPermissions.editFarmers,
              StaffPermissions.deleteFarmers,
            ]),
            _buildPermissionGroup('Milk Collection', [
              StaffPermissions.viewMilkCollection,
              StaffPermissions.addMilkCollection,
              StaffPermissions.editMilkCollection,
              StaffPermissions.deleteMilkCollection,
            ]),
            _buildPermissionGroup('Products', [
              StaffPermissions.viewProducts,
              StaffPermissions.addProducts,
              StaffPermissions.editProducts,
              StaffPermissions.deleteProducts,
            ]),
            _buildPermissionGroup('Sales', [
              StaffPermissions.viewSales,
              StaffPermissions.addSales,
              StaffPermissions.editSales,
              StaffPermissions.deleteSales,
            ]),
            _buildPermissionGroup('Purchases', [
              StaffPermissions.viewPurchases,
              StaffPermissions.addPurchases,
              StaffPermissions.editPurchases,
              StaffPermissions.deletePurchases,
            ]),
            _buildPermissionGroup('Expenses', [
              StaffPermissions.viewExpenses,
              StaffPermissions.addExpenses,
              StaffPermissions.editExpenses,
              StaffPermissions.deleteExpenses,
            ]),
            _buildPermissionGroup('Others', [
              StaffPermissions.viewReports,
              StaffPermissions.viewStaff,
              StaffPermissions.manageStaff,
              StaffPermissions.viewSettings,
              StaffPermissions.manageSettings,
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildPermissionGroup(String title, List<String> permissions) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: permissions.map((permission) {
            final isSelected = _selectedPermissions.contains(permission);
            return FilterChip(
              label: Text(
                _getPermissionLabel(permission),
                style: const TextStyle(fontSize: 11),
              ),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedPermissions.add(permission);
                  } else {
                    _selectedPermissions.remove(permission);
                  }
                });
              },
            );
          }).toList(),
        ),
        const Divider(height: 24),
      ],
    );
  }

  Widget _buildAdditionalInfoSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Additional Information',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notes',
                hintText: 'Enter any additional notes',
                prefixIcon: Icon(Icons.note),
              ),
              maxLines: 4,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return ElevatedButton(
      onPressed: _saveStaff,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Text(
        widget.staff == null ? 'Add Staff' : 'Update Staff',
        style: const TextStyle(fontSize: 16),
      ),
    );
  }

  void _saveStaff() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      final controller = context.read<StaffController>();
      final now = DateTime.now();

      final staff = StaffModel(
        id: widget.staff?.id ?? StaffModel.generateId(),
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        email: _emailController.text.trim().isEmpty
            ? null
            : _emailController.text.trim(),
        address: _addressController.text.trim().isEmpty
            ? null
            : _addressController.text.trim(),
        role: _selectedRole,
        department: _departmentController.text.trim().isEmpty
            ? null
            : _departmentController.text.trim(),
        salary: double.parse(_salaryController.text),
        joiningDate: _joiningDate,
        isActive: _isActive,
        aadharNumber: _aadharController.text.trim().isEmpty
            ? null
            : _aadharController.text.trim(),
        panNumber: _panController.text.trim().isEmpty
            ? null
            : _panController.text.trim(),
        bankAccountNumber: _accountNumberController.text.trim().isEmpty
            ? null
            : _accountNumberController.text.trim(),
        ifscCode: _ifscController.text.trim().isEmpty
            ? null
            : _ifscController.text.trim(),
        emergencyContact: _emergencyContactController.text.trim().isEmpty
            ? null
            : _emergencyContactController.text.trim(),
        permissions: _selectedPermissions,
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
        createdAt: widget.staff?.createdAt ?? now,
        updatedAt: now,
      );

      if (widget.staff == null) {
        await controller.addStaff(staff);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Staff added successfully')),
          );
        }
      } else {
        await controller.updateStaff(staff);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Staff updated successfully')),
          );
        }
      }

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  String _getRoleLabel(StaffRole role) {
    switch (role) {
      case StaffRole.admin:
        return 'Admin';
      case StaffRole.manager:
        return 'Manager';
      case StaffRole.supervisor:
        return 'Supervisor';
      case StaffRole.collectionAgent:
        return 'Collection Agent';
      case StaffRole.salesPerson:
        return 'Sales Person';
      case StaffRole.accountant:
        return 'Accountant';
      case StaffRole.driver:
        return 'Driver';
      case StaffRole.staff:
        return 'Staff';
    }
  }

  String _getPermissionLabel(String permission) {
    return permission.split('_').map((word) {
      return word[0].toUpperCase() + word.substring(1);
    }).join(' ');
  }
}
