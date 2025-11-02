import 'package:flutter/foundation.dart';
import '../models/staff_model.dart';
import '../services/hive_service.dart';

class StaffController extends ChangeNotifier {
  List<StaffModel> _staff = [];
  List<StaffModel> _filteredStaff = [];
  bool _isLoading = false;
  String _searchQuery = '';
  StaffRole? _selectedRole;
  bool? _selectedActiveStatus;

  List<StaffModel> get staff => _searchQuery.isEmpty && _selectedRole == null && _selectedActiveStatus == null
      ? _staff
      : _filteredStaff;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  StaffRole? get selectedRole => _selectedRole;
  bool? get selectedActiveStatus => _selectedActiveStatus;

  // Load all staff
  Future<void> loadStaff() async {
    try {
      _isLoading = true;
      notifyListeners();

      final box = await HiveService.getStaffBox();
      _staff = box.values.map((e) {
        if (e is Map) {
          return StaffModel.fromJson(Map<String, dynamic>.from(e));
        }
        return e as StaffModel;
      }).toList();

      // Sort by name
      _staff.sort((a, b) => a.name.compareTo(b.name));

      _filteredStaff = _staff;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      debugPrint('Error loading staff: $e');
      rethrow;
    }
  }

  // Add new staff
  Future<void> addStaff(StaffModel staff) async {
    try {
      final box = await HiveService.getStaffBox();
      await box.put(staff.id, staff.toJson());
      await loadStaff();
      debugPrint('Staff added: ${staff.id}');
    } catch (e) {
      debugPrint('Error adding staff: $e');
      rethrow;
    }
  }

  // Update staff
  Future<void> updateStaff(StaffModel staff) async {
    try {
      final box = await HiveService.getStaffBox();
      staff.updatedAt = DateTime.now();
      await box.put(staff.id, staff.toJson());
      await loadStaff();
      debugPrint('Staff updated: ${staff.id}');
    } catch (e) {
      debugPrint('Error updating staff: $e');
      rethrow;
    }
  }

  // Delete staff
  Future<void> deleteStaff(String staffId) async {
    try {
      final box = await HiveService.getStaffBox();
      await box.delete(staffId);
      await loadStaff();
      debugPrint('Staff deleted: $staffId');
    } catch (e) {
      debugPrint('Error deleting staff: $e');
      rethrow;
    }
  }

  // Get staff by ID
  StaffModel? getStaffById(String id) {
    try {
      return _staff.firstWhere((s) => s.id == id);
    } catch (e) {
      return null;
    }
  }

  // Search staff
  void searchStaff(String query) {
    _searchQuery = query.toLowerCase();
    _applyFilters();
  }

  // Clear search
  void clearSearch() {
    _searchQuery = '';
    _applyFilters();
  }

  // Filter by role
  void filterByRole(StaffRole? role) {
    _selectedRole = role;
    _applyFilters();
  }

  // Filter by active status
  void filterByActiveStatus(bool? isActive) {
    _selectedActiveStatus = isActive;
    _applyFilters();
  }

  // Clear all filters
  void clearFilters() {
    _searchQuery = '';
    _selectedRole = null;
    _selectedActiveStatus = null;
    _filteredStaff = _staff;
    notifyListeners();
  }

  // Apply all filters
  void _applyFilters() {
    _filteredStaff = _staff.where((staff) {
      // Search filter
      if (_searchQuery.isNotEmpty) {
        final matchesSearch = staff.name.toLowerCase().contains(_searchQuery) ||
            staff.phone.toLowerCase().contains(_searchQuery) ||
            (staff.email?.toLowerCase().contains(_searchQuery) ?? false) ||
            (staff.department?.toLowerCase().contains(_searchQuery) ?? false);
        if (!matchesSearch) return false;
      }

      // Role filter
      if (_selectedRole != null && staff.role != _selectedRole) {
        return false;
      }

      // Active status filter
      if (_selectedActiveStatus != null && staff.isActive != _selectedActiveStatus) {
        return false;
      }

      return true;
    }).toList();

    notifyListeners();
  }

  // Get staff by role
  List<StaffModel> getStaffByRole(StaffRole role) {
    return _staff.where((s) => s.role == role).toList();
  }

  // Get active staff
  List<StaffModel> getActiveStaff() {
    return _staff.where((s) => s.isActive).toList();
  }

  // Get inactive staff
  List<StaffModel> getInactiveStaff() {
    return _staff.where((s) => !s.isActive).toList();
  }

  // Get staff by department
  List<StaffModel> getStaffByDepartment(String department) {
    return _staff.where((s) => s.department == department).toList();
  }

  // Get all departments
  List<String> getDepartments() {
    final departments = <String>{};
    for (var staff in _staff) {
      if (staff.department != null && staff.department!.isNotEmpty) {
        departments.add(staff.department!);
      }
    }
    return departments.toList()..sort();
  }

