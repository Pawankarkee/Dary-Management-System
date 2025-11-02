import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../controllers/expense_controller.dart';
import '../../../models/expense_model.dart';
import '../../../config/routes/app_router.dart';

class ExpenseDetailScreen extends StatelessWidget {
  final String expenseId;

  const ExpenseDetailScreen({Key? key, required this.expenseId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense Details'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) async {
              final controller = context.read<ExpenseController>();
              final expense = controller.getExpenseById(expenseId);
              
              if (expense == null) return;

              switch (value) {
                case 'edit':
                  Navigator.pushNamed(
                    context,
                    AppRouter.addExpense,
                    arguments: expense,
                  );
                  break;
                case 'delete':
                  _showDeleteDialog(context, controller);
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit),
                    SizedBox(width: 12),
                    Text('Edit'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, color: Colors.red),
                    SizedBox(width: 12),
                    Text('Delete', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Consumer<ExpenseController>(
        builder: (context, controller, child) {
          final expense = controller.getExpenseById(expenseId);

          if (expense == null) {
            return const Center(
              child: Text('Expense not found'),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeaderCard(context, expense),
                const SizedBox(height: 16),
                _buildDetailsCard(context, expense),
                const SizedBox(height: 16),
                _buildPaymentCard(context, expense),
                if (expense.isRecurring) ...[
                  const SizedBox(height: 16),
                  _buildRecurringCard(context, expense),
                ],
                if (expense.notes != null && expense.notes!.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _buildNotesCard(context, expense),
                ],
                const SizedBox(height: 16),
                _buildTimestampCard(context, expense),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeaderCard(BuildContext context, ExpenseModel expense) {
    final categoryColor = _getCategoryColor(expense.category);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: categoryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getCategoryIcon(expense.category),
                    color: categoryColor,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        expense.title,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: categoryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: categoryColor.withOpacity(0.3),
                          ),
                        ),
                        child: Text(
                          _getCategoryLabel(expense.category),
                          style: TextStyle(
                            fontSize: 12,
                            color: categoryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Amount',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '₹${expense.amount.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Date',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('MMM d, y').format(expense.expenseDate),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            if (expense.isRecurring) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.purple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.purple.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.repeat, color: Colors.purple, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Recurring Expense',
                      style: TextStyle(
                        color: Colors.purple,
                        fontWeight: FontWeight.w600,
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

  Widget _buildDetailsCard(BuildContext context, ExpenseModel expense) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Details',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (expense.description.isNotEmpty) ...[
              _buildDetailRow(
                Icons.description,
                'Description',
                expense.description,
              ),
              const SizedBox(height: 12),
            ],
            if (expense.paidTo != null && expense.paidTo!.isNotEmpty) ...[
              _buildDetailRow(
                Icons.person,
                'Paid To',
                expense.paidTo!,
              ),
              const SizedBox(height: 12),
            ],
            _buildDetailRow(
              Icons.calendar_today,
              'Expense Date',
              DateFormat('EEEE, MMMM d, y').format(expense.expenseDate),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentCard(BuildContext context, ExpenseModel expense) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Payment Information',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildDetailRow(
              _getPaymentMethodIcon(expense.paymentMethod),
              'Payment Method',
              _getPaymentMethodLabel(expense.paymentMethod),
            ),
            if (expense.referenceNumber != null && expense.referenceNumber!.isNotEmpty) ...[
              const SizedBox(height: 12),
              _buildDetailRow(
                Icons.tag,
                'Reference Number',
                expense.referenceNumber!,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRecurringCard(BuildContext context, ExpenseModel expense) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recurring Information',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildDetailRow(
              Icons.repeat,
              'Frequency',
              expense.recurringType != null
                  ? _getRecurringTypeLabel(expense.recurringType!)
                  : 'N/A',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesCard(BuildContext context, ExpenseModel expense) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Notes',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              expense.notes!,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimestampCard(BuildContext context, ExpenseModel expense) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Timestamps',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildDetailRow(
              Icons.add_circle_outline,
              'Created',
              DateFormat('MMM d, y - hh:mm a').format(expense.createdAt),
            ),
            const SizedBox(height: 12),
            _buildDetailRow(
              Icons.update,
              'Last Updated',
              DateFormat('MMM d, y - hh:mm a').format(expense.updatedAt),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
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
              const SizedBox(height: 4),
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
    );
  }

  void _showDeleteDialog(BuildContext context, ExpenseController controller) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Expense'),
        content: const Text(
          'Are you sure you want to delete this expense? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              try {
                await controller.deleteExpense(expenseId);
                if (context.mounted) {
                  Navigator.pop(context); // Close dialog
                  Navigator.pop(context); // Go back to list
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Expense deleted successfully')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error deleting expense: $e')),
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

  IconData _getCategoryIcon(ExpenseCategory category) {
    switch (category) {
      case ExpenseCategory.salary:
        return Icons.people;
      case ExpenseCategory.animalFeed:
        return Icons.grass;
      case ExpenseCategory.veterinary:
        return Icons.medical_services;
      case ExpenseCategory.electricity:
        return Icons.bolt;
      case ExpenseCategory.water:
        return Icons.water_drop;
      case ExpenseCategory.transport:
        return Icons.local_shipping;
      case ExpenseCategory.maintenance:
        return Icons.build;
      case ExpenseCategory.packaging:
        return Icons.inventory_2;
      case ExpenseCategory.marketing:
        return Icons.campaign;
      case ExpenseCategory.rent:
        return Icons.home;
      case ExpenseCategory.insurance:
        return Icons.security;
      case ExpenseCategory.equipment:
        return Icons.construction;
      case ExpenseCategory.fuel:
        return Icons.local_gas_station;
      case ExpenseCategory.office:
        return Icons.business;
      case ExpenseCategory.other:
        return Icons.more_horiz;
    }
  }

  Color _getCategoryColor(ExpenseCategory category) {
    switch (category) {
      case ExpenseCategory.salary:
        return Colors.blue;
      case ExpenseCategory.animalFeed:
        return Colors.green;
      case ExpenseCategory.veterinary:
        return Colors.red;
      case ExpenseCategory.electricity:
        return Colors.yellow.shade700;
      case ExpenseCategory.water:
        return Colors.cyan;
      case ExpenseCategory.transport:
        return Colors.orange;
      case ExpenseCategory.maintenance:
        return Colors.brown;
      case ExpenseCategory.packaging:
        return Colors.purple;
      case ExpenseCategory.marketing:
        return Colors.pink;
      case ExpenseCategory.rent:
        return Colors.indigo;
      case ExpenseCategory.insurance:
        return Colors.teal;
      case ExpenseCategory.equipment:
        return Colors.deepOrange;
      case ExpenseCategory.fuel:
        return Colors.amber;
      case ExpenseCategory.office:
        return Colors.blueGrey;
      case ExpenseCategory.other:
        return Colors.grey;
    }
  }

  String _getCategoryLabel(ExpenseCategory category) {
    switch (category) {
      case ExpenseCategory.salary:
        return 'Salary';
      case ExpenseCategory.animalFeed:
        return 'Animal Feed';
      case ExpenseCategory.veterinary:
        return 'Veterinary';
      case ExpenseCategory.electricity:
        return 'Electricity';
      case ExpenseCategory.water:
        return 'Water';
      case ExpenseCategory.transport:
        return 'Transport';
      case ExpenseCategory.maintenance:
        return 'Maintenance';
      case ExpenseCategory.packaging:
        return 'Packaging';
      case ExpenseCategory.marketing:
        return 'Marketing';
      case ExpenseCategory.rent:
        return 'Rent';
      case ExpenseCategory.insurance:
        return 'Insurance';
      case ExpenseCategory.equipment:
        return 'Equipment';
      case ExpenseCategory.fuel:
        return 'Fuel';
      case ExpenseCategory.office:
        return 'Office';
      case ExpenseCategory.other:
        return 'Other';
    }
  }

  IconData _getPaymentMethodIcon(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.cash:
        return Icons.money;
      case PaymentMethod.upi:
        return Icons.qr_code;
      case PaymentMethod.card:
        return Icons.credit_card;
      case PaymentMethod.cheque:
        return Icons.receipt;
      case PaymentMethod.bankTransfer:
        return Icons.account_balance;
    }
  }

  String _getPaymentMethodLabel(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.cash:
        return 'Cash';
      case PaymentMethod.upi:
        return 'UPI';
      case PaymentMethod.card:
        return 'Card';
      case PaymentMethod.cheque:
        return 'Cheque';
      case PaymentMethod.bankTransfer:
        return 'Bank Transfer';
    }
  }

  String _getRecurringTypeLabel(RecurringType type) {
    switch (type) {
      case RecurringType.daily:
        return 'Daily';
      case RecurringType.weekly:
        return 'Weekly';
      case RecurringType.monthly:
        return 'Monthly';
      case RecurringType.yearly:
        return 'Yearly';
    }
  }
}
