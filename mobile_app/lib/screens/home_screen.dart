import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'dart:async'; // Added for Timer
import '../providers/auth_provider.dart';
import '../services/api_service.dart';
import '../services/location_service.dart';
import '../models/attendance.dart';
import '../models/user.dart';
import '../utils/constants.dart';
import '../utils/app_theme.dart';
import '../widgets/home_background_painter.dart'; // Import Custom Painter
import 'attendance_history_screen.dart';
import 'leave_request_screen.dart';
import 'face_recognition_screen.dart';
import '../widgets/custom_loading_indicator.dart';
import 'login_screen.dart'; // Needed for logout

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
  
  // Real-time clock
  late Timer _timer;
  DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadTodayAttendance();
    _startTimer();
    
    // Status Bar - Translucent/Transparent for full bleed
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light, // White icons on blue bg
    ));
  }
  
  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _now = DateTime.now();
        });
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
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
  
  Future<void> _logout() async {
    final auth = context.read<AuthProvider>();
    await auth.logout();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
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
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // 1. Custom Background Painter (Blue Curves)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: size.height * 0.45, // Occupy top ~45%
            child: CustomPaint(
              painter: HomeBackgroundPainter(),
            ),
          ),
          
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 2. Header (Avatar + Name)
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white.withOpacity(0.5), width: 2),
                        ),
                        child: CircleAvatar(
                          radius: 24,
                          backgroundColor: Colors.white,
                          child: Icon(Icons.person, color: AppTheme.primaryBlue), // Fallback image
                          // foregroundImage: NetworkImage('...'), // If implementing photo
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Hello, ${user?.fullName?.split(' ').first ?? 'User'}",
                            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
                          ),
                          const Text("Staff Staff", // Placeholder for position
                            style: TextStyle(color: Colors.white70, fontSize: 14),
                          ),
                        ],
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.notifications_none_rounded, color: Colors.white),
                        onPressed: () {}, // Notification action
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 30),
                  
                  // 3. Clock Card (White box)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                         Text(
                           DateFormat('HH:mm:ss').format(_now) + " WIB",
                           style: const TextStyle(
                             fontSize: 32,
                             fontWeight: FontWeight.bold,
                             color: AppTheme.primaryBlue,
                             fontFamily: 'monospace', // Monospaced for clearer counting
                             letterSpacing: -1,
                           ),
                         ),
                         const SizedBox(height: 4),
                         Text(
                           DateFormat('EEEE, d MMMM yyyy').format(_now),
                           style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                         ),
                         const SizedBox(height: 16),
                         Divider(color: Colors.grey.shade200, height: 1),
                         const SizedBox(height: 16),
                         const Text("Jadwal Anda Hari Ini", style: TextStyle(color: Colors.grey, fontSize: 12)),
                         const SizedBox(height: 4),
                         const Text(
                           "08:00 AM - 05:00 PM",
                           style: TextStyle(
                             fontSize: 18,
                             fontWeight: FontWeight.bold,
                             color: Colors.black87,
                           ),
                         ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // 4. Banner (Blue Gradient)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF4481EB), Color(0xFF04BEFE)], // Light Blue Gradient
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                         BoxShadow(color: const Color(0xFF04BEFE).withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5)),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text("Jangan lupa Absen masuk", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                              Text("dan juga Absen pulang ya!", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                            ],
                          ),
                        ),
                        // Add Image.asset here if Available. For now, Icon.
                        const Icon(Icons.back_hand_rounded, color: Colors.white, size: 40),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // 5. Grid Menu
                  LayoutBuilder(
                    builder: (context, constraints) {
                      return GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 3,
                        mainAxisSpacing: 20,
                        crossAxisSpacing: 20,
                        childAspectRatio: 1.0,
                        children: [
                          _buildGridItem("Datang", Icons.login_rounded, () => _processAttendance(true), isActive: true),
                          _buildGridItem("Pulang", Icons.logout_rounded, () => _processAttendance(false), isActive: true),
                          _buildGridItem("Izin", Icons.calendar_month_outlined, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LeaveRequestScreen())), isActive: true),
                          _buildGridItem("Aktivitas", Icons.assignment_outlined, null, isActive: true),
                          _buildGridItem("History", Icons.history, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AttendanceHistoryScreen())), isActive: true),
                          _buildGridItem("Planning", Icons.edit_calendar_outlined, null, isActive: true),
                          _buildGridItem("Approval", Icons.check_circle_outline, null, isActive: true),
                          _buildGridItem("Jadwal", Icons.schedule, null, isActive: true),
                          _buildGridItem("Cuti", Icons.beach_access, null, isActive: true),
                        ],
                      );
                    }
                  ),
                  
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.1),
              child: const Center(child: CustomLoadingIndicator(size: 50)),
            ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0, // Home
        onTap: (index) {
          if (index == 2) _logout(); // Temporary Profile/Logout action
        },
        selectedItemColor: AppTheme.primaryBlue,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        elevation: 10,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.pie_chart_rounded), label: 'History'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
      ),
    );
  }

  Widget _buildGridItem(String label, IconData icon, VoidCallback? onTap, {bool isActive = false}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isActive ? AppTheme.primaryBlue : Colors.grey.shade200, 
            width: isActive ? 2 : 1
          ),
          boxShadow: [
             if (isActive) BoxShadow(color: AppTheme.primaryBlue.withOpacity(0.1), blurRadius: 8, offset: const Offset(0,4)),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isActive ? AppTheme.primaryBlue : Colors.blueGrey, size: 30),
            const SizedBox(height: 8),
            Text(label, style: TextStyle(
              fontSize: 12, 
              fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
              color: isActive ? AppTheme.primaryBlue : Colors.black87,
            )),
          ],
        ),
      ),
    );
  }
}
