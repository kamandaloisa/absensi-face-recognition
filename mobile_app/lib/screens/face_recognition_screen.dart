import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'dart:async';
import '../utils/app_theme.dart';

class FaceRecognitionScreen extends StatefulWidget {
  final bool isCheckIn;
  
  const FaceRecognitionScreen({
    super.key,
    this.isCheckIn = true,
  });

  @override
  State<FaceRecognitionScreen> createState() => _FaceRecognitionScreenState();
}

class _FaceRecognitionScreenState extends State<FaceRecognitionScreen> with SingleTickerProviderStateMixin {
  CameraController? _cameraController;
  bool _isCameraInitialized = false;
  bool _isFaceDetected = false;
  bool _isProcessing = false;
  String _detectionStatus = 'Position your face in the frame';
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    
    // Pulse animation for frame
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        setState(() {
          _detectionStatus = 'No camera available';
        });
        return;
      }

      // Get front camera
      final frontCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );

      _cameraController = CameraController(
        frontCamera,
        ResolutionPreset.high,
        enableAudio: false,
      );

      await _cameraController!.initialize();
      
      if (mounted) {
        setState(() {
          _isCameraInitialized = true;
        });
        
        // Simulate face detection (in production, use ML Kit or TensorFlow)
        _startFaceDetection();
      }
    } catch (e) {
      setState(() {
        _detectionStatus = 'Camera error: ${e.toString()}';
      });
    }
  }

  void _startFaceDetection() {
    // Simulate face detection with timer
    Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      
      // Random simulation - in production, use actual ML Kit face detection
      if (!_isProcessing) {
        setState(() {
          _isFaceDetected = DateTime.now().second % 3 == 0;
          if (_isFaceDetected) {
            _detectionStatus = '✓ Face detected - Hold still';
          } else {
            _detectionStatus = 'Position your face in the frame';
          }
        });
      }
    });
  }

  Future<void> _captureAndVerify() async {
    if (!_isFaceDetected || _isProcessing) return;
    
    setState(() {
      _isProcessing = true;
      _detectionStatus = 'Verifying face...';
    });

    try {
      // Simulate face verification
      await Future.delayed(const Duration(seconds: 2));
      
      if (!mounted) return;
      
      // Return success with face data
      Navigator.pop(context, {
        'success': true,
        'photo': 'base64_encoded_photo_here',
      });
    } catch (e) {
      setState(() {
        _isProcessing = false;
        _detectionStatus = 'Verification failed';
      });
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(widget.isCheckIn ? 'Check In - Face Verification' : 'Check Out - Face Verification'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          // Camera Preview
          if (_isCameraInitialized && _cameraController != null)
            SizedBox.expand(
              child: CameraPreview(_cameraController!),
            )
          else
            const Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),

          // Face Frame Overlay
          Center(
            child: AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _pulseAnimation.value,
                  child: Container(
                    width: 280,
                    height: 360,
                    decoration: BoxDecoration(
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.circular(200),
                      border: Border.all(
                        color: _isFaceDetected
                            ? AppTheme.successGreen
                            : Colors.white.withOpacity(0.7),
                        width: 3,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Top Instructions
          Positioned(
            top: 20,
            left: 0,
            right: 0,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Icon(
                    _isFaceDetected ? Icons.check_circle : Icons.face_retouching_natural,
                    color: _isFaceDetected ? AppTheme.successGreen : Colors.white,
                    size: 32,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _detectionStatus,
                    style: TextStyle(
                      color: _isFaceDetected ? AppTheme.successGreen : Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),

          // Bottom Instructions & Capture Button
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Column(
              children: [
                // Tips
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Column(
                    children: [
                      Row(
                        children: [
                          Icon(Icons.wb_sunny, color: Colors.white, size: 16),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Ensure good lighting',
                              style: TextStyle(color: Colors.white, fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.face, color: Colors.white, size: 16),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Remove glasses or mask',
                              style: TextStyle(color: Colors.white, fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                
                // Capture Button
                if (_isFaceDetected && !_isProcessing)
                  GestureDetector(
                    onTap: _captureAndVerify,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppTheme.successGreen,
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.successGreen.withOpacity(0.5),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                  )
                else if (_isProcessing)
                  const SizedBox(
                    width: 80,
                    height: 80,
                    child: CircularProgressIndicator(
                      strokeWidth: 4,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                else
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.3),
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
