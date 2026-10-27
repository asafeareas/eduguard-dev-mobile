import 'package:flutter/material.dart';

import '../../models/academic/student.dart';
import '../../theme/app_theme.dart';
import '../../viewmodels/attendance/attendance_view_model.dart';
import '../../widgets/app_avatar.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_search_field.dart';
import '../../widgets/app_snack_bar.dart';
import '../../widgets/bottom_action_bar.dart';
import '../../widgets/empty_state_view.dart';
import '../../widgets/loading_state_view.dart';
import '../../widgets/metric_tile.dart';
import '../../widgets/page_header.dart';
import '../../widgets/status_badge.dart';
import 'attendance_history_view.dart';

/// Tela principal para realização, alteração e consulta da chamada de uma turma.
class AttendanceView extends StatefulWidget {
  const AttendanceView({
    super.key,
    required this.viewModel,
  });

  final AttendanceViewModel viewModel;

  @override
  State<AttendanceView> createState() => _AttendanceViewState();
}

class _AttendanceViewState extends State<AttendanceView> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    widget.viewModel.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final current = widget.viewModel.selectedDate;
    final picked = await showDatePicker(
      context: context,
      initialDate: current,
      firstDate: DateTime(current.year - 1),
      lastDate: DateTime(current.year + 1),
      helpText: 'SELECIONE A DATA DA CHAMADA',
      confirmText: 'CONFIRMAR',
      cancelText: 'CANCELAR',
    );

    if (picked != null && picked != current) {
      await widget.viewModel.loadForDate(picked);
    }
  }

  void _showTopicDialog(BuildContext context) {
    final controller = TextEditingController(text: widget.viewModel.topic ?? '');
    showDialog<void>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Conteúdo / Tópico da Aula'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'Ex: Introdução a Widgets, Revisão P1...',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () {
                widget.viewModel.updateTopic(
                  controller.text.trim().isEmpty ? null : controller.text.trim(),
                );
                Navigator.of(ctx).pop();
              },
              child: const Text('Salvar'),
            ),
          ],
        );
      },
    );
  }

  void _showObservationDialog(BuildContext context, Student student) {
    final controller = TextEditingController(
      text: widget.viewModel.observation(student.id) ?? '',
    );

    showDialog<void>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text('Observação para ${student.name}'),
          content: TextField(
            controller: controller,
            autofocus: true,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: 'Ex: Atestado médico, saída antecipada...',
            ),
          ),
          actions: [
            if (widget.viewModel.observation(student.id) != null)
              TextButton(
                onPressed: () {
                  widget.viewModel.setStudentObservation(student.id, null);
                  Navigator.of(ctx).pop();
                },
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.danger,
                ),
                child: const Text('Remover'),
              ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () {
                widget.viewModel.setStudentObservation(
                  student.id,
                  controller.text.trim(),
                );
                Navigator.of(ctx).pop();
              },
              child: const Text('Salvar'),
            ),
          ],
        );
      },
    );
  }

  void _openHistory(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => AttendanceHistoryView(viewModel: widget.viewModel),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.viewModel,
      builder: (context, _) {
        final vm = widget.viewModel;
        final academicClass = vm.academicClass;
        final filteredStudents = vm.filteredStudents;

        return Scaffold(
          extendBody: true,
          appBar: AppBar(
            title: const Text('Registro de Frequência'),
            actions: [
              IconButton(
                icon: Badge(
                  isLabelVisible: vm.history.isNotEmpty,
                  label: Text('${vm.history.length}'),
                  child: const Icon(Icons.history),
                ),
                tooltip: 'Histórico de Chamadas',
                onPressed: () => _openHistory(context),
              ),
              const SizedBox(width: AppSpacing.xs),
            ],
          ),
          bottomNavigationBar: BottomActionBar(
            title: '${vm.presentCount} presentes de ${vm.totalStudentsCount}',
            status: vm.isSaved
                ? 'Chamada salva no sistema'
                : 'Alterações pendentes de envio',
            statusTone: vm.isSaved ? AppTone.success : AppTone.warning,
            action: FilledButton.icon(
              onPressed: () async {
                await vm.saveAttendance();
                if (context.mounted) {
                  showAppSnackBar(
                    context,
                    'Chamada do dia ${vm.formattedSelectedDate} salva com sucesso! (${vm.presentCount} presentes, ${vm.absentCount} faltas)',
                    tone: AppTone.success,
                  );
                }
              },
              icon: const Icon(Icons.check_rounded, size: AppSizes.iconMd),
              label: Text(
                vm.isExistingSession ? 'Atualizar Chamada' : 'Salvar Chamada',
              ),
            ),
          ),
          body: vm.isLoading
              ? const LoadingStateView()
              : Builder(
                  // Builder garante o padding inferior da barra translúcida.
                  builder: (context) => CustomScrollView(
                    slivers: [
                      // Cabeçalho da Turma
                      SliverToBoxAdapter(
                        child: PageHeader(
                          title: academicClass.name,
                          subtitle:
                              '${academicClass.code} • ${academicClass.shift} • ${academicClass.room}',
                          trailing: StatusBadge(
                            label: vm.isSaved ? 'Salva' : 'Pendente',
                            icon: vm.isSaved
                                ? Icons.check_circle_rounded
                                : Icons.edit_note_rounded,
                            tone: vm.isSaved
                                ? AppTone.success
                                : AppTone.warning,
                          ),
                        ),
                      ),

                      // Barra de Navegação de Data
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(
                            AppSpacing.page,
                            0,
                            AppSpacing.page,
                            AppSpacing.md,
                          ),
                          child: _DateNavigator(
                            selectedDate: vm.selectedDate,
                            formattedDate: vm.formattedSelectedDate,
                            onPrev: () => vm.loadForDate(
                              vm.selectedDate.subtract(const Duration(days: 1)),
                            ),
                            onNext: () => vm.loadForDate(
                              vm.selectedDate.add(const Duration(days: 1)),
                            ),
                            onTapDate: () => _selectDate(context),
                            onToday: () => vm.loadForDate(DateTime.now()),
                          ),
                        ),
                      ),

                      // Cartão de Resumo e Métricas
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.page,
                          ),
                          child: _AttendanceSummaryCard(
                            presentCount: vm.presentCount,
                            absentCount: vm.absentCount,
                            totalCount: vm.totalStudentsCount,
                            attendanceRate: vm.attendanceRate,
                            topic: vm.topic,
                            onEditTopic: () => _showTopicDialog(context),
                          ),
                        ),
                      ),

                      // Ações Rápidas (Todos Presentes, Todos Ausentes)
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(
                            AppSpacing.page,
                            AppSpacing.md,
                            AppSpacing.page,
                            AppSpacing.md,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () => vm.markAll(true),
                                  icon: const Icon(
                                    Icons.done_all_rounded,
                                    size: AppSizes.iconSm,
                                    color: AppColors.success,
                                  ),
                                  label: const Text('Todos Presentes'),
                                ),
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () => vm.markAll(false),
                                  icon: const Icon(
                                    Icons.remove_done_rounded,
                                    size: AppSizes.iconSm,
                                    color: AppColors.danger,
                                  ),
                                  label: const Text('Todos Ausentes'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Campo de Pesquisa de Estudantes
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(
                            AppSpacing.page,
                            0,
                            AppSpacing.page,
                            AppSpacing.md,
                          ),
                          child: AppSearchField(
                            controller: _searchController,
                            hintText: 'Filtrar estudante por nome ou matrícula...',
                            onChanged: vm.updateSearchFilter,
                            onClear: vm.clearSearch,
                          ),
                        ),
                      ),

                      // Lista de Estudantes
                      if (filteredStudents.isEmpty)
                        const SliverFillRemaining(
                          hasScrollBody: false,
                          child: EmptyStateView(
                            icon: Icons.search_off_rounded,
                            title: 'Nenhum resultado',
                            message: 'Nenhum estudante corresponde ao filtro.',
                          ),
                        )
                      else
                        SliverPadding(
                          padding: EdgeInsets.fromLTRB(
                            AppSpacing.page,
                            0,
                            AppSpacing.page,
                            MediaQuery.paddingOf(context).bottom + AppSpacing.xxl,
                          ),
                          sliver: SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                final student = filteredStudents[index];

                                return _StudentAttendanceCard(
                                  student: student,
                                  isPresent: vm.isPresent(student.id),
                                  observation: vm.observation(student.id),
                                  onSetPresence: (val) =>
                                      vm.setStudentPresence(student.id, val),
                                  onAddObservation: () =>
                                      _showObservationDialog(context, student),
                                );
                              },
                              childCount: filteredStudents.length,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
        );
      },
    );
  }
}

