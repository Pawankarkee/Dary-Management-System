import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../controllers/farmer_controller.dart';
import '../../../models/farmer_model.dart';
import '../../../config/theme/app_theme.dart';
import '../../../config/routes/app_router.dart';
import '../../../utils/formatters.dart';

class FarmerDetailScreen extends StatelessWidget {
  final String farmerId;
  const FarmerDetailScreen({super.key, required this.farmerId});

  @override
  Widget build(BuildContext context) {
    final farmerController = Provider.of<FarmerController>(context);
    final farmer = farmerController.getFarmerById(farmerId);

    if (farmer == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Farmer Details')),
        body: const Center(child: Text('Farmer not found')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Farmer Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              await Navigator.pushNamed(context, AppRouter.addFarmer, arguments: farmer);
              // reload farmers after edit
              await farmerController.loadFarmers();
            },
            tooltip: 'Edit',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 64,
              backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
              backgroundImage: (farmer.photoPath != null && farmer.photoPath!.isNotEmpty)
                  ? (farmer.photoPath!.startsWith('http')
                      ? NetworkImage(farmer.photoPath!)
                      : FileImage(File(farmer.photoPath!)) as ImageProvider)
                  : null,
              child: farmer.photoPath == null || farmer.photoPath!.isEmpty
                  ? Icon(Icons.person, size: 64, color: AppTheme.primaryColor)
                  : null,
            ),
            const SizedBox(height: 16),
            Text(
              farmer.name,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text('ID: ${farmer.id}'),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _infoRow('Phone', farmer.phone != null ? AppFormatters.phone(farmer.phone!) : 'N/A'),
                    const Divider(),
                    _infoRow('Address', farmer.address ?? 'N/A'),
                    const Divider(),
                    _infoRow('Village', farmer.village ?? 'N/A'),
                    const Divider(),
                    _infoRow('Milk Type', farmer.milkTypeDisplay),
                    const Divider(),
                    _infoRow('Balance', AppFormatters.currency(farmer.runningBalance)),
                    const Divider(),
                    _infoRow('Status', farmer.isActive ? 'Active' : 'Inactive'),
                    const Divider(),
                    _infoRow('Created', farmer.createdAt.toLocal().toString()),
                    const Divider(),
                    _infoRow('Updated', farmer.updatedAt.toLocal().toString()),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          Flexible(child: Text(value, textAlign: TextAlign.right)),
        ],
      ),
    );
  }
}

