class ApiConstants {
  // Base URL - Change this to your computer's IP address when testing on real device
  static const String baseUrl = 'http://localhost:8000/api';
  
  // For testing on real Android device, use your computer's IP:
  // static const String baseUrl = 'http://192.168.1.XXX:8000/api';
  
  // Endpoints
  static const String loginEndpoint = '/login';
  static const String logoutEndpoint = '/logout';
  static const String profileEndpoint = '/profile';
  static const String checkInEndpoint = '/attendance/check-in';
  static const String checkOutEndpoint = '/attendance/check-out';
  static const String todayAttendanceEndpoint = '/attendance/today';
  static const String attendanceHistoryEndpoint = '/attendance/history';
  static const String leavesEndpoint = '/leaves';
  
  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  
  // Office Location (Example - Jakarta)
  static const double officeLatitude = -6.200000;
  static const double officeLongitude = 106.816666;
  static const double officeRadius = 100; // meters
}
