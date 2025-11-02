import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'config/theme/app_theme.dart';
import 'config/routes/app_router.dart';
import 'controllers/theme_controller.dart';
import 'controllers/auth_controller.dart';
import 'controllers/farmer_controller.dart';
import 'controllers/milk_controller.dart';
import 'controllers/transaction_controller.dart';
import 'controllers/product_controller.dart';
import 'controllers/sales_controller.dart';
import 'controllers/supplier_controller.dart';
import 'controllers/purchase_controller.dart';
import 'controllers/expense_controller.dart';
import 'controllers/staff_controller.dart';
import 'controllers/processing_controller.dart';
import 'controllers/sync_controller.dart';
import 'controllers/backup_controller.dart';
import 'controllers/farmer_advance_controller.dart';
import 'controllers/collection_center_controller.dart';
import 'controllers/quality_test_controller.dart';
import 'services/hive_service.dart';
import 'services/performance_service.dart';
import 'services/security_service.dart';
import 'views/screens/splash_screen.dart';

void main() async {
  // Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  // ==================== PERFORMANCE OPTIMIZATIONS ====================
  
  // Set preferred orientations (portrait only for mobile optimization)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Configure system UI for optimal performance
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  // Disable debug banner in production
  if (kReleaseMode) {
    debugPrint = (String? message, {int? wrapWidth}) {};
  }

  // ==================== INITIALIZE SERVICES ====================
  
  // Initialize Hive database
  await Hive.initFlutter();
  await HiveService.init();
  
  // Initialize performance optimization service
  await PerformanceOptimizationService().initialize();
  
  // Initialize security service
  await SecurityService().initialize();

  // ==================== ERROR HANDLING ====================
  
  // Catch Flutter framework errors
  FlutterError.onError = (FlutterErrorDetails details) {
    if (kDebugMode) {
      FlutterError.dumpErrorToConsole(details);
    } else {
      // In production, log to crash reporting service
      print('Flutter Error: ${details.exception}');
    }
  };

  // Catch async errors
  PlatformDispatcher.instance.onError = (error, stack) {
    if (kDebugMode) {
      print('Async Error: $error\n$stack');
    }
    return true;
  };

  runApp(const DairifyApp());
}

class DairifyApp extends StatelessWidget {
  const DairifyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeController()),
        ChangeNotifierProvider(create: (_) => AuthController()),
        ChangeNotifierProvider(create: (_) => FarmerController()),
        ChangeNotifierProvider(create: (_) => MilkController()),
        ChangeNotifierProvider(create: (_) => TransactionController()),
        ChangeNotifierProvider(create: (_) => ProductController()),
        ChangeNotifierProvider(create: (_) => SalesController()),
        ChangeNotifierProvider(create: (_) => SupplierController()),
        ChangeNotifierProvider(create: (_) => PurchaseController()),
        ChangeNotifierProvider(create: (_) => ExpenseController()),
        ChangeNotifierProvider(create: (_) => StaffController()),
        ChangeNotifierProvider(create: (_) => ProcessingController()),
        ChangeNotifierProvider(create: (_) => SyncController()),
        ChangeNotifierProvider(create: (_) => BackupController()),
        // New controllers for additional modules
        ChangeNotifierProvider(create: (_) => FarmerAdvanceController()),
        ChangeNotifierProvider(create: (_) => CollectionCenterController()),
        ChangeNotifierProvider(create: (_) => QualityTestController()),
      ],
      child: Consumer<ThemeController>(
        builder: (context, themeController, _) {
          return MaterialApp(
            title: 'Dairify - Dairy Management',
            debugShowCheckedModeBanner: false,
            
            // ==================== THEME CONFIGURATION ====================
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeController.themeMode,
            
            // ==================== PERFORMANCE SETTINGS ====================
            
            // Show performance overlay in debug mode (disable in production)
            showPerformanceOverlay: false,
            
            // Disable semantics debugger in production
            showSemanticsDebugger: false,
            
            // Enable checkerboard layers to identify expensive rendering
            checkerboardRasterCacheImages: kDebugMode && false,
            checkerboardOffscreenLayers: kDebugMode && false,
            
            // ==================== NAVIGATION ====================
            onGenerateRoute: AppRouter.generateRoute,
            
            // Use hero animations
            builder: (context, child) {
              // Add error handling and performance optimizations
              return MediaQuery(
                // Ensure text scale factor is constrained for consistency
                data: MediaQuery.of(context).copyWith(
                  textScaleFactor: MediaQuery.of(context).textScaleFactor.clamp(0.8, 1.2),
                ),
                child: child!,
              );
            },
            
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}
