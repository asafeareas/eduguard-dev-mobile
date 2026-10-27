import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Ícone dentro de um quadrado arredondado com fundo tonal.
class IconTile extends StatelessWidget {
  const IconTile({
    super.key,
    required this.icon,
    this.tone = AppTone.accent,
    this.size = AppSizes.iconTile,
    this.filled = false,
  });

  final IconData icon;
  final AppTone tone;
  final double size;

  /// Quando verdadeiro, usa a cor sólida do tom (para itens de destaque).
  final bool filled;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: filled ? tone.color : tone.background,
        borderRadius: BorderRadius.circular(size * 0.28),
      ),
      child: Icon(
        icon,
        size: size * 0.5,
        color: filled ? AppColors.onAccent : tone.color,
      ),
    );
  }
}