  // Get staff statistics
  Map<String, dynamic> getStaffStatistics() {
    final totalStaff = _staff.length;
    final activeStaff = getActiveStaff().length;
    final inactiveStaff = getInactiveStaff().length;

    // Role-wise breakdown
    final roleBreakdown = <StaffRole, int>{};
    for (var staff in _staff) {
      roleBreakdown[staff.role] = (roleBreakdown[staff.role] ?? 0) + 1;
    }

    // Total salary expense
    final totalSalaryExpense = _staff
        .where((s) => s.isActive)
        .fold<double>(0.0, (sum, staff) => sum + staff.salary);

    // Department-wise count
    final departmentBreakdown = <String, int>{};
    for (var staff in _staff) {
      if (staff.department != null && staff.department!.isNotEmpty) {
        departmentBreakdown[staff.department!] = 
            (departmentBreakdown[staff.department!] ?? 0) + 1;
      }
    }

    return {
      'totalStaff': totalStaff,
      'activeStaff': activeStaff,
      'inactiveStaff': inactiveStaff,
      'roleBreakdown': roleBreakdown,
      'totalSalaryExpense': totalSalaryExpense,
      'departmentBreakdown': departmentBreakdown,
    };
  }

  // Get recent joinings (last 30 days)
  List<StaffModel> getRecentJoinings() {
    final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
    return _staff
        .where((s) => s.joiningDate.isAfter(thirtyDaysAgo))
        .toList()
      ..sort((a, b) => b.joiningDate.compareTo(a.joiningDate));
  }

  // Get upcoming birthdays (if we add DOB in future)
  // This is a placeholder for future enhancement

  // Check if staff has permission
  bool hasPermission(String staffId, String permission) {
    final staff = getStaffById(staffId);
    if (staff == null) return false;
    return staff.hasPermission(permission);
  }

  // Update staff permissions
  Future<void> updateStaffPermissions(String staffId, List<String> permissions) async {
    final staff = getStaffById(staffId);
    if (staff == null) return;

    final updatedStaff = staff.copyWith(
      permissions: permissions,
      updatedAt: DateTime.now(),
    );

    await updateStaff(updatedStaff);
  }

  // Deactivate staff (relieve)
  Future<void> relieveStaff(String staffId, DateTime relievingDate) async {
    final staff = getStaffById(staffId);
    if (staff == null) return;

    final updatedStaff = staff.copyWith(
      isActive: false,
      relievingDate: relievingDate,
      updatedAt: DateTime.now(),
    );

    await updateStaff(updatedStaff);
  }

  // Reactivate staff
  Future<void> reactivateStaff(String staffId) async {
    final staff = getStaffById(staffId);
    if (staff == null) return;

    final updatedStaff = staff.copyWith(
      isActive: true,
      relievingDate: null,
      updatedAt: DateTime.now(),
    );

    await updateStaff(updatedStaff);
  }

  // Get salary report
  Map<String, dynamic> getSalaryReport() {
    final activeStaff = getActiveStaff();
    
    final totalSalary = activeStaff.fold<double>(
      0.0,
      (sum, staff) => sum + staff.salary,
    );

    final roleWiseSalary = <StaffRole, double>{};
    for (var staff in activeStaff) {
      roleWiseSalary[staff.role] = 
          (roleWiseSalary[staff.role] ?? 0.0) + staff.salary;
    }

    final departmentWiseSalary = <String, double>{};
    for (var staff in activeStaff) {
      if (staff.department != null && staff.department!.isNotEmpty) {
        departmentWiseSalary[staff.department!] = 
            (departmentWiseSalary[staff.department!] ?? 0.0) + staff.salary;
      }
    }

    return {
      'totalSalary': totalSalary,
      'staffCount': activeStaff.length,
      'averageSalary': activeStaff.isEmpty ? 0.0 : totalSalary / activeStaff.length,
      'roleWiseSalary': roleWiseSalary,
      'departmentWiseSalary': departmentWiseSalary,
    };
  }

  // Set staff login credentials
  Future<bool> setStaffCredentials(String staffId, String username, String password) async {
    try {
      // Check if username already exists
      if (await isUsernameExists(username, excludeStaffId: staffId)) {
        return false;
      }

      final staff = getStaffById(staffId);
      if (staff == null) return false;

      // Hash the password (simple hash for now, should use proper hashing in production)
      staff.username = username.toLowerCase().trim();
      staff.passwordHash = _hashPassword(password);
      
      await updateStaff(staff);
      return true;
    } catch (e) {
      debugPrint('Error setting staff credentials: $e');
      return false;
    }
  }

  // Validate staff login
  Future<StaffModel?> validateStaffLogin(String username, String password) async {
    try {
      final staff = _staff.firstWhere(
        (s) => s.username?.toLowerCase() == username.toLowerCase().trim() && s.isActive,
        orElse: () => throw Exception('Staff not found'),
      );

      if (staff.passwordHash == _hashPassword(password)) {
        return staff;
      }
      return null;
    } catch (e) {
      debugPrint('Error validating staff login: $e');
      return null;
    }
  }

  // Check if username exists
  Future<bool> isUsernameExists(String username, {String? excludeStaffId}) async {
    try {
      return _staff.any((s) => 
        s.username?.toLowerCase() == username.toLowerCase().trim() && 
        s.id != excludeStaffId
      );
    } catch (e) {
      return false;
    }
  }

  // Simple password hashing (use proper bcrypt/argon2 in production)
  String _hashPassword(String password) {
    // For demo purposes - in production, use crypto packages like:
    // - crypto (SHA-256)
    // - bcrypt
    // - argon2
    return password.split('').map((c) => c.codeUnitAt(0).toRadixString(16).padLeft(2, '0')).join();
  }

  // Get staff by username
  StaffModel? getStaffByUsername(String username) {
    try {
      return _staff.firstWhere(
        (s) => s.username?.toLowerCase() == username.toLowerCase().trim(),
      );
    } catch (e) {
      return null;
    }
  }
}
