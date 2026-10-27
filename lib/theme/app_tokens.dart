import 'package:flutter/widgets.dart';

/// Escala de espaçamento baseada em múltiplos de 4.
abstract final class AppSpacing {
  static const double xxs = 2;
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;

  /// Margem lateral padrão das telas em celulares.
  static const double page = 16;

  /// Margem lateral em telas largas (tablets / paisagem).
  static const double pageWide = 28;

  /// Largura a partir da qual a tela é considerada larga.
  static const double wideBreakpoint = 600;

  /// Largura máxima do conteúdo em telas largas.
  static const double maxContentWidth = 720;

  static double pagePadding(double width) =>
      width > wideBreakpoint ? pageWide : page;
}

/// Raios de borda.
abstract final class AppRadius {
  static const double xs = 6;
  static const double sm = 10;
  static const double md = 14;
  static const double lg = 20;
  static const double xl = 28;
  static const double pill = 999;

  static const BorderRadius smAll = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius mdAll = BorderRadius.all(Radius.circular(md));
  static const BorderRadius lgAll = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius pillAll = BorderRadius.all(Radius.circular(pill));
  static const BorderRadius sheet = BorderRadius.vertical(
    top: Radius.circular(xl),
  );
}

/// Tamanhos de ícones e áreas de toque.
abstract final class AppSizes {
  static const double iconXs = 14;
  static const double iconSm = 16;
  static const double iconMd = 20;
  static const double iconLg = 24;

  /// Área de toque mínima recomendada (HIG: 44pt; Material: 48dp).
  static const double minTouchTarget = 44;
  static const double buttonHeight = 50;
  static const double avatarSm = 36;
  static const double avatarMd = 44;
  static const double iconTile = 40;
}

/// Durações e curvas de animação.
abstract final class AppMotion {
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 240);
  static const Curve curve = Curves.easeOutCubic;
}

/// Parâmetros do efeito de vidro (Glassmorphism).
abstract final class AppGlass {
  /// Desfoque moderado: suficiente para separar camadas sem pesar na GPU.
  static const double blurSigma = 24;
}
