import 'package:flutter/material.dart';
import '../services/backup_service.dart';

enum BackupStatus {
  idle,
  creating,
  restoring,
  success,
  error,
}

class BackupController extends ChangeNotifier {
  final BackupService _backupService = BackupService();

  BackupStatus _status = BackupStatus.idle;
  String? _message;
  String? _lastBackupPath;
  List<Map<String, dynamic>> _backupList = [];
  Map<String, dynamic> _backupStats = {};

  BackupStatus get status => _status;
  String? get message => _message;
  String? get lastBackupPath => _lastBackupPath;
  List<Map<String, dynamic>> get backupList => _backupList;
  Map<String, dynamic> get backupStats => _backupStats;

  BackupController() {
    _init();
  }

  Future<void> _init() async {
    await loadBackupList();
    await loadBackupStats();
  }

  /// Create full backup
  Future<bool> createBackup() async {
    try {
      _status = BackupStatus.creating;
      _message = 'Creating backup...';
      notifyListeners();

      final backupPath = await _backupService.createFullBackup();

      _lastBackupPath = backupPath;
      _status = BackupStatus.success;
      _message = 'Backup created successfully!';

      // Refresh backup list
      await loadBackupList();
      await loadBackupStats();

      notifyListeners();
      return true;
    } catch (e) {
      _status = BackupStatus.error;
      _message = 'Error creating backup: $e';
      notifyListeners();
      return false;
    }
  }

  /// Restore from backup
  Future<bool> restoreBackup(String backupFilePath) async {
    try {
      _status = BackupStatus.restoring;
      _message = 'Restoring from backup...';
      notifyListeners();

      final success = await _backupService.restoreFromBackup(backupFilePath);

      if (success) {
        _status = BackupStatus.success;
        _message = 'Backup restored successfully!';
      } else {
        _status = BackupStatus.error;
        _message = 'Failed to restore backup';
      }

      notifyListeners();
      return success;
    } catch (e) {
      _status = BackupStatus.error;
      _message = 'Error restoring backup: $e';
      notifyListeners();
      return false;
    }
  }

  /// Load backup list
  Future<void> loadBackupList() async {
    try {
      _backupList = await _backupService.listBackups();
      notifyListeners();
    } catch (e) {
      print('Error loading backup list: $e');
    }
  }

  /// Load backup statistics
  Future<void> loadBackupStats() async {
    try {
      _backupStats = await _backupService.getBackupStats();
      notifyListeners();
    } catch (e) {
      print('Error loading backup stats: $e');
    }
  }

  /// Delete backup
  Future<bool> deleteBackup(String backupFilePath) async {
    try {
      final success = await _backupService.deleteBackup(backupFilePath);
      if (success) {
        await loadBackupList();
        await loadBackupStats();
      }
      return success;
    } catch (e) {
      print('Error deleting backup: $e');
      return false;
    }
  }

  /// Delete old backups
  Future<int> deleteOldBackups({int keepLast = 10}) async {
    try {
      final count = await _backupService.deleteOldBackups(keepLast: keepLast);
      await loadBackupList();
      await loadBackupStats();
      return count;
    } catch (e) {
      print('Error deleting old backups: $e');
      return 0;
    }
  }

  /// Create daily backup
  Future<bool> createDailyBackup() async {
    try {
      _status = BackupStatus.creating;
      _message = 'Creating daily backup...';
      notifyListeners();

      final backupPath = await _backupService.createDailyBackup();

      if (backupPath != null) {
        _lastBackupPath = backupPath;
        _status = BackupStatus.success;
        _message = 'Daily backup created!';

        await loadBackupList();
        await loadBackupStats();

        notifyListeners();
        return true;
      } else {
        _status = BackupStatus.idle;
        _message = 'Daily backup already exists';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _status = BackupStatus.error;
      _message = 'Error creating daily backup: $e';
      notifyListeners();
      return false;
    }
  }

  /// Export backup to custom location
  Future<String?> exportBackup(String destinationPath) async {
    try {
      _status = BackupStatus.creating;
      _message = 'Exporting backup...';
      notifyListeners();

      final exportedPath = await _backupService.exportBackup(destinationPath);

      if (exportedPath != null) {
        _status = BackupStatus.success;
        _message = 'Backup exported successfully!';
      } else {
        _status = BackupStatus.error;
        _message = 'Failed to export backup';
      }

      notifyListeners();
      return exportedPath;
    } catch (e) {
      _status = BackupStatus.error;
      _message = 'Error exporting backup: $e';
      notifyListeners();
      return null;
    }
  }

  /// Reset status
  void resetStatus() {
    _status = BackupStatus.idle;
    _message = null;
    notifyListeners();
  }

  /// Get backup directory path
  Future<String> getBackupDirectory() async {
    final dir = await _backupService.getBackupDirectory();
    return dir.path;
  }
}
