import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../utils/app_constants.dart';

/// Splash screen with Halloween-themed animations
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _glowController;
  late AnimationController _ghostController;

  late Animation<double> _logoScale;
  late Animation<double> _logoRotation;
  late Animation<double> _glowAnimation;
  late Animation<double> _ghostAnimation;

  @override
  void initState() {
    super.initState();

    // Logo animation controller
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    // Glow animation controller
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    // Ghost floating animation controller
    _ghostController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat(reverse: true);

    // Logo scale animation
    _logoScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: Curves.elasticOut,
      ),
    );

    // Logo rotation animation
    _logoRotation = Tween<double>(begin: -0.2, end: 0.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: Curves.easeOut,
      ),
    );

    // Glow animation
    _glowAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(
        parent: _glowController,
        curve: Curves.easeInOut,
      ),
    );

    // Ghost floating animation
    _ghostAnimation = Tween<double>(begin: -20.0, end: 20.0).animate(
      CurvedAnimation(
        parent: _ghostController,
        curve: Curves.easeInOut,
      ),
    );

    // Start animations
    _logoController.forward();

    // Navigate to home after splash duration
    _navigateToHome();
  }

  Future<void> _navigateToHome() async {
    await Future.delayed(AppConstants.splashDuration);
    if (mounted) {
      Navigator.of(context).pushReplacementNamed(AppConstants.homeRoute);
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _glowController.dispose();
    _ghostController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: HalloweenGradients.spookyNight,
        ),
        child: Stack(
          children: [
            // Floating ghost particles background
            ..._buildGhostParticles(),

            // Main content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Animated logo with glow effect
                  AnimatedBuilder(
                    animation: Listenable.merge([
                      _logoController,
                      _glowController,
                    ]),
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _logoScale.value,
                        child: Transform.rotate(
                          angle: _logoRotation.value,
                          child: Container(
                            width: 150,
                            height: 150,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: AppConstants.primaryOrange
                                      .withValues(alpha: _glowAnimation.value * 0.6),
                                  blurRadius: 50 * _glowAnimation.value,
                                  spreadRadius: 10 * _glowAnimation.value,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.nights_stay,
                              size: 100,
                              color: AppConstants.pumpkinOrange,
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 40),

                  // App name with creepy font
                  FadeTransition(
                    opacity: _logoController,
                    child: Text(
                      AppConstants.appName,
                      style: GoogleFonts.creepster(
                        fontSize: 56,
                        color: AppConstants.primaryOrange,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                            color: AppConstants.primaryOrange.withValues(alpha: 0.5),
                            blurRadius: 20,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Tagline
                  FadeTransition(
                    opacity: _logoController,
                    child: Text(
                      AppConstants.appTagline,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: AppConstants.ghostWhite.withValues(alpha: 0.8),
                        fontWeight: FontWeight.w300,
                        letterSpacing: 2,
                      ),
                    ),
                  ),

                  const SizedBox(height: 60),

                  // Loading indicator
                  SizedBox(
                    width: 40,
                    height: 40,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppConstants.primaryOrange.withValues(alpha: 0.8),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Version number at bottom
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: Center(
                child: Text(
                  'v${AppConstants.version}',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: AppConstants.ghostWhite.withValues(alpha: 0.5),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build floating ghost particles for background effect
  List<Widget> _buildGhostParticles() {
    return List.generate(15, (index) {
      // Use index to create varied positions
      final left = (index * 17.3) % 100;
      final top = (index * 23.7) % 100;
      final size = 20.0 + ((index * 7) % 40).toDouble();

      return AnimatedBuilder(
        animation: _ghostAnimation,
        builder: (context, child) {
          return Positioned(
            left: MediaQuery.of(context).size.width * (left / 100),
            top: MediaQuery.of(context).size.height * (top / 100) +
                _ghostAnimation.value * (index % 2 == 0 ? 1 : -1),
            child: Opacity(
              opacity: 0.1 + (index % 3) * 0.1,
              child: Icon(
                Icons.bubble_chart,
                size: size,
                color: AppConstants.ghostWhite,
              ),
            ),
          );
        },
      );
    });
  }
}
