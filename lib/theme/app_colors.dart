import 'package:flutter/material.dart';

/// Paleta oficial do EduGuard (tema exclusivamente dark).
///
/// Fundos em preto/grafite organizados em camadas, texto em três níveis de
/// ênfase, uma única cor de destaque e cores semânticas inspiradas nas
/// cores de sistema do iOS em modo escuro.
abstract final class AppColors {
  // Camadas de fundo (da mais profunda para a mais elevada)
  static const Color background = Color(0xFF0A0A0C);
  static const Color surface = Color(0xFF141417);
  static const Color surfaceElevated = Color(0xFF1C1C21);
  static const Color surfaceHighest = Color(0xFF26262C);

  // Texto e ícones
  static const Color textPrimary = Color(0xFFF5F5F7);
  static const Color textSecondary = Color(0xFFA1A1AA);
  static const Color textTertiary = Color(0xFF6B6B74);

  // Linhas e separadores (hairlines translúcidas)
  static const Color border = Color(0x14FFFFFF); // 8%
  static const Color borderStrong = Color(0x24FFFFFF); // 14%
  static const Color divider = Color(0x0FFFFFFF); // 6%

  // Destaque
  static const Color accent = Color(0xFF4F8CFF);
  static const Color accentMuted = Color(0xFF1A2A4A);
  static const Color onAccent = Color(0xFFFFFFFF);

  // Semânticas
  static const Color success = Color(0xFF32D74B);
  static const Color warning = Color(0xFFFF9F0A);
  static const Color danger = Color(0xFFFF453A);
  static const Color info = Color(0xFF64D2FF);

  // Glassmorphism
  static const Color glassFill = Color(0xB8141417); // ~72% de surface
  static const Color glassBorder = Color(0x1AFFFFFF); // 10%

  static const Color scrim = Color(0x99000000);
}

/// Tons semânticos usados por badges, ícones e métricas.
enum AppTone { neutral, accent, success, warning, danger, info }

extension AppToneColors on AppTone {
  Color get color => switch (this) {
    AppTone.neutral => AppColors.textSecondary,
    AppTone.accent => AppColors.accent,
    AppTone.success => AppColors.success,
    AppTone.warning => AppColors.warning,
    AppTone.danger => AppColors.danger,
    AppTone.info => AppColors.info,
  };

  /// Fundo translúcido do tom, discreto o suficiente para manter o contraste.
  Color get background => this == AppTone.neutral
      ? AppColors.surfaceHighest
      : color.withValues(alpha: 0.14);
}
