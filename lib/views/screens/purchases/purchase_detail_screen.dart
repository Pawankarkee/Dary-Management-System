import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../controllers/purchase_controller.dart';
import '../../../controllers/supplier_controller.dart';
import '../../../models/purchase_model.dart';
import '../../../config/theme/app_theme.dart';
import '../../../config/constants/app_constants.dart';
import '../../../utils/responsive.dart';
import '../../../config/routes/app_router.dart';
import 'add_purchase_screen.dart';

class PurchaseDetailScreen extends StatefulWidget {
  final String purchaseId;

  const PurchaseDetailScreen({super.key, required this.purchaseId});

  @override
  State<PurchaseDetailScreen> createState() => _PurchaseDetailScreenState();
}

class _PurchaseDetailScreenState extends State<PurchaseDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final purchaseController = Provider.of<PurchaseController>(context);
    final supplierController = Provider.of<SupplierController>(context);
    final purchase = purchaseController.getPurchaseById(widget.purchaseId);

    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    if (purchase == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Purchase Details')),
        body: const Center(child: Text('Purchase not found')),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.lightBackground,
      appBar: AppBar(
        title: const Text('Purchase Details'),
        actions: [
          if (purchase.status != PurchaseStatus.cancelled) ...[
            PopupMenuButton<String>(
              onSelected: (value) {
                switch (value) {
                  case 'edit':
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddPurchaseScreen(purchase: purchase),
                      ),
                    );
                    break;
                  case 'receive':
                    _markAsReceived(context, purchase, purchaseController);
                    break;
                  case 'payment':
                    _recordPayment(context, purchase, purchaseController, supplierController);
                    break;
                  case 'cancel':
                    _cancelPurchase(context, purchase, purchaseController, supplierController);
                    break;
                  case 'delete':
                    _deletePurchase(context, purchase, purchaseController);
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
                if (purchase.status == PurchaseStatus.pending)
                  const PopupMenuItem(
                    value: 'receive',
                    child: Row(
                      children: [
                        Icon(Icons.check_circle, size: 20, color: Colors.green),
                        SizedBox(width: 12),
                        Text('Mark as Received'),
                      ],
                    ),
                  ),
                if (purchase.balanceAmount > 0)
                  const PopupMenuItem(
                    value: 'payment',
                    child: Row(
                      children: [
                        Icon(Icons.payment, size: 20, color: Colors.blue),
                        SizedBox(width: 12),
                        Text('Record Payment'),
                      ],
                    ),
                  ),
                const PopupMenuItem(
                  value: 'cancel',
                  child: Row(
                    children: [
                      Icon(Icons.cancel, size: 20, color: Colors.orange),
                      SizedBox(width: 12),
                      Text('Cancel Purchase'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, size: 20, color: Colors.red),
                      SizedBox(width: 12),
                      Text('Delete'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(isMobile ? MobileSizes.spaceL : 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Card
            _buildHeaderCard(purchase, isMobile, context),

            SizedBox(height: isMobile ? MobileSizes.spaceL : 20),

            // Supplier Info
            _buildSupplierCard(purchase, isMobile, context),

            SizedBox(height: isMobile ? MobileSizes.spaceL : 20),

            // Items List
            _buildItemsCard(purchase, isMobile),

            SizedBox(height: isMobile ? MobileSizes.spaceL : 20),

            // Financial Summary
            _buildFinancialCard(purchase, isMobile),

            if (purchase.notes != null && purchase.notes!.isNotEmpty) ...[
              SizedBox(height: isMobile ? MobileSizes.spaceL : 20),
              _buildNotesCard(purchase, isMobile),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard(PurchaseModel purchase, bool isMobile, BuildContext context) {
    final isOverdue = purchase.dueDate.isBefore(DateTime.now()) &&
        purchase.paymentStatus != PaymentStatus.paid;

    return Card(
      child: Padding(
        padding: EdgeInsets.all(isMobile ? MobileSizes.cardPadding : 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.shopping_bag,
                    size: isMobile ? 40 : 48,
                    color: AppTheme.primaryColor,
                  ),
                ),
                SizedBox(width: isMobile ? MobileSizes.spaceM : 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        purchase.invoiceNumber,
                        style: TextStyle(
                          fontSize: isMobile ? MobileSizes.screenTitle : 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: isMobile ? MobileSizes.spaceXS : 6),
                      Row(
                        children: [
                          _buildStatusBadge(purchase.status, isMobile),
                          SizedBox(width: isMobile ? MobileSizes.spaceS : 8),
                          _buildPaymentBadge(purchase.paymentStatus, isMobile),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: isMobile ? MobileSizes.spaceL : 20),
            const Divider(),
            SizedBox(height: isMobile ? MobileSizes.spaceM : 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Purchase Date',
                        style: TextStyle(
                          fontSize: isMobile ? MobileSizes.caption : 12,
                          color: Colors.grey,
                        ),
                      ),
                      SizedBox(height: isMobile ? 2 : 4),
                      Text(
                        DateFormat('MMM dd, yyyy').format(purchase.purchaseDate),
                        style: TextStyle(
                          fontSize: isMobile ? MobileSizes.bodyMedium : 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Due Date',
                        style: TextStyle(
                          fontSize: isMobile ? MobileSizes.caption : 12,
                          color: isOverdue ? AppTheme.errorColor : Colors.grey,
                        ),
                      ),
                      SizedBox(height: isMobile ? 2 : 4),
                      Text(
                        DateFormat('MMM dd, yyyy').format(purchase.dueDate),
                        style: TextStyle(
                          fontSize: isMobile ? MobileSizes.bodyMedium : 14,
                          fontWeight: FontWeight.w600,
                          color: isOverdue ? AppTheme.errorColor : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (isOverdue) ...[
              SizedBox(height: isMobile ? MobileSizes.spaceM : 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.errorColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.warning_amber,
                      size: isMobile ? MobileSizes.iconMedium : 24,
                      color: AppTheme.errorColor,
                    ),
                    SizedBox(width: isMobile ? MobileSizes.spaceM : 12),
                    Expanded(
                      child: Text(
                        'This purchase is overdue!',
                        style: TextStyle(
                          fontSize: isMobile ? MobileSizes.bodyMedium : 14,
                          color: AppTheme.errorColor,
                          fontWeight: FontWeight.w600,
                        ),
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

  Widget _buildSupplierCard(PurchaseModel purchase, bool isMobile, BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(
            context,
            AppRouter.supplierDetail,
            arguments: purchase.supplierId,
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(isMobile ? MobileSizes.cardPadding : 20),
          child: Row(
            children: [
              Icon(
                Icons.store,
                size: isMobile ? MobileSizes.iconLarge : 32,
                color: AppTheme.primaryColor,
              ),
              SizedBox(width: isMobile ? MobileSizes.spaceM : 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Supplier',
                      style: TextStyle(
                        fontSize: isMobile ? MobileSizes.caption : 12,
                        color: Colors.grey,
                      ),
                    ),
                    SizedBox(height: isMobile ? 2 : 4),
                    Text(
                      purchase.supplierName,
                      style: TextStyle(
                        fontSize: isMobile ? MobileSizes.bodyLarge : 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: isMobile ? 16 : 20,
                color: Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildItemsCard(PurchaseModel purchase, bool isMobile) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(isMobile ? MobileSizes.cardPadding : 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Items (${purchase.items.length})',
              style: TextStyle(
                fontSize: isMobile ? MobileSizes.sectionTitle : 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: isMobile ? MobileSizes.spaceM : 16),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: purchase.items.length,
              separatorBuilder: (_, __) => Divider(height: isMobile ? 24 : 32),
              itemBuilder: (context, index) {
                final item = purchase.items[index];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            item.itemName,
                            style: TextStyle(
                              fontSize: isMobile ? MobileSizes.bodyMedium : 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Text(
                          '${AppConstants.RUPEE_SYMBOL}${item.amount.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: isMobile ? MobileSizes.bodyLarge : 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    if (item.description.isNotEmpty) ...[
                      SizedBox(height: isMobile ? MobileSizes.spaceXS : 4),
                      Text(
                        item.description,
                        style: TextStyle(
                          fontSize: isMobile ? MobileSizes.bodySmall : 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                    SizedBox(height: isMobile ? MobileSizes.spaceS : 6),
                    Text(
                      '${item.quantity} ${item.unit} × ${AppConstants.RUPEE_SYMBOL}${item.rate.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: isMobile ? MobileSizes.bodySmall : 13,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFinancialCard(PurchaseModel purchase, bool isMobile) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(isMobile ? MobileSizes.cardPadding : 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Financial Summary',
              style: TextStyle(
                fontSize: isMobile ? MobileSizes.sectionTitle : 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: isMobile ? MobileSizes.spaceL : 20),
            _buildFinancialRow('Subtotal', purchase.subtotal, isMobile),
            if (purchase.taxAmount > 0) ...[
              SizedBox(height: isMobile ? MobileSizes.spaceM : 12),
              _buildFinancialRow('Tax', purchase.taxAmount, isMobile),
            ],
            if (purchase.otherCharges > 0) ...[
              SizedBox(height: isMobile ? MobileSizes.spaceM : 12),
              _buildFinancialRow('Other Charges', purchase.otherCharges, isMobile),
            ],
            if (purchase.discount > 0) ...[
              SizedBox(height: isMobile ? MobileSizes.spaceM : 12),
              _buildFinancialRow('Discount', -purchase.discount, isMobile, isDiscount: true),
            ],
            SizedBox(height: isMobile ? MobileSizes.spaceM : 12),
            const Divider(thickness: 2),
            SizedBox(height: isMobile ? MobileSizes.spaceM : 12),
            _buildFinancialRow('Total Amount', purchase.totalAmount, isMobile, isTotal: true),
            SizedBox(height: isMobile ? MobileSizes.spaceM : 12),
            _buildFinancialRow('Paid Amount', purchase.paidAmount, isMobile, color: AppTheme.successColor),
            SizedBox(height: isMobile ? MobileSizes.spaceM : 12),
            _buildFinancialRow('Balance', purchase.balanceAmount, isMobile, color: purchase.balanceAmount > 0 ? AppTheme.errorColor : AppTheme.successColor, isTotal: true),
          ],
        ),
      ),
    );
  }

  Widget _buildFinancialRow(String label, double amount, bool isMobile, {bool isTotal = false, bool isDiscount = false, Color? color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isMobile ? MobileSizes.bodyMedium : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: color ?? (isTotal ? AppTheme.primaryColor : Colors.grey.shade700),
          ),
        ),
        Text(
          '${isDiscount && amount < 0 ? "-" : ""}${AppConstants.RUPEE_SYMBOL}${amount.abs().toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: isMobile ? (isTotal ? MobileSizes.bodyLarge : MobileSizes.bodyMedium) : (isTotal ? 18 : 14),
            fontWeight: FontWeight.bold,
            color: color ?? (isTotal ? AppTheme.primaryColor : Colors.black87),
          ),
        ),
      ],
    );
  }

  Widget _buildNotesCard(PurchaseModel purchase, bool isMobile) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(isMobile ? MobileSizes.cardPadding : 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Notes',
              style: TextStyle(
                fontSize: isMobile ? MobileSizes.sectionTitle : 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: isMobile ? MobileSizes.spaceM : 12),
            Text(
              purchase.notes!,
              style: TextStyle(
                fontSize: isMobile ? MobileSizes.bodyMedium : 14,
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(PurchaseStatus status, bool isMobile) {
    Color color;
    String label;
    
    switch (status) {
      case PurchaseStatus.pending:
        color = Colors.orange;
        label = 'PENDING';
        break;
      case PurchaseStatus.received:
        color = AppTheme.successColor;
        label = 'RECEIVED';
        break;
      case PurchaseStatus.cancelled:
        color = Colors.red;
        label = 'CANCELLED';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: isMobile ? MobileSizes.caption : 11,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildPaymentBadge(PaymentStatus status, bool isMobile) {
    Color color;
    String label;
    
    switch (status) {
      case PaymentStatus.unpaid:
        color = AppTheme.errorColor;
        label = 'UNPAID';
        break;
      case PaymentStatus.partial:
        color = Colors.orange;
        label = 'PARTIAL';
        break;
      case PaymentStatus.paid:
        color = AppTheme.successColor;
        label = 'PAID';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: isMobile ? MobileSizes.caption : 11,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  void _markAsReceived(BuildContext context, PurchaseModel purchase, PurchaseController controller) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Mark as Received'),
        content: const Text('Mark this purchase as received?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await controller.markAsReceived(purchase.id);
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Purchase marked as received')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              }
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  void _recordPayment(BuildContext context, PurchaseModel purchase, PurchaseController purchaseController, SupplierController supplierController) {
    final amountController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Record Payment'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Balance Due: ${AppConstants.RUPEE_SYMBOL}${purchase.balanceAmount.toStringAsFixed(2)}'),
              const SizedBox(height: 16),
              TextFormField(
                controller: amountController,
                decoration: InputDecoration(
                  labelText: 'Payment Amount',
                  prefixText: AppConstants.RUPEE_SYMBOL,
                ),
                keyboardType: TextInputType.number,
                autofocus: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter amount';
                  }
                  final amount = double.tryParse(value);
                  if (amount == null || amount <= 0) {
                    return 'Invalid amount';
                  }
                  if (amount > purchase.balanceAmount) {
                    return 'Amount exceeds balance';
                  }
                  return null;
                },
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
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                try {
                  final amount = double.parse(amountController.text);
                  await purchaseController.recordPayment(
                    purchase.id,
                    amount,
                    supplierController,
                  );
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Payment of ${AppConstants.RUPEE_SYMBOL}${amount.toStringAsFixed(2)} recorded')),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: $e')),
                    );
                  }
                }
              }
            },
            child: const Text('Record'),
          ),
        ],
      ),
    );
  }

  void _cancelPurchase(BuildContext context, PurchaseModel purchase, PurchaseController purchaseController, SupplierController supplierController) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Purchase'),
        content: const Text('Are you sure you want to cancel this purchase? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () async {
              try {
                await purchaseController.cancelPurchase(purchase.id, supplierController);
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Purchase cancelled')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              }
            },
            child: const Text('Yes, Cancel', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _deletePurchase(BuildContext context, PurchaseModel purchase, PurchaseController controller) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Purchase'),
        content: const Text('Are you sure you want to delete this purchase? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              try {
                await controller.deletePurchase(purchase.id);
                if (context.mounted) {
                  Navigator.pop(context); // Close dialog
                  Navigator.pop(context); // Go back to list
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Purchase deleted')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
