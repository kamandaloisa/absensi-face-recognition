import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'login_screen.dart';
import '../utils/app_theme.dart';
import 'dart:math';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> with TickerProviderStateMixin {
  late AnimationController _shimmerController;
  
  // Swipe Logic
  double _dragValue = 0.0;
  double _dragWidth = 0.0; // Total track width
  final double _buttonSize = 64.0;
  final double _padding = 8.0; 
  bool _isFinished = false;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
       vsync: this,
       duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  void _onDragUpdate(DragUpdateDetails details) {
    if (_isFinished || _dragWidth == 0.0) return;
    
    setState(() {
      // Allow dragging but clamp
      double maxDrag = _dragWidth - _buttonSize - (_padding * 2);
      _dragValue = (_dragValue + details.delta.dx).clamp(0.0, maxDrag);
    });
  }

  void _onDragEnd(DragEndDetails details) {
    if (_isFinished) return;
    
    double maxDrag = _dragWidth - _buttonSize - (_padding * 2);
    
    // Threshold to finish (65%)
    if (_dragValue > maxDrag * 0.65) {
      setState(() {
        _dragValue = maxDrag;
        _isFinished = true;
      });
      HapticFeedback.mediumImpact();
      _navigateToLogin();
    } else {
      // Smooth Snap Back
      _animateBack();
    }
  }

  void _animateBack() {
    final startValue = _dragValue;
    // Animation controller for snap back
    AnimationController backController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    
    Animation<double> animation = Tween<double>(begin: startValue, end: 0.0)
      .animate(CurvedAnimation(parent: backController, curve: Curves.easeOut));

    animation.addListener(() {
      setState(() {
        _dragValue = animation.value;
      });
    });

    backController.forward().then((_) => backController.dispose());
  }

  void _navigateToLogin() {
    Future.delayed(const Duration(milliseconds: 300), () {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 600),
          pageBuilder: (_, __, ___) => const LoginScreen(),
          transitionsBuilder: (_, animation, __, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Logo
          
          
              
              // Main Headline
              RichText(
                textAlign: TextAlign.left,
                text: TextSpan(
                  style: TextStyle(
                    fontSize: 42, // Slightly adjusted for better fit
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textDark,
                    height: 1.1,
                    letterSpacing: -1.0,
                    fontFamily: 'sans-serif',
                  ),
                  children: const [
                    TextSpan(text: ''),
                    TextSpan(text: ''),
                    TextSpan(text: ''),
                  ],
                ),
              ),
              
              
              // Spacer reduced to move logo up
              const Spacer(flex: 2),
              
              // Central Image 
              Center(
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.9, end: 1.05),
                  duration: const Duration(seconds: 2),
                  curve: Curves.easeInOutSine,
                  builder: (context, value, child) {
                    return Transform.scale(scale: value, child: child);
                  },
                  onEnd: () {}, // Could loop ping-pong here if needed
                  child: Container(
                    height: 280,
                    width: 280,
                    padding: const EdgeInsets.all(40), // Padding for the logo
                    child: Image.asset(
                      'assets/images/biznet_symbol.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
              
              // Spacer increased to push logo up
              const Spacer(flex: 6),
              
              // Swipe to Start Slider
              LayoutBuilder(
                builder: (context, constraints) {
                  // Capture width for drag calculations
                  if (_dragWidth != constraints.maxWidth) {
                     // Defer set state to next frame to avoid build error, or just set it
                     // Since build is called, we can't setState, but we can store it.
                     Future.microtask(() => _dragWidth = constraints.maxWidth);
                  }
                  
                  return Container(
                    height: 80,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9), 
                      borderRadius: BorderRadius.circular(50),
                      border: Border.all(color: Colors.white, width: 2), // Clean border
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    padding: EdgeInsets.all(_padding),
                    child: Stack(
                      alignment: Alignment.centerLeft,
                      children: [
                        // Background Text & Shimmer
                        Center(
                          child: AnimatedBuilder(
                            animation: _shimmerController,
                            builder: (context, child) {
                              return ShaderMask(
                                shaderCallback: (bounds) {
                                  return LinearGradient(
                                    colors: const [
                                      Color(0xFF94A3B8), // Base Grey
                                      AppTheme.primaryBlue, // Shine Blue instead of White
                                      Color(0xFF94A3B8), 
                                    ],
                                    stops: const [0.4, 0.5, 0.6],
                                    begin: Alignment(-1.0 + (_shimmerController.value * 3), 0),
                                    end: Alignment(1.0 + (_shimmerController.value * 3), 0),
                                    tileMode: TileMode.repeated,
                                  ).createShader(bounds);
                                },
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text(
                                      'Swipe to Start',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white, 
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Icon(Icons.keyboard_double_arrow_right_rounded, size: 20, color: Colors.white),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                        
                        // Draggable Knob
                        Positioned(
                          left: _dragValue, 
                          child: GestureDetector(
                            onHorizontalDragStart: (_) => HapticFeedback.lightImpact(),
                            onHorizontalDragUpdate: _onDragUpdate,
                            onHorizontalDragEnd: _onDragEnd,
                            child: Container(
                              width: _buttonSize,
                              height: _buttonSize,
                              decoration: BoxDecoration(
                                color: AppTheme.primaryBlue, // Blue Button
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppTheme.primaryBlue.withOpacity(0.3),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 28),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
