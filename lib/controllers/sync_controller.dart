import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:hive/hive.dart';

import '../services/hive_service.dart';
import '../services/mock_server_service.dart';

enum SyncStatus {
  idle,
  syncing,
  success,
  error,
}

class SyncController extends ChangeNotifier {
  SyncStatus _syncStatus = SyncStatus.idle;
  DateTime? _lastSyncTime;
  int _pendingSyncCount = 0;
  String? _errorMessage;
  bool _isOnline = false;

  SyncStatus get syncStatus => _syncStatus;
  DateTime? get lastSyncTime => _lastSyncTime;
  int get pendingSyncCount => _pendingSyncCount;
  String? get errorMessage => _errorMessage;
  bool get isOnline => _isOnline;

  final Dio _dio = Dio();
  final Connectivity _connectivity = Connectivity();
  // Use mock server when a real API is not configured
  final bool _useMockServer = true;

  SyncController() {
    _init();
  }

  Future<void> _init() async {
    await _checkConnectivity();
    await _loadPendingSyncCount();
    _listenToConnectivity();
  }

  // Check connectivity
  Future<void> _checkConnectivity() async {
    final result = await _connectivity.checkConnectivity();
    _isOnline = result != ConnectivityResult.none;
    notifyListeners();
  }

  // Listen to connectivity changes
  void _listenToConnectivity() {
    _connectivity.onConnectivityChanged.listen((result) {
      final wasOnline = _isOnline;
      _isOnline = result != ConnectivityResult.none;
      notifyListeners();

      // Auto-sync when coming back online
      if (!wasOnline && _isOnline && _pendingSyncCount > 0) {
        syncNow();
      }
    });
  }

  // Load pending sync count
  Future<void> _loadPendingSyncCount() async {
    try {
      final syncBox = await HiveService.getSyncQueueBox();
      _pendingSyncCount = syncBox.length;
      notifyListeners();
    } catch (e) {
      print('Error loading pending sync count: $e');
    }
  }

