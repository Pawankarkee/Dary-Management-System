import 'package:flutter/material.dart';
import '../../../config/theme/app_theme.dart';

/// Party Ledger Module
/// Complete account statements for all parties (farmers, customers, suppliers)
class PartyLedgerScreen extends StatefulWidget {
  const PartyLedgerScreen({super.key});

  @override
  State<PartyLedgerScreen> createState() => _PartyLedgerScreenState();
}

class _PartyLedgerScreenState extends State<PartyLedgerScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.account_balance, size: 24),
            SizedBox(width: 8),
            Text('Party Ledgers'),
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
              Icon(Icons.account_balance, size: 100, color: AppTheme.primaryColor.withOpacity(0.3)),
              SizedBox(height: 24),
              Text('Party Ledgers', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold), textAlign: TextAlign.center),
              SizedBox(height: 16),
              Text('Complete account statements for farmers, customers, and suppliers', style: TextStyle(color: Colors.grey.shade600), textAlign: TextAlign.center),
              SizedBox(height: 32),
              ElevatedButton.icon(icon: Icon(Icons.arrow_back), label: Text('Back to Home'), onPressed: () => Navigator.pop(context)),
            ],
          ),
        ),
      ),
    );
  }
}
