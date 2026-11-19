import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../state/app_state.dart';
import 'customer/customer_shell.dart';
import 'mechanic/mechanic_shell.dart';
import 'auth_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
    _scale = CurvedAnimation(parent: _controller, curve: Curves.elasticOut);

    Future<void>.delayed(const Duration(milliseconds: 1500), () {
      if (!mounted) return;
      final shell = appState.isSignedIn
          ? (appState.isMechanic
              ? const MechanicShell()
              : const CustomerShell())
          : const AuthScreen();
      Navigator.of(context).pushReplacement(
        PageRouteBuilder<void>(
          transitionDuration: const Duration(milliseconds: 420),
          pageBuilder: (_, __, ___) => shell,
          transitionsBuilder: (_, animation, __, child) => FadeTransition(
            opacity: animation,
            child: child,
          ),
        ),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: _SplashBody());
  }
}

// Kept as a separate widget so the controller does not rebuild the tree.
class _SplashBody extends StatelessWidget {
  const _SplashBody();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.navy,
            const Color(0xFF123049),
            const Color(0xFF0A5F5A),
          ],
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: -120,
            right: -80,
            child: _glow(300, AppColors.teal.withOpacity(0.16)),
          ),
          Positioned(
            bottom: -100,
            left: -60,
            child: _glow(260, AppColors.amber.withOpacity(0.10)),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ScaleTransition(
                scale: _splashScale(context),
                child: Container(
                  width: 92,
                  height: 92,
                  decoration: BoxDecoration(
                    gradient: AppColors.tealGradient,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.teal.withOpacity(0.45),
                        blurRadius: 34,
                        offset: const Offset(0, 14),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.car_repair_rounded,
                      size: 50, color: AppColors.white),
                ),
              ),
              const SizedBox(height: 22),
              Text(
                'CarAid',
                style: TextStyle(
                  fontFamily: 'UberMove',
                  fontSize: 38,
                  color: AppColors.white,
                  letterSpacing: -0.6,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Help arrives.',
                style: TextStyle(
                  color: AppColors.white.withOpacity(0.72),
                  fontSize: 14,
                  letterSpacing: 3.2,
                ),
              ),
              const SizedBox(height: 46),
              SizedBox(
                width: 140,
                child: LinearProgressIndicator(
                  minHeight: 3,
                  backgroundColor: AppColors.white.withOpacity(0.15),
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(AppColors.amber),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // The animation belongs to the stateful parent; inherited here cheaply.
  static Animation<double> _splashScale(BuildContext context) {
    final state = context.findAncestorStateOfType<_SplashScreenState>();
    return state?._scale ?? const AlwaysStoppedAnimation<double>(1);
  }

  static Widget _glow(double size, Color color) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      );
}
