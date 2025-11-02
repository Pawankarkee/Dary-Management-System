import 'package:flutter/material.dart';
import '../../../config/theme/app_theme.dart';

/// Collection Center Management Module
/// Manage multiple milk collection centers/locations
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../controllers/collection_center_controller.dart';
import '../../../models/collection_center_model.dart';
import '../../../config/theme/app_theme.dart';
import '../../../utils/responsive.dart';

class CollectionCenterScreen extends StatefulWidget {
  const CollectionCenterScreen({super.key});

  @override
  State<CollectionCenterScreen> createState() => _CollectionCenterScreenState();
}

class _CollectionCenterScreenState extends State<CollectionCenterScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CollectionCenterController>().loadCenters();
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
    final controller = context.watch<CollectionCenterController>();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Collection Centers'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => controller.loadCenters(),
            tooltip: 'Refresh',
          ),
          IconButton(
            icon: const Icon(Icons.add_location),
            onPressed: () => _showAddCenterDialog(),
            tooltip: 'Add Center',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: isMobile,
          tabs: const [
            Tab(text: 'Centers', icon: Icon(Icons.business, size: 18)),
            Tab(text: 'Receptions', icon: Icon(Icons.local_shipping, size: 18)),
            Tab(text: 'Stock', icon: Icon(Icons.inventory, size: 18)),
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
                hintText: 'Search centers...',
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

          // Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildCentersList(controller, isMobile),
                _buildReceptionsList(controller, isMobile),
                _buildStockView(controller, isMobile),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          if (_tabController.index == 0) {
            _showAddCenterDialog();
          } else if (_tabController.index == 1) {
            _showAddReceptionDialog();
          }
        },
        icon: const Icon(Icons.add),
        label: Text(_tabController.index == 0 ? 'Add Center' : 'Receive Milk'),
      ),
    );
  }

  Widget _buildSummaryCards(CollectionCenterController controller, bool isMobile) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? MobileSizes.spaceM : 16,
        vertical: MobileSizes.spaceS,
      ),
      child: Responsive.isDesktop(context)
          ? Row(
              children: [
                Expanded(child: _buildSummaryCard('Total Centers', 
                    '${controller.centers.length}', Icons.business, AppTheme.primaryColor)),
                const SizedBox(width: 12),
                Expanded(child: _buildSummaryCard('Capacity', 
                    '${controller.getTotalCapacity().toStringAsFixed(0)}L', 
                    Icons.storage, Colors.blue)),
                const SizedBox(width: 12),
                Expanded(child: _buildSummaryCard('Current Stock', 
                    '${controller.getTotalStock().toStringAsFixed(0)}L', 
                    Icons.inventory, AppTheme.warningColor)),
                const SizedBox(width: 12),
                Expanded(child: _buildSummaryCard('Received Today', 
                    '${controller.getTotalMilkReceived().toStringAsFixed(0)}L', 
                    Icons.check_circle, AppTheme.successColor)),
              ],
            )
          : SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildSummaryCard('Centers', '${controller.centers.length}', 
                      Icons.business, AppTheme.primaryColor),
                  const SizedBox(width: 8),
                  _buildSummaryCard('Capacity', '${controller.getTotalCapacity().toStringAsFixed(0)}L', 
                      Icons.storage, Colors.blue),
                  const SizedBox(width: 8),
                  _buildSummaryCard('Stock', '${controller.getTotalStock().toStringAsFixed(0)}L', 
                      Icons.inventory, AppTheme.warningColor),
                  const SizedBox(width: 8),
                  _buildSummaryCard('Today', '${controller.getTotalMilkReceived().toStringAsFixed(0)}L', 
                      Icons.check_circle, AppTheme.successColor),
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
        width: isMobile ? 120 : null,
        padding: EdgeInsets.all(isMobile ? MobileSizes.spaceM : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: isMobile ? 20 : 24),
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
                fontSize: isMobile ? 10 : 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCentersList(CollectionCenterController controller, bool isMobile) {
    if (controller.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    List<CollectionCenterModel> centers = controller.centers;

    if (_searchController.text.isNotEmpty) {
      centers = controller.searchCenters(_searchController.text);
    }

    if (centers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.business, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'No centers found',
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: _showAddCenterDialog,
              icon: const Icon(Icons.add),
              label: const Text('Add First Center'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(isMobile ? MobileSizes.spaceM : 16),
      itemCount: centers.length,
      itemBuilder: (context, index) {
        final center = centers[index];
        return _buildCenterCard(center, isMobile);
      },
    );
  }

  Widget _buildCenterCard(CollectionCenterModel center, bool isMobile) {
    final statusColor = _getStatusColor(center.status);
    final utilizationColor = center.capacityUtilization > 90 
        ? AppTheme.errorColor 
        : center.capacityUtilization > 70 
            ? AppTheme.warningColor 
            : AppTheme.successColor;
    
    return Card(
      margin: EdgeInsets.only(bottom: isMobile ? MobileSizes.spaceM : 12),
      elevation: MobileSizes.cardElevation,
      child: InkWell(
        onTap: () => _showCenterDetails(center),
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
                    child: Icon(Icons.business, color: statusColor, size: isMobile ? 20 : 24),
                  ),
                  SizedBox(width: isMobile ? MobileSizes.spaceS : 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          center.name,
                          style: TextStyle(
                            fontSize: isMobile ? MobileSizes.bodyLarge : 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Code: ${center.code}',
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
                      center.status.name.toUpperCase(),
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

              // Details
              Row(
                children: [
                  Icon(Icons.location_on, size: isMobile ? 16 : 18, color: Colors.grey),
                  SizedBox(width: isMobile ? 4 : 6),
                  Expanded(
                    child: Text(
                      center.address,
                      style: TextStyle(fontSize: isMobile ? 12 : 13, color: Colors.grey),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.person, size: isMobile ? 16 : 18, color: Colors.grey),
                  SizedBox(width: isMobile ? 4 : 6),
                  Text(
                    '${center.contactPerson} • ${center.phone}',
                    style: TextStyle(fontSize: isMobile ? 12 : 13, color: Colors.grey),
                  ),
                ],
              ),
              SizedBox(height: isMobile ? MobileSizes.spaceM : 12),

              // Capacity Info
              Container(
                padding: EdgeInsets.all(isMobile ? MobileSizes.spaceS : 12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildInfoColumn('Capacity', '${center.capacity.toStringAsFixed(0)}L', isMobile),
                    ),
                    Expanded(
                      child: _buildInfoColumn('Stock', '${center.currentStock.toStringAsFixed(0)}L', isMobile),
                    ),
                    Expanded(
                      child: _buildInfoColumn('Available', '${center.availableSpace.toStringAsFixed(0)}L', isMobile),
                    ),
                    Expanded(
                      child: _buildInfoColumn('Usage', '${center.capacityUtilization.toStringAsFixed(1)}%', isMobile),
                    ),
                  ],
                ),
              ),
              SizedBox(height: isMobile ? MobileSizes.spaceS : 8),

              // Utilization Bar
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Capacity Utilization',
                        style: TextStyle(
                          fontSize: isMobile ? 11 : 12,
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        '${center.capacityUtilization.toStringAsFixed(1)}%',
                        style: TextStyle(
                          fontSize: isMobile ? 11 : 12,
                          fontWeight: FontWeight.bold,
                          color: utilizationColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: center.capacityUtilization / 100,
                      backgroundColor: Colors.grey.shade300,
                      valueColor: AlwaysStoppedAnimation<Color>(utilizationColor),
                      minHeight: 6,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReceptionsList(CollectionCenterController controller, bool isMobile) {
    if (controller.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final receptions = controller.receptions;

    if (receptions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.local_shipping, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'No milk receptions recorded',
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(isMobile ? MobileSizes.spaceM : 16),
      itemCount: receptions.length,
      itemBuilder: (context, index) {
        final reception = receptions[index];
        return _buildReceptionCard(reception, isMobile);
      },
    );
  }

  Widget _buildReceptionCard(MilkReceptionModel reception, bool isMobile) {
    final dateFormat = DateFormat('dd MMM yyyy, hh:mm a');
    final qualityColor = reception.qualityPassed ? AppTheme.successColor : AppTheme.errorColor;
    
    return Card(
      margin: EdgeInsets.only(bottom: isMobile ? MobileSizes.spaceM : 12),
      elevation: MobileSizes.cardElevation,
      child: Padding(
        padding: EdgeInsets.all(isMobile ? MobileSizes.cardPadding : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  reception.qualityPassed ? Icons.check_circle : Icons.cancel,
                  color: qualityColor,
                  size: isMobile ? 20 : 24,
                ),
                SizedBox(width: isMobile ? MobileSizes.spaceS : 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        reception.farmerName,
                        style: TextStyle(
                          fontSize: isMobile ? MobileSizes.bodyLarge : 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        reception.centerName,
                        style: TextStyle(
                          fontSize: isMobile ? MobileSizes.bodySmall : 13,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '${reception.quantity.toStringAsFixed(1)}L',
                  style: TextStyle(
                    fontSize: isMobile ? 18 : 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ],
            ),
            SizedBox(height: isMobile ? MobileSizes.spaceS : 12),
            Container(
              padding: EdgeInsets.all(isMobile ? MobileSizes.spaceS : 10),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _buildInfoColumn('Fat', '${reception.fat.toStringAsFixed(1)}%', isMobile),
                  ),
                  Expanded(
                    child: _buildInfoColumn('SNF', '${reception.snf.toStringAsFixed(1)}%', isMobile),
                  ),
                  Expanded(
                    child: _buildInfoColumn('Temp', '${reception.temperature.toStringAsFixed(1)}°C', isMobile),
                  ),
                ],
              ),
            ),
            SizedBox(height: isMobile ? MobileSizes.spaceS : 8),
            Row(
              children: [
                Icon(Icons.schedule, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  dateFormat.format(reception.receptionTime),
                  style: TextStyle(fontSize: isMobile ? 11 : 12, color: Colors.grey),
                ),
                const Spacer(),
                Text(
                  'By: ${reception.receivedBy}',
                  style: TextStyle(fontSize: isMobile ? 11 : 12, color: Colors.grey),
                ),
              ],
            ),
            if (reception.remarks != null && reception.remarks!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.note, size: 16, color: Colors.blue.shade700),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        reception.remarks!,
                        style: TextStyle(fontSize: 12, color: Colors.blue.shade900),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStockView(CollectionCenterController controller, bool isMobile) {
    if (controller.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final centers = controller.getActiveCenters();

    if (centers.isEmpty) {
      return const Center(child: Text('No active centers'));
    }

    return ListView.builder(
      padding: EdgeInsets.all(isMobile ? MobileSizes.spaceM : 16),
      itemCount: centers.length,
      itemBuilder: (context, index) {
        final center = centers[index];
        return Card(
          margin: EdgeInsets.only(bottom: isMobile ? MobileSizes.spaceM : 12),
          child: Padding(
            padding: EdgeInsets.all(isMobile ? MobileSizes.cardPadding : 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  center.name,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildStockInfo('Current Stock', 
                          '${center.currentStock.toStringAsFixed(0)}L', 
                          Icons.inventory, AppTheme.primaryColor),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStockInfo('Capacity', 
                          '${center.capacity.toStringAsFixed(0)}L', 
                          Icons.storage, Colors.blue),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: center.capacityUtilization / 100,
                  backgroundColor: Colors.grey.shade300,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    center.capacityUtilization > 90 ? AppTheme.errorColor : AppTheme.successColor,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStockInfo(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
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

  Color _getStatusColor(CenterStatus status) {
    switch (status) {
      case CenterStatus.active:
        return AppTheme.successColor;
      case CenterStatus.inactive:
        return Colors.grey;
      case CenterStatus.maintenance:
        return AppTheme.warningColor;
    }
  }

  void _showAddCenterDialog() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Add center form coming soon')),
    );
  }

  void _showAddReceptionDialog() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Milk reception form coming soon')),
    );
  }

  void _showCenterDetails(CollectionCenterModel center) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Viewing details for ${center.name}')),
    );
  }
}
