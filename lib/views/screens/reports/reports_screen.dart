import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../controllers/sales_controller.dart';
import '../../../controllers/milk_controller.dart';
import '../../../controllers/farmer_controller.dart';
import '../../../controllers/product_controller.dart';
import '../../../config/theme/app_theme.dart';
import '../../../config/routes/app_router.dart';
import '../../../config/constants/app_constants.dart';
import '../../../utils/responsive.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  int _selectedReportIndex = 0;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              Navigator.pushReplacementNamed(context, AppRouter.home);
            }
          },
          tooltip: 'Back',
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () => _showExportDialog(context, isMobile),
            tooltip: 'Export Report',
          ),
        ],
      ),
      backgroundColor: AppTheme.lightBackground,
      body: Row(
        children: [
          // Report Types Sidebar
          if (!isMobile)
            Container(
              width: 250,
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(2, 0),
                  ),
                ],
              ),
              child: _buildReportsList(isMobile),
            ),

          // Report Content
          Expanded(
            child: Column(
              children: [
                if (isMobile) ...[
                  // Mobile Report Selector
                  Container(
                    padding: EdgeInsets.all(MobileSizes.spaceL),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: DropdownButtonFormField<int>(
                      value: _selectedReportIndex,
                      decoration: const InputDecoration(
                        labelText: 'Select Report',
                        prefixIcon: Icon(Icons.assessment),
                      ),
                      items: _reportTypes.asMap().entries.map((entry) {
                        return DropdownMenuItem(
                          value: entry.key,
                          child: Row(
                            children: [
                              Icon(entry.value['icon'] as IconData, size: 20),
                              const SizedBox(width: 12),
                              Text(entry.value['title'] as String),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _selectedReportIndex = value);
                        }
                      },
                    ),
                  ),
                ],
                
                Expanded(
                  child: _buildReportContent(isMobile),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportsList(bool isMobile) {
    return ListView.builder(
      padding: EdgeInsets.symmetric(vertical: isMobile ? MobileSizes.spaceM : 16),
      itemCount: _reportTypes.length,
      itemBuilder: (context, index) {
        final report = _reportTypes[index];
        final isSelected = _selectedReportIndex == index;

        return ListTile(
          leading: Icon(
            report['icon'] as IconData,
            color: isSelected ? AppTheme.primaryColor : Colors.grey,
          ),
          title: Text(
            report['title'] as String,
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? AppTheme.primaryColor : Colors.black87,
            ),
          ),
          selected: isSelected,
          selectedTileColor: AppTheme.primaryColor.withOpacity(0.1),
          onTap: () => setState(() => _selectedReportIndex = index),
        );
      },
    );
  }

  Widget _buildReportContent(bool isMobile) {
    switch (_selectedReportIndex) {
      case 0:
        return _SalesReportView(isMobile: isMobile);
      case 1:
        return _MilkReportView(isMobile: isMobile);
      case 2:
        return _StockReportView(isMobile: isMobile);
      case 3:
        return _FarmerReportView(isMobile: isMobile);
      case 4:
        return _FinancialSummaryView(isMobile: isMobile);
      case 5:
        return _ProfitLossAnalysisView(isMobile: isMobile);
      default:
        return const Center(child: Text('Select a report'));
    }
  }

  final List<Map<String, dynamic>> _reportTypes = [
    {'icon': Icons.point_of_sale, 'title': 'Sales Report'},
    {'icon': Icons.water_drop, 'title': 'Milk Collection'},
    {'icon': Icons.inventory, 'title': 'Stock Report'},
    {'icon': Icons.people, 'title': 'Farmer Report'},
    {'icon': Icons.account_balance_wallet, 'title': 'Financial Summary'},
    {'icon': Icons.analytics, 'title': 'Profit & Loss Analysis'},
  ];

  // Show export dialog
  void _showExportDialog(BuildContext context, bool isMobile) {
    DateTime startDate = DateTime.now().subtract(const Duration(days: 30));
    DateTime endDate = DateTime.now();
    String reportType = 'All Reports';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Export Reports'),
          content: SizedBox(
            width: isMobile ? double.maxFinite : 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Select Report Type'),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: reportType,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  items: [
                    'All Reports',
                    'Sales Report',
                    'Financial Summary',
                    'Inventory Report',
                  ].map((type) => DropdownMenuItem(
                    value: type,
                    child: Text(type),
                  )).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => reportType = value);
                    }
                  },
                ),
                const SizedBox(height: 16),
                const Text('Date Range'),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.calendar_today, size: 18),
                        label: Text(DateFormat('dd/MM/yy').format(startDate)),
                        onPressed: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: startDate,
                            firstDate: DateTime(2020),
                            lastDate: DateTime.now(),
                          );
                          if (date != null) {
                            setState(() => startDate = date);
                          }
                        },
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Text('to'),
                    ),
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.calendar_today, size: 18),
                        label: Text(DateFormat('dd/MM/yy').format(endDate)),
                        onPressed: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: endDate,
                            firstDate: startDate,
                            lastDate: DateTime.now(),
                          );
                          if (date != null) {
                            setState(() => endDate = date);
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.picture_as_pdf, size: 18),
              label: const Text('Export PDF'),
              onPressed: () {
                Navigator.pop(context);
                _exportToPDF(reportType, startDate, endDate);
              },
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.table_chart, size: 18),
              label: const Text('Export Excel'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
              onPressed: () {
                Navigator.pop(context);
                _exportToExcel(reportType, startDate, endDate);
              },
            ),
          ],
        ),
      ),
    );
  }

  // Export to PDF
  Future<void> _exportToPDF(String reportType, DateTime startDate, DateTime endDate) async {
    try {
      final pdf = pw.Document();
      final salesController = Provider.of<SalesController>(context, listen: false);
      final milkController = Provider.of<MilkController>(context, listen: false);
      final farmerController = Provider.of<FarmerController>(context, listen: false);
      final productController = Provider.of<ProductController>(context, listen: false);

      // Calculate profit/loss
      final profitLoss = _calculateProfitLoss();

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          build: (context) => [
            pw.Header(
              level: 0,
              child: pw.Text(
                'Dairy Management Report',
                style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
              ),
            ),
            pw.Paragraph(
              text: 'Report Type: $reportType',
              style: const pw.TextStyle(fontSize: 14),
            ),
            pw.Paragraph(
              text: 'Date Range: ${DateFormat('dd/MM/yyyy').format(startDate)} - ${DateFormat('dd/MM/yyyy').format(endDate)}',
              style: const pw.TextStyle(fontSize: 14),
            ),
            pw.SizedBox(height: 20),
            
            // Profit/Loss Summary
            pw.Header(level: 1, child: pw.Text('Financial Summary')),
            pw.Table.fromTextArray(
              headers: ['Metric', 'Amount'],
              data: [
                ['Total Sales', '${AppConstants.RUPEE_SYMBOL}${profitLoss['totalSales']?.toStringAsFixed(2) ?? '0.00'}'],
                ['Total Expenses', '${AppConstants.RUPEE_SYMBOL}${profitLoss['totalExpenses']?.toStringAsFixed(2) ?? '0.00'}'],
                ['Gross Profit', '${AppConstants.RUPEE_SYMBOL}${profitLoss['grossProfit']?.toStringAsFixed(2) ?? '0.00'}'],
                ['Profit Margin', '${profitLoss['profitMargin']?.toStringAsFixed(2) ?? '0.00'}%'],
              ],
            ),
            pw.SizedBox(height: 20),

            // Sales Summary
            pw.Header(level: 1, child: pw.Text('Sales Overview')),
            pw.Table.fromTextArray(
              headers: ['Metric', 'Value'],
              data: [
                ['Total Sales', salesController.sales.length.toString()],
                ['Total Revenue', '${AppConstants.RUPEE_SYMBOL}${salesController.sales.fold<double>(0, (sum, sale) => sum + sale.totalAmount).toStringAsFixed(2)}'],
              ],
            ),
            pw.SizedBox(height: 20),

            // Inventory Summary
            pw.Header(level: 1, child: pw.Text('Inventory Status')),
            pw.Table.fromTextArray(
              headers: ['Product', 'Stock', 'Value'],
              data: productController.products.map((product) => [
                product.name,
                '${product.currentStock} ${product.unit.toString().split('.').last}',
                '${AppConstants.RUPEE_SYMBOL}${(product.currentStock * product.sellingPrice).toStringAsFixed(2)}',
              ]).toList(),
            ),
            pw.SizedBox(height: 20),

            // Farmers Summary
            pw.Header(level: 1, child: pw.Text('Farmer Statistics')),
            pw.Paragraph(text: 'Total Farmers: ${farmerController.farmers.length}'),
            pw.Paragraph(text: 'Active Farmers: ${farmerController.farmers.where((f) => f.isActive).length}'),
            pw.SizedBox(height: 20),

            // Milk Collection Summary
            pw.Header(level: 1, child: pw.Text('Milk Collection')),
            pw.Table.fromTextArray(
              headers: ['Metric', 'Value'],
              data: [
                ['Total Collections', milkController.collections.length.toString()],
                ['Total Quantity', '${milkController.collections.fold<double>(0, (sum, coll) => sum + coll.quantity).toStringAsFixed(2)} Liters'],
                ['Total Amount', '${AppConstants.RUPEE_SYMBOL}${milkController.collections.fold<double>(0, (sum, coll) => sum + coll.totalAmount).toStringAsFixed(2)}'],
              ],
            ),
          ],
        ),
      );

      // Save and share PDF
      await Printing.sharePdf(
        bytes: await pdf.save(),
        filename: 'dairy_report_${DateFormat('yyyyMMdd').format(DateTime.now())}.pdf',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('PDF report generated successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error generating PDF: $e')),
        );
      }
    }
  }

  // Export to Excel
  Future<void> _exportToExcel(String reportType, DateTime startDate, DateTime endDate) async {
    try {
      final excel = Excel.createExcel();
      final salesController = Provider.of<SalesController>(context, listen: false);
      final milkController = Provider.of<MilkController>(context, listen: false);
      final farmerController = Provider.of<FarmerController>(context, listen: false);
      final productController = Provider.of<ProductController>(context, listen: false);

      // Remove default sheet
      excel.delete('Sheet1');

      // Calculate profit/loss
      final profitLoss = _calculateProfitLoss();

      // Create Financial Summary Sheet
      var financialSheet = excel['Financial Summary'];
      financialSheet.appendRow([TextCellValue('Dairy Management Report')]);
      financialSheet.appendRow([TextCellValue('Date Range:'), TextCellValue('${DateFormat('dd/MM/yyyy').format(startDate)} - ${DateFormat('dd/MM/yyyy').format(endDate)}')]);
      financialSheet.appendRow([]);
      financialSheet.appendRow([TextCellValue('Metric'), TextCellValue('Amount')]);
      financialSheet.appendRow([TextCellValue('Total Sales'), TextCellValue(profitLoss['totalSales']?.toStringAsFixed(2) ?? '0.00')]);
      financialSheet.appendRow([TextCellValue('Total Expenses'), TextCellValue(profitLoss['totalExpenses']?.toStringAsFixed(2) ?? '0.00')]);
      financialSheet.appendRow([TextCellValue('Gross Profit'), TextCellValue(profitLoss['grossProfit']?.toStringAsFixed(2) ?? '0.00')]);
      financialSheet.appendRow([TextCellValue('Profit Margin'), TextCellValue('${profitLoss['profitMargin']?.toStringAsFixed(2) ?? '0.00'}%')]);

      // Create Sales Sheet
      var salesSheet = excel['Sales'];
      salesSheet.appendRow([
        TextCellValue('Sale ID'),
        TextCellValue('Date'),
        TextCellValue('Customer'),
        TextCellValue('Total Amount'),
        TextCellValue('Payment Method'),
      ]);
      for (var sale in salesController.sales) {
        salesSheet.appendRow([
          TextCellValue(sale.id),
          TextCellValue(DateFormat('dd/MM/yyyy HH:mm').format(sale.saleDate)),
          TextCellValue(sale.farmerName ?? 'Walk-in'),
          TextCellValue(sale.totalAmount.toStringAsFixed(2)),
          TextCellValue(sale.paymentMethod.toString().split('.').last),
        ]);
      }

      // Create Products Sheet
      var productsSheet = excel['Products'];
      productsSheet.appendRow([
        TextCellValue('Product'),
        TextCellValue('Category'),
        TextCellValue('Stock'),
        TextCellValue('Unit'),
        TextCellValue('Purchase Price'),
        TextCellValue('Selling Price'),
        TextCellValue('Total Value'),
      ]);
      for (var product in productController.products) {
        productsSheet.appendRow([
          TextCellValue(product.name),
          TextCellValue(product.category.toString().split('.').last),
          TextCellValue(product.currentStock.toString()),
          TextCellValue(product.unit.toString().split('.').last),
          TextCellValue(product.purchasePrice.toStringAsFixed(2)),
          TextCellValue(product.sellingPrice.toStringAsFixed(2)),
          TextCellValue((product.currentStock * product.sellingPrice).toStringAsFixed(2)),
        ]);
      }

      // Create Milk Collection Sheet
      var milkSheet = excel['Milk Collection'];
      milkSheet.appendRow([
        TextCellValue('Collection ID'),
        TextCellValue('Date'),
        TextCellValue('Farmer'),
        TextCellValue('Quantity (L)'),
        TextCellValue('Fat %'),
        TextCellValue('SNF %'),
        TextCellValue('Amount'),
      ]);
      for (var collection in milkController.collections) {
        final farmer = farmerController.farmers.firstWhere(
          (f) => f.id == collection.farmerId,
          orElse: () => farmerController.farmers.first,
        );
        milkSheet.appendRow([
          TextCellValue(collection.id),
          TextCellValue(DateFormat('dd/MM/yyyy HH:mm').format(collection.date)),
          TextCellValue(farmer.name),
          TextCellValue(collection.quantity.toStringAsFixed(2)),
          TextCellValue(collection.fat.toStringAsFixed(1)),
          TextCellValue(collection.snf.toStringAsFixed(1)),
          TextCellValue(collection.totalAmount.toStringAsFixed(2)),
        ]);
      }

      // Create Farmers Sheet
      var farmersSheet = excel['Farmers'];
      farmersSheet.appendRow([
        TextCellValue('Farmer ID'),
        TextCellValue('Name'),
        TextCellValue('Phone'),
        TextCellValue('Status'),
        TextCellValue('Total Collections'),
      ]);
      for (var farmer in farmerController.farmers) {
        final collections = milkController.collections.where((c) => c.farmerId == farmer.id).length;
        farmersSheet.appendRow([
          TextCellValue(farmer.id),
          TextCellValue(farmer.name),
          TextCellValue(farmer.phone ?? ''),
          TextCellValue(farmer.isActive ? 'Active' : 'Inactive'),
          TextCellValue(collections.toString()),
        ]);
      }

      // Save Excel file
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/dairy_report_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.xlsx');
      await file.writeAsBytes(excel.encode()!);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Excel report saved: ${file.path}'),
            action: SnackBarAction(
              label: 'OK',
              onPressed: () {},
            ),
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error generating Excel: $e')),
        );
      }
    }
  }

  // Calculate profit and loss
  Map<String, double> _calculateProfitLoss() {
    final salesController = Provider.of<SalesController>(context, listen: false);
    final milkController = Provider.of<MilkController>(context, listen: false);
    final productController = Provider.of<ProductController>(context, listen: false);

    // Calculate total sales (revenue from products sold)
    double totalSales = salesController.sales.fold<double>(
      0,
      (sum, sale) => sum + sale.totalAmount,
    );

    // Calculate total expenses (milk purchases + product purchase costs)
    double milkExpenses = milkController.collections.fold<double>(
      0,
      (sum, collection) => sum + collection.totalAmount,
    );

    // Estimate product purchase costs (simplified: assume 70% of selling price as cost)
    double productCosts = 0;
    for (var sale in salesController.sales) {
      for (var item in sale.items) {
        final product = productController.products.firstWhere(
          (p) => p.id == item.productId,
          orElse: () => productController.products.first,
        );
        productCosts += item.quantity * product.purchasePrice;
      }
    }

    double totalExpenses = milkExpenses + productCosts;
    double grossProfit = totalSales - totalExpenses;
    double profitMargin = totalSales > 0 ? (grossProfit / totalSales) * 100 : 0;

    return {
      'totalSales': totalSales,
      'totalExpenses': totalExpenses,
      'milkExpenses': milkExpenses,
      'productCosts': productCosts,
      'grossProfit': grossProfit,
      'profitMargin': profitMargin,
    };
  }
}

