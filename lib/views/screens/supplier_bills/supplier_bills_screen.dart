import 'package:flutter/material.dart';
import '../../../config/theme/app_theme.dart';

/// Supplier Bills Management Module  
/// Manage bills and invoices from suppliers
class SupplierBillsScreen extends StatefulWidget {
  const SupplierBillsScreen({super.key});

  @override
  State<SupplierBillsScreen> createState() => _SupplierBillsScreenState();
}

class _SupplierBillsScreenState extends State<SupplierBillsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.description, size: 24),
            SizedBox(width: 8),
            Text('Supplier Bills'),
          ],
        ),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.description, size: 100, color: AppTheme.primaryColor.withOpacity(0.3)),
              SizedBox(height: 24),
              Text('Supplier Bills Management', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold), textAlign: TextAlign.center),
              SizedBox(height: 16),
              Text('Track and manage supplier bills, invoices, and payments', style: TextStyle(color: Colors.grey.shade600), textAlign: TextAlign.center),
              SizedBox(height: 32),
              ElevatedButton.icon(icon: Icon(Icons.arrow_back), label: Text('Back to Home'), onPressed: () => Navigator.pop(context)),
            ],
          ),
        ),
      ),
    );
  }
}
