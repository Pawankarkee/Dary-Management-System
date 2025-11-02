import 'package:flutter/material.dart';
import '../../views/screens/splash_screen.dart';
import '../../views/screens/intro_screen.dart';
import '../../views/screens/auth/login_screen.dart';
import '../../views/screens/auth/register_screen.dart';
import '../../views/layouts/main_layout.dart';
import '../../views/screens/farmers/farmers_screen.dart';
import '../../views/screens/farmers/farmer_detail_screen.dart';
import '../../views/screens/farmers/add_farmer_screen.dart';
import '../../views/screens/milk/milk_collection_screen.dart';
import '../../views/screens/milk/add_milk_collection_screen.dart';
import '../../views/screens/products/products_screen.dart';
import '../../views/screens/products/add_product_screen.dart';
import '../../views/screens/sales/pos_screen_redesigned.dart';
import '../../views/screens/suppliers/suppliers_screen.dart';
import '../../views/screens/suppliers/supplier_detail_screen.dart';
import '../../views/screens/suppliers/add_supplier_screen.dart';
import '../../views/screens/purchases/purchases_screen.dart';
import '../../views/screens/purchases/add_purchase_screen.dart';
import '../../views/screens/purchases/purchase_detail_screen.dart';
import '../../views/screens/expenses/expenses_screen.dart';
import '../../views/screens/expenses/add_expense_screen.dart';
import '../../views/screens/expenses/expense_detail_screen.dart';
import '../../views/screens/staff/staff_screen.dart';
import '../../views/screens/staff/add_staff_screen.dart';
import '../../views/screens/staff/staff_detail_screen.dart';
import '../../models/expense_model.dart';
import '../../models/staff_model.dart';
import '../../models/farmer_model.dart';
import '../../views/screens/processing/processing_batches_screen.dart';
import '../../views/screens/processing/add_processing_batch_screen.dart';
import '../../views/screens/processing/processing_batch_detail_screen.dart';
import '../../views/screens/reports/reports_screen.dart';
import '../../views/screens/settings/settings_screen.dart';
import '../../views/screens/farmer_advance/farmer_advance_screen.dart';
import '../../views/screens/collection_center/collection_center_screen.dart';
import '../../views/screens/snf_fat/snf_fat_testing_screen.dart';
import '../../views/screens/supplier_bills/supplier_bills_screen.dart';
import '../../views/screens/party_ledger/party_ledger_screen.dart';

