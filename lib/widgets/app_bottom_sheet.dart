import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'glass_surface.dart';

/// Exibe uma folha modal translúcida padronizada, com alça de arraste.
Future<T?> showAppBottomSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool isScrollControlled = false,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: isScrollControlled,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    elevation: 0,
    builder: (ctx) => GlassSurface(
      borderRadius: AppRadius.sheet,
      color: AppColors.surfaceElevated.withValues(alpha: 0.86),
      border: const Border(top: BorderSide(color: AppColors.glassBorder)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const _Grabber(),
          Flexible(child: builder(ctx)),
        ],
      ),
    ),
  );
}

class _Grabber extends StatelessWidget {
  const _Grabber();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.sm),
      child: Container(
        width: 36,
        height: 5,
        decoration: const BoxDecoration(
          color: AppColors.borderStrong,
          borderRadius: AppRadius.pillAll,
        ),
      ),
    );
  }
}

/// Cabeçalho de folhas modais: título, subtítulo opcional e botão fechar.
class SheetHeader extends StatelessWidget {
  const SheetHeader({super.key, required this.title, this.subtitle});

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: AppSpacing.sm),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: textTheme.titleLarge),
                if (subtitle != null) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(subtitle!, style: textTheme.bodySmall),
                ],
              ],
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.close_rounded, size: AppSizes.iconMd),
          tooltip: 'Fechar',
          style: IconButton.styleFrom(
            backgroundColor: AppColors.surfaceHighest,
            foregroundColor: AppColors.textSecondary,
            shape: const CircleBorder(),
            minimumSize: const Size.square(32),
            fixedSize: const Size.square(32),
            padding: EdgeInsets.zero,
            tapTargetSize: MaterialTapTargetSize.padded,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }
}
