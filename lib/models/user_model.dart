enum UserRole {
  admin,
  collector,
}

class UserModel {
  final String id;
  final String name;
  final UserRole role;
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.name,
    required this.role,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'role': role.toString(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'],
      role: json['role'] == 'UserRole.admin' ? UserRole.admin : UserRole.collector,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  bool get isAdmin => role == UserRole.admin;
  bool get isCollector => role == UserRole.collector;
}
