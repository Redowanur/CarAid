import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'screens/splash_screen.dart';

class CarAidApp extends StatelessWidget {
  const CarAidApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CarAid',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: const SplashScreen(),
      builder: (context, child) {
        final media = MediaQuery.of(context);
        return MediaQuery(
          data: media.copyWith(
            textScaleFactor: media.textScaleFactor.clamp(0.9, 1.15),
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
