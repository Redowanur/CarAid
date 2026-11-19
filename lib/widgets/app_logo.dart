import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';

class CarAidLogo extends StatelessWidget {
  final double size;
  final bool light;

  const CarAidLogo({super.key, this.size = 52, this.light = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(size * 0.30),
            boxShadow: [
              BoxShadow(
                color: AppColors.teal.withOpacity(0.35),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(size * 0.30),
            child: Image.asset(
              'assets/logo.jpeg',
              width: size,
              height: size,
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          'CarAid',
          style: AppText.display(size * 0.58,
              color: light ? AppColors.white : AppColors.ink),
        ),
      ],
    );
  }
}
