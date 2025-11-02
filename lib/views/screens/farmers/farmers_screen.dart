import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../../../controllers/farmer_controller.dart';
import '../../../config/theme/app_theme.dart';
import '../../../config/routes/app_router.dart';
import '../../../models/farmer_model.dart';
import '../../../utils/formatters.dart';

class FarmersScreen extends StatefulWidget {
  const FarmersScreen({super.key});

  @override
  State<FarmersScreen> createState() => _FarmersScreenState();
}

class _FarmersScreenState extends State<FarmersScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  Future<void> _navigateBack(BuildContext context) async {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      Navigator.of(context).pushReplacementNamed(AppRouter.home);
    }
  }

  Future<bool> _handleWillPop() async {
    if (Navigator.of(context).canPop()) {
      return true;
    }
    Navigator.of(context).pushReplacementNamed(AppRouter.home);
    return false;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final farmerController = Provider.of<FarmerController>(context);
    final isMobile = AppTheme.isMobile(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final mutedTextColor = theme.textTheme.bodySmall?.color?.withOpacity(0.6) ??
        colorScheme.onSurface.withOpacity(0.6);
    final inputFillColor = theme.inputDecorationTheme.fillColor ??
        colorScheme.surfaceVariant
            .withOpacity(theme.brightness == Brightness.dark ? 0.35 : 0.08);
    final outlineColor = colorScheme.outline
        .withOpacity(theme.brightness == Brightness.dark ? 0.45 : 0.25);
    
    List<FarmerModel> farmers = farmerController.getAllFarmers();
    
    // Enhanced filter: search by name, ID, or phone
    if (_searchQuery.isNotEmpty) {
      final queryLower = _searchQuery.toLowerCase();
      farmers = farmers.where((farmer) {
        return farmer.name.toLowerCase().contains(queryLower) ||
               farmer.id.toLowerCase().contains(queryLower) ||
               (farmer.village ?? '').toLowerCase().contains(queryLower) ||
               (farmer.phone?.contains(_searchQuery) ?? false);
      }).toList();
    }

    return WillPopScope(
      onWillPop: _handleWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Farmers'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => _navigateBack(context),
            tooltip: 'Back',
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                Navigator.pushNamed(context, AppRouter.addFarmer);
              },
              tooltip: 'Add Farmer',
            ),
          ],
        ),
        body: Column(
        children: [
          // Enhanced Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: 'Search farmers by name, ID, or phone...',
                hintStyle: theme.textTheme.bodySmall?.copyWith(
                  fontSize: 13.0,
                  color: mutedTextColor,
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: colorScheme.primary,
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
                        Icons.filter_list,
                          color: mutedTextColor,
                        size: 20,
                      ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                    borderSide: BorderSide(color: outlineColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  borderSide: BorderSide(color: AppTheme.primaryColor, width: 2),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                    borderSide: BorderSide(color: outlineColor),
                ),
                filled: true,
                  fillColor: inputFillColor,
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
              style: TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.w500,
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),

          // Search result count
          if (_searchQuery.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Icon(
                    farmers.isEmpty ? Icons.search_off : Icons.check_circle,
                    size: 16,
                    color: farmers.isEmpty ? AppTheme.errorColor : AppTheme.successColor,
                  ),
                  SizedBox(width: 6),
                  Text(
                    '${farmers.length} farmer${farmers.length != 1 ? 's' : ''} found',
                    style: TextStyle(
                      fontSize: 12.5,
                      color: farmers.isEmpty ? AppTheme.errorColor : Colors.grey.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

          if (_searchQuery.isNotEmpty) SizedBox(height: 12),

          // Stats Summary
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Total Farmers',
                    farmers.length.toString(),
                    Icons.people,
                    AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Active',
                    farmers.where((f) => f.isActive).length.toString(),
                    Icons.check_circle,
                    AppTheme.successColor,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Farmers List
          Expanded(
            child: farmers.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.people_outline,
                          size: 80,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _searchQuery.isEmpty
                              ? 'No farmers yet'
                              : 'No farmers found',
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _searchQuery.isEmpty
                              ? 'Add your first farmer to get started'
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
                    itemCount: farmers.length,
                    itemBuilder: (context, index) {
                      final farmer = farmers[index];
                      return _buildFarmerCard(context, farmer, isMobile);
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushNamed(context, AppRouter.addFarmer);
        },
        icon: const Icon(Icons.add),
        label: Text(isMobile ? 'Add' : 'Add Farmer'),
      ),
    ),
  );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    final theme = Theme.of(context);
    final backgroundOpacity = theme.brightness == Brightness.dark ? 0.22 : 0.12;
    final borderOpacity = theme.brightness == Brightness.dark ? 0.35 : 0.18;
    final labelColor = theme.textTheme.bodySmall?.color?.withOpacity(0.7) ??
        theme.colorScheme.onSurface.withOpacity(0.7);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(backgroundOpacity),
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(color: color.withOpacity(borderOpacity)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: labelColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFarmerCard(BuildContext context, FarmerModel farmer, bool isMobile) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final mutedColor = theme.textTheme.bodySmall?.color?.withOpacity(0.6) ??
        (colorScheme.onSurface.withOpacity(0.6));
    final badgeBackground = farmer.isActive
        ? AppTheme.successColor.withOpacity(theme.brightness == Brightness.dark ? 0.25 : 0.1)
        : colorScheme.surfaceVariant.withOpacity(theme.brightness == Brightness.dark ? 0.35 : 0.2);
    final avatarBackground = farmer.isActive
        ? AppTheme.primaryColor.withOpacity(theme.brightness == Brightness.dark ? 0.25 : 0.12)
        : colorScheme.surfaceVariant.withOpacity(theme.brightness == Brightness.dark ? 0.5 : 0.3);
    final locationDisplay = (farmer.address?.trim().isNotEmpty == true)
        ? farmer.address!.trim()
        : (farmer.village?.trim().isNotEmpty == true ? farmer.village!.trim() : 'N/A');

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 1,
      child: ListTile(
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        leading: CircleAvatar(
          radius: 20,
          backgroundColor: avatarBackground,
          backgroundImage: (farmer.photoPath != null && farmer.photoPath!.isNotEmpty)
              ? (farmer.photoPath!.startsWith('http')
                  ? NetworkImage(farmer.photoPath!)
                  : FileImage(File(farmer.photoPath!)) as ImageProvider)
              : null,
          child: farmer.photoPath == null || farmer.photoPath!.isEmpty
              ? Icon(
                  Icons.person,
                  color: farmer.isActive ? AppTheme.primaryColor : mutedColor,
                  size: 22,
                )
              : null,
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                farmer.name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: badgeBackground,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                farmer.isActive ? 'Active' : 'Inactive',
                style: TextStyle(
                  fontSize: 9,
                  color: farmer.isActive ? AppTheme.successColor : mutedColor,
                  fontWeight: FontWeight.w600,
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
                Icon(Icons.badge, size: 11, color: mutedColor),
                const SizedBox(width: 3),
                Flexible(
                  child: Text(
                    farmer.id,
                    style: TextStyle(fontSize: 10, color: mutedColor),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 12),
                Icon(Icons.phone, size: 11, color: mutedColor),
                const SizedBox(width: 3),
                Flexible(
                  child: Text(
                    farmer.phone != null ? AppFormatters.phone(farmer.phone!) : 'N/A',
                    style: TextStyle(fontSize: 10, color: mutedColor),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 3),
            Row(
              children: [
                Icon(Icons.location_on, size: 11, color: mutedColor),
                const SizedBox(width: 3),
                Expanded(
                  child: Text(
                    locationDisplay,
                    style: TextStyle(fontSize: 10, color: mutedColor),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  child: _buildInfoChip(
                    'Balance',
                    AppFormatters.currency(farmer.runningBalance),
                    farmer.runningBalance >= 0 ? AppTheme.successColor : AppTheme.errorColor,
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: _buildInfoChip(
                    'Type',
                    farmer.milkType.toString().split('.').last.toUpperCase(),
                    AppTheme.accentColor,
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
              case 'view':
                Navigator.pushNamed(
                  context,
                  AppRouter.farmerDetail,
                  arguments: farmer.id,
                );
                break;
              case 'edit':
                Navigator.pushNamed(
                  context,
                  AppRouter.addFarmer,
                  arguments: farmer,
                );
                break;
              case 'toggle':
                final farmerController = Provider.of<FarmerController>(context, listen: false);
                final updated = farmer.copyWith(isActive: !farmer.isActive);
                await farmerController.updateFarmer(updated);
                break;
              case 'delete':
                _showDeleteDialog(context, farmer);
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'view',
              child: Row(
                children: [
                  Icon(Icons.visibility, size: 20),
                  SizedBox(width: 12),
                  Text('View Details'),
                ],
              ),
            ),
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
            PopupMenuItem(
              value: 'toggle',
              child: Row(
                children: [
                  Icon(
                    farmer.isActive ? Icons.block : Icons.check_circle,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Text(farmer.isActive ? 'Deactivate' : 'Activate'),
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
        onTap: () {
          Navigator.pushNamed(
            context,
            AppRouter.farmerDetail,
            arguments: farmer.id,
          );
        },
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
        crossAxisAlignment: CrossAxisAlignment.start,
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
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, FarmerModel farmer) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Farmer'),
        content: Text(
          'Are you sure you want to delete ${farmer.name}?\n\nThis action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final farmerController = Provider.of<FarmerController>(context, listen: false);
              await farmerController.deleteFarmer(farmer.id);
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${farmer.name} deleted')),
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
