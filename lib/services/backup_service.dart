import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import 'hive_service.dart';

/// BackupService - Handles data backup and restore operations
/// 
/// Features:
/// - Automatic backup to databackup folder
/// - Export all Hive boxes data
/// - JSON format for easy reading
/// - Timestamped backup files
/// - Restore from backup
/// - Backup history management
class BackupService {
  static const String _backupFolderName = 'databackup';

  // Singleton pattern
  static final BackupService _instance = BackupService._internal();
  factory BackupService() => _instance;
  BackupService._internal();

  /// Get backup directory path
  Future<Directory> getBackupDirectory() async {
    // For mobile/desktop apps
    final Directory appDocDir = await getApplicationDocumentsDirectory();
    final Directory backupDir = Directory('${appDocDir.path}/$_backupFolderName');

    // Create directory if it doesn't exist
    if (!await backupDir.exists()) {
      await backupDir.create(recursive: true);
      print('✅ Backup directory created: ${backupDir.path}');
    }

    return backupDir;
  }

  /// Create full backup of all data
  Future<String> createFullBackup() async {
    try {
      print('🔄 Starting full backup...');

      final backupDir = await getBackupDirectory();
      final timestamp = DateFormat('yyyy-MM-dd_HH-mm-ss').format(DateTime.now());
      final backupFileName = 'dairify_backup_$timestamp.json';
      final backupFile = File('${backupDir.path}/$backupFileName');

      // Collect all data from Hive boxes
      final Map<String, dynamic> backupData = {
        'backup_info': {
          'app_name': 'Dairify',
          'backup_date': DateTime.now().toIso8601String(),
          'version': '1.0.0',
          'timestamp': timestamp,
        },
        'farmers': await _getAllBoxData(HiveService.farmersBox),
        'milk_collections': await _getAllBoxData(HiveService.milkCollectionsBox),
        'transactions': await _getAllBoxData(HiveService.transactionsBox),
        'products': await _getAllBoxData(HiveService.productsBox),
        'sales': await _getAllBoxData(HiveService.salesBox),
        'sync_queue': await _getAllBoxData(HiveService.syncQueueBox),
        'settings': await _getAllBoxData(HiveService.settingsBox),
        'rate_charts': await _getAllBoxData(HiveService.rateChartsBox),
        'users': await _getAllBoxData(HiveService.userBox),
      };

      // Count total records
      int totalRecords = 0;
      backupData.forEach((key, value) {
        if (key != 'backup_info' && value is Map) {
          totalRecords += value.length;
        }
      });

      backupData['backup_info']['total_records'] = totalRecords;

      // Write to file
      final jsonString = JsonEncoder.withIndent('  ').convert(backupData);
      await backupFile.writeAsString(jsonString);

      final fileSizeKB = (await backupFile.length()) / 1024;

      print('✅ Backup created successfully!');
      print('📁 File: $backupFileName');
      print('📊 Total records: $totalRecords');
      print('💾 Size: ${fileSizeKB.toStringAsFixed(2)} KB');
      print('📍 Location: ${backupFile.path}');

      return backupFile.path;
    } catch (e) {
      print('❌ Error creating backup: $e');
      rethrow;
    }
  }

  /// Get all data from a Hive box
  Future<Map<String, dynamic>> _getAllBoxData(String boxName) async {
    try {
      final box = await _getBox(boxName);
      final Map<String, dynamic> data = {};

      for (var key in box.keys) {
        final value = box.get(key);
        if (value != null) {
          // Convert to JSON-serializable format
          if (value is Map) {
            data[key.toString()] = Map<String, dynamic>.from(value);
          } else {
            data[key.toString()] = value;
          }
        }
      }

      return data;
    } catch (e) {
      print('⚠️ Error reading box $boxName: $e');
      return {};
    }
  }

  /// Get Hive box by name
  Future<dynamic> _getBox(String boxName) async {
    switch (boxName) {
      case 'farmers':
        return await HiveService.getFarmersBox();
      case 'milk_collections':
        return await HiveService.getMilkCollectionsBox();
      case 'transactions':
        return await HiveService.getTransactionsBox();
      case 'products':
        return await HiveService.getProductsBox();
      case 'sales':
        return await HiveService.getSalesBox();
      case 'sync_queue':
        return await HiveService.getSyncQueueBox();
      case 'settings':
        return await HiveService.getSettingsBox();
      case 'rate_charts':
        return await HiveService.getRateChartsBox();
      case 'user':
        return await HiveService.getUserBox();
      default:
        throw Exception('Unknown box: $boxName');
    }
  }

