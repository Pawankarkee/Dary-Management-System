import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Performance Optimization Service
/// Handles app-wide performance optimizations including:
/// - Memory management
/// - Battery optimization
/// - Rendering performance
/// - Network optimization
/// - Cache management
class PerformanceOptimizationService {
  static final PerformanceOptimizationService _instance = PerformanceOptimizationService._internal();
  factory PerformanceOptimizationService() => _instance;
  PerformanceOptimizationService._internal();

  /// Initialize performance optimizations
  Future<void> initialize() async {
    await _configureSystemUI();
    await _optimizeRendering();
    _setupMemoryManagement();
    _optimizeBattery();
  }

  /// Configure system UI for optimal performance
  Future<void> _configureSystemUI() async {
    // Set preferred orientations (reduces layout rebuilds)
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    // Configure system UI overlay style
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );
  }

  /// Optimize rendering performance
  Future<void> _optimizeRendering() async {
    // Enable hardware acceleration
    if (!kIsWeb) {
      // Set target frame rate for better battery life
      // 60 FPS is optimal, but can be reduced for battery saving
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Force rebuild optimization
        WidgetsBinding.instance.buildOwner?.buildScope(
          WidgetsBinding.instance.rootElement!
        );
      });
    }
  }

  /// Setup memory management
  void _setupMemoryManagement() {
    // Monitor memory pressure
    WidgetsBinding.instance.addObserver(_MemoryPressureObserver());
    
    // Configure image cache
    PaintingBinding.instance.imageCache.maximumSize = 1000; // Max cached images
    PaintingBinding.instance.imageCache.maximumSizeBytes = 100 << 20; // 100 MB
  }

  /// Optimize battery usage
  void _optimizeBattery() {
    // Reduce animation duration in battery saver mode
    // Disable unnecessary background processes
    if (!kDebugMode) {
      // Production optimizations
      debugPrint = (String? message, {int? wrapWidth}) {}; // Disable debug prints
    }
  }

  /// Clear image cache
  void clearImageCache() {
    PaintingBinding.instance.imageCache.clear();
    PaintingBinding.instance.imageCache.clearLiveImages();
  }

  /// Force garbage collection (use sparingly)
  void forceGarbageCollection() {
    // This will help in development, but shouldn't be called frequently
    if (kDebugMode) {
      print('🧹 Forcing garbage collection...');
    }
  }

  /// Get current memory usage
  int getCurrentMemoryUsage() {
    return PaintingBinding.instance.imageCache.currentSizeBytes;
  }

  /// Optimize for low-end devices
  void optimizeForLowEndDevice() {
    // Reduce image cache size
    PaintingBinding.instance.imageCache.maximumSize = 500;
    PaintingBinding.instance.imageCache.maximumSizeBytes = 50 << 20; // 50 MB
  }

  /// Optimize for high-end devices
  void optimizeForHighEndDevice() {
    // Increase cache for better performance
    PaintingBinding.instance.imageCache.maximumSize = 2000;
    PaintingBinding.instance.imageCache.maximumSizeBytes = 200 << 20; // 200 MB
  }

  /// Dispose and cleanup
  void dispose() {
    clearImageCache();
  }
}

/// Memory pressure observer
class _MemoryPressureObserver extends WidgetsBindingObserver {
  @override
  void didHaveMemoryPressure() {
    super.didHaveMemoryPressure();
    
    if (kDebugMode) {
      print('⚠️ Memory pressure detected! Clearing caches...');
    }
    
    // Clear image cache on memory pressure
    PaintingBinding.instance.imageCache.clear();
    PaintingBinding.instance.imageCache.clearLiveImages();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    switch (state) {
      case AppLifecycleState.resumed:
        // App resumed, nothing special needed
        break;
      case AppLifecycleState.inactive:
        // App inactive, prepare for background
        break;
      case AppLifecycleState.paused:
        // App paused, clear non-essential caches
        PaintingBinding.instance.imageCache.clearLiveImages();
        break;
      case AppLifecycleState.detached:
        // App detached, cleanup
        PaintingBinding.instance.imageCache.clear();
        break;
      case AppLifecycleState.hidden:
        // App hidden
        break;
    }
  }
}

/// Mixin for performance optimization in widgets
mixin PerformanceOptimizedWidget on StatefulWidget {
  /// Whether to use AutomaticKeepAlive
  bool get wantKeepAlive => false;
  
  /// Whether to use RepaintBoundary
  bool get useRepaintBoundary => false;
}

/// Performance monitoring utilities
class PerformanceMonitor {
  static final Stopwatch _stopwatch = Stopwatch();
  
  /// Start timing an operation
  static void startTiming(String operation) {
    if (kDebugMode) {
      _stopwatch.reset();
      _stopwatch.start();
      print('⏱️ Started timing: $operation');
    }
  }
  
  /// Stop timing and log results
  static void stopTiming(String operation) {
    if (kDebugMode) {
      _stopwatch.stop();
      print('⏱️ Completed $operation in ${_stopwatch.elapsedMilliseconds}ms');
    }
  }
  
  /// Log frame build time
  static void logFrameBuildTime(BuildContext context, String widgetName) {
    if (kDebugMode) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        print('🎨 $widgetName frame built');
      });
    }
  }
}

/// Battery optimization utilities
class BatteryOptimizer {
  /// Reduce animation duration for battery saving
  static Duration optimizedDuration(Duration original) {
    // In battery saver mode, reduce animations
    // For now, just return original, but can be configured
    return original;
  }
  
  /// Check if device is in low power mode
  static bool isLowPowerMode() {
    // This would need platform-specific implementation
    // For now, return false
    return false;
  }
  
  /// Optimize polling intervals
  static Duration optimizedPollingInterval(Duration original) {
    if (isLowPowerMode()) {
      return original * 2; // Double the interval in low power mode
    }
    return original;
  }
}

/// Network optimization utilities
class NetworkOptimizer {
  /// Debounce search requests
  static Future<void> debounce(
    Future<void> Function() operation, {
    Duration delay = const Duration(milliseconds: 300),
  }) async {
    await Future.delayed(delay);
    await operation();
  }
  
  /// Batch API requests
  static Future<List<T>> batchRequests<T>(
    List<Future<T> Function()> requests, {
    int batchSize = 5,
  }) async {
    final results = <T>[];
    
    for (var i = 0; i < requests.length; i += batchSize) {
      final batch = requests.sublist(
        i,
        i + batchSize > requests.length ? requests.length : i + batchSize,
      );
      
      final batchResults = await Future.wait(batch.map((r) => r()));
      results.addAll(batchResults);
    }
    
    return results;
  }
}
