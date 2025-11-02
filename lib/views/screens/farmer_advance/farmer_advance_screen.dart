import 'package:flutter/material.dart';
import '../../../config/theme/app_theme.dart';
import '../../../config/routes/app_router.dart';

/// Farmer Advance Payment Module
/// Manage advance payments/loans given to farmers
/// Features:
/// - Track advance payments
/// - Deduct from milk payments
/// - Payment history
/// - Interest calculation (optional)
/// - Repayment tracking
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../controllers/farmer_advance_controller.dart';
import '../../../controllers/farmer_controller.dart';
import '../../../models/farmer_advance_model.dart';
import '../../../config/theme/app_theme.dart';
import '../../../utils/responsive.dart';

class FarmerAdvanceScreen extends StatefulWidget {
  const FarmerAdvanceScreen({super.key});

  @override
  State<FarmerAdvanceScreen> createState() => _FarmerAdvanceScreenState();
}

class _FarmerAdvanceScreenState extends State<FarmerAdvanceScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  late TabController _tabController;
  AdvanceStatus? _statusFilter;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FarmerAdvanceController>().loadAdvances();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);
    final controller = context.watch<FarmerAdvanceController>();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Farmer Advances'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
            tooltip: 'Filter',
          ),
          IconButton(
            icon: const Icon(Icons.file_download),
            onPressed: () {
              // TODO: Export to Excel/PDF
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Export feature coming soon')),
              );
            },
            tooltip: 'Export',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: isMobile,
          tabs: const [
            Tab(text: 'All', icon: Icon(Icons.list, size: 18)),
            Tab(text: 'Active', icon: Icon(Icons.access_time, size: 18)),
            Tab(text: 'Completed', icon: Icon(Icons.check_circle, size: 18)),
            Tab(text: 'Overdue', icon: Icon(Icons.warning, size: 18)),
          ],
        ),
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: EdgeInsets.all(isMobile ? MobileSizes.spaceM : 16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by farmer name, purpose...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {});
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(MobileSizes.inputRadius),
                ),
                filled: true,
              ),
              onChanged: (value) => setState(() {}),
            ),
          ),

          // Summary Cards
          _buildSummaryCards(controller, isMobile),

          // Advances List
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildAdvancesList(controller, null),
                _buildAdvancesList(controller, AdvanceStatus.active),
                _buildAdvancesList(controller, AdvanceStatus.completed),
                _buildAdvancesList(controller, AdvanceStatus.overdue),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddAdvanceDialog(),
        icon: const Icon(Icons.add),
        label: Text(isMobile ? 'Add' : 'New Advance'),
      ),
    );
  }

  Widget _buildSummaryCards(FarmerAdvanceController controller, bool isMobile) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? MobileSizes.spaceM : 16,
        vertical: MobileSizes.spaceS,
      ),
      child: Responsive.isDesktop(context)
          ? Row(
              children: [
                Expanded(child: _buildSummaryCard('Total Advances', 
                    '₹${controller.getTotalAdvanceAmount().toStringAsFixed(2)}', 
                    Icons.account_balance_wallet, AppTheme.primaryColor)),
                const SizedBox(width: 12),
                Expanded(child: _buildSummaryCard('Outstanding', 
                    '₹${controller.getTotalOutstanding().toStringAsFixed(2)}', 
                    Icons.pending_actions, AppTheme.warningColor)),
                const SizedBox(width: 12),
                Expanded(child: _buildSummaryCard('Paid Amount', 
                    '₹${controller.getTotalPaidAmount().toStringAsFixed(2)}', 
                    Icons.check_circle, AppTheme.successColor)),
                const SizedBox(width: 12),
                Expanded(child: _buildSummaryCard('Total Count', 
                    '${controller.advances.length}', 
                    Icons.numbers, Colors.blue)),
              ],
            )
          : SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildSummaryCard('Total', '₹${controller.getTotalAdvanceAmount().toStringAsFixed(0)}', 
                      Icons.account_balance_wallet, AppTheme.primaryColor),
                  const SizedBox(width: 8),
                  _buildSummaryCard('Outstanding', '₹${controller.getTotalOutstanding().toStringAsFixed(0)}', 
                      Icons.pending_actions, AppTheme.warningColor),
                  const SizedBox(width: 8),
                  _buildSummaryCard('Paid', '₹${controller.getTotalPaidAmount().toStringAsFixed(0)}', 
                      Icons.check_circle, AppTheme.successColor),
                  const SizedBox(width: 8),
                  _buildSummaryCard('Count', '${controller.advances.length}', 
                      Icons.numbers, Colors.blue),
                ],
              ),
            ),
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color color) {
    final isMobile = Responsive.isMobile(context);
    return Card(
      elevation: MobileSizes.cardElevation,
      child: Container(
        width: isMobile ? 140 : null,
        padding: EdgeInsets.all(isMobile ? MobileSizes.spaceM : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: color, size: isMobile ? 20 : 24),
                if (isMobile) const SizedBox(),
              ],
            ),
            SizedBox(height: isMobile ? MobileSizes.spaceXS : 8),
            Text(
              value,
              style: TextStyle(
                fontSize: isMobile ? 16 : 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            SizedBox(height: isMobile ? 2 : 4),
            Text(
              title,
              style: TextStyle(
                fontSize: isMobile ? 11 : 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdvancesList(FarmerAdvanceController controller, AdvanceStatus? status) {
    if (controller.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    List<FarmerAdvanceModel> advances = status == null
        ? controller.advances
        : status == AdvanceStatus.overdue
            ? controller.getOverdueAdvances()
            : controller.filterByStatus(status);

    // Apply search filter
    if (_searchController.text.isNotEmpty) {
      advances = advances.where((advance) {
        final query = _searchController.text.toLowerCase();
        return advance.farmerName.toLowerCase().contains(query) ||
               advance.purpose.toLowerCase().contains(query);
      }).toList();
    }

    if (advances.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'No advances found',
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }

    final isMobile = Responsive.isMobile(context);
    
    return ListView.builder(
      padding: EdgeInsets.all(isMobile ? MobileSizes.spaceM : 16),
      itemCount: advances.length,
      itemBuilder: (context, index) {
        final advance = advances[index];
        return _buildAdvanceCard(advance, isMobile);
      },
    );
  }

  Widget _buildAdvanceCard(FarmerAdvanceModel advance, bool isMobile) {
    final statusColor = _getStatusColor(advance.status);
    final dateFormat = DateFormat('dd MMM yyyy');
    
    return Card(
      margin: EdgeInsets.only(bottom: isMobile ? MobileSizes.spaceM : 12),
      elevation: MobileSizes.cardElevation,
      child: InkWell(
        onTap: () => _showAdvanceDetails(advance),
        borderRadius: BorderRadius.circular(MobileSizes.cardRadius),
        child: Padding(
          padding: EdgeInsets.all(isMobile ? MobileSizes.cardPadding : 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: statusColor.withOpacity(0.2),
                    child: Icon(
                      Icons.person,
                      color: statusColor,
                      size: isMobile ? 20 : 24,
                    ),
                  ),
                  SizedBox(width: isMobile ? MobileSizes.spaceS : 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          advance.farmerName,
                          style: TextStyle(
                            fontSize: isMobile ? MobileSizes.bodyLarge : 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          advance.purpose,
                          style: TextStyle(
                            fontSize: isMobile ? MobileSizes.bodySmall : 13,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      advance.status.name.toUpperCase(),
                      style: TextStyle(
                        fontSize: isMobile ? 10 : 11,
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: isMobile ? MobileSizes.spaceM : 12),

              // Amount Details
              Container(
                padding: EdgeInsets.all(isMobile ? MobileSizes.spaceS : 12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildInfoColumn('Amount', '₹${advance.amount.toStringAsFixed(2)}', isMobile),
                    ),
                    if (advance.interestRate > 0)
                      Expanded(
                        child: _buildInfoColumn('Interest', '${advance.interestRate}%', isMobile),
                      ),
                    Expanded(
                      child: _buildInfoColumn('Paid', '₹${advance.paidAmount.toStringAsFixed(2)}', isMobile),
                    ),
                    Expanded(
                      child: _buildInfoColumn('Balance', '₹${advance.remainingAmount.toStringAsFixed(2)}', isMobile),
                    ),
                  ],
                ),
              ),
              SizedBox(height: isMobile ? MobileSizes.spaceS : 8),

              // Progress Bar
              if (advance.status != AdvanceStatus.cancelled)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Repayment Progress',
                          style: TextStyle(
                            fontSize: isMobile ? 11 : 12,
                            color: Colors.grey,
                          ),
                        ),
                        Text(
                          '${advance.paidPercentage.toStringAsFixed(1)}%',
                          style: TextStyle(
                            fontSize: isMobile ? 11 : 12,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: advance.paidPercentage / 100,
                        backgroundColor: Colors.grey.shade300,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          advance.isFullyPaid ? AppTheme.successColor : AppTheme.primaryColor,
                        ),
                        minHeight: 6,
                      ),
                    ),
                  ],
                ),
              
              SizedBox(height: isMobile ? MobileSizes.spaceS : 8),

              // Footer
              Row(
                children: [
                  Icon(Icons.calendar_today, size: isMobile ? 14 : 16, color: Colors.grey),
                  SizedBox(width: isMobile ? 4 : 6),
                  Text(
                    'Issued: ${dateFormat.format(advance.issueDate)}',
                    style: TextStyle(
                      fontSize: isMobile ? 11 : 12,
                      color: Colors.grey,
                    ),
                  ),
                  if (advance.dueDate != null) ...[
                    const Spacer(),
                    Icon(
                      Icons.event,
                      size: isMobile ? 14 : 16,
                      color: advance.dueDate!.isBefore(DateTime.now()) && !advance.isFullyPaid
                          ? AppTheme.errorColor
                          : Colors.grey,
                    ),
                    SizedBox(width: isMobile ? 4 : 6),
                    Text(
                      'Due: ${dateFormat.format(advance.dueDate!)}',
                      style: TextStyle(
                        fontSize: isMobile ? 11 : 12,
                        color: advance.dueDate!.isBefore(DateTime.now()) && !advance.isFullyPaid
                            ? AppTheme.errorColor
                            : Colors.grey,
                      ),
                    ),
                  ],
                ],
              ),

              // Action Buttons
              if (advance.status == AdvanceStatus.active) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _showPaymentDialog(advance),
                        icon: const Icon(Icons.payment, size: 18),
                        label: const Text('Add Payment'),
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                            vertical: isMobile ? 8 : 12,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _showAdvanceDetails(advance),
                        icon: const Icon(Icons.visibility, size: 18),
                        label: const Text('View Details'),
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                            vertical: isMobile ? 8 : 12,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoColumn(String label, String value, bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isMobile ? 10 : 11,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: isMobile ? 12 : 13,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(AdvanceStatus status) {
    switch (status) {
      case AdvanceStatus.active:
        return AppTheme.warningColor;
      case AdvanceStatus.completed:
        return AppTheme.successColor;
      case AdvanceStatus.overdue:
        return AppTheme.errorColor;
      case AdvanceStatus.cancelled:
        return Colors.grey;
    }
  }

  void _showFilterDialog() {
    // TODO: Implement filter dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Filter feature coming soon')),
    );
  }

  void _showAddAdvanceDialog() {
    // TODO: Navigate to add advance screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Add advance dialog coming soon')),
    );
  }

  void _showAdvanceDetails(FarmerAdvanceModel advance) {
    // TODO: Navigate to advance details screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Viewing details for ${advance.farmerName}')),
    );
  }

  void _showPaymentDialog(FarmerAdvanceModel advance) {
    // TODO: Show payment dialog
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Add payment for ${advance.farmerName}')),
    );
  }
}

