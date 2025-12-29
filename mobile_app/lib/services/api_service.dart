import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';
import '../models/user.dart';
import '../models/attendance.dart';

class ApiService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: ApiConstants.baseUrl,
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
  ));

  // Add token to requests
  Future<void> _addAuthHeader() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(ApiConstants.tokenKey);
    if (token != null) {
      _dio.options.headers['Authorization'] = 'Bearer $token';
    }
  }

  // Login
  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final response = await _dio.post(
        ApiConstants.loginEndpoint,
        data: {
          'username': username,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Login failed');
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Login failed');
    }
  }

  // Logout
  Future<void> logout() async {
    await _addAuthHeader();
    try {
      await _dio.post(ApiConstants.logoutEndpoint);
    } catch (e) {
      // Ignore errors on logout
    }
  }

  // Get Profile
  Future<User> getProfile() async {
    await _addAuthHeader();
    try {
      final response = await _dio.get(ApiConstants.profileEndpoint);
      return User.fromJson(response.data['user']);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to get profile');
    }
  }

  // Check-in
  Future<Attendance> checkIn({
    required double latitude,
    required double longitude,
    String? photo,
  }) async {
    await _addAuthHeader();
    try {
      final response = await _dio.post(
        ApiConstants.checkInEndpoint,
        data: {
          'latitude': latitude,
          'longitude': longitude,
          if (photo != null) 'photo': photo,
        },
      );

      return Attendance.fromJson(response.data['attendance']);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Check-in failed');
    }
  }

  // Check-out
  Future<Attendance> checkOut({
    required double latitude,
    required double longitude,
    String? photo,
  }) async {
    await _addAuthHeader();
    try {
      final response = await _dio.post(
        ApiConstants.checkOutEndpoint,
        data: {
          'latitude': latitude,
          'longitude': longitude,
          if (photo != null) 'photo': photo,
        },
      );

      return Attendance.fromJson(response.data['attendance']);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Check-out failed');
    }
  }

  // Get today's attendance
  Future<Attendance?> getTodayAttendance() async {
    await _addAuthHeader();
    try {
      final response = await _dio.get(ApiConstants.todayAttendanceEndpoint);
      if (response.data['attendance'] != null) {
        return Attendance.fromJson(response.data['attendance']);
      }
      return null;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to get attendance');
    }
  }

  // Get attendance history
  Future<List<Attendance>> getAttendanceHistory({int page = 1}) async {
    await _addAuthHeader();
    try {
      final response = await _dio.get(
        ApiConstants.attendanceHistoryEndpoint,
        queryParameters: {'page': page},
      );

      final List<dynamic> data = response.data['data'];
      return data.map((json) => Attendance.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to get history');
    }
  }
}
