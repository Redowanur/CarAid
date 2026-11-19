import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';

class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Gradient? gradient;
  final Color? background;
  final Color foreground;
  final double height;
  final bool loading;
  final bool expanded;

  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.gradient,
    this.background,
    this.foreground = AppColors.white,
    this.height = 54,
    this.loading = false,
    this.expanded = true,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null && !loading;
    final decoration = BoxDecoration(
      gradient: enabled
          ? gradient ?? (background == null ? AppColors.tealGradient : null)
          : null,
      color: enabled
          ? (gradient != null ? null : background ?? AppColors.teal)
          : AppColors.border,
      borderRadius: BorderRadius.circular(18),
      boxShadow: enabled
          ? [
              BoxShadow(
                color: (background ?? AppColors.teal).withOpacity(0.28),
                blurRadius: 22,
                offset: const Offset(0, 10),
              ),
            ]
          : null,
    );

    return SizedBox(
      width: expanded ? double.infinity : null,
      height: height,
      child: Material(
        color: Colors.transparent,
        child: Ink(
          decoration: decoration,
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: enabled ? onPressed : null,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: expanded ? MainAxisSize.max : MainAxisSize.min,
                children: [
                  if (loading)
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.2,
                        color: foreground,
                      ),
                    )
                  else if (icon != null)
                    Icon(icon,
                        size: 20,
                        color: enabled ? foreground : AppColors.faint),
                  if (loading || icon != null) const SizedBox(width: 10),
                  Text(
                    label,
                    style: AppText.body(
                      size: 15.5,
                      weight: FontWeight.w700,
                      color: enabled ? foreground : AppColors.faint,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class SecondaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Color color;
  final double height;

  const SecondaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.color = AppColors.ink,
    this.height = 54,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: height,
      child: Material(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onPressed,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 20, color: color),
                  const SizedBox(width: 10),
                ],
                Text(
                  label,
                  style: AppText.body(
                    size: 15,
                    weight: FontWeight.w700,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final Color background;
  final Color foreground;
  final double size;
  final String? tooltip;

  const CircleIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.background = AppColors.white,
    this.foreground = AppColors.ink,
    this.size = 46,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final button = Material(
      color: background,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: SizedBox(
          width: size,
          height: size,
          child: Icon(icon, size: size * 0.46, color: foreground),
        ),
      ),
    );
    if (tooltip == null) return button;
    return Tooltip(message: tooltip!, child: button);
  }
}

class AppPill extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback? onTap;
  final IconData? icon;
  final Color selectedColor;
  final EdgeInsets padding;

  const AppPill({
    super.key,
    required this.label,
    this.selected = false,
    this.onTap,
    this.icon,
    this.selectedColor = AppColors.teal,
    this.padding =
        const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? selectedColor.withOpacity(0.12) : AppColors.white,
      borderRadius: BorderRadius.circular(40),
      child: InkWell(
        borderRadius: BorderRadius.circular(40),
        onTap: onTap,
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(40),
            border: Border.all(
              color: selected ? selectedColor : AppColors.border,
              width: selected ? 1.4 : 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: 16,
                  color: selected ? selectedColor : AppColors.muted,
                ),
                const SizedBox(width: 6),
              ],
              Text(
                label,
                style: AppText.body(
                  size: 12.5,
                  weight: FontWeight.w600,
                  color: selected ? selectedColor : AppColors.muted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