  /// Restore data from backup file
  Future<bool> restoreFromBackup(String backupFilePath) async {
    try {
      print('🔄 Starting restore from: $backupFilePath');

      final backupFile = File(backupFilePath);
      if (!await backupFile.exists()) {
        print('❌ Backup file not found');
        return false;
      }

      // Read backup file
      final jsonString = await backupFile.readAsString();
      final Map<String, dynamic> backupData = json.decode(jsonString);

      // Validate backup
      if (!backupData.containsKey('backup_info')) {
        print('❌ Invalid backup file format');
        return false;
      }

      print('📋 Backup info:');
      print('   Date: ${backupData['backup_info']['backup_date']}');
      print('   Records: ${backupData['backup_info']['total_records']}');

      // Restore each box
      int restoredCount = 0;

      for (var boxName in [
        'farmers',
        'milk_collections',
        'transactions',
        'products',
        'sales',
        'sync_queue',
        'settings',
        'rate_charts',
        'users',
      ]) {
        if (backupData.containsKey(boxName)) {
          final boxData = backupData[boxName] as Map<String, dynamic>;
          final count = await _restoreBoxData(boxName, boxData);
          restoredCount += count;
          print('✅ Restored $count records to $boxName');
        }
      }

      print('✅ Restore completed! Total records: $restoredCount');
      return true;
    } catch (e) {
      print('❌ Error restoring backup: $e');
      return false;
    }
  }

  /// Restore data to a specific box
  Future<int> _restoreBoxData(String boxName, Map<String, dynamic> data) async {
    try {
      final box = await _getBox(boxName);
      int count = 0;

      for (var entry in data.entries) {
        await box.put(entry.key, entry.value);
        count++;
      }

      return count;
    } catch (e) {
      print('⚠️ Error restoring box $boxName: $e');
      return 0;
    }
  }

  /// List all backup files
  Future<List<Map<String, dynamic>>> listBackups() async {
    try {
      final backupDir = await getBackupDirectory();
      final List<Map<String, dynamic>> backups = [];

      if (!await backupDir.exists()) {
        return backups;
      }

      final files = backupDir.listSync();
      for (var file in files) {
        if (file is File && file.path.endsWith('.json')) {
          final stat = await file.stat();
          final fileName = file.path.split('/').last;

          // Try to read backup info
          Map<String, dynamic>? backupInfo;
          try {
            final content = await file.readAsString();
            final data = json.decode(content);
            backupInfo = data['backup_info'];
          } catch (e) {
            // Ignore read errors
          }

          backups.add({
            'file_name': fileName,
            'file_path': file.path,
            'size_kb': (stat.size / 1024).toStringAsFixed(2),
            'created': stat.modified.toIso8601String(),
            'backup_info': backupInfo,
          });
        }
      }

      // Sort by date (newest first)
      backups.sort((a, b) => b['created'].compareTo(a['created']));

      return backups;
    } catch (e) {
      print('❌ Error listing backups: $e');
      return [];
    }
  }

  /// Delete old backups (keep last N backups)
  Future<int> deleteOldBackups({int keepLast = 10}) async {
    try {
      final backups = await listBackups();
      if (backups.length <= keepLast) {
        print('ℹ️ No old backups to delete');
        return 0;
      }

      int deletedCount = 0;
      final toDelete = backups.skip(keepLast);

      for (var backup in toDelete) {
        final file = File(backup['file_path']);
        if (await file.exists()) {
          await file.delete();
          deletedCount++;
          print('🗑️ Deleted: ${backup['file_name']}');
        }
      }

      print('✅ Deleted $deletedCount old backup(s)');
      return deletedCount;
    } catch (e) {
      print('❌ Error deleting old backups: $e');
      return 0;
    }
  }

  /// Delete specific backup file
  Future<bool> deleteBackup(String backupFilePath) async {
    try {
      final file = File(backupFilePath);
      if (await file.exists()) {
        await file.delete();
        print('✅ Backup deleted: ${file.path.split('/').last}');
        return true;
      }
      return false;
    } catch (e) {
      print('❌ Error deleting backup: $e');
      return false;
    }
  }

  /// Create automatic daily backup
  Future<String?> createDailyBackup() async {
    try {
      final backups = await listBackups();
      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

      // Check if backup already exists for today
      final todayBackup = backups.where((b) => b['file_name'].contains(today));
      if (todayBackup.isNotEmpty) {
        print('ℹ️ Daily backup already exists for today');
        return todayBackup.first['file_path'];
      }

      // Create new backup
      return await createFullBackup();
    } catch (e) {
      print('❌ Error creating daily backup: $e');
      return null;
    }
  }

  /// Export backup to custom location
  Future<String?> exportBackup(String destinationPath) async {
    try {
      // Create temporary backup
      final backupPath = await createFullBackup();

      // Copy to destination
      final sourceFile = File(backupPath);
      final fileName = sourceFile.path.split('/').last;
      final destFile = File('$destinationPath/$fileName');

      await sourceFile.copy(destFile.path);

      print('✅ Backup exported to: ${destFile.path}');
      return destFile.path;
    } catch (e) {
      print('❌ Error exporting backup: $e');
      return null;
    }
  }

  /// Get backup statistics
  Future<Map<String, dynamic>> getBackupStats() async {
    try {
      final backups = await listBackups();
      final backupDir = await getBackupDirectory();

      int totalSize = 0;
      for (var backup in backups) {
        final sizeKB = double.parse(backup['size_kb']);
        totalSize += (sizeKB * 1024).toInt();
      }

      return {
        'total_backups': backups.length,
        'total_size_mb': (totalSize / (1024 * 1024)).toStringAsFixed(2),
        'backup_directory': backupDir.path,
        'latest_backup': backups.isNotEmpty ? backups.first : null,
        'oldest_backup': backups.isNotEmpty ? backups.last : null,
      };
    } catch (e) {
      print('❌ Error getting backup stats: $e');
      return {};
    }
  }
}
