import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Avatar circular com iniciais.
class AppAvatar extends StatelessWidget {
  const AppAvatar({
    super.key,
    required this.initials,
    this.tone = AppTone.neutral,
    this.size = AppSizes.avatarMd,
    this.filled = false,
  });

  final String initials;
  final AppTone tone;
  final double size;

  /// Fundo sólido na cor do tom (ex.: avatar do professor).
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final foreground = filled
        ? AppColors.onAccent
        : (tone == AppTone.neutral ? AppColors.textPrimary : tone.color);

    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: filled ? tone.color : tone.background,
        shape: BoxShape.circle,
      ),
      child: Text(
        initials,
        style: TextStyle(
          fontSize: size * 0.36,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
          color: foreground,
        ),
      ),
    );
  }
}