  // Sync now
  Future<bool> syncNow() async {
    if (!_isOnline) {
      _errorMessage = 'No internet connection';
      _syncStatus = SyncStatus.error;
      notifyListeners();
      return false;
    }

    if (_syncStatus == SyncStatus.syncing) {
      return false; // Already syncing
    }

    _syncStatus = SyncStatus.syncing;
    _errorMessage = null;
    notifyListeners();

    try {
      final syncBox = await HiveService.getSyncQueueBox();
      final items = syncBox.values.toList();

      if (items.isEmpty) {
        _syncStatus = SyncStatus.success;
        _lastSyncTime = DateTime.now();
        notifyListeners();
        return true;
      }

      // Sync each item
      for (var item in items) {
        final data = Map<String, dynamic>.from(item);
        await _syncItem(data);
        
        // Remove from queue after successful sync
        await syncBox.delete(data['id']);
      }

      _syncStatus = SyncStatus.success;
      _lastSyncTime = DateTime.now();
      _pendingSyncCount = 0;
      notifyListeners();

      return true;
    } catch (e) {
      _syncStatus = SyncStatus.error;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Sync individual item
  Future<void> _syncItem(Map<String, dynamic> data) async {
    final type = data['type'];
    final action = data['action'];
    final referenceId = data['referenceId'];

    String endpoint = '';
    Map<String, dynamic>? payload;

    // Determine endpoint and payload based on type and action
    switch (type) {
      case 'farmer':
        endpoint = '/api/farmers';
        if (action == 'create' || action == 'update') {
          final farmersBox = await HiveService.getFarmersBox();
          payload = Map<String, dynamic>.from(farmersBox.get(referenceId));
        }
        break;
      case 'milk_collection':
        endpoint = '/api/milk-collections';
        if (action == 'create') {
          final collectionsBox = await HiveService.getMilkCollectionsBox();
          payload = Map<String, dynamic>.from(collectionsBox.get(referenceId));
        }
        break;
      case 'transaction':
        endpoint = '/api/transactions';
        if (action == 'create') {
          final transactionsBox = await HiveService.getTransactionsBox();
          payload = Map<String, dynamic>.from(transactionsBox.get(referenceId));
        }
        break;
      case 'product':
        endpoint = '/api/products';
        if (action == 'create' || action == 'update') {
          final productsBox = await HiveService.getProductsBox();
          payload = Map<String, dynamic>.from(productsBox.get(referenceId));
        }
        break;
    }

    // Make API call or use mock server
    if (_useMockServer) {
      // For farmer payloads, include file bytes if a local photo exists
      if (payload != null && payload.containsKey('photoPath')) {
        final photoPath = payload['photoPath'];
        try {
          final file = File(photoPath);
          if (await file.exists()) {
            final bytes = await file.readAsBytes();
            // send to mock server
            await MockServerService.postItem(type, {...payload, 'action': action}, fileBytes: bytes);
          } else {
            await MockServerService.postItem(type, {...payload, 'action': action});
          }
        } catch (e) {
          // ignore file read errors, still post payload
          await MockServerService.postItem(type, {...payload, 'action': action});
        }
      } else if (action == 'delete') {
        // remove from mock server box if exists
        final box = await HiveService.getFarmersBox();
        final serverBox = await Hive.openBox('server_$type');
        await serverBox.delete(referenceId);
      } else if (payload != null) {
        await MockServerService.postItem(type, {...payload, 'action': action});
      }
    } else {
      if (action == 'create') {
        await _dio.post('https://your-api-url.com$endpoint', data: payload);
      } else if (action == 'update') {
        await _dio.put('https://your-api-url.com$endpoint/$referenceId', data: payload);
      } else if (action == 'delete') {
        await _dio.delete('https://your-api-url.com$endpoint/$referenceId');
      }
    }
  }

  /// Pull updates from mock server and write them into local boxes.
  /// Currently only pulls farmers, milk_collections, transactions and products.
  Future<void> fetchUpdates() async {
    if (!_useMockServer) return;

    try {
      // Farmers
      final serverFarmers = await MockServerService.fetchUpdates('farmer', since: _lastSyncTime);
      if (serverFarmers.isNotEmpty) {
        final farmersBox = await HiveService.getFarmersBox();
        for (var rec in serverFarmers) {
          final id = rec['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString();

          // If photo bytes present, write to a local file and set photoPath
          String? photoPath;
          if (rec.containsKey('photoBytes')) {
            try {
              final bytes = base64Decode(rec['photoBytes']);
              final dir = await getApplicationDocumentsDirectory();
              final file = File('${dir.path}/server_photo_$id.jpg');
              await file.writeAsBytes(bytes, flush: true);
              photoPath = file.path;
            } catch (e) {
              // ignore file write errors
            }
          }

          final record = Map<String, dynamic>.from(rec);
          if (photoPath != null) record['photoPath'] = photoPath;

          await farmersBox.put(id, record);
        }
      }

      // TODO: Implement other types (milk_collection, transaction, product) similarly when needed.

      _lastSyncTime = DateTime.now();
      notifyListeners();
    } catch (e) {
      print('Error fetching updates from mock server: $e');
    }
  }

  // Add item to sync queue
  Future<void> queueForSync({
    required String type,
    required String action,
    required String referenceId,
  }) async {
    try {
      final syncBox = await HiveService.getSyncQueueBox();
      final id = DateTime.now().millisecondsSinceEpoch.toString();
      
      await syncBox.put(id, {
        'id': id,
        'type': type,
        'action': action,
        'referenceId': referenceId,
        'timestamp': DateTime.now().toIso8601String(),
      });

      await _loadPendingSyncCount();
    } catch (e) {
      print('Error queuing for sync: $e');
    }
  }

  // Clear sync queue
  Future<void> clearSyncQueue() async {
    try {
      final syncBox = await HiveService.getSyncQueueBox();
      await syncBox.clear();
      _pendingSyncCount = 0;
      notifyListeners();
    } catch (e) {
      print('Error clearing sync queue: $e');
    }
  }

  // Get time since last sync
  String getTimeSinceLastSync() {
    if (_lastSyncTime == null) return 'Never';

    final duration = DateTime.now().difference(_lastSyncTime!);
    
    if (duration.inMinutes < 1) return 'Just now';
    if (duration.inMinutes < 60) return '${duration.inMinutes} min ago';
    if (duration.inHours < 24) return '${duration.inHours} hours ago';
    return '${duration.inDays} days ago';
  }
}
