import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';
import '../services/location_service.dart';
import '../models/attendance.dart';
import '../models/user.dart';
import '../utils/constants.dart';
import '../utils/app_theme.dart';
import 'attendance_history_screen.dart';
import 'leave_request_screen.dart';
import 'face_recognition_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService _apiService = ApiService();
  final LocationService _locationService = LocationService();
  
  Attendance? _todayAttendance;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadTodayAttendance();
    // Clean Status Bar
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));
  }

  Future<void> _loadTodayAttendance() async {
    setState(() => _isLoading = true);
    try {
      final attendance = await _apiService.getTodayAttendance();
      if (mounted) {
        setState(() {
          _todayAttendance = attendance;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _processAttendance(bool isCheckIn) async {
    setState(() => _isLoading = true);
    try {
      final position = await _locationService.getCurrentPosition();
      final isWithinRadius = await _locationService.isWithinOfficeRadius(
        ApiConstants.officeLatitude,
        ApiConstants.officeLongitude,
        ApiConstants.officeRadius,
      );

      if (!isWithinRadius) {
        throw Exception('Location not valid. Please move closer to the office.');
      }

      if (!mounted) return;

      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FaceRecognitionScreen(isCheckIn: isCheckIn),
        ),
      );

      if (result == null || result['success'] != true) {
         setState(() => _isLoading = false);
         return;
      }

      Attendance attendance;
      if (isCheckIn) {
        attendance = await _apiService.checkIn(
          latitude: position.latitude,
          longitude: position.longitude,
        );
      } else {
        attendance = await _apiService.checkOut(
          latitude: position.latitude,
          longitude: position.longitude,
        );
      }

      if (mounted) {
        setState(() {
          _todayAttendance = attendance;
          _isLoading = false;
        });
        _showSuccessDialog(isCheckIn ? 'Check In Successful!' : 'Check Out Successful!');
      }

    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showErrorSnackBar(e.toString().replaceAll('Exception: ', ''));
      }
    }
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Success", style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text(message),
        actions: [
          TextButton(
            child: const Text("OK", style: TextStyle(color: AppTheme.primaryBlue, fontWeight: FontWeight.bold)),
            onPressed: () => Navigator.pop(context),
          )
        ],
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.errorRed,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;

    return Scaffold(
      backgroundColor: Colors.white, // Strictly White
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Header (Clean White)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Good Morning,',
                        style: AppTheme.caption.copyWith(fontSize: 16),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user?.fullName ?? 'User',
                        style: AppTheme.largeTitle.copyWith(fontSize: 24),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppTheme.primaryBlue.withOpacity(0.2), width: 2),
                    ),
                    child: CircleAvatar(
                      radius: 22,
                      backgroundColor: AppTheme.accentBlue,
                      child: Text(
                        user?.fullName?.substring(0, 1).toUpperCase() ?? 'U',
                        style: const TextStyle(
                          color: AppTheme.primaryBlue,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // 2. Attendance Stats (White Card with subtle shadow)
              _buildAttendanceCard(),
              
              const SizedBox(height: 32),

              // 3. Quick Actions (Minimalist grid)
              Text("Quick Actions", style: AppTheme.title1.copyWith(fontSize: 18)),
              const SizedBox(height: 16),
              _buildQuickActionGrid(),

              const SizedBox(height: 32),
              
              // 4. Info Section
              _buildInfoBanner(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAttendanceCard() {
    return Container(
      decoration: AppTheme.cleanCardDecoration,
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Today's Status", style: AppTheme.caption),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        width: 8, height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _todayAttendance != null ? AppTheme.successGreen : Colors.grey.shade400,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _todayAttendance != null ? 'Present' : 'Not Checked In',
                        style: AppTheme.body.copyWith(
                          fontWeight: FontWeight.w600,
                          color: _todayAttendance != null ? AppTheme.successGreen : Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Text(
                DateFormat('d MMM').format(DateTime.now()),
                style: AppTheme.title1.copyWith(fontSize: 20, color: AppTheme.primaryBlue),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(child: _buildTimeStat("Check In", _todayAttendance?.checkInTime)),
              Container(width: 1, height: 40, color: const Color(0xFFF1F5F9)),
              Expanded(child: _buildTimeStat("Check Out", _todayAttendance?.checkOutTime)),
            ],
          ),
          const SizedBox(height: 24),
          if (!_isLoading) _buildMainButton(),
          if (_isLoading) const Center(child: CircularProgressIndicator(color: AppTheme.primaryBlue)),
        ],
      ),
    );
  }

  Widget _buildTimeStat(String label, DateTime? time) {
    return Column(
      children: [
        Text(
          time != null ? DateFormat('HH:mm').format(time) : '--:--',
          style: AppTheme.title1.copyWith(fontSize: 24),
        ),
        const SizedBox(height: 4),
        Text(label, style: AppTheme.caption),
      ],
    );
  }

  Widget _buildMainButton() {
     bool canCheckIn = _todayAttendance == null || !_todayAttendance!.hasCheckedIn;
     
     if (_todayAttendance != null && _todayAttendance!.hasCheckedOut) {
       return Container(
         width: double.infinity,
         padding: const EdgeInsets.symmetric(vertical: 16),
         decoration: BoxDecoration(
           color: AppTheme.accentBlue,
           borderRadius: BorderRadius.circular(12),
         ),
         child: const Center(
           child: Text("Day Completed", style: TextStyle(color: AppTheme.primaryBlue, fontWeight: FontWeight.w600)),
         ),
       );
     }

     return SizedBox(
       width: double.infinity,
       child: ElevatedButton(
         onPressed: () => _processAttendance(canCheckIn),
         style: ElevatedButton.styleFrom(
           backgroundColor: AppTheme.primaryBlue,
           foregroundColor: Colors.white,
           elevation: 0,
           padding: const EdgeInsets.symmetric(vertical: 16),
           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
         ),
         child: Text(canCheckIn ? "Check In Now" : "Check Out Now", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
       ),
     );
  }

  Widget _buildQuickActionGrid() {
    return Row(
      children: [
        _buildActionButton("History", Icons.history, const AttendanceHistoryScreen()),
        const SizedBox(width: 16),
        _buildActionButton("Leave", Icons.calendar_today_outlined, const LeaveRequestScreen()),
        const SizedBox(width: 16),
        _buildActionButton("Profile", Icons.person_outline, null),
      ],
    );
  }

  Widget _buildActionButton(String label, IconData icon, Widget? page) {
    return Expanded(
      child: InkWell(
        onTap: page != null ? () => Navigator.push(context, MaterialPageRoute(builder: (_) => page)) : null,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: AppTheme.cleanCardDecoration,
          child: Column(
            children: [
              Icon(icon, color: AppTheme.primaryBlue, size: 28),
              const SizedBox(height: 12),
              Text(label, style: AppTheme.body.copyWith(fontSize: 14, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.backgroundLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.primaryBlue.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: AppTheme.primaryBlue.withOpacity(0.7), size: 20),
          const SizedBox(width: 12),
          Text("Don't forget to check out!", style: AppTheme.caption.copyWith(color: AppTheme.primaryBlue)),
        ],
      ),
    );
  }
}