class _DateNavigator extends StatelessWidget {
  const _DateNavigator({
    required this.selectedDate,
    required this.formattedDate,
    required this.onPrev,
    required this.onNext,
    required this.onTapDate,
    required this.onToday,
  });

  final DateTime selectedDate;
  final String formattedDate;
  final VoidCallback onPrev;
  final VoidCallback onNext;
  final VoidCallback onTapDate;
  final VoidCallback onToday;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final now = DateTime.now();
    final isToday = selectedDate.year == now.year &&
        selectedDate.month == now.month &&
        selectedDate.day == now.day;

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.xs),
      borderRadius: AppRadius.mdAll,
      child: Row(
        children: [
          IconButton(
            onPressed: onPrev,
            tooltip: 'Dia anterior',
            icon: const Icon(Icons.chevron_left_rounded),
          ),
          Expanded(
            child: InkWell(
              onTap: onTapDate,
              borderRadius: AppRadius.smAll,
              child: SizedBox(
                height: AppSizes.minTouchTarget,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.calendar_today_rounded,
                      size: AppSizes.iconSm,
                      color: AppColors.accent,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      formattedDate,
                      style: AppTypography.numeric(textTheme.titleSmall),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (!isToday)
            TextButton(
              onPressed: onToday,
              style: TextButton.styleFrom(
                minimumSize: const Size(0, AppSizes.minTouchTarget),
              ),
              child: const Text('Hoje'),
            ),
          IconButton(
            onPressed: onNext,
            tooltip: 'Próximo dia',
            icon: const Icon(Icons.chevron_right_rounded),
          ),
        ],
      ),
    );
  }
}

