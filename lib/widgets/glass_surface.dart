import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Superfície translúcida com desfoque de fundo (Glassmorphism).
///
/// Use apenas em camadas que flutuam sobre conteúdo rolável — barras
/// inferiores e folhas modais — onde o desfoque comunica profundidade.
/// O [RepaintBoundary] isola o filtro para evitar repinturas desnecessárias.
class GlassSurface extends StatelessWidget {
  const GlassSurface({
    super.key,
    required this.child,
    this.borderRadius = BorderRadius.zero,
    this.border,
    this.color = AppColors.glassFill,
    this.blurSigma = AppGlass.blurSigma,
  });

  final Widget child;
  final BorderRadius borderRadius;
  final Border? border;
  final Color color;
  final double blurSigma;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: ClipRRect(
        borderRadius: borderRadius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: color,
              borderRadius: borderRadius,
              border: border ?? Border.all(color: AppColors.glassBorder),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
