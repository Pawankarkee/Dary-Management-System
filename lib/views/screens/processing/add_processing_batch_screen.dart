import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../controllers/processing_controller.dart';
import '../../../controllers/product_controller.dart';
import '../../../controllers/staff_controller.dart';
import '../../../models/processing_batch_model.dart';

class AddProcessingBatchScreen extends StatefulWidget {
  final String? batchId;

  const AddProcessingBatchScreen({Key? key, this.batchId}) : super(key: key);

  @override
  State<AddProcessingBatchScreen> createState() => _AddProcessingBatchScreenState();
}

class _AddProcessingBatchScreenState extends State<AddProcessingBatchScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Basic Info
  late TextEditingController _batchNumberController;
  ProcessingType _selectedType = ProcessingType.pasteurization;
  BatchStatus _selectedStatus = BatchStatus.planned;
  DateTime _startTime = DateTime.now();
  DateTime? _endTime;
  
  // Raw Materials
  late TextEditingController _rawMilkController;
  late TextEditingController _rawMilkSourceController;
  
  // Processing Details
  late TextEditingController _temperatureController;
  late TextEditingController _durationController;
  late TextEditingController _equipmentController;
  String? _selectedOperatorId;
  String? _selectedOperatorName;
  
  // Resources
  late TextEditingController _energyController;
  late TextEditingController _waterController;
  
  // Additional Materials
  final List<AdditionalMaterial> _additionalMaterials = [];
  
  // Output Products
  final List<ProcessingOutput> _outputs = [];
  
  // Quality Checks
  final List<QualityCheck> _qualityChecks = [];
  
  // Other
  late TextEditingController _notesController;
  late TextEditingController _productionCostController;
  late TextEditingController _yieldController;

  bool _isEdit = false;
  ProcessingBatchModel? _existingBatch;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _loadData();
  }

  void _initializeControllers() {
    _batchNumberController = TextEditingController(
      text: ProcessingBatchModel.generateBatchNumber(),
    );
    _rawMilkController = TextEditingController();
    _rawMilkSourceController = TextEditingController();
    _temperatureController = TextEditingController();
    _durationController = TextEditingController();
    _equipmentController = TextEditingController();
    _energyController = TextEditingController();
    _waterController = TextEditingController();
    _notesController = TextEditingController();
    _productionCostController = TextEditingController();
    _yieldController = TextEditingController();
  }

  Future<void> _loadData() async {
    if (widget.batchId != null) {
      final controller = context.read<ProcessingController>();
      _existingBatch = controller.getBatchById(widget.batchId!);
      
      if (_existingBatch != null) {
        setState(() {
          _isEdit = true;
          _batchNumberController.text = _existingBatch!.batchNumber;
          _selectedType = _existingBatch!.processingType;
          _selectedStatus = _existingBatch!.status;
          _startTime = _existingBatch!.startTime;
          _endTime = _existingBatch!.endTime;
          _rawMilkController.text = _existingBatch!.rawMilkQuantity.toString();
          _rawMilkSourceController.text = _existingBatch!.rawMilkSource ?? '';
          _temperatureController.text = _existingBatch!.temperature?.toString() ?? '';
          _durationController.text = _existingBatch!.duration?.toString() ?? '';
          _equipmentController.text = _existingBatch!.equipmentUsed ?? '';
          _selectedOperatorId = _existingBatch!.operatorId;
          _selectedOperatorName = _existingBatch!.operatorName;
          _energyController.text = _existingBatch!.energyConsumed?.toString() ?? '';
          _waterController.text = _existingBatch!.waterUsed?.toString() ?? '';
          _notesController.text = _existingBatch!.notes ?? '';
          _productionCostController.text = _existingBatch!.productionCost?.toString() ?? '';
          _yieldController.text = _existingBatch!.yieldPercentage?.toString() ?? '';
          _additionalMaterials.addAll(_existingBatch!.additionalMaterials);
          _outputs.addAll(_existingBatch!.outputs);
          _qualityChecks.addAll(_existingBatch!.qualityChecks);
        });
      }
    }
    
    // Load staff for operator selection
    await context.read<StaffController>().loadStaff();
  }

  @override
  void dispose() {
    _batchNumberController.dispose();
    _rawMilkController.dispose();
    _rawMilkSourceController.dispose();
    _temperatureController.dispose();
    _durationController.dispose();
    _equipmentController.dispose();
    _energyController.dispose();
    _waterController.dispose();
    _notesController.dispose();
    _productionCostController.dispose();
    _yieldController.dispose();
    super.dispose();
  }

  Future<void> _saveBatch() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      final controller = context.read<ProcessingController>();
      
      final batch = ProcessingBatchModel(
        id: _isEdit ? _existingBatch!.id : ProcessingBatchModel.generateId(),
        batchNumber: _batchNumberController.text.trim(),
        processingType: _selectedType,
        status: _selectedStatus,
        startTime: _startTime,
        endTime: _endTime,
        rawMilkQuantity: double.parse(_rawMilkController.text),
        rawMilkSource: _rawMilkSourceController.text.trim().isEmpty
            ? null
            : _rawMilkSourceController.text.trim(),
        outputs: _outputs,
        qualityChecks: _qualityChecks,
        temperature: _temperatureController.text.isEmpty
            ? null
            : double.parse(_temperatureController.text),
        duration: _durationController.text.isEmpty
            ? null
            : int.parse(_durationController.text),
        operatorId: _selectedOperatorId,
        operatorName: _selectedOperatorName,
        energyConsumed: _energyController.text.isEmpty
            ? null
            : double.parse(_energyController.text),
        waterUsed: _waterController.text.isEmpty
            ? null
            : double.parse(_waterController.text),
        additionalMaterials: _additionalMaterials,
        equipmentUsed: _equipmentController.text.trim().isEmpty
            ? null
            : _equipmentController.text.trim(),
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
        productionCost: _productionCostController.text.isEmpty
            ? null
            : double.parse(_productionCostController.text),
        yieldPercentage: _yieldController.text.isEmpty
            ? null
            : double.parse(_yieldController.text),
        createdAt: _isEdit ? _existingBatch!.createdAt : DateTime.now(),
        updatedAt: DateTime.now(),
      );

      if (_isEdit) {
        await controller.updateBatch(batch);
      } else {
        await controller.addBatch(batch);
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEdit
                ? 'Batch updated successfully'
                : 'Batch created successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving batch: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _addOutput() {
    showDialog(
      context: context,
      builder: (context) {
        final productController = TextEditingController();
        final quantityController = TextEditingController();
        final unitController = TextEditingController(text: 'kg');
        final qualityController = TextEditingController();
        final remarksController = TextEditingController();

        return AlertDialog(
          title: const Text('Add Output Product'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: productController,
                  decoration: const InputDecoration(
                    labelText: 'Product Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: quantityController,
                  decoration: const InputDecoration(
                    labelText: 'Quantity',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: unitController,
                  decoration: const InputDecoration(
                    labelText: 'Unit (kg, L, pieces)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: qualityController,
                  decoration: const InputDecoration(
                    labelText: 'Quality Score (0-100)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: remarksController,
                  decoration: const InputDecoration(
                    labelText: 'Remarks (Optional)',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (productController.text.isNotEmpty &&
                    quantityController.text.isNotEmpty) {
                  setState(() {
                    _outputs.add(ProcessingOutput(
                      productId: 'PROD-${DateTime.now().millisecondsSinceEpoch}',
                      productName: productController.text.trim(),
                      quantity: double.parse(quantityController.text),
                      unit: unitController.text.trim(),
                      qualityScore: qualityController.text.isEmpty
                          ? null
                          : double.parse(qualityController.text),
                      remarks: remarksController.text.trim().isEmpty
                          ? null
                          : remarksController.text.trim(),
                    ));
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _addQualityCheck() {
    showDialog(
      context: context,
      builder: (context) {
        final parameterController = TextEditingController();
        final valueController = TextEditingController();
        final rangeController = TextEditingController();
        bool isPassed = true;

        return StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            title: const Text('Add Quality Check'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: parameterController,
                    decoration: const InputDecoration(
                      labelText: 'Parameter (e.g., pH, Fat %)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: valueController,
                    decoration: const InputDecoration(
                      labelText: 'Value',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: rangeController,
                    decoration: const InputDecoration(
                      labelText: 'Expected Range (Optional)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SwitchListTile(
                    title: const Text('Passed'),
                    value: isPassed,
                    onChanged: (value) => setState(() => isPassed = value),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (parameterController.text.isNotEmpty &&
                      valueController.text.isNotEmpty) {
                    this.setState(() {
                      _qualityChecks.add(QualityCheck(
                        parameter: parameterController.text.trim(),
                        value: valueController.text.trim(),
                        expectedRange: rangeController.text.trim().isEmpty
                            ? null
                            : rangeController.text.trim(),
                        isPassed: isPassed,
                        checkedAt: DateTime.now(),
                        checkedBy: _selectedOperatorName,
                      ));
                    });
                    Navigator.pop(context);
                  }
                },
                child: const Text('Add'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _addMaterial() {
    showDialog(
      context: context,
      builder: (context) {
        final nameController = TextEditingController();
        final quantityController = TextEditingController();
        final unitController = TextEditingController();
        final costController = TextEditingController();

        return AlertDialog(
          title: const Text('Add Additional Material'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Material Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: quantityController,
                  decoration: const InputDecoration(
                    labelText: 'Quantity',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: unitController,
                  decoration: const InputDecoration(
                    labelText: 'Unit',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: costController,
                  decoration: const InputDecoration(
                    labelText: 'Cost (Optional)',
                    prefixText: '₹',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isNotEmpty &&
                    quantityController.text.isNotEmpty &&
                    unitController.text.isNotEmpty) {
                  setState(() {
                    _additionalMaterials.add(AdditionalMaterial(
                      materialName: nameController.text.trim(),
                      quantity: double.parse(quantityController.text),
                      unit: unitController.text.trim(),
                      cost: costController.text.isEmpty
                          ? null
                          : double.parse(costController.text),
                    ));
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Edit Batch' : 'New Processing Batch'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveBatch,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Basic Information
            _buildSectionHeader('Basic Information'),
            TextFormField(
              controller: _batchNumberController,
              decoration: const InputDecoration(
                labelText: 'Batch Number',
                border: OutlineInputBorder(),
              ),
              validator: (value) =>
                  value?.isEmpty ?? true ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<ProcessingType>(
              value: _selectedType,
              decoration: const InputDecoration(
                labelText: 'Processing Type',
                border: OutlineInputBorder(),
              ),
              items: ProcessingType.values.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type.displayName),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) setState(() => _selectedType = value);
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<BatchStatus>(
              value: _selectedStatus,
              decoration: const InputDecoration(
                labelText: 'Status',
                border: OutlineInputBorder(),
              ),
              items: BatchStatus.values.map((status) {
                return DropdownMenuItem(
                  value: status,
                  child: Text(status.displayName),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) setState(() => _selectedStatus = value);
              },
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Start Time'),
              subtitle: Text(DateFormat('dd MMM yyyy, hh:mm a').format(_startTime)),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _startTime,
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (date != null) {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.fromDateTime(_startTime),
                  );
                  if (time != null) {
                    setState(() {
                      _startTime = DateTime(
                        date.year,
                        date.month,
                        date.day,
                        time.hour,
                        time.minute,
                      );
                    });
                  }
                }
              },
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: Colors.grey.shade400),
              ),
            ),

            const SizedBox(height: 24),

            // Raw Materials
            _buildSectionHeader('Raw Materials'),
            TextFormField(
              controller: _rawMilkController,
              decoration: const InputDecoration(
                labelText: 'Raw Milk Quantity (Liters)',
                border: OutlineInputBorder(),
                suffixText: 'L',
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value?.isEmpty ?? true) return 'Required';
                if (double.tryParse(value!) == null) return 'Invalid number';
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _rawMilkSourceController,
              decoration: const InputDecoration(
                labelText: 'Source (Optional)',
                border: OutlineInputBorder(),
                hintText: 'Supplier name or collection reference',
              ),
            ),

            const SizedBox(height: 24),

            // Processing Details
            _buildSectionHeader('Processing Details'),
            TextFormField(
              controller: _temperatureController,
              decoration: const InputDecoration(
                labelText: 'Temperature (°C)',
                border: OutlineInputBorder(),
                suffixText: '°C',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _durationController,
              decoration: const InputDecoration(
                labelText: 'Duration (Minutes)',
                border: OutlineInputBorder(),
                suffixText: 'min',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _equipmentController,
              decoration: const InputDecoration(
                labelText: 'Equipment Used',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Consumer<StaffController>(
              builder: (context, staffController, _) {
                final activeStaff = staffController.staff.where((s) => s.isActive).toList();
                return DropdownButtonFormField<String>(
                  value: _selectedOperatorId,
                  decoration: const InputDecoration(
                    labelText: 'Operator',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    const DropdownMenuItem(
                      value: null,
                      child: Text('Select Operator'),
                    ),
                    ...activeStaff.map((staff) {
                      return DropdownMenuItem(
                        value: staff.id,
                        child: Text('${staff.name} (${staff.role.name})'),
                      );
                    }),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      final staff = activeStaff.firstWhere((s) => s.id == value);
                      setState(() {
                        _selectedOperatorId = value;
                        _selectedOperatorName = staff.name;
                      });
                    }
                  },
                );
              },
            ),

            const SizedBox(height: 24),

            // Resources
            _buildSectionHeader('Resource Consumption'),
            TextFormField(
              controller: _energyController,
              decoration: const InputDecoration(
                labelText: 'Energy Consumed (Units)',
                border: OutlineInputBorder(),
                suffixText: 'kWh',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _waterController,
              decoration: const InputDecoration(
                labelText: 'Water Used (Liters)',
                border: OutlineInputBorder(),
                suffixText: 'L',
              ),
              keyboardType: TextInputType.number,
            ),

            const SizedBox(height: 24),

            // Additional Materials
            _buildSectionHeader('Additional Materials'),
            if (_additionalMaterials.isEmpty)
              const Text('No materials added', style: TextStyle(color: Colors.grey))
            else
              ..._additionalMaterials.asMap().entries.map((entry) {
                final material = entry.value;
                return Card(
                  child: ListTile(
                    title: Text(material.materialName),
                    subtitle: Text('${material.quantity} ${material.unit}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (material.cost != null)
                          Text('₹${material.cost!.toStringAsFixed(2)}'),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            setState(() => _additionalMaterials.removeAt(entry.key));
                          },
                        ),
                      ],
                    ),
                  ),
                );
              }),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: _addMaterial,
              icon: const Icon(Icons.add),
              label: const Text('Add Material'),
            ),

            const SizedBox(height: 24),

            // Output Products
            _buildSectionHeader('Output Products'),
            if (_outputs.isEmpty)
              const Text('No outputs added', style: TextStyle(color: Colors.grey))
            else
              ..._outputs.asMap().entries.map((entry) {
                final output = entry.value;
                return Card(
                  child: ListTile(
                    title: Text(output.productName),
                    subtitle: Text('${output.quantity} ${output.unit}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (output.qualityScore != null)
                          Chip(
                            label: Text('${output.qualityScore!.toInt()}%'),
                            backgroundColor: output.qualityScore! >= 70
                                ? Colors.green.shade100
                                : Colors.orange.shade100,
                          ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            setState(() => _outputs.removeAt(entry.key));
                          },
                        ),
                      ],
                    ),
                  ),
                );
              }),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: _addOutput,
              icon: const Icon(Icons.add),
              label: const Text('Add Output Product'),
            ),

            const SizedBox(height: 24),

            // Quality Checks
            _buildSectionHeader('Quality Checks'),
            if (_qualityChecks.isEmpty)
              const Text('No quality checks added', style: TextStyle(color: Colors.grey))
            else
              ..._qualityChecks.asMap().entries.map((entry) {
                final check = entry.value;
                return Card(
                  child: ListTile(
                    leading: Icon(
                      check.isPassed ? Icons.check_circle : Icons.cancel,
                      color: check.isPassed ? Colors.green : Colors.red,
                    ),
                    title: Text(check.parameter),
                    subtitle: Text('Value: ${check.value}${check.expectedRange != null ? " (Expected: ${check.expectedRange})" : ""}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        setState(() => _qualityChecks.removeAt(entry.key));
                      },
                    ),
                  ),
                );
              }),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: _addQualityCheck,
              icon: const Icon(Icons.add),
              label: const Text('Add Quality Check'),
            ),

            const SizedBox(height: 24),

            // Additional Information
            _buildSectionHeader('Additional Information'),
            TextFormField(
              controller: _productionCostController,
              decoration: const InputDecoration(
                labelText: 'Production Cost',
                border: OutlineInputBorder(),
                prefixText: '₹',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _yieldController,
              decoration: const InputDecoration(
                labelText: 'Yield Percentage',
                border: OutlineInputBorder(),
                suffixText: '%',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notes',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),

            const SizedBox(height: 32),

            ElevatedButton(
              onPressed: _saveBatch,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
              ),
              child: Text(_isEdit ? 'Update Batch' : 'Create Batch'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
