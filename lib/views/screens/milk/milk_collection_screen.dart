import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../controllers/milk_controller.dart';
import '../../../controllers/farmer_controller.dart';
import '../../../config/theme/app_theme.dart';
import '../../../config/routes/app_router.dart';
import '../../../models/milk_collection_model.dart';
import '../../../utils/formatters.dart';

class MilkCollectionScreen extends StatefulWidget {
  const MilkCollectionScreen({super.key});

  @override
  State<MilkCollectionScreen> createState() => _MilkCollectionScreenState();
}

class _MilkCollectionScreenState extends State<MilkCollectionScreen> {
  DateTime _selectedDate = DateTime.now();
  Shift? _selectedShift;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final milkController = Provider.of<MilkController>(context);
    final farmerController = Provider.of<FarmerController>(context);
    final isMobile = AppTheme.isMobile(context);

    // Get collections for selected date
    List<MilkCollectionModel> collections = milkController.getCollectionsByDate(_selectedDate);
    
    // Filter by shift if selected
    if (_selectedShift != null) {
      collections = collections.where((c) => c.shift == _selectedShift).toList();
    }

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      collections = collections.where((collection) {
        final farmer = farmerController.getFarmerById(collection.farmerId);
        return farmer?.name.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false;
      }).toList();
    }

    // Calculate totals
    final totalQuantity = collections.fold<double>(0.0, (sum, c) => sum + c.quantity);
    final totalAmount = collections.fold<double>(0.0, (sum, c) => sum + c.totalAmount);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Milk Collection'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
          tooltip: 'Back',
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.pushNamed(context, AppRouter.addMilkCollection);
            },
            tooltip: 'Add Collection',
          ),
        ],
      ),
      body: Column(
        children: [
          // Date and Shift Filter
          Container(
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).cardColor,
            child: Column(
              children: [
                Row(
                  children: [
                    // Selected Date
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _selectDate(context),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppTheme.primaryColor),
                            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.calendar_today, size: 18, color: AppTheme.primaryColor),
                              const SizedBox(width: 8),
                              Text(
                                AppFormatters.date(_selectedDate),
                                style: const TextStyle(fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Today Button
                    if (!_isToday())
                      ElevatedButton.icon(
                        onPressed: () {
                          setState(() => _selectedDate = DateTime.now());
                        },
                        icon: const Icon(Icons.today, size: 18),
                        label: const Text('Today'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                // Shift Filter
                Row(
                  children: [
                    Expanded(
                      child: _buildShiftChip('All', null, collections.length),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildShiftChip(
                        'Morning',
                        Shift.morning,
                        collections.where((c) => c.shift == Shift.morning).length,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildShiftChip(
                        'Evening',
                        Shift.evening,
                        collections.where((c) => c.shift == Shift.evening).length,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Enhanced Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: 'Search by farmer name, ID, or village...',
                hintStyle: TextStyle(
                  fontSize: 13.0,
                  color: Colors.grey.shade500,
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: AppTheme.primaryColor,
                  size: 22,
                ),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 20),
                        tooltip: 'Clear search',
                        onPressed: () {
                          setState(() {
                            _searchController.clear();
                            _searchQuery = '';
                          });
                        },
                      )
                    : Icon(
                        Icons.filter_alt,
                        color: Colors.grey.shade400,
                        size: 20,
                      ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppTheme.primaryColor, width: 2),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
              style: TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.w500,
              ),
              onChanged: (value) {
                setState(() => _searchQuery = value);
              },
            ),
          ),

          // Search result indicator
          if (_searchQuery.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Icon(
                    collections.isEmpty ? Icons.search_off : Icons.check_circle,
                    size: 16,
                    color: collections.isEmpty ? AppTheme.errorColor : AppTheme.successColor,
                  ),
                  SizedBox(width: 6),
                  Text(
                    '${collections.length} collection${collections.length != 1 ? 's' : ''} found',
                    style: TextStyle(
                      fontSize: 12.5,
                      color: collections.isEmpty ? AppTheme.errorColor : Colors.grey.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

          if (_searchQuery.isNotEmpty) SizedBox(height: 12),

          // Summary Cards
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: _buildSummaryCard(
                    'Collections',
                    collections.length.toString(),
                    Icons.receipt,
                    AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildSummaryCard(
                    'Quantity',
                    '${totalQuantity.toStringAsFixed(1)} L',
                    Icons.water_drop,
                    AppTheme.accentColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildSummaryCard(
                    'Amount',
                    AppFormatters.currency(totalAmount),
                    Icons.currency_rupee,
                    AppTheme.successColor,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Collections List
          Expanded(
            child: collections.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.water_drop_outlined,
                          size: 80,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _searchQuery.isEmpty
                              ? 'No collections for ${AppFormatters.date(_selectedDate)}'
                              : 'No collections found',
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _searchQuery.isEmpty
                              ? 'Add milk collection to get started'
                              : 'Try a different search term',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: collections.length,
                    itemBuilder: (context, index) {
                      final collection = collections[index];
                      final farmer = farmerController.getFarmerById(collection.farmerId);
                      return _buildCollectionCard(context, collection, farmer?.name ?? 'Unknown', isMobile);
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushNamed(context, AppRouter.addMilkCollection);
        },
        icon: const Icon(Icons.add),
        label: Text(isMobile ? 'Add' : 'Add Collection'),
      ),
    );
  }

  Widget _buildShiftChip(String label, Shift? shift, int count) {
    final isSelected = _selectedShift == shift;
    return GestureDetector(
      onTap: () {
        setState(() => _selectedShift = shift);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          border: Border.all(
            color: isSelected ? AppTheme.primaryColor : Colors.grey.shade300,
          ),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey.shade700,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              count.toString(),
              style: TextStyle(
                color: isSelected ? Colors.white : AppTheme.primaryColor,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade700,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCollectionCard(BuildContext context, MilkCollectionModel collection, String farmerName, bool isMobile) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 1,
      child: ListTile(
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        leading: CircleAvatar(
          radius: 20,
          backgroundColor: collection.shift == Shift.morning
              ? Colors.orange.shade100
              : Colors.indigo.shade100,
          child: Icon(
            collection.shift == Shift.morning ? Icons.wb_sunny : Icons.nightlight,
            color: collection.shift == Shift.morning ? Colors.orange : Colors.indigo,
            size: 20,
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                farmerName,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppTheme.successColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                AppFormatters.currency(collection.totalAmount),
                style: TextStyle(
                  fontSize: 10,
                  color: AppTheme.successColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.access_time, size: 11, color: Colors.grey.shade600),
                const SizedBox(width: 3),
                Text(
                  AppFormatters.time(collection.date),
                  style: TextStyle(fontSize: 10, color: Colors.grey.shade700),
                ),
                const SizedBox(width: 12),
                Icon(Icons.water_drop, size: 11, color: Colors.grey.shade600),
                const SizedBox(width: 3),
                Text(
                  '${collection.quantity.toStringAsFixed(1)} L',
                  style: TextStyle(fontSize: 10, color: Colors.grey.shade700),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  child: _buildInfoChip(
                    'FAT',
                    AppFormatters.fatSnf(collection.fat),
                    AppTheme.accentColor,
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: _buildInfoChip(
                    'SNF',
                    AppFormatters.fatSnf(collection.snf),
                    AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: _buildInfoChip(
                    'Rate',
                    AppFormatters.currency(collection.ratePerLiter, showSymbol: false),
                    AppTheme.successColor,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert),
          onSelected: (value) async {
            switch (value) {
              case 'edit':
                Navigator.pushNamed(
                  context,
                  AppRouter.addMilkCollection,
                  arguments: collection,
                );
                break;
              case 'delete':
                _showDeleteDialog(context, collection, farmerName);
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit, size: 20),
                  SizedBox(width: 12),
                  Text('Edit'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, size: 20, color: Colors.red),
                  SizedBox(width: 12),
                  Text('Delete', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 8,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 1),
          Text(
            value,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
    }
  }

  bool _isToday() {
    final now = DateTime.now();
    return _selectedDate.year == now.year &&
        _selectedDate.month == now.month &&
        _selectedDate.day == now.day;
  }

  void _showDeleteDialog(BuildContext context, MilkCollectionModel collection, String farmerName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Collection'),
        content: Text(
          'Are you sure you want to delete this collection for $farmerName?\n\nThis action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement delete when method is available in controller
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Delete feature coming soon!')),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
