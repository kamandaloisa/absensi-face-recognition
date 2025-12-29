class User {
  final int id;
  final String username;
  final String fullName;
  final String? employeeCode;
  final String role;
  final String? department;
  final String? position;
  final String? email;
  final String? phone;

  User({
    required this.id,
    required this.username,
    required this.fullName,
    this.employeeCode,
    required this.role,
    this.department,
    this.position,
    this.email,
    this.phone,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      fullName: json['full_name'],
      employeeCode: json['employee_code'],
      role: json['role'],
      department: json['department'],
      position: json['position'],
      email: json['email'],
      phone: json['phone'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'full_name': fullName,
      'employee_code': employeeCode,
      'role': role,
      'department': department,
      'position': position,
      'email': email,
      'phone': phone,
    };
  }

  bool get isAdmin => role == 'admin';
  bool get isEmployee => role == 'employee';
}