// Sales Report View
class _SalesReportView extends StatelessWidget {
  final bool isMobile;

  const _SalesReportView({required this.isMobile});

  @override
  Widget build(BuildContext context) {
    final salesController = Provider.of<SalesController>(context);
    final todaySummary = salesController.getTodaySummary();
    final statistics = salesController.getSalesStatistics();
    final topProducts = salesController.getTopSellingProducts(limit: 5);

    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? MobileSizes.spaceL : 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            'Sales Report',
            style: TextStyle(
              fontSize: isMobile ? MobileSizes.screenTitle : 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: isMobile ? MobileSizes.spaceL : 20),

          // Today's Summary
          Text(
            "Today's Sales",
            style: TextStyle(
              fontSize: isMobile ? MobileSizes.sectionTitle : 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: isMobile ? MobileSizes.spaceM : 12),

          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: isMobile ? 2 : 4,
            crossAxisSpacing: isMobile ? 10 : 16,
            mainAxisSpacing: isMobile ? 10 : 16,
            childAspectRatio: isMobile ? 1.3 : 1.5,
            children: [
              _StatCard(
                icon: Icons.shopping_cart,
                label: 'Total Sales',
                value: todaySummary['totalSales'].toString(),
                color: AppTheme.primaryColor,
                isMobile: isMobile,
              ),
              _StatCard(
                icon: Icons.currency_rupee,
                label: 'Revenue',
                value: '${AppConstants.RUPEE_SYMBOL}${todaySummary['totalAmount'].toStringAsFixed(0)}',
                color: AppTheme.successColor,
                isMobile: isMobile,
              ),
              _StatCard(
                icon: Icons.inventory_2,
                label: 'Items Sold',
                value: todaySummary['totalItems'].toString(),
                color: AppTheme.accentColor,
                isMobile: isMobile,
              ),
              _StatCard(
                icon: Icons.discount,
                label: 'Discounts',
                value: '${AppConstants.RUPEE_SYMBOL}${todaySummary['totalDiscount'].toStringAsFixed(0)}',
                color: Colors.red,
                isMobile: isMobile,
              ),
            ],
          ),

          SizedBox(height: isMobile ? MobileSizes.spaceXL : 32),

          // Overall Statistics
          Text(
            'Overall Statistics',
            style: TextStyle(
              fontSize: isMobile ? MobileSizes.sectionTitle : 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: isMobile ? MobileSizes.spaceM : 12),

          Card(
            child: Padding(
              padding: EdgeInsets.all(isMobile ? MobileSizes.cardPadding : 16),
              child: Column(
                children: [
                  _InfoRow(
                    'Total Revenue:',
                    '${AppConstants.RUPEE_SYMBOL}${statistics['totalRevenue'].toStringAsFixed(2)}',
                    isMobile,
                  ),
                  Divider(height: isMobile ? 20 : 24),
                  _InfoRow(
                    'Total Transactions:',
                    statistics['totalTransactions'].toString(),
                    isMobile,
                  ),
                  Divider(height: isMobile ? 20 : 24),
                  _InfoRow(
                    'Average Order Value:',
                    '${AppConstants.RUPEE_SYMBOL}${statistics['averageOrderValue'].toStringAsFixed(2)}',
                    isMobile,
                  ),
                  Divider(height: isMobile ? 20 : 24),
                  _InfoRow(
                    'Total Items Sold:',
                    statistics['totalItemsSold'].toString(),
                    isMobile,
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: isMobile ? MobileSizes.spaceXL : 32),

          // Top Selling Products
          if (topProducts.isNotEmpty) ...[
            Text(
              'Top Selling Products',
              style: TextStyle(
                fontSize: isMobile ? MobileSizes.sectionTitle : 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: isMobile ? MobileSizes.spaceM : 12),

            Card(
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: EdgeInsets.all(isMobile ? MobileSizes.cardPadding : 16),
                itemCount: topProducts.length,
                separatorBuilder: (_, __) => Divider(height: isMobile ? 20 : 24),
                itemBuilder: (context, index) {
                  final product = topProducts[index];
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(
                      product['productName'],
                      style: TextStyle(
                        fontSize: isMobile ? MobileSizes.bodyMedium : 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      'Qty: ${product['quantity']}',
                      style: TextStyle(
                        fontSize: isMobile ? MobileSizes.bodySmall : 12,
                      ),
                    ),
                    trailing: Text(
                      '${AppConstants.RUPEE_SYMBOL}${product['amount'].toStringAsFixed(0)}',
                      style: TextStyle(
                        fontSize: isMobile ? MobileSizes.bodyMedium : 14,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.successColor,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// Milk Report View
class _MilkReportView extends StatelessWidget {
  final bool isMobile;

  const _MilkReportView({required this.isMobile});

  @override
  Widget build(BuildContext context) {
    final milkController = Provider.of<MilkController>(context);
    final todaySummary = milkController.getTodaySummary();

    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? MobileSizes.spaceL : 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Milk Collection Report',
            style: TextStyle(
              fontSize: isMobile ? MobileSizes.screenTitle : 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: isMobile ? MobileSizes.spaceL : 20),

          Text(
            "Today's Collection",
            style: TextStyle(
              fontSize: isMobile ? MobileSizes.sectionTitle : 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: isMobile ? MobileSizes.spaceM : 12),

          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: isMobile ? 2 : 4,
            crossAxisSpacing: isMobile ? 10 : 16,
            mainAxisSpacing: isMobile ? 10 : 16,
            childAspectRatio: isMobile ? 1.3 : 1.5,
            children: [
              _StatCard(
                icon: Icons.water_drop,
                label: 'Total Quantity',
                value: '${todaySummary['totalQuantity'].toStringAsFixed(1)} L',
                color: AppTheme.primaryColor,
                isMobile: isMobile,
              ),
              _StatCard(
                icon: Icons.currency_rupee,
                label: 'Total Amount',
                value: '${AppConstants.RUPEE_SYMBOL}${todaySummary['totalAmount'].toStringAsFixed(0)}',
                color: AppTheme.successColor,
                isMobile: isMobile,
              ),
              _StatCard(
                icon: Icons.wb_sunny,
                label: 'Morning',
                value: todaySummary['morningCount'].toString(),
                color: Colors.orange,
                isMobile: isMobile,
              ),
              _StatCard(
                icon: Icons.nightlight_round,
                label: 'Evening',
                value: todaySummary['eveningCount'].toString(),
                color: Colors.indigo,
                isMobile: isMobile,
              ),
            ],
          ),

          SizedBox(height: isMobile ? MobileSizes.spaceXL : 32),

          Card(
            child: Padding(
              padding: EdgeInsets.all(isMobile ? MobileSizes.cardPadding : 16),
              child: Column(
                children: [
                  _InfoRow(
                    'Total Farmers:',
                    todaySummary['totalFarmers'].toString(),
                    isMobile,
                  ),
                  Divider(height: isMobile ? 20 : 24),
                  _InfoRow(
                    'Average per Farmer:',
                    '${(todaySummary['totalQuantity'] / (todaySummary['totalFarmers'] > 0 ? todaySummary['totalFarmers'] : 1)).toStringAsFixed(1)} L',
                    isMobile,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Stock Report View
class _StockReportView extends StatelessWidget {
  final bool isMobile;

  const _StockReportView({required this.isMobile});

  @override
  Widget build(BuildContext context) {
    final productController = Provider.of<ProductController>(context);
    final allProducts = productController.products;
    final lowStock = productController.lowStockProducts;
    final expiring = productController.expiringProducts;

    double totalValue = 0;
    for (var product in allProducts) {
      totalValue += product.currentStock * product.purchasePrice;
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? MobileSizes.spaceL : 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Stock Report',
            style: TextStyle(
              fontSize: isMobile ? MobileSizes.screenTitle : 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: isMobile ? MobileSizes.spaceL : 20),

          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: isMobile ? 2 : 4,
            crossAxisSpacing: isMobile ? 10 : 16,
            mainAxisSpacing: isMobile ? 10 : 16,
            childAspectRatio: isMobile ? 1.3 : 1.5,
            children: [
              _StatCard(
                icon: Icons.inventory_2,
                label: 'Total Products',
                value: allProducts.length.toString(),
                color: AppTheme.primaryColor,
                isMobile: isMobile,
              ),
              _StatCard(
                icon: Icons.currency_rupee,
                label: 'Stock Value',
                value: '${AppConstants.RUPEE_SYMBOL}${totalValue.toStringAsFixed(0)}',
                color: AppTheme.successColor,
                isMobile: isMobile,
              ),
              _StatCard(
                icon: Icons.warning_amber,
                label: 'Low Stock',
                value: lowStock.length.toString(),
                color: Colors.orange,
                isMobile: isMobile,
              ),
              _StatCard(
                icon: Icons.access_time,
                label: 'Expiring Soon',
                value: expiring.length.toString(),
                color: Colors.red,
                isMobile: isMobile,
              ),
            ],
          ),

          if (lowStock.isNotEmpty) ...[
            SizedBox(height: isMobile ? MobileSizes.spaceXL : 32),
            Text(
              'Low Stock Products',
              style: TextStyle(
                fontSize: isMobile ? MobileSizes.sectionTitle : 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: isMobile ? MobileSizes.spaceM : 12),

            Card(
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: EdgeInsets.all(isMobile ? MobileSizes.cardPadding : 16),
                itemCount: lowStock.length,
                separatorBuilder: (_, __) => Divider(height: isMobile ? 16 : 20),
                itemBuilder: (context, index) {
                  final product = lowStock[index];
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(
                      Icons.warning_amber,
                      color: Colors.orange,
                      size: isMobile ? MobileSizes.iconLarge : 24,
                    ),
                    title: Text(
                      product.name,
                      style: TextStyle(
                        fontSize: isMobile ? MobileSizes.bodyMedium : 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      'Current: ${product.currentStock} ${product.unitDisplay}',
                      style: TextStyle(
                        fontSize: isMobile ? MobileSizes.bodySmall : 12,
                      ),
                    ),
                    trailing: Text(
                      'Min: ${product.minStockLevel}',
                      style: TextStyle(
                        fontSize: isMobile ? MobileSizes.bodySmall : 12,
                        color: Colors.orange,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// Farmer Report View
class _FarmerReportView extends StatelessWidget {
  final bool isMobile;

  const _FarmerReportView({required this.isMobile});

  @override
  Widget build(BuildContext context) {
    final farmerController = Provider.of<FarmerController>(context);
    final allFarmers = farmerController.farmers;
    final cowFarmers = allFarmers.where((f) => f.milkType.toString().contains('cow')).length;
    final buffaloFarmers = allFarmers.where((f) => f.milkType.toString().contains('buffalo')).length;

    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? MobileSizes.spaceL : 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Farmer Report',
            style: TextStyle(
              fontSize: isMobile ? MobileSizes.screenTitle : 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: isMobile ? MobileSizes.spaceL : 20),

          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: isMobile ? 2 : 4,
            crossAxisSpacing: isMobile ? 10 : 16,
            mainAxisSpacing: isMobile ? 10 : 16,
            childAspectRatio: isMobile ? 1.3 : 1.5,
            children: [
              _StatCard(
                icon: Icons.people,
                label: 'Total Farmers',
                value: allFarmers.length.toString(),
                color: AppTheme.primaryColor,
                isMobile: isMobile,
              ),
              _StatCard(
                icon: Icons.water_drop,
                label: 'Cow Farmers',
                value: cowFarmers.toString(),
                color: Colors.blue,
                isMobile: isMobile,
              ),
              _StatCard(
                icon: Icons.water_drop,
                label: 'Buffalo Farmers',
                value: buffaloFarmers.toString(),
                color: Colors.brown,
                isMobile: isMobile,
              ),
              _StatCard(
                icon: Icons.check_circle,
                label: 'Active',
                value: allFarmers.where((f) => f.isActive).length.toString(),
                color: AppTheme.successColor,
                isMobile: isMobile,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Financial Summary View
class _FinancialSummaryView extends StatelessWidget {
  final bool isMobile;

  const _FinancialSummaryView({required this.isMobile});

  @override
  Widget build(BuildContext context) {
    final salesController = Provider.of<SalesController>(context);
    final milkController = Provider.of<MilkController>(context);
    
    final salesStats = salesController.getSalesStatistics();
    final milkSummary = milkController.getTodaySummary();

    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? MobileSizes.spaceL : 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Financial Summary',
            style: TextStyle(
              fontSize: isMobile ? MobileSizes.screenTitle : 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: isMobile ? MobileSizes.spaceL : 20),

          Card(
            child: Padding(
              padding: EdgeInsets.all(isMobile ? MobileSizes.cardPadding : 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Revenue',
                    style: TextStyle(
                      fontSize: isMobile ? MobileSizes.sectionTitle : 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.successColor,
                    ),
                  ),
                  SizedBox(height: isMobile ? MobileSizes.spaceM : 16),
                  _InfoRow(
                    'Product Sales:',
                    '${AppConstants.RUPEE_SYMBOL}${salesStats['totalRevenue'].toStringAsFixed(2)}',
                    isMobile,
                  ),
                  Divider(height: isMobile ? 20 : 24),
                  _InfoRow(
                    'Today\'s Sales:',
                    '${AppConstants.RUPEE_SYMBOL}${salesController.getTodaySummary()['totalAmount'].toStringAsFixed(2)}',
                    isMobile,
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: isMobile ? MobileSizes.spaceL : 20),

          Card(
            child: Padding(
              padding: EdgeInsets.all(isMobile ? MobileSizes.cardPadding : 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Expenses',
                    style: TextStyle(
                      fontSize: isMobile ? MobileSizes.sectionTitle : 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.errorColor,
                    ),
                  ),
                  SizedBox(height: isMobile ? MobileSizes.spaceM : 16),
                  _InfoRow(
                    'Milk Purchases:',
                    '${AppConstants.RUPEE_SYMBOL}${milkSummary['totalAmount'].toStringAsFixed(2)}',
                    isMobile,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Profit & Loss Analysis View
class _ProfitLossAnalysisView extends StatelessWidget {
  final bool isMobile;

  const _ProfitLossAnalysisView({required this.isMobile});

  @override
  Widget build(BuildContext context) {
    final salesController = Provider.of<SalesController>(context);
    final milkController = Provider.of<MilkController>(context);
    final productController = Provider.of<ProductController>(context);

    // Calculate profit/loss metrics
    double totalSales = salesController.sales.fold<double>(
      0,
      (sum, sale) => sum + sale.totalAmount,
    );

    double milkExpenses = milkController.collections.fold<double>(
      0,
      (sum, collection) => sum + collection.totalAmount,
    );

    double productCosts = 0;
    for (var sale in salesController.sales) {
      for (var item in sale.items) {
        final product = productController.products.firstWhere(
          (p) => p.id == item.productId,
          orElse: () => productController.products.first,
        );
        productCosts += item.quantity * product.purchasePrice;
      }
    }

    double totalExpenses = milkExpenses + productCosts;
    double grossProfit = totalSales - totalExpenses;
    double profitMargin = totalSales > 0 ? (grossProfit / totalSales) * 100 : 0;

    // Prepare data for charts
    List<FlSpot> profitTrendSpots = [];
    List<BarChartGroupData> categoryBars = [];

    // Generate profit trend data (last 7 days)
    for (int i = 6; i >= 0; i--) {
      final date = DateTime.now().subtract(Duration(days: i));
      final daySales = salesController.sales.where((s) =>
        s.saleDate.year == date.year &&
        s.saleDate.month == date.month &&
        s.saleDate.day == date.day
      ).fold<double>(0, (sum, sale) => sum + sale.totalAmount);
      
      final dayExpenses = milkController.collections.where((c) =>
        c.date.year == date.year &&
        c.date.month == date.month &&
        c.date.day == date.day
      ).fold<double>(0, (sum, coll) => sum + coll.totalAmount);
      
      profitTrendSpots.add(FlSpot((6 - i).toDouble(), daySales - dayExpenses));
    }

    // Generate category comparison bars
    categoryBars = [
      BarChartGroupData(
        x: 0,
        barRods: [
          BarChartRodData(
            toY: totalSales,
            color: Colors.green,
            width: isMobile ? 20 : 30,
          ),
        ],
      ),
      BarChartGroupData(
        x: 1,
        barRods: [
          BarChartRodData(
            toY: totalExpenses,
            color: Colors.red,
            width: isMobile ? 20 : 30,
          ),
        ],
      ),
      BarChartGroupData(
        x: 2,
        barRods: [
          BarChartRodData(
            toY: grossProfit > 0 ? grossProfit : 0,
            color: Colors.blue,
            width: isMobile ? 20 : 30,
          ),
        ],
      ),
    ];

    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? MobileSizes.spaceL : 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Profit & Loss Analysis',
            style: TextStyle(
              fontSize: isMobile ? MobileSizes.screenTitle : 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: isMobile ? MobileSizes.spaceL : 20),

          // Summary Cards
          Wrap(
            spacing: isMobile ? MobileSizes.spaceM : 16,
            runSpacing: isMobile ? MobileSizes.spaceM : 16,
            children: [
              SizedBox(
                width: isMobile ? double.infinity : 200,
                child: _StatCard(
                  icon: Icons.trending_up,
                  label: 'Total Sales',
                  value: '${AppConstants.RUPEE_SYMBOL}${totalSales.toStringAsFixed(2)}',
                  color: Colors.green,
                  isMobile: isMobile,
                ),
              ),
              SizedBox(
                width: isMobile ? double.infinity : 200,
                child: _StatCard(
                  icon: Icons.trending_down,
                  label: 'Total Expenses',
                  value: '${AppConstants.RUPEE_SYMBOL}${totalExpenses.toStringAsFixed(2)}',
                  color: Colors.red,
                  isMobile: isMobile,
                ),
              ),
              SizedBox(
                width: isMobile ? double.infinity : 200,
                child: _StatCard(
                  icon: grossProfit >= 0 ? Icons.check_circle : Icons.warning,
                  label: grossProfit >= 0 ? 'Gross Profit' : 'Gross Loss',
                  value: '${AppConstants.RUPEE_SYMBOL}${grossProfit.abs().toStringAsFixed(2)}',
                  color: grossProfit >= 0 ? Colors.blue : Colors.orange,
                  isMobile: isMobile,
                ),
              ),
              SizedBox(
                width: isMobile ? double.infinity : 200,
                child: _StatCard(
                  icon: Icons.percent,
                  label: 'Profit Margin',
                  value: '${profitMargin.toStringAsFixed(1)}%',
                  color: profitMargin >= 0 ? Colors.teal : Colors.deepOrange,
                  isMobile: isMobile,
                ),
              ),
            ],
          ),

          SizedBox(height: isMobile ? MobileSizes.spaceL : 24),

          // Expense Breakdown
          Card(
            child: Padding(
              padding: EdgeInsets.all(isMobile ? MobileSizes.cardPadding : 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Expense Breakdown',
                    style: TextStyle(
                      fontSize: isMobile ? MobileSizes.sectionTitle : 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: isMobile ? MobileSizes.spaceM : 16),
                  _InfoRow(
                    'Milk Purchases:',
                    '${AppConstants.RUPEE_SYMBOL}${milkExpenses.toStringAsFixed(2)}',
                    isMobile,
                  ),
                  SizedBox(height: isMobile ? MobileSizes.spaceS : 8),
                  _InfoRow(
                    'Product Costs:',
                    '${AppConstants.RUPEE_SYMBOL}${productCosts.toStringAsFixed(2)}',
                    isMobile,
                  ),
                  Divider(height: isMobile ? 20 : 24),
                  _InfoRow(
                    'Total Expenses:',
                    '${AppConstants.RUPEE_SYMBOL}${totalExpenses.toStringAsFixed(2)}',
                    isMobile,
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: isMobile ? MobileSizes.spaceL : 24),

          // Sales vs Expenses Bar Chart
          Card(
            child: Padding(
              padding: EdgeInsets.all(isMobile ? MobileSizes.cardPadding : 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Financial Comparison',
                    style: TextStyle(
                      fontSize: isMobile ? MobileSizes.sectionTitle : 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: isMobile ? MobileSizes.spaceM : 16),
                  SizedBox(
                    height: isMobile ? 200 : 300,
                    child: BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        maxY: (totalSales > totalExpenses ? totalSales : totalExpenses) * 1.2,
                        barTouchData: BarTouchData(enabled: true),
                        titlesData: FlTitlesData(
                          show: true,
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                switch (value.toInt()) {
                                  case 0:
                                    return Text('Sales', style: TextStyle(fontSize: isMobile ? 10 : 12));
                                  case 1:
                                    return Text('Expenses', style: TextStyle(fontSize: isMobile ? 10 : 12));
                                  case 2:
                                    return Text('Profit', style: TextStyle(fontSize: isMobile ? 10 : 12));
                                  default:
                                    return const Text('');
                                }
                              },
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: isMobile ? 40 : 50,
                              getTitlesWidget: (value, meta) {
                                return Text(
                                  '${AppConstants.RUPEE_SYMBOL}${(value / 1000).toStringAsFixed(0)}k',
                                  style: TextStyle(fontSize: isMobile ? 9 : 11),
                                );
                              },
                            ),
                          ),
                          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        ),
                        gridData: FlGridData(show: true),
                        borderData: FlBorderData(show: true),
                        barGroups: categoryBars,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: isMobile ? MobileSizes.spaceL : 24),

          // Profit Trend Line Chart
          Card(
            child: Padding(
              padding: EdgeInsets.all(isMobile ? MobileSizes.cardPadding : 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '7-Day Profit Trend',
                    style: TextStyle(
                      fontSize: isMobile ? MobileSizes.sectionTitle : 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: isMobile ? MobileSizes.spaceM : 16),
                  SizedBox(
                    height: isMobile ? 200 : 300,
                    child: LineChart(
                      LineChartData(
                        gridData: FlGridData(show: true),
                        titlesData: FlTitlesData(
                          show: true,
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 22,
                              getTitlesWidget: (value, meta) {
                                final date = DateTime.now().subtract(Duration(days: 6 - value.toInt()));
                                return Text(
                                  DateFormat('dd/MM').format(date),
                                  style: TextStyle(fontSize: isMobile ? 9 : 11),
                                );
                              },
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: isMobile ? 40 : 50,
                              getTitlesWidget: (value, meta) {
                                return Text(
                                  '${AppConstants.RUPEE_SYMBOL}${(value / 1000).toStringAsFixed(0)}k',
                                  style: TextStyle(fontSize: isMobile ? 9 : 11),
                                );
                              },
                            ),
                          ),
                          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        ),
                        borderData: FlBorderData(show: true),
                        lineBarsData: [
                          LineChartBarData(
                            spots: profitTrendSpots,
                            isCurved: true,
                            color: Colors.blue,
                            barWidth: 3,
                            isStrokeCapRound: true,
                            dotData: FlDotData(show: true),
                            belowBarData: BarAreaData(
                              show: true,
                              color: Colors.blue.withOpacity(0.3),
                            ),
                          ),
                        ],
                        lineTouchData: LineTouchData(enabled: true),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: isMobile ? MobileSizes.spaceL : 24),

          // Key Insights
          Card(
            color: Colors.blue.shade50,
            child: Padding(
              padding: EdgeInsets.all(isMobile ? MobileSizes.cardPadding : 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.lightbulb, color: Colors.blue.shade700),
                      const SizedBox(width: 8),
                      Text(
                        'Key Insights',
                        style: TextStyle(
                          fontSize: isMobile ? MobileSizes.sectionTitle : 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade900,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: isMobile ? MobileSizes.spaceM : 12),
                  if (grossProfit >= 0) ...[
                    _InsightTile(
                      '✓ Your business is profitable with a ${profitMargin.toStringAsFixed(1)}% margin',
                      Colors.green,
                      isMobile,
                    ),
                  ] else ...[
                    _InsightTile(
                      '⚠ Your expenses exceed sales. Review cost management',
                      Colors.orange,
                      isMobile,
                    ),
                  ],
                  const SizedBox(height: 8),
                  _InsightTile(
                    'Milk purchases account for ${((milkExpenses / totalExpenses) * 100).toStringAsFixed(1)}% of total expenses',
                    Colors.blue.shade700,
                    isMobile,
                  ),
                  const SizedBox(height: 8),
                  _InsightTile(
                    'Total sales: ${salesController.sales.length} transactions',
                    Colors.blue.shade700,
                    isMobile,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Insight Tile Widget
class _InsightTile extends StatelessWidget {
  final String text;
  final Color color;
  final bool isMobile;

  const _InsightTile(this.text, this.color, this.isMobile);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.arrow_right, color: color, size: isMobile ? 16 : 18),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: isMobile ? MobileSizes.bodyMedium : 14,
              color: color,
            ),
          ),
        ),
      ],
    );
  }
}

// Reusable Widgets
class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final bool isMobile;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: isMobile ? MobileSizes.cardElevation : 2,
      child: Padding(
        padding: EdgeInsets.all(isMobile ? MobileSizes.cardPadding : 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: isMobile ? MobileSizes.iconLarge : 32,
              color: color,
            ),
            SizedBox(height: isMobile ? MobileSizes.spaceS : 8),
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.center,
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: isMobile ? MobileSizes.bodyLarge : 20,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            SizedBox(height: isMobile ? MobileSizes.spaceXS : 4),
            Text(
              label,
              style: TextStyle(
                fontSize: isMobile ? MobileSizes.caption : 11,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isMobile;

  const _InfoRow(this.label, this.value, this.isMobile);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isMobile ? MobileSizes.bodyMedium : 14,
            color: Colors.grey.shade700,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isMobile ? MobileSizes.bodyMedium : 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