class AppRouter {
  static const String splash = '/';
  static const String intro = '/intro';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String farmers = '/farmers';
  static const String farmerDetail = '/farmer-detail';
  static const String addFarmer = '/add-farmer';
  static const String farmerAdvance = '/farmer-advance';
  static const String collectionCenter = '/collection-center';
  static const String milkCollection = '/milk-collection';
  static const String milkCollections = '/milk-collections';
  static const String addMilkCollection = '/add-milk-collection';
  static const String snfFatTesting = '/snf-fat-testing';
  static const String products = '/products';
  static const String addProduct = '/add-product';
  static const String pos = '/pos';
  static const String suppliers = '/suppliers';
  static const String supplierDetail = '/supplier-detail';
  static const String addSupplier = '/add-supplier';
  static const String supplierBills = '/supplier-bills';
  static const String purchases = '/purchases';
  static const String purchaseDetail = '/purchase-detail';
  static const String addPurchase = '/add-purchase';
  static const String expenses = '/expenses';
  static const String expenseDetail = '/expense-detail';
  static const String addExpense = '/add-expense';
  static const String staff = '/staff';
  static const String staffDetail = '/staff-detail';
  static const String addStaff = '/add-staff';
  static const String processingBatches = '/processing-batches';
  static const String processingBatchDetail = '/processing-batch-detail';
  static const String addProcessingBatch = '/add-processing-batch';
  static const String partyLedgers = '/party-ledgers';
  static const String reports = '/reports';
  static const String settingsRoute = '/settings';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      
      case intro:
        return MaterialPageRoute(builder: (_) => const IntroScreen());
      
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      
      case register:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());
      
      case home:
        return MaterialPageRoute(builder: (_) => const MainLayout());
      
      case farmers:
        return MaterialPageRoute(builder: (_) => const FarmersScreen());
      
      case farmerAdvance:
        return MaterialPageRoute(builder: (_) => const FarmerAdvanceScreen());
      
      case collectionCenter:
        return MaterialPageRoute(builder: (_) => const CollectionCenterScreen());
      
      case farmerDetail:
        final farmerId = settings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => FarmerDetailScreen(farmerId: farmerId),
        );
      
      case addFarmer:
        final farmer = settings.arguments as dynamic;
        // Accept either a FarmerModel or null
        return MaterialPageRoute(builder: (_) => AddFarmerScreen(farmer: farmer is FarmerModel ? farmer : null));
      
      case milkCollection:
        return MaterialPageRoute(builder: (_) => const MilkCollectionScreen());
      
      case milkCollections:
        return MaterialPageRoute(builder: (_) => const MilkCollectionScreen());
      
      case snfFatTesting:
        return MaterialPageRoute(builder: (_) => const SNFFatTestingScreen());
      
      case addMilkCollection:
        return MaterialPageRoute(builder: (_) => const AddMilkCollectionScreen());
      
      case products:
        return MaterialPageRoute(builder: (_) => const ProductsScreen());
      
      case addProduct:
        return MaterialPageRoute(builder: (_) => const AddProductScreen());
      
      case pos:
        return MaterialPageRoute(builder: (_) => const POSScreenRedesigned());
      
      case suppliers:
        return MaterialPageRoute(builder: (_) => const SuppliersScreen());
      
      case supplierBills:
        return MaterialPageRoute(builder: (_) => const SupplierBillsScreen());
      
      case supplierDetail:
        final supplierId = settings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => SupplierDetailScreen(supplierId: supplierId),
        );
      
      case addSupplier:
        return MaterialPageRoute(builder: (_) => const AddSupplierScreen());
      
      case purchases:
        return MaterialPageRoute(builder: (_) => const PurchasesScreen());
      
      case addPurchase:
        return MaterialPageRoute(builder: (_) => const AddPurchaseScreen());
      
      case purchaseDetail:
        final purchaseId = settings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => PurchaseDetailScreen(purchaseId: purchaseId),
        );
      
      case expenses:
        return MaterialPageRoute(builder: (_) => const ExpensesScreen());
      
      case addExpense:
        final expense = settings.arguments as ExpenseModel?;
        return MaterialPageRoute(
          builder: (_) => AddExpenseScreen(expense: expense),
        );
      
      case expenseDetail:
        final expenseId = settings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => ExpenseDetailScreen(expenseId: expenseId),
        );
      
      case staff:
        return MaterialPageRoute(builder: (_) => const StaffScreen());
      
      case staffDetail:
        final staffId = settings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => StaffDetailScreen(staffId: staffId),
        );
      
      case addStaff:
        final staff = settings.arguments as StaffModel?;
        return MaterialPageRoute(
          builder: (_) => AddStaffScreen(staff: staff),
        );
      
      case processingBatches:
        return MaterialPageRoute(builder: (_) => const ProcessingBatchesScreen());
      
      case processingBatchDetail:
        final batchId = settings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => ProcessingBatchDetailScreen(batchId: batchId),
        );
      
      case addProcessingBatch:
        final batchId = settings.arguments as String?;
        return MaterialPageRoute(
          builder: (_) => AddProcessingBatchScreen(batchId: batchId),
        );
      
      case reports:
        return MaterialPageRoute(builder: (_) => const ReportsScreen());
      
      case partyLedgers:
        return MaterialPageRoute(builder: (_) => const PartyLedgerScreen());
      
      case settingsRoute:
        return MaterialPageRoute(builder: (_) => const SettingsScreen());
      
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}
