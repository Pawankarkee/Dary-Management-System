import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../controllers/expense_controller.dart';
import '../../../models/expense_model.dart';

class AddExpenseScreen extends StatefulWidget {
  final ExpenseModel? expense;

  const AddExpenseScreen({Key? key, this.expense}) : super(key: key);

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _amountController;
  late TextEditingController _paidToController;
  late TextEditingController _referenceController;
  late TextEditingController _notesController;

  ExpenseCategory _selectedCategory = ExpenseCategory.other;
  PaymentMethod _selectedPaymentMethod = PaymentMethod.cash;
  DateTime _selectedDate = DateTime.now();
  bool _isRecurring = false;
  RecurringType? _recurringType;

  @override
  void initState() {
    super.initState();
    
    if (widget.expense != null) {
      final expense = widget.expense!;
      _titleController = TextEditingController(text: expense.title);
      _descriptionController = TextEditingController(text: expense.description);
      _amountController = TextEditingController(text: expense.amount.toString());
      _paidToController = TextEditingController(text: expense.paidTo ?? '');
      _referenceController = TextEditingController(text: expense.referenceNumber ?? '');
      _notesController = TextEditingController(text: expense.notes ?? '');
      _selectedCategory = expense.category;
      _selectedPaymentMethod = expense.paymentMethod;
      _selectedDate = expense.expenseDate;
      _isRecurring = expense.isRecurring;
      _recurringType = expense.recurringType;
    } else {
      _titleController = TextEditingController();
      _descriptionController = TextEditingController();
      _amountController = TextEditingController();
      _paidToController = TextEditingController();
      _referenceController = TextEditingController();
      _notesController = TextEditingController();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _amountController.dispose();
    _paidToController.dispose();
    _referenceController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.expense == null ? 'Add Expense' : 'Edit Expense'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildBasicInfoSection(),
            const SizedBox(height: 24),
            _buildCategorySection(),
            const SizedBox(height: 24),
            _buildPaymentSection(),
            const SizedBox(height: 24),
            _buildRecurringSection(),
            const SizedBox(height: 24),
            _buildAdditionalInfoSection(),
            const SizedBox(height: 32),
            _buildSaveButton(),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicInfoSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Basic Information',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title *',
                hintText: 'Enter expense title',
                prefixIcon: Icon(Icons.title),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a title';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                hintText: 'Enter description',
                prefixIcon: Icon(Icons.description),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _amountController,
              decoration: const InputDecoration(
                labelText: 'Amount *',
                hintText: 'Enter amount',
                prefixIcon: Icon(Icons.currency_rupee),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter an amount';
                }
                if (double.tryParse(value) == null) {
                  return 'Please enter a valid number';
                }
                if (double.parse(value) <= 0) {
                  return 'Amount must be greater than 0';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (date != null) {
                  setState(() {
                    _selectedDate = date;
                  });
                }
              },
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Expense Date *',
                  prefixIcon: Icon(Icons.calendar_today),
                ),
                child: Text(
                  DateFormat('MMM d, y').format(_selectedDate),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Category',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<ExpenseCategory>(
              value: _selectedCategory,
              decoration: const InputDecoration(
                labelText: 'Select Category *',
                prefixIcon: Icon(Icons.category),
              ),
              items: ExpenseCategory.values.map((category) {
                return DropdownMenuItem(
                  value: category,
                  child: Row(
                    children: [
                      Icon(_getCategoryIcon(category), size: 20),
                      const SizedBox(width: 12),
                      Text(_getCategoryLabel(category)),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedCategory = value;
                  });
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Payment Details',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<PaymentMethod>(
              value: _selectedPaymentMethod,
              decoration: const InputDecoration(
                labelText: 'Payment Method *',
                prefixIcon: Icon(Icons.payment),
              ),
              items: PaymentMethod.values.map((method) {
                return DropdownMenuItem(
                  value: method,
                  child: Row(
                    children: [
                      Icon(_getPaymentMethodIcon(method), size: 20),
                      const SizedBox(width: 12),
                      Text(_getPaymentMethodLabel(method)),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedPaymentMethod = value;
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _paidToController,
              decoration: const InputDecoration(
                labelText: 'Paid To',
                hintText: 'Enter vendor/person name',
                prefixIcon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _referenceController,
              decoration: const InputDecoration(
                labelText: 'Reference Number',
                hintText: 'Enter transaction/invoice reference',
                prefixIcon: Icon(Icons.tag),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecurringSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Recurring Expense',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Switch(
                  value: _isRecurring,
                  onChanged: (value) {
                    setState(() {
                      _isRecurring = value;
                      if (!value) {
                        _recurringType = null;
                      } else {
                        _recurringType = RecurringType.monthly;
                      }
                    });
                  },
                ),
              ],
            ),
            if (_isRecurring) ...[
              const SizedBox(height: 16),
              DropdownButtonFormField<RecurringType>(
                value: _recurringType,
                decoration: const InputDecoration(
                  labelText: 'Recurring Frequency',
                  prefixIcon: Icon(Icons.repeat),
                ),
                items: RecurringType.values.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(_getRecurringTypeLabel(type)),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _recurringType = value;
                  });
                },
                validator: (value) {
                  if (_isRecurring && value == null) {
                    return 'Please select recurring frequency';
                  }
                  return null;
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAdditionalInfoSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Additional Information',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notes',
                hintText: 'Enter any additional notes',
                prefixIcon: Icon(Icons.note),
              ),
              maxLines: 4,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return ElevatedButton(
      onPressed: _saveExpense,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Text(
        widget.expense == null ? 'Add Expense' : 'Update Expense',
        style: const TextStyle(fontSize: 16),
      ),
    );
  }

  void _saveExpense() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      final controller = context.read<ExpenseController>();
      final now = DateTime.now();

      final expense = ExpenseModel(
        id: widget.expense?.id ?? ExpenseModel.generateId(),
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        amount: double.parse(_amountController.text),
        category: _selectedCategory,
        expenseDate: _selectedDate,
        paymentMethod: _selectedPaymentMethod,
        referenceNumber: _referenceController.text.trim().isEmpty
            ? null
            : _referenceController.text.trim(),
        paidTo: _paidToController.text.trim().isEmpty
            ? null
            : _paidToController.text.trim(),
        isRecurring: _isRecurring,
        recurringType: _recurringType,
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
        createdAt: widget.expense?.createdAt ?? now,
        updatedAt: now,
      );

      if (widget.expense == null) {
        await controller.addExpense(expense);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Expense added successfully')),
          );
        }
      } else {
        await controller.updateExpense(expense);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Expense updated successfully')),
          );
        }
      }

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
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
