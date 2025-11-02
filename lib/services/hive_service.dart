import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

class HiveService {
  static const String farmersBox = 'farmers';
  static const String milkCollectionsBox = 'milk_collections';
  static const String transactionsBox = 'transactions';
  static const String productsBox = 'products';
  static const String salesBox = 'sales';
  static const String suppliersBox = 'suppliers';
  static const String purchasesBox = 'purchases';
  static const String expensesBox = 'expenses';
  static const String staffBox = 'staff';
  static const String processingBatchesBox = 'processing_batches';
  static const String syncQueueBox = 'sync_queue';
  static const String settingsBox = 'settings';
  static const String rateChartsBox = 'rate_charts';
  static const String userBox = 'user';

  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  static const String _encryptionKeyName = 'hive_encryption_key';

  /// Get or generate encryption key for Hive boxes
  static Future<List<int>> _getEncryptionKey() async {
    try {
      // Try to read existing key
      final keyString = await _secureStorage.read(key: _encryptionKeyName);
      
      if (keyString != null) {
        return base64Url.decode(keyString);
      }

      // Generate new key (256-bit for AES)
      final key = Hive.generateSecureKey();
      
      // Store key securely
      await _secureStorage.write(
        key: _encryptionKeyName,
        value: base64Url.encode(key),
      );
      
      return key;
    } catch (e) {
      print('❌ Error getting encryption key: $e');
      rethrow;
    }
  }

  static Future<void> init() async {
    try {
      // Get encryption key for sensitive boxes
      final encryptionKey = await _getEncryptionKey();

      // Open all boxes
      // User box is encrypted for security
      await Future.wait([
        Hive.openBox(farmersBox),
        Hive.openBox(milkCollectionsBox),
        Hive.openBox(transactionsBox),
        Hive.openBox(productsBox),
        Hive.openBox(salesBox),
        Hive.openBox(suppliersBox),
        Hive.openBox(purchasesBox),
        Hive.openBox(expensesBox),
        Hive.openBox(staffBox),
        Hive.openBox(processingBatchesBox),
        Hive.openBox(syncQueueBox),
        Hive.openBox(settingsBox),
        Hive.openBox(rateChartsBox),
        Hive.openBox(
          userBox,
          encryptionCipher: HiveAesCipher(encryptionKey),
        ),
      ]);
      
      print('✅ Hive initialized successfully (with encryption)');
    } catch (e) {
      print('❌ Error initializing Hive: $e');
      rethrow;
    }
  }

  /// Get encrypted user box
  static Future<Box> getUserBox() async {
    if (!Hive.isBoxOpen(userBox)) {
      final encryptionKey = await _getEncryptionKey();
      return await Hive.openBox(
        userBox,
        encryptionCipher: HiveAesCipher(encryptionKey),
      );
    }
    return Hive.box(userBox);
  }

  static Future<Box> getFarmersBox() async {
    return await Hive.openBox(farmersBox);
  }

  static Future<Box> getMilkCollectionsBox() async {
    return await Hive.openBox(milkCollectionsBox);
  }

  static Future<Box> getTransactionsBox() async {
    return await Hive.openBox(transactionsBox);
  }

  static Future<Box> getProductsBox() async {
    return await Hive.openBox(productsBox);
  }

  static Future<Box> getSalesBox() async {
    return await Hive.openBox(salesBox);
  }

  static Future<Box> getSuppliersBox() async {
    return await Hive.openBox(suppliersBox);
  }

  static Future<Box> getPurchasesBox() async {
    return await Hive.openBox(purchasesBox);
  }

  static Future<Box> getExpensesBox() async {
    return await Hive.openBox(expensesBox);
  }

  static Future<Box> getStaffBox() async {
    return await Hive.openBox(staffBox);
  }

  static Future<Box> getProcessingBatchesBox() async {
    return await Hive.openBox(processingBatchesBox);
  }

  static Future<Box> getSyncQueueBox() async {
    return await Hive.openBox(syncQueueBox);
  }

  static Future<Box> getSettingsBox() async {
    return await Hive.openBox(settingsBox);
  }

  static Future<Box> getRateChartsBox() async {
    return await Hive.openBox(rateChartsBox);
  }

  // Remove duplicate getUserBox - already defined above with encryption

  // Clear all data (with encryption support)
  static Future<void> clearAllData() async {
    try {
      await Hive.deleteBoxFromDisk(farmersBox);
      await Hive.deleteBoxFromDisk(milkCollectionsBox);
      await Hive.deleteBoxFromDisk(transactionsBox);
      await Hive.deleteBoxFromDisk(productsBox);
      await Hive.deleteBoxFromDisk(salesBox);
      await Hive.deleteBoxFromDisk(suppliersBox);
      await Hive.deleteBoxFromDisk(purchasesBox);
      await Hive.deleteBoxFromDisk(expensesBox);
      await Hive.deleteBoxFromDisk(staffBox);
      await Hive.deleteBoxFromDisk(processingBatchesBox);
      await Hive.deleteBoxFromDisk(syncQueueBox);
      await Hive.deleteBoxFromDisk(rateChartsBox);
      
      // Note: userBox is encrypted, keep encryption key when reinitializing
      await Hive.deleteBoxFromDisk(userBox);
      
      // Reinitialize boxes
      await init();
      
      print('✅ All data cleared successfully');
    } catch (e) {
      print('❌ Error clearing data: $e');
      rethrow;
    }
  }

  /// Clear encryption key (WARNING: This will make all encrypted data inaccessible)
  static Future<void> clearEncryptionKey() async {
    try {
      await _secureStorage.delete(key: _encryptionKeyName);
      print('⚠️ Encryption key cleared');
    } catch (e) {
      print('❌ Error clearing encryption key: $e');
      rethrow;
    }
  }

  /// Get box info for debugging
  static Future<Map<String, dynamic>> getBoxInfo() async {
    return {
      'farmers': (await getFarmersBox()).length,
      'milk_collections': (await getMilkCollectionsBox()).length,
      'transactions': (await getTransactionsBox()).length,
      'products': (await getProductsBox()).length,
      'sales': (await getSalesBox()).length,
      'suppliers': (await getSuppliersBox()).length,
      'purchases': (await getPurchasesBox()).length,
      'expenses': (await getExpensesBox()).length,
      'staff': (await getStaffBox()).length,
      'processing_batches': (await getProcessingBatchesBox()).length,
      'sync_queue': (await getSyncQueueBox()).length,
      'settings': (await getSettingsBox()).length,
      'rate_charts': (await getRateChartsBox()).length,
      'users': (await getUserBox()).length,
    };
  }
}
