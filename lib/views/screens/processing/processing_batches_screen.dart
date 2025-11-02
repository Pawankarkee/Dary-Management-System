import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../controllers/processing_controller.dart';
import '../../../models/processing_batch_model.dart';
import '../../../config/routes/app_router.dart';

class ProcessingBatchesScreen extends StatefulWidget {
  const ProcessingBatchesScreen({Key? key}) : super(key: key);

  @override
  State<ProcessingBatchesScreen> createState() => _ProcessingBatchesScreenState();
}

class _ProcessingBatchesScreenState extends State<ProcessingBatchesScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProcessingController>().loadBatches();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showFilterDialog() {
    final controller = context.read<ProcessingController>();
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Filter Batches'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Processing Type', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    FilterChip(
                      label: const Text('All'),
                      selected: controller.selectedType == null,
                      onSelected: (_) {
                        controller.filterByType(null);
                        setState(() {});
                      },
                    ),
                    ...ProcessingType.values.map((type) => FilterChip(
                      label: Text(type.displayName),
                      selected: controller.selectedType == type,
                      onSelected: (_) {
                        controller.filterByType(type);
                        setState(() {});
                      },
                    )),
                  ],
                ),
                const SizedBox(height: 16),
                const Text('Status', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    FilterChip(
                      label: const Text('All'),
                      selected: controller.selectedStatus == null,
                      onSelected: (_) {
                        controller.filterByStatus(null);
                        setState(() {});
                      },
                    ),
                    ...BatchStatus.values.map((status) => FilterChip(
                      label: Text(status.displayName),
                      selected: controller.selectedStatus == status,
                      onSelected: (_) {
                        controller.filterByStatus(status);
                        setState(() {});
                      },
                    )),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                controller.clearFilters();
                Navigator.pop(context);
              },
              child: const Text('Clear All'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Done'),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(BatchStatus status) {
    switch (status) {
      case BatchStatus.planned:
        return Colors.blue;
      case BatchStatus.inProgress:
        return Colors.orange;
      case BatchStatus.qualityCheck:
        return Colors.purple;
      case BatchStatus.completed:
        return Colors.green;
      case BatchStatus.rejected:
        return Colors.red;
      case BatchStatus.cancelled:
        return Colors.grey;
    }
  }

  IconData _getProcessingTypeIcon(ProcessingType type) {
    switch (type) {
      case ProcessingType.pasteurization:
        return Icons.thermostat;
      case ProcessingType.homogenization:
        return Icons.blender;
      case ProcessingType.creamSeparation:
        return Icons.filter_alt;
      case ProcessingType.butterMaking:
        return Icons.cake;
      case ProcessingType.cheeseProduction:
        return Icons.food_bank;
      case ProcessingType.yogurtProduction:
        return Icons.local_drink;
      case ProcessingType.paneerMaking:
        return Icons.rectangle;
      case ProcessingType.gheeProduction:
        return Icons.opacity;
      case ProcessingType.milkPowder:
        return Icons.grain;
      case ProcessingType.iceCream:
        return Icons.icecream;
      case ProcessingType.flavoredMilk:
        return Icons.local_cafe;
      case ProcessingType.condensedMilk:
        return Icons.water_drop;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manufacturing & Processing'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: Consumer<ProcessingController>(
        builder: (context, controller, child) {
          if (controller.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final stats = controller.getStatistics();

          return Column(
            children: [
              // Search Bar
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search by batch number, type, operator...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              controller.searchBatches('');
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onChanged: controller.searchBatches,
                ),
              ),

              // Active Filters
              if (controller.selectedType != null ||
                  controller.selectedStatus != null ||
                  controller.searchQuery.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Wrap(
                    spacing: 8,
                    children: [
                      if (controller.selectedType != null)
                        Chip(
                          label: Text(controller.selectedType!.displayName),
                          onDeleted: () => controller.filterByType(null),
                          deleteIcon: const Icon(Icons.close, size: 18),
                        ),
                      if (controller.selectedStatus != null)
                        Chip(
                          label: Text(controller.selectedStatus!.displayName),
                          onDeleted: () => controller.filterByStatus(null),
                          deleteIcon: const Icon(Icons.close, size: 18),
                        ),
                      if (controller.searchQuery.isNotEmpty)
                        Chip(
                          label: Text('Search: ${controller.searchQuery}'),
                          onDeleted: () {
                            _searchController.clear();
                            controller.searchBatches('');
                          },
                          deleteIcon: const Icon(Icons.close, size: 18),
                        ),
                    ],
                  ),
                ),

              const SizedBox(height: 8),

              // Statistics Cards
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        'Total Batches',
                        stats['totalBatches'].toString(),
                        Icons.batch_prediction,
                        Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        'Completed',
                        stats['completedBatches'].toString(),
                        Icons.check_circle,
                        Colors.green,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        'In Progress',
                        stats['inProgressBatches'].toString(),
                        Icons.autorenew,
                        Colors.orange,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Batches List
              Expanded(
                child: controller.batches.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.factory, size: 64, color: Colors.grey[400]),
                            const SizedBox(height: 16),
                            Text(
                              'No processing batches found',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Tap + to create a new batch',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: controller.batches.length,
                        itemBuilder: (context, index) {
                          final batch = controller.batches[index];
                          return _buildBatchCard(batch);
                        },
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushNamed(context, AppRouter.addProcessingBatch);
        },
        icon: const Icon(Icons.add),
        label: const Text('New Batch'),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBatchCard(ProcessingBatchModel batch) {
    final dateFormat = DateFormat('dd MMM yyyy, hh:mm a');
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(
            context,
            AppRouter.processingBatchDetail,
            arguments: batch.id,
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getProcessingTypeIcon(batch.processingType),
                      color: Colors.blue,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          batch.batchNumber,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          batch.processingType.displayName,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getStatusColor(batch.status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      batch.status.displayName,
                      style: TextStyle(
                        color: _getStatusColor(batch.status),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),

              const Divider(height: 24),

              // Batch Details
              Row(
                children: [
                  Expanded(
                    child: _buildDetailItem(
                      Icons.water_drop,
                      'Raw Milk',
                      '${batch.rawMilkQuantity.toStringAsFixed(1)} L',
                    ),
                  ),
                  Expanded(
                    child: _buildDetailItem(
                      Icons.production_quantity_limits,
                      'Outputs',
                      '${batch.outputs.length} products',
                    ),
                  ),
                  if (batch.yieldPercentage != null)
                    Expanded(
                      child: _buildDetailItem(
                        Icons.trending_up,
                        'Yield',
                        '${batch.yieldPercentage!.toStringAsFixed(1)}%',
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 12),

              // Operator and Time
              Row(
                children: [
                  if (batch.operatorName != null) ...[
                    Icon(Icons.person, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      batch.operatorName!,
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                    ),
                    const SizedBox(width: 16),
                  ],
                  Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      dateFormat.format(batch.startTime),
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                    ),
                  ),
                ],
              ),

              // Quality Status
              if (batch.qualityChecks.isNotEmpty) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.verified,
                      size: 16,
                      color: batch.qualityChecks.every((q) => q.isPassed)
                          ? Colors.green
                          : Colors.orange,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${batch.qualityChecks.where((q) => q.isPassed).length}/${batch.qualityChecks.length} checks passed',
                      style: TextStyle(
                        fontSize: 13,
                        color: batch.qualityChecks.every((q) => q.isPassed)
                            ? Colors.green
                            : Colors.orange,
                      ),
                    ),
                  ],
                ),
              ],

              // Production Cost
              if (batch.productionCost != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.currency_rupee, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      'Cost: ₹${batch.productionCost!.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
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

  Widget _buildDetailItem(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[500],
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
