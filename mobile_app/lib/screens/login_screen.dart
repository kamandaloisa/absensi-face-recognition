import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../utils/app_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLogin = true; 

  // Exact Colors from Reference
  final Color _primaryBlue = const Color(0xFF2563EB); // Royal Blue
  final Color _darkBackground = const Color(0xFF0F172A); // Dark Slate/Navy
  final Color _subTextColor = const Color(0xFF94A3B8); // Slate 400
  final Color _inputBorder = const Color(0xFFE2E8F0); // Slate 200

  @override
  void initState() {
    super.initState();
    // Make status bar transparent to match the immersive dark feel
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = context.read<AuthProvider>();
      // Simulate login for demo purposes since we changed fields to Email
      final success = await authProvider.login(
        "admin", // Hardcoded for demo compatibility
        _passwordController.text,
      );

      if (!mounted) return;

      if (!success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.error ?? 'Authentication failed'),
            backgroundColor: AppTheme.errorRed,
          ),
        );
        authProvider.clearError();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _darkBackground,
      body: Stack(
        children: [
          // Background - Subtle Stars/Dust
          Positioned.fill(
             child: CustomPaint(
               painter: BackgroundPainter(),
             ),
          ),

          Column(
            children: [
              // Top Section (Dark)
              Expanded(
                flex: 4, // Adjust ratio to match image (approx 40% top)
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),
                      const SizedBox(height: 20),
                      // Biznet Logo
                      Image.asset(
                        'assets/images/biznet_logo.png',
                        height: 48, // Adjusted height for logo
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(height: 48),
                      // Heading
                      const Text(
                        'Get Started now',
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: -0.5,
                          fontFamily: 'sans-serif',
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Create an account or log in to explore our app',
                        style: TextStyle(
                          fontSize: 15,
                          color: _subTextColor,
                          height: 1.5,
                          fontFamily: 'sans-serif',
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Bottom Section (White Sheet)
              Expanded(
                flex: 6, // approx 60% bottom
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(32),
                      topRight: Radius.circular(32),
                    ),
                  ),
                  padding: const EdgeInsets.fromLTRB(32, 40, 32, 0),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Tab Selector
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9), // Slate 100
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Expanded(child: _buildTabButton('Log In', true)),
                              Expanded(child: _buildTabButton('Sign up', false)),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),
                    
                        // Login Form
                        Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel('Email'),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _emailController,
                                style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black87),
                                decoration: _buildInputDecoration('Loisbecket@gmail.com'),
                                validator: (value) => value!.isEmpty ? 'Required' : null,
                              ),
                              
                              const SizedBox(height: 24),
                              
                              _buildLabel('Password'),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _passwordController,
                                obscureText: _obscurePassword,
                                style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.black87, letterSpacing: 2),
                                decoration: _buildInputDecoration('•••••••').copyWith(
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      Icons.visibility_off_outlined,
                                      color: Colors.grey[400],
                                      size: 20,
                                    ),
                                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                                  ),
                                ),
                                validator: (value) => value!.isEmpty ? 'Required' : null,
                              ),
                    
                              const SizedBox(height: 20),
                              
                              // Remember Me & Forgot Password
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: Checkbox(
                                          value: false, 
                                          onChanged: (v) {},
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                                          side: BorderSide(color: Colors.grey[400]!, width: 1.5),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Text(
                                        'Remember me', 
                                        style: TextStyle(
                                          color: Colors.grey[600], 
                                          fontSize: 14, 
                                          fontWeight: FontWeight.w500
                                        )
                                      ),
                                    ],
                                  ),
                                  TextButton(
                                    onPressed: () {},
                                    style: TextButton.styleFrom(
                                      padding: EdgeInsets.zero,
                                      minimumSize: Size.zero,
                                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    ),
                                    child: Text(
                                      'Forgot Password ?',
                                      style: TextStyle(
                                        color: _primaryBlue, 
                                        fontWeight: FontWeight.w600, 
                                        fontSize: 14
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                    
                              const SizedBox(height: 32),
                    
                              // Main Button
                              SizedBox(
                                width: double.infinity,
                                height: 56,
                                child: Consumer<AuthProvider>(
                                  builder: (context, auth, _) {
                                    return ElevatedButton(
                                      onPressed: auth.isLoading ? null : _login,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: _primaryBlue,
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(16),
                                        ),
                                        elevation: 0,
                                        textStyle: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      child: auth.isLoading
                                          ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                                          : const Text('Log In'),
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(height: 20), // Bottom padding
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(String text, bool isActive) {
    return GestureDetector(
      onTap: () {
        setState(() => _isLogin = isActive);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: _isLogin == isActive ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          boxShadow: _isLogin == isActive 
            ? [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4, spreadRadius: 0, offset: const Offset(0, 2))]
            : [],
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 15, // Slightly larger
              color: _isLogin == isActive ? Colors.black87 : Colors.grey[500],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        color: Colors.grey[600],
        fontWeight: FontWeight.w500,
        fontSize: 14,
      ),
    );
  }

  InputDecoration _buildInputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.black87, fontWeight: FontWeight.normal),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18), // Taller input
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: _inputBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: _inputBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: _primaryBlue.withOpacity(0.5), width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red),
      ),
    );
  }
}

// Minimalist Background Painter (Just clear background + maybe very subtle noise/dots)
class BackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    // A few random dust particles
    final  points = [
      Offset(size.width * 0.2, size.height * 0.1),
      Offset(size.width * 0.8, size.height * 0.2),
      Offset(size.width * 0.5, size.height * 0.3),
      Offset(size.width * 0.1, size.height * 0.35),
      Offset(size.width * 0.9, size.height * 0.15),
    ];
    
    for (var point in points) {
      canvas.drawCircle(point, 1.0, paint);
    }
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
