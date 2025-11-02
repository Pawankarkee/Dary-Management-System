import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../controllers/staff_controller.dart';
import '../../../models/staff_model.dart';
import '../../../config/routes/app_router.dart';

class StaffScreen extends StatefulWidget {
  const StaffScreen({Key? key}) : super(key: key);

  @override
  State<StaffScreen> createState() => _StaffScreenState();
}

class _StaffScreenState extends State<StaffScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StaffController>().loadStaff();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Staff Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildFilterChips(),
          _buildStatisticsRow(),
          Expanded(child: _buildStaffList()),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushNamed(context, AppRouter.addStaff);
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Staff'),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search staff...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    context.read<StaffController>().clearSearch();
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onChanged: (value) {
          context.read<StaffController>().searchStaff(value);
        },
      ),
    );
  }

  Widget _buildFilterChips() {
    final controller = context.watch<StaffController>();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          if (controller.selectedRole != null ||
              controller.selectedActiveStatus != null)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ActionChip(
                label: const Text('Clear Filters'),
                onPressed: () => controller.clearFilters(),
                avatar: const Icon(Icons.clear, size: 18),
              ),
            ),
          if (controller.selectedRole != null)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Chip(
                label: Text(_getRoleLabel(controller.selectedRole!)),
                deleteIcon: const Icon(Icons.close, size: 18),
                onDeleted: () => controller.filterByRole(null),
              ),
            ),
          if (controller.selectedActiveStatus != null)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Chip(
                label: Text(controller.selectedActiveStatus! ? 'Active' : 'Inactive'),
                deleteIcon: const Icon(Icons.close, size: 18),
                onDeleted: () => controller.filterByActiveStatus(null),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatisticsRow() {
    final controller = context.watch<StaffController>();
    final stats = controller.getStaffStatistics();

    return Container(
      margin: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              'Total',
              '${stats['totalStaff']}',
              Icons.people,
              Colors.blue,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              'Active',
              '${stats['activeStaff']}',
              Icons.check_circle,
              Colors.green,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              'Salary',
              '₹${(stats['totalSalaryExpense'] as double).toStringAsFixed(0)}',
              Icons.currency_rupee,
              Colors.orange,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStaffList() {
    return Consumer<StaffController>(
      builder: (context, controller, child) {
        if (controller.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.staff.isEmpty) {
          return _buildEmptyState();
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.staff.length,
          itemBuilder: (context, index) {
            final staff = controller.staff[index];
            return _buildStaffCard(staff);
          },
        );
      },
    );
  }

  Widget _buildStaffCard(StaffModel staff) {
    final roleColor = _getRoleColor(staff.role);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(
            context,
            AppRouter.staffDetail,
            arguments: staff.id,
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: roleColor.withOpacity(0.2),
                child: Text(
                  staff.name.isNotEmpty ? staff.name[0].toUpperCase() : '?',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: roleColor,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            staff.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
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
                              fontSize: 10,
                              color: staff.isActive ? Colors.green : Colors.red,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
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
                              fontSize: 11,
                              color: roleColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        if (staff.department != null &&
                            staff.department!.isNotEmpty) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.grey.withOpacity(0.3),
                              ),
                            ),
                            child: Text(
                              staff.department!,
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey[700],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.phone, size: 14, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          staff.phone,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        if (staff.email != null && staff.email!.isNotEmpty) ...[
                          const SizedBox(width: 12),
                          Icon(Icons.email, size: 14, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              staff.email!,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.calendar_today,
                            size: 14, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          'Joined: ${DateFormat('MMM d, y').format(staff.joiningDate)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '₹${staff.salary.toStringAsFixed(0)}/month',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_outline,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No staff members found',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add your first staff member to get started',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Staff'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Role', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: StaffRole.values.map((role) {
                  return FilterChip(
                    label: Text(_getRoleLabel(role)),
                    selected: context.read<StaffController>().selectedRole == role,
                    onSelected: (selected) {
                      context.read<StaffController>().filterByRole(
                        selected ? role : null,
                      );
                      Navigator.pop(context);
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              const Text('Status', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  FilterChip(
                    label: const Text('Active'),
                    selected: context.read<StaffController>().selectedActiveStatus == true,
                    onSelected: (selected) {
                      context.read<StaffController>().filterByActiveStatus(
                        selected ? true : null,
                      );
                      Navigator.pop(context);
                    },
                  ),
                  FilterChip(
                    label: const Text('Inactive'),
                    selected: context.read<StaffController>().selectedActiveStatus == false,
                    onSelected: (selected) {
                      context.read<StaffController>().filterByActiveStatus(
                        selected ? false : null,
                      );
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              context.read<StaffController>().clearFilters();
              Navigator.pop(context);
            },
            child: const Text('Clear All'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
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
}
