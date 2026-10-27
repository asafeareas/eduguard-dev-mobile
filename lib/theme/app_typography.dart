import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Hierarquia tipográfica do EduGuard.
///
/// Usa a fonte nativa da plataforma (SF Pro no iOS, Roboto no Android),
/// com tamanhos e pesos inspirados na escala do Apple HIG.
abstract final class AppTypography {
  static const List<FontFeature> _tabular = [FontFeature.tabularFigures()];

  static const TextTheme textTheme = TextTheme(
    // Large Title / títulos de destaque
    displaySmall: TextStyle(
      fontSize: 34,
      height: 1.15,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.6,
      color: AppColors.textPrimary,
    ),
    // Title 1
    headlineMedium: TextStyle(
      fontSize: 28,
      height: 1.2,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.5,
      color: AppColors.textPrimary,
    ),
    // Title 2 — números de destaque (métricas)
    headlineSmall: TextStyle(
      fontSize: 24,
      height: 1.2,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.4,
      color: AppColors.textPrimary,
      fontFeatures: _tabular,
    ),
    // Title 3 — títulos de tela e de folhas modais
    titleLarge: TextStyle(
      fontSize: 20,
      height: 1.25,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.3,
      color: AppColors.textPrimary,
    ),
    // Headline — títulos de cards e seções
    titleMedium: TextStyle(
      fontSize: 17,
      height: 1.3,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.2,
      color: AppColors.textPrimary,
    ),
    // Subheadline — títulos de itens de lista
    titleSmall: TextStyle(
      fontSize: 15,
      height: 1.3,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.1,
      color: AppColors.textPrimary,
    ),
    // Body
    bodyLarge: TextStyle(
      fontSize: 16,
      height: 1.4,
      fontWeight: FontWeight.w400,
      letterSpacing: -0.1,
      color: AppColors.textPrimary,
    ),
    // Callout
    bodyMedium: TextStyle(
      fontSize: 15,
      height: 1.4,
      fontWeight: FontWeight.w400,
      color: AppColors.textSecondary,
    ),
    // Footnote — textos auxiliares
    bodySmall: TextStyle(
      fontSize: 13,
      height: 1.35,
      fontWeight: FontWeight.w400,
      color: AppColors.textSecondary,
    ),
    // Labels de botões
    labelLarge: TextStyle(
      fontSize: 15,
      height: 1.2,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.1,
    ),
    // Labels de chips / metadados
    labelMedium: TextStyle(
      fontSize: 13,
      height: 1.2,
      fontWeight: FontWeight.w500,
      color: AppColors.textSecondary,
    ),
    // Caption — badges e legendas
    labelSmall: TextStyle(
      fontSize: 11,
      height: 1.2,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.2,
      color: AppColors.textSecondary,
    ),
  );

  /// Estilo para valores numéricos alinhados (notas, contadores).
  static TextStyle numeric(TextStyle? base) =>
      (base ?? const TextStyle()).copyWith(fontFeatures: _tabular);

  /// Rótulo de seção em caixa alta discreta (estilo "grouped list" do iOS).
  static const TextStyle overline = TextStyle(
    fontSize: 12,
    height: 1.2,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.6,
    color: AppColors.textTertiary,
  );
}
