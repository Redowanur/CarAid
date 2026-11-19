import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final VoidCallback? onTap;
  final Color color;
  final Gradient? gradient;
  final Color? borderColor;
  final double radius;
  final List<BoxShadow>? shadow;
  final EdgeInsetsGeometry? margin;

  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.onTap,
    this.color = AppColors.white,
    this.gradient,
    this.borderColor,
    this.radius = 22,
    this.shadow,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    final radiusValue = BorderRadius.circular(radius);
    final container = Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: gradient == null ? color : null,
        gradient: gradient,
        borderRadius: radiusValue,
        border: Border.all(color: borderColor ?? AppColors.border),
        boxShadow: shadow ?? AppColors.softShadow,
      ),
      child: child,
    );

    if (onTap == null) return container;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: radiusValue,
        onTap: onTap,
        child: container,
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;
  final EdgeInsets padding;

  const SectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
    this.padding = const EdgeInsets.fromLTRB(20, 26, 20, 12),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Row(
        children: [
          Expanded(child: Text(title, style: AppText.h2())),
          if (actionLabel != null)
            GestureDetector(
              onTap: onAction,
              child: Row(
                children: [
                  Text(
                    actionLabel!,
                    style: AppText.label(
                      size: 12.5,
                      color: AppColors.teal,
                      weight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 2),
                  const Icon(Icons.arrow_forward_rounded,
                      size: 16, color: AppColors.teal),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class IconTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double size;
  final double radius;

  const IconTile({
    super.key,
    required this.icon,
    this.color = AppColors.teal,
    this.size = 46,
    this.radius = 15,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(radius),
      ),
      child: Icon(icon, color: color, size: size * 0.48),
    );
  }
}

class StatusPill extends StatelessWidget {
  final String label;
  final Color color;
  final IconData? icon;

  const StatusPill({
    super.key,
    required this.label,
    this.color = AppColors.teal,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 13, color: color),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: AppText.label(
              size: 11,
              color: color,
              weight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class InitialsAvatar extends StatelessWidget {
  final String name;
  final double size;
  final Color color;
  final bool showOnline;

  const InitialsAvatar({
    super.key,
    required this.name,
    this.size = 48,
    this.color = AppColors.teal,
    this.showOnline = false,
  });

  @override
  Widget build(BuildContext context) {
    final letters = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();
    final initials = letters.isEmpty
        ? '?'
        : letters.length == 1
            ? letters.first.substring(0, 1).toUpperCase()
            : (letters.first.substring(0, 1) + letters.last.substring(0, 1))
                .toUpperCase();

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [color.withOpacity(0.95), color.withOpacity(0.65)],
              ),
              borderRadius: BorderRadius.circular(size * 0.34),
            ),
            alignment: Alignment.center,
            child: Text(
              initials,
              style: AppText.display(size * 0.34, color: AppColors.white),
            ),
          ),
          if (showOnline)
            Positioned(
              right: 1,
              bottom: 1,
              child: Container(
                width: size * 0.26,
                height: size * 0.26,
                decoration: BoxDecoration(
                  color: AppColors.teal,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.white, width: 2),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final Widget? action;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: AppColors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 34, color: AppColors.faint),
          ),
          const SizedBox(height: 18),
          Text(title, style: AppText.h3(), textAlign: TextAlign.center),
          const SizedBox(height: 8),
          Text(
            message,
            style: AppText.body(color: AppColors.muted, height: 1.5),
            textAlign: TextAlign.center,
          ),
          if (action != null) ...[
            const SizedBox(height: 20),
            action!,
          ],
        ],
      ),
    );
  }
}