class _AttendanceSummaryCard extends StatelessWidget {
  const _AttendanceSummaryCard({
    required this.presentCount,
    required this.absentCount,
    required this.totalCount,
    required this.attendanceRate,
    this.topic,
    required this.onEditTopic,
  });

  final int presentCount;
  final int absentCount;
  final int totalCount;
  final double attendanceRate;
  final String? topic;
  final VoidCallback onEditTopic;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final hasTopic = topic?.isNotEmpty == true;

    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.md,
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: MetricTile(
                        value: '$presentCount',
                        label: 'Presentes',
                        tone: AppTone.success,
                      ),
                    ),
                    Expanded(
                      child: MetricTile(
                        value: '$absentCount',
                        label: 'Faltas',
                        tone: AppTone.danger,
                      ),
                    ),
                    Expanded(
                      child: MetricTile(
                        value: '${attendanceRate.toStringAsFixed(0)}%',
                        label: 'Frequência',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                ClipRRect(
                  borderRadius: AppRadius.pillAll,
                  child: LinearProgressIndicator(
                    value: totalCount == 0 ? 0 : presentCount / totalCount,
                    minHeight: 6,
                    backgroundColor: AppColors.danger.withValues(alpha: 0.25),
                    color: AppColors.success,
                  ),
                ),
              ],
            ),
          ),
          const Divider(),
          InkWell(
            onTap: onEditTopic,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.md,
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.menu_book_outlined,
                    size: AppSizes.iconSm,
                    color: AppColors.textTertiary,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      hasTopic
                          ? 'Conteúdo: $topic'
                          : 'Toque para adicionar conteúdo da aula',
                      style: textTheme.bodySmall?.copyWith(
                        color: hasTopic
                            ? AppColors.textPrimary
                            : AppColors.textTertiary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const Icon(
                    Icons.edit_outlined,
                    size: AppSizes.iconSm,
                    color: AppColors.accent,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StudentAttendanceCard extends StatelessWidget {
  const _StudentAttendanceCard({
    required this.student,
    required this.isPresent,
    this.observation,
    required this.onSetPresence,
    required this.onAddObservation,
  });

  final Student student;
  final bool isPresent;
  final String? observation;
  final ValueChanged<bool> onSetPresence;
  final VoidCallback onAddObservation;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return AppCard(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md + 2,
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.sm,
      ),
      borderColor: isPresent
          ? AppColors.border
          : AppColors.danger.withValues(alpha: 0.35),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AppAvatar(
                initials: student.initials,
                tone: isPresent ? AppTone.success : AppTone.danger,
                size: AppSizes.avatarSm + 4,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      student.name,
                      style: textTheme.titleSmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'Matrícula: ${student.registration}',
                      style: textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              _PresenceToggle(
                isPresent: isPresent,
                onChanged: onSetPresence,
              ),
            ],
          ),
          if (observation != null)
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.sm),
              child: Material(
                color: AppColors.surfaceElevated,
                borderRadius: AppRadius.smAll,
                child: InkWell(
                  onTap: onAddObservation,
                  borderRadius: AppRadius.smAll,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.sticky_note_2_outlined,
                          size: AppSizes.iconXs,
                          color: AppColors.accent,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(
                            observation!,
                            style: textTheme.bodySmall?.copyWith(
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        const Icon(
                          Icons.edit_outlined,
                          size: AppSizes.iconXs,
                          color: AppColors.textTertiary,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            )
          else
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: onAddObservation,
                icon: const Icon(Icons.add_rounded, size: AppSizes.iconSm),
                label: const Text('Adicionar observação'),
                style: TextButton.styleFrom(
                  minimumSize: const Size(0, 36),
                  textStyle: textTheme.labelMedium,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Controle segmentado Presente / Falta.
class _PresenceToggle extends StatelessWidget {
  const _PresenceToggle({
    required this.isPresent,
    required this.onChanged,
  });

  final bool isPresent;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: const BoxDecoration(
        color: AppColors.surfaceHighest,
        borderRadius: AppRadius.smAll,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _PresenceSegment(
            label: 'P',
            semanticLabel: 'Presente',
            icon: Icons.check_rounded,
            selected: isPresent,
            tone: AppTone.success,
            onTap: () => onChanged(true),
          ),
          _PresenceSegment(
            label: 'F',
            semanticLabel: 'Falta',
            icon: Icons.close_rounded,
            selected: !isPresent,
            tone: AppTone.danger,
            onTap: () => onChanged(false),
          ),
        ],
      ),
    );
  }
}

class _PresenceSegment extends StatelessWidget {
  const _PresenceSegment({
    required this.label,
    required this.semanticLabel,
    required this.icon,
    required this.selected,
    required this.tone,
    required this.onTap,
  });

  final String label;
  final String semanticLabel;
  final IconData icon;
  final bool selected;
  final AppTone tone;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final foreground = selected ? AppColors.onAccent : AppColors.textTertiary;

    return Semantics(
      button: true,
      selected: selected,
      label: semanticLabel,
      excludeSemantics: true,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: AppMotion.fast,
          curve: AppMotion.curve,
          constraints: const BoxConstraints(minHeight: 36, minWidth: 48),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm + 2),
          decoration: BoxDecoration(
            color: selected ? tone.color : Colors.transparent,
            borderRadius: const BorderRadius.all(Radius.circular(7)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: AppSizes.iconSm, color: foreground),
              const SizedBox(width: AppSpacing.xs),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: foreground,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
