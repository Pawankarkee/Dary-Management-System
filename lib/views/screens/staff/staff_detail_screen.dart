import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../controllers/staff_controller.dart';
import '../../../models/staff_model.dart';
import '../../../config/routes/app_router.dart';

class StaffDetailScreen extends StatelessWidget {
  final String staffId;

  const StaffDetailScreen({Key? key, required this.staffId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Staff Details'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) async {
              final controller = context.read<StaffController>();
              final staff = controller.getStaffById(staffId);
              
              if (staff == null) return;

              switch (value) {
                case 'edit':
                  Navigator.pushNamed(
                    context,
                    AppRouter.addStaff,
                    arguments: staff,
                  );
                  break;
                case 'credentials':
                  _showSetCredentialsDialog(context, controller, staff);
                  break;
                case 'relieve':
                  if (staff.isActive) {
                    _showRelieveDialog(context, controller);
                  }
                  break;
                case 'reactivate':
                  if (!staff.isActive) {
                    await controller.reactivateStaff(staffId);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Staff reactivated successfully')),
                      );
                    }
                  }
                  break;
                case 'delete':
                  _showDeleteDialog(context, controller);
                  break;
              }
            },
            itemBuilder: (context) {
              final staff = context.read<StaffController>().getStaffById(staffId);
              return [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit),
                      SizedBox(width: 12),
                      Text('Edit'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'credentials',
                  child: Row(
                    children: [
                      Icon(Icons.vpn_key, color: Colors.blue),
                      SizedBox(width: 12),
                      Text('Set Login Credentials', style: TextStyle(color: Colors.blue)),
                    ],
                  ),
                ),
                if (staff?.isActive == true)
                  const PopupMenuItem(
                    value: 'relieve',
                    child: Row(
                      children: [
                        Icon(Icons.exit_to_app, color: Colors.orange),
                        SizedBox(width: 12),
                        Text('Relieve', style: TextStyle(color: Colors.orange)),
                      ],
                    ),
                  ),
                if (staff?.isActive == false)
                  const PopupMenuItem(
                    value: 'reactivate',
                    child: Row(
                      children: [
                        Icon(Icons.replay, color: Colors.green),
                        SizedBox(width: 12),
                        Text('Reactivate', style: TextStyle(color: Colors.green)),
                      ],
                    ),
                  ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, color: Colors.red),
                      SizedBox(width: 12),
                      Text('Delete', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ];
            },
          ),
        ],
      ),
      body: Consumer<StaffController>(
        builder: (context, controller, child) {
          final staff = controller.getStaffById(staffId);

          if (staff == null) {
            return const Center(
              child: Text('Staff not found'),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeaderCard(context, staff),
                const SizedBox(height: 16),
                _buildContactCard(context, staff),
                const SizedBox(height: 16),
                _buildEmploymentCard(context, staff),
                const SizedBox(height: 16),
                _buildSalaryCard(context, staff),
                const SizedBox(height: 16),
                _buildDocumentsCard(context, staff),
                if (staff.bankAccountNumber != null || staff.ifscCode != null) ...[
                  const SizedBox(height: 16),
                  _buildBankingCard(context, staff),
                ],
                const SizedBox(height: 16),
                _buildPermissionsCard(context, staff),
                if (staff.notes != null && staff.notes!.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _buildNotesCard(context, staff),
                ],
                const SizedBox(height: 16),
                _buildTimestampCard(context, staff),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeaderCard(BuildContext context, StaffModel staff) {
    final roleColor = _getRoleColor(staff.role);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: roleColor.withOpacity(0.2),
              child: Text(
                staff.name.isNotEmpty ? staff.name[0].toUpperCase() : '?',
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: roleColor,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              staff.name,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: roleColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: roleColor.withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    _getRoleLabel(staff.role),
                    style: TextStyle(
                      fontSize: 14,
                      color: roleColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: staff.isActive
                        ? Colors.green.withOpacity(0.1)
                        : Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: staff.isActive
                          ? Colors.green.withOpacity(0.3)
                          : Colors.red.withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    staff.isActive ? 'Active' : 'Inactive',
                    style: TextStyle(
                      fontSize: 14,
                      color: staff.isActive ? Colors.green : Colors.red,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            if (staff.department != null && staff.department!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                staff.department!,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  staff.username != null ? Icons.check_circle : Icons.warning,
                  size: 16,
                  color: staff.username != null ? Colors.green : Colors.orange,
                ),
                const SizedBox(width: 4),
                Text(
                  staff.username != null 
                      ? 'Login credentials set' 
                      : 'No login credentials',
                  style: TextStyle(
                    fontSize: 12,
                    color: staff.username != null ? Colors.green : Colors.orange,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactCard(BuildContext context, StaffModel staff) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
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
            _buildDetailRow(Icons.phone, 'Phone', staff.phone),
            if (staff.email != null && staff.email!.isNotEmpty) ...[
              const SizedBox(height: 12),
              _buildDetailRow(Icons.email, 'Email', staff.email!),
            ],
            if (staff.address != null && staff.address!.isNotEmpty) ...[
              const SizedBox(height: 12),
              _buildDetailRow(Icons.location_on, 'Address', staff.address!),
            ],
            if (staff.emergencyContact != null && staff.emergencyContact!.isNotEmpty) ...[
              const SizedBox(height: 12),
              _buildDetailRow(Icons.emergency, 'Emergency Contact', staff.emergencyContact!),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEmploymentCard(BuildContext context, StaffModel staff) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
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
            _buildDetailRow(
              Icons.calendar_today,
              'Joining Date',
              DateFormat('MMMM d, y').format(staff.joiningDate),
            ),
            if (staff.relievingDate != null) ...[
              const SizedBox(height: 12),
              _buildDetailRow(
                Icons.exit_to_app,
                'Relieving Date',
                DateFormat('MMMM d, y').format(staff.relievingDate!),
              ),
            ],
            const SizedBox(height: 12),
            _buildDetailRow(
              Icons.work,
              'Experience',
              _calculateExperience(staff.joiningDate, staff.relievingDate),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSalaryCard(BuildContext context, StaffModel staff) {
    final yearlySalary = staff.salary * 12;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Salary Information',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Monthly Salary',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '₹${staff.salary.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Yearly Salary',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '₹${yearlySalary.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentsCard(BuildContext context, StaffModel staff) {
    if (staff.aadharNumber == null && staff.panNumber == null) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
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
            if (staff.aadharNumber != null && staff.aadharNumber!.isNotEmpty)
              _buildDetailRow(Icons.credit_card, 'Aadhar Number', staff.aadharNumber!),
            if (staff.panNumber != null && staff.panNumber!.isNotEmpty) ...[
              const SizedBox(height: 12),
              _buildDetailRow(Icons.account_balance_wallet, 'PAN Number', staff.panNumber!),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBankingCard(BuildContext context, StaffModel staff) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
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
            if (staff.bankAccountNumber != null && staff.bankAccountNumber!.isNotEmpty)
              _buildDetailRow(Icons.account_balance, 'Account Number', staff.bankAccountNumber!),
            if (staff.ifscCode != null && staff.ifscCode!.isNotEmpty) ...[
              const SizedBox(height: 12),
              _buildDetailRow(Icons.code, 'IFSC Code', staff.ifscCode!),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPermissionsCard(BuildContext context, StaffModel staff) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Permissions (${staff.permissions.length})',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (staff.permissions.isEmpty)
              Text(
                'No permissions assigned',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: staff.permissions.map((permission) {
                  return Chip(
                    label: Text(
                      _getPermissionLabel(permission),
                      style: const TextStyle(fontSize: 11),
                    ),
                    backgroundColor: Colors.blue.withOpacity(0.1),
                    side: BorderSide(color: Colors.blue.withOpacity(0.3)),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesCard(BuildContext context, StaffModel staff) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Notes',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              staff.notes!,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimestampCard(BuildContext context, StaffModel staff) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Timestamps',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildDetailRow(
              Icons.add_circle_outline,
              'Created',
              DateFormat('MMM d, y - hh:mm a').format(staff.createdAt),
            ),
            const SizedBox(height: 12),
            _buildDetailRow(
              Icons.update,
              'Last Updated',
              DateFormat('MMM d, y - hh:mm a').format(staff.updatedAt),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showSetCredentialsDialog(BuildContext context, StaffController controller, StaffModel staff) {
    final usernameController = TextEditingController(text: staff.username ?? '');
    final passwordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool obscurePassword = true;
    bool obscureConfirm = true;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Set Login Credentials'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (staff.username != null) ...[
                    Text(
                      'Current username: ${staff.username}',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                    const SizedBox(height: 8),
                  ],
                  Text(
                    'Staff will use these credentials to log into the system.',
                    style: TextStyle(color: Colors.grey[700], fontSize: 13),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: usernameController,
                    decoration: const InputDecoration(
                      labelText: 'Username',
                      prefixIcon: Icon(Icons.person),
                      border: OutlineInputBorder(),
                      hintText: 'Enter username',
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Username is required';
                      }
                      if (value.trim().length < 3) {
                        return 'Username must be at least 3 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: passwordController,
                    obscureText: obscurePassword,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: const Icon(Icons.lock),
                      border: const OutlineInputBorder(),
                      hintText: 'Enter password',
                      suffixIcon: IconButton(
                        icon: Icon(obscurePassword ? Icons.visibility : Icons.visibility_off),
                        onPressed: () => setState(() => obscurePassword = !obscurePassword),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Password is required';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: confirmPasswordController,
                    obscureText: obscureConfirm,
                    decoration: InputDecoration(
                      labelText: 'Confirm Password',
                      prefixIcon: const Icon(Icons.lock_outline),
                      border: const OutlineInputBorder(),
                      hintText: 'Re-enter password',
                      suffixIcon: IconButton(
                        icon: Icon(obscureConfirm ? Icons.visibility : Icons.visibility_off),
                        onPressed: () => setState(() => obscureConfirm = !obscureConfirm),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please confirm password';
                      }
                      if (value != passwordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  try {
                    final success = await controller.setStaffCredentials(
                      staff.id,
                      usernameController.text.trim(),
                      passwordController.text,
                    );
                    
                    if (dialogContext.mounted) {
                      Navigator.pop(dialogContext);
                      
                      if (success) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Login credentials set for ${staff.name}'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Username already exists. Please choose a different one.'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  } catch (e) {
                    if (dialogContext.mounted) {
                      Navigator.pop(dialogContext);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error setting credentials: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _showRelieveDialog(BuildContext context, StaffController controller) {
    DateTime selectedDate = DateTime.now();
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Relieve Staff'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Are you sure you want to relieve this staff member?'),
              const SizedBox(height: 16),
              InkWell(
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (date != null) {
                    setState(() {
                      selectedDate = date;
                    });
                  }
                },
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Relieving Date',
                    prefixIcon: Icon(Icons.calendar_today),
                  ),
                  child: Text(
                    DateFormat('MMM d, y').format(selectedDate),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                try {
                  await controller.relieveStaff(staffId, selectedDate);
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Staff relieved successfully')),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error relieving staff: $e')),
                    );
                  }
                }
              },
              child: const Text('Relieve', style: TextStyle(color: Colors.orange)),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, StaffController controller) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Staff'),
        content: const Text(
          'Are you sure you want to delete this staff member? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              try {
                await controller.deleteStaff(staffId);
                if (context.mounted) {
                  Navigator.pop(context); // Close dialog
                  Navigator.pop(context); // Go back to list
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Staff deleted successfully')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error deleting staff: $e')),
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

  String _calculateExperience(DateTime joiningDate, DateTime? relievingDate) {
    final endDate = relievingDate ?? DateTime.now();
    final difference = endDate.difference(joiningDate);
    
    final years = (difference.inDays / 365).floor();
    final months = ((difference.inDays % 365) / 30).floor();
    
    if (years > 0) {
      return '$years year${years > 1 ? 's' : ''} ${months > 0 ? '$months month${months > 1 ? 's' : ''}' : ''}';
    } else if (months > 0) {
      return '$months month${months > 1 ? 's' : ''}';
    } else {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''}';
    }
  }

  Color _getRoleColor(StaffRole role) {
    switch (role) {
      case StaffRole.admin:
        return Colors.purple;
      case StaffRole.manager:
        return Colors.blue;
      case StaffRole.supervisor:
        return Colors.indigo;
      case StaffRole.collectionAgent:
        return Colors.teal;
      case StaffRole.salesPerson:
        return Colors.orange;
      case StaffRole.accountant:
        return Colors.green;
      case StaffRole.driver:
        return Colors.brown;
      case StaffRole.staff:
        return Colors.grey;
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
