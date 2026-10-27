import 'package:flutter/material.dart';

import '../../models/attendance/attendance_session.dart';
import '../../theme/app_theme.dart';
import '../../viewmodels/attendance/attendance_view_model.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_snack_bar.dart';
import '../../widgets/empty_state_view.dart';
import '../../widgets/page_header.dart';
import '../../widgets/status_badge.dart';

/// Tela para consulta do histórico de chamadas já registradas para a turma.
class AttendanceHistoryView extends StatelessWidget {
  const AttendanceHistoryView({super.key, required this.viewModel});

  final AttendanceViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final history = viewModel.history;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Histórico de Chamadas'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PageHeader(
            title: viewModel.academicClass.name,
            subtitle:
                '${viewModel.academicClass.code} • ${history.length} chamada(s) registrada(s)',
          ),
          Expanded(
            child: history.isEmpty
                ? const EmptyStateView(
                    icon: Icons.event_busy_outlined,
                    title: 'Nenhuma chamada registrada',
                    message:
                        'Realize e salve a primeira chamada para que ela apareça aqui.',
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.page,
                      0,
                      AppSpacing.page,
                      AppSpacing.xxl,
                    ),
                    itemCount: history.length,
                    separatorBuilder: (_, _) =>
                        const SizedBox(height: AppSpacing.sm),
                    itemBuilder: (context, index) {
                      final session = history[index];
                      return _HistoryCard(
                        session: session,
                        isSelected: AttendanceSession.normalizeDate(session.date) ==
                            viewModel.selectedDate,
                        onTap: () {
                          viewModel.loadForDate(session.date);
                          Navigator.of(context).pop();
                          showAppSnackBar(
                            context,
                            'Chamada do dia ${session.formattedDate} carregada.',
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  const _HistoryCard({
    required this.session,
    required this.isSelected,
    required this.onTap,
  });

  final AttendanceSession session;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final rate = session.attendanceRate;

    final AppTone rateTone;
    if (rate >= 80) {
      rateTone = AppTone.success;
    } else if (rate >= 60) {
      rateTone = AppTone.warning;
    } else {
      rateTone = AppTone.danger;
    }

    return AppCard(
      onTap: onTap,
      borderColor: isSelected ? AppColors.accent : AppColors.border,
      borderWidth: isSelected ? 1.5 : 1,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                session.formattedDate,
                style: AppTypography.numeric(textTheme.titleMedium),
              ),
              if (isSelected) ...[
                const SizedBox(width: AppSpacing.sm),
                const StatusBadge(label: 'Em edição', tone: AppTone.accent),
              ],
              const Spacer(),
              StatusBadge(
                label: '${rate.toStringAsFixed(0)}% presença',
                tone: rateTone,
              ),
            ],
          ),
          if (session.topic != null && session.topic!.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              session.topic!,
              style: textTheme.bodySmall,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              _SummaryPill(
                icon: Icons.check_circle_outline_rounded,
                tone: AppTone.success,
                text: '${session.presentCount} presentes',
              ),
              const SizedBox(width: AppSpacing.lg),
              _SummaryPill(
                icon: Icons.highlight_off_rounded,
                tone: AppTone.danger,
                text: '${session.absentCount} faltas',
              ),
              const Spacer(),
              Text(
                'Abrir',
                style: textTheme.labelMedium?.copyWith(
                  color: AppColors.accent,
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                size: AppSizes.iconMd,
                color: AppColors.accent,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryPill extends StatelessWidget {
  const _SummaryPill({
    required this.icon,
    required this.tone,
    required this.text,
  });

  final IconData icon;
  final AppTone tone;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: AppSizes.iconXs, color: tone.color),
        const SizedBox(width: AppSpacing.xs),
        Text(
          text,
          style: AppTypography.numeric(Theme.of(context).textTheme.labelMedium),
        ),
      ],
    );
  }
}
