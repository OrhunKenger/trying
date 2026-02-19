import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    Future.delayed(const Duration(milliseconds: 3000), () {
      if (mounted) {
        context.go('/auth');
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background gradient
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 1.5,
                colors: [
                  Color(0xFF1A0000),
                  AppColors.darkBackground,
                ],
              ),
            ),
          ),

          // Animated circles background
          ..._buildAnimatedCircles(),

          // Content
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo container
              AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  return Container(
                    width: 130,
                    height: 130,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(
                              0.3 + 0.2 * _pulseController.value),
                          blurRadius: 40 + 20 * _pulseController.value,
                          spreadRadius: 10 + 5 * _pulseController.value,
                        ),
                      ],
                    ),
                    child: child,
                  );
                },
                child: Container(
                  width: 130,
                  height: 130,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const RadialGradient(
                      colors: [AppColors.primaryLight, AppColors.primaryDark],
                    ),
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.5),
                      width: 2,
                    ),
                  ),
                  child: const Icon(
                    Icons.directions_car_rounded,
                    color: Colors.white,
                    size: 65,
                  ),
                ),
              )
                  .animate()
                  .scale(
                    begin: const Offset(0, 0),
                    end: const Offset(1, 1),
                    duration: 800.ms,
                    curve: Curves.elasticOut,
                  )
                  .fadeIn(duration: 400.ms),

              const SizedBox(height: 32),

              // App name
              const Text(
                'CypCar',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 48,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 2,
                ),
              )
                  .animate()
                  .slideY(
                    begin: 0.5,
                    end: 0,
                    duration: 600.ms,
                    delay: 300.ms,
                    curve: Curves.easeOut,
                  )
                  .fadeIn(duration: 600.ms, delay: 300.ms),

              const SizedBox(height: 8),

              // Tagline
              Text(
                'Kıbrıs\'ın Araç Pazaryeri',
                style: TextStyle(
                  color: AppColors.darkTextSecondary,
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 1,
                ),
              )
                  .animate()
                  .fadeIn(duration: 600.ms, delay: 600.ms)
                  .slideY(begin: 0.3, end: 0, duration: 600.ms, delay: 600.ms),

              const SizedBox(height: 80),

              // Loading indicator
              SizedBox(
                width: 200,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: const LinearProgressIndicator(
                    backgroundColor: AppColors.darkSurface2,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                  ),
                ),
              )
                  .animate()
                  .fadeIn(duration: 400.ms, delay: 1000.ms),
            ],
          ),

          // Bottom branding
          Positioned(
            bottom: 48,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Text(
                  'v1.0.0',
                  style: TextStyle(
                    color: AppColors.darkTextHint,
                    fontSize: 12,
                  ),
                ),
              ],
            ).animate().fadeIn(duration: 400.ms, delay: 1200.ms),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildAnimatedCircles() {
    return [
      Positioned(
        top: -50,
        right: -50,
        child: AnimatedBuilder(
          animation: _pulseController,
          builder: (context, child) => Container(
            width: 200 + 20 * _pulseController.value,
            height: 200 + 20 * _pulseController.value,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary.withOpacity(0.05),
            ),
          ),
        ),
      ),
      Positioned(
        bottom: -80,
        left: -60,
        child: AnimatedBuilder(
          animation: _pulseController,
          builder: (context, child) => Container(
            width: 280 + 15 * _pulseController.value,
            height: 280 + 15 * _pulseController.value,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primaryDark.withOpacity(0.08),
            ),
          ),
        ),
      ),
    ];
  }
}
