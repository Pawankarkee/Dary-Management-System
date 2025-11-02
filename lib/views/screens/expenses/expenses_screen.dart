import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../controllers/expense_controller.dart';
import '../../../models/expense_model.dart';
import '../../../config/theme/app_theme.dart';
import '../../../config/routes/app_router.dart';
import '../../../utils/responsive.dart';

class ExpensesScreen extends StatefulWidget {
  const ExpensesScreen({Key? key}) : super(key: key);

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ExpenseController>().loadExpenses();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expenses'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildFilterChips(),
          _buildStatisticsRow(),
          Expanded(child: _buildExpensesList()),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushNamed(context, AppRouter.addExpense);
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Expense'),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search expenses...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    context.read<ExpenseController>().clearSearch();
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onChanged: (value) {
          context.read<ExpenseController>().searchExpenses(value);
        },
      ),
    );
  }

  Widget _buildFilterChips() {
    final controller = context.watch<ExpenseController>();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          if (controller.selectedCategory != null ||
              controller.selectedPaymentMethod != null ||
              controller.selectedDateRange != null)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ActionChip(
                label: const Text('Clear Filters'),
                onPressed: () => controller.clearFilters(),
                avatar: const Icon(Icons.clear, size: 18),
              ),
            ),
          if (controller.selectedCategory != null)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Chip(
                label: Text(_getCategoryLabel(controller.selectedCategory!)),
                deleteIcon: const Icon(Icons.close, size: 18),
                onDeleted: () => controller.filterByCategory(null),
              ),
            ),
          if (controller.selectedPaymentMethod != null)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Chip(
                label: Text(_getPaymentMethodLabel(controller.selectedPaymentMethod!)),
                deleteIcon: const Icon(Icons.close, size: 18),
                onDeleted: () => controller.filterByPaymentMethod(null),
              ),
            ),
          if (controller.selectedDateRange != null)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Chip(
                label: Text(
                  '${DateFormat('MMM d').format(controller.selectedDateRange!.start)} - ${DateFormat('MMM d').format(controller.selectedDateRange!.end)}',
                ),
                deleteIcon: const Icon(Icons.close, size: 18),
                onDeleted: () => controller.filterByDateRange(null),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatisticsRow() {
    final controller = context.watch<ExpenseController>();
    final stats = controller.getExpenseStatistics();

    return Container(
      margin: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              'Total',
              '${stats['totalExpenses']}',
              Icons.receipt_long,
              Colors.blue,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              'Amount',
              '₹${stats['totalAmount'].toStringAsFixed(0)}',
              Icons.currency_rupee,
              Colors.green,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              'This Month',
              '₹${stats['thisMonthTotal'].toStringAsFixed(0)}',
              Icons.calendar_today,
              Colors.orange,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpensesList() {
    return Consumer<ExpenseController>(
      builder: (context, controller, child) {
        if (controller.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.expenses.isEmpty) {
          return _buildEmptyState();
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.expenses.length,
          itemBuilder: (context, index) {
            final expense = controller.expenses[index];
            return _buildExpenseCard(expense);
          },
        );
      },
    );
  }

  Widget _buildExpenseCard(ExpenseModel expense) {
    final categoryColor = _getCategoryColor(expense.category);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(
            context,
            AppRouter.expenseDetail,
            arguments: expense.id,
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: categoryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getCategoryIcon(expense.category),
                      color: categoryColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          expense.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
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
                                  fontSize: 11,
                                  color: categoryColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            if (expense.isRecurring) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.purple.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.purple.withOpacity(0.3),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.repeat,
                                      size: 10,
                                      color: Colors.purple,
                                    ),
                                    const SizedBox(width: 2),
                                    Text(
                                      'Recurring',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.purple,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '₹${expense.amount.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DateFormat('MMM d, y').format(expense.expenseDate),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              if (expense.paidTo != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.person_outline, size: 14, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      'Paid to: ${expense.paidTo}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
              if (expense.description.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  expense.description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    _getPaymentMethodIcon(expense.paymentMethod),
                    size: 14,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _getPaymentMethodLabel(expense.paymentMethod),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  if (expense.referenceNumber != null) ...[
                    const SizedBox(width: 12),
                    Icon(Icons.tag, size: 14, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      expense.referenceNumber!,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No expenses found',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add your first expense to get started',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Expenses'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Category', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: ExpenseCategory.values.map((category) {
                  return FilterChip(
                    label: Text(_getCategoryLabel(category)),
                    selected: context.read<ExpenseController>().selectedCategory == category,
                    onSelected: (selected) {
                      context.read<ExpenseController>().filterByCategory(
                        selected ? category : null,
                      );
                      Navigator.pop(context);
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              const Text('Payment Method', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: PaymentMethod.values.map((method) {
                  return FilterChip(
                    label: Text(_getPaymentMethodLabel(method)),
                    selected: context.read<ExpenseController>().selectedPaymentMethod == method,
                    onSelected: (selected) {
                      context.read<ExpenseController>().filterByPaymentMethod(
                        selected ? method : null,
                      );
                      Navigator.pop(context);
                    },
                  );
                }).toList(),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              context.read<ExpenseController>().clearFilters();
              Navigator.pop(context);
            },
            child: const Text('Clear All'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
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
}
