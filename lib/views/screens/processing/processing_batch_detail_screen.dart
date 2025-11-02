import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../controllers/processing_controller.dart';
import '../../../models/processing_batch_model.dart';
import '../../../config/routes/app_router.dart';

class ProcessingBatchDetailScreen extends StatelessWidget {
  final String batchId;

  const ProcessingBatchDetailScreen({Key? key, required this.batchId}) : super(key: key);

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

  void _showStatusChangeDialog(BuildContext context, ProcessingBatchModel batch) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Change Batch Status'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.play_arrow, color: Colors.orange),
              title: const Text('Start Batch'),
              subtitle: const Text('Mark as in progress'),
              enabled: batch.status == BatchStatus.planned,
              onTap: () async {
                await context.read<ProcessingController>().startBatch(batchId);
                Navigator.pop(dialogContext);
              },
            ),
            ListTile(
              leading: const Icon(Icons.science, color: Colors.purple),
              title: const Text('Quality Check'),
              subtitle: const Text('Send for quality inspection'),
              enabled: batch.status == BatchStatus.inProgress,
              onTap: () async {
                await context.read<ProcessingController>().sendToQualityCheck(batchId);
                Navigator.pop(dialogContext);
              },
            ),
            ListTile(
              leading: const Icon(Icons.check_circle, color: Colors.green),
              title: const Text('Complete'),
              subtitle: const Text('Mark as completed'),
              enabled: batch.status == BatchStatus.qualityCheck || batch.status == BatchStatus.inProgress,
              onTap: () async {
                await context.read<ProcessingController>().completeBatch(batchId);
                Navigator.pop(dialogContext);
              },
            ),
            ListTile(
              leading: const Icon(Icons.cancel, color: Colors.red),
              title: const Text('Reject'),
              subtitle: const Text('Mark as rejected'),
              onTap: () {
                Navigator.pop(dialogContext);
                _showRejectDialog(context, batch);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showRejectDialog(BuildContext context, ProcessingBatchModel batch) {
    final reasonController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Reject Batch'),
        content: TextField(
          controller: reasonController,
          decoration: const InputDecoration(
            labelText: 'Rejection Reason',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (reasonController.text.isNotEmpty) {
                await context.read<ProcessingController>().rejectBatch(
                  batchId,
                  reasonController.text.trim(),
                );
                Navigator.pop(dialogContext);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Reject'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Batch'),
        content: const Text('Are you sure you want to delete this batch? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await context.read<ProcessingController>().deleteBatch(batchId);
              Navigator.pop(dialogContext);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Batch Details'),
        actions: [
          PopupMenuButton(
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit),
                    SizedBox(width: 8),
                    Text('Edit'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'status',
                child: Row(
                  children: [
                    Icon(Icons.update),
                    SizedBox(width: 8),
                    Text('Change Status'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Delete', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
            onSelected: (value) {
              final batch = context.read<ProcessingController>().getBatchById(batchId);
              if (batch == null) return;

              switch (value) {
                case 'edit':
                  Navigator.pushNamed(
                    context,
                    AppRouter.addProcessingBatch,
                    arguments: batchId,
                  );
                  break;
                case 'status':
                  _showStatusChangeDialog(context, batch);
                  break;
                case 'delete':
                  _showDeleteConfirmation(context);
                  break;
              }
            },
          ),
        ],
      ),
      body: Consumer<ProcessingController>(
        builder: (context, controller, child) {
          final batch = controller.getBatchById(batchId);

          if (batch == null) {
            return const Center(
              child: Text('Batch not found'),
            );
          }

          final dateFormat = DateFormat('dd MMM yyyy, hh:mm a');

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Header Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _getProcessingTypeIcon(batch.processingType),
                          size: 48,
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        batch.batchNumber,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        batch.processingType.displayName,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: _getStatusColor(batch.status).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          batch.status.displayName,
                          style: TextStyle(
                            color: _getStatusColor(batch.status),
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Timeline Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Timeline',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildInfoRow(Icons.access_time, 'Started', dateFormat.format(batch.startTime)),
                      if (batch.endTime != null)
                        _buildInfoRow(Icons.check, 'Completed', dateFormat.format(batch.endTime!)),
                      if (batch.duration != null)
                        _buildInfoRow(Icons.timer, 'Duration', '${batch.duration} minutes'),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Raw Materials Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Raw Materials',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildInfoRow(Icons.water_drop, 'Raw Milk', '${batch.rawMilkQuantity.toStringAsFixed(1)} L'),
                      if (batch.rawMilkSource != null)
                        _buildInfoRow(Icons.source, 'Source', batch.rawMilkSource!),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Processing Details Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Processing Details',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (batch.temperature != null)
                        _buildInfoRow(Icons.thermostat, 'Temperature', '${batch.temperature}°C'),
                      if (batch.equipmentUsed != null)
                        _buildInfoRow(Icons.precision_manufacturing, 'Equipment', batch.equipmentUsed!),
                      if (batch.operatorName != null)
                        _buildInfoRow(Icons.person, 'Operator', batch.operatorName!),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Resource Consumption Card
              if (batch.energyConsumed != null || batch.waterUsed != null)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Resource Consumption',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (batch.energyConsumed != null)
                          _buildInfoRow(Icons.bolt, 'Energy', '${batch.energyConsumed} kWh'),
                        if (batch.waterUsed != null)
                          _buildInfoRow(Icons.water, 'Water', '${batch.waterUsed} L'),
                      ],
                    ),
                  ),
                ),

              if (batch.energyConsumed != null || batch.waterUsed != null)
                const SizedBox(height: 16),

              // Additional Materials Card
              if (batch.additionalMaterials.isNotEmpty)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Additional Materials',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ...batch.additionalMaterials.map((material) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              const Icon(Icons.category, size: 20, color: Colors.grey),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text('${material.materialName}: ${material.quantity} ${material.unit}'),
                              ),
                              if (material.cost != null)
                                Text(
                                  '₹${material.cost!.toStringAsFixed(2)}',
                                  style: const TextStyle(fontWeight: FontWeight.w600),
                                ),
                            ],
                          ),
                        )),
                      ],
                    ),
                  ),
                ),

              if (batch.additionalMaterials.isNotEmpty)
                const SizedBox(height: 16),

              // Output Products Card
              if (batch.outputs.isNotEmpty)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text(
                              'Output Products',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.blue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${batch.outputs.length} products',
                                style: const TextStyle(
                                  color: Colors.blue,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ...batch.outputs.map((output) => Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        output.productName,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                    if (output.qualityScore != null)
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: output.qualityScore! >= 70
                                              ? Colors.green.withOpacity(0.1)
                                              : Colors.orange.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          '${output.qualityScore!.toInt()}%',
                                          style: TextStyle(
                                            color: output.qualityScore! >= 70 ? Colors.green : Colors.orange,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${output.quantity} ${output.unit}',
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                                if (output.remarks != null) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    output.remarks!,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[500],
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        )),
                      ],
                    ),
                  ),
                ),

              if (batch.outputs.isNotEmpty)
                const SizedBox(height: 16),

              // Quality Checks Card
              if (batch.qualityChecks.isNotEmpty)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text(
                              'Quality Checks',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: batch.qualityChecks.every((q) => q.isPassed)
                                    ? Colors.green.withOpacity(0.1)
                                    : Colors.orange.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${batch.qualityChecks.where((q) => q.isPassed).length}/${batch.qualityChecks.length} passed',
                                style: TextStyle(
                                  color: batch.qualityChecks.every((q) => q.isPassed)
                                      ? Colors.green
                                      : Colors.orange,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ...batch.qualityChecks.map((check) => Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: Icon(
                              check.isPassed ? Icons.check_circle : Icons.cancel,
                              color: check.isPassed ? Colors.green : Colors.red,
                            ),
                            title: Text(check.parameter),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Value: ${check.value}'),
                                if (check.expectedRange != null)
                                  Text('Expected: ${check.expectedRange}'),
                                Text(
                                  'Checked: ${DateFormat('dd MMM, hh:mm a').format(check.checkedAt)}',
                                  style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                                ),
                              ],
                            ),
                          ),
                        )),
                      ],
                    ),
                  ),
                ),

              if (batch.qualityChecks.isNotEmpty)
                const SizedBox(height: 16),

              // Production Metrics Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Production Metrics',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (batch.yieldPercentage != null)
                        _buildInfoRow(Icons.trending_up, 'Yield', '${batch.yieldPercentage!.toStringAsFixed(2)}%'),
                      if (batch.productionCost != null)
                        _buildInfoRow(Icons.currency_rupee, 'Production Cost', '₹${batch.productionCost!.toStringAsFixed(2)}'),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Notes Card
              if (batch.notes != null)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Notes',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(batch.notes!),
                      ],
                    ),
                  ),
                ),

              if (batch.notes != null)
                const SizedBox(height: 16),

              // Timestamps Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Timestamps',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildInfoRow(Icons.add_circle, 'Created', dateFormat.format(batch.createdAt)),
                      _buildInfoRow(Icons.update, 'Last Updated', dateFormat.format(batch.updatedAt)),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
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
                const SizedBox(height: 2),
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
      ),
    );
  }
}
