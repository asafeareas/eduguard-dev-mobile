import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../models/academic/student.dart';
import '../../models/grades/assessment.dart';
import '../../theme/app_theme.dart';
import '../../viewmodels/grades/grades_view_model.dart';
import '../../widgets/app_avatar.dart';
import '../../widgets/app_bottom_sheet.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_search_field.dart';
import '../../widgets/app_snack_bar.dart';
import '../../widgets/bottom_action_bar.dart';
import '../../widgets/empty_state_view.dart';
import '../../widgets/error_state_view.dart';
import '../../widgets/loading_state_view.dart';
import '../../widgets/metric_tile.dart';
import '../../widgets/page_header.dart';
import '../../widgets/status_badge.dart';
import 'grade_results_view.dart';

/// Tela de lançamento e edição das notas de uma turma por avaliação.
class GradesView extends StatefulWidget {
  const GradesView({
    super.key,
    required this.viewModel,
  });

  final GradesViewModel viewModel;

  @override
  State<GradesView> createState() => _GradesViewState();
}

class _GradesViewState extends State<GradesView> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    widget.viewModel.dispose();
    super.dispose();
  }

  /// Pergunta ao professor se deseja descartar notas não salvas
  Future<bool> _confirmDiscard(BuildContext context) async {
    if (!widget.viewModel.hasUnsavedChanges) return true;
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Descartar alterações?'),
        content: const Text(
          'Existem notas não salvas nesta avaliação. Deseja descartá-las?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Continuar editando'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
            child: const Text('Descartar'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  Future<void> _selectAssessment(BuildContext context, String id) async {
    final vm = widget.viewModel;
    if (vm.selectedAssessment?.id == id) return;
    if (await _confirmDiscard(context)) {
      vm.selectAssessment(id);
    }
  }

  void _showFeedback(
    BuildContext context,
    String message, {
    AppTone tone = AppTone.neutral,
  }) {
    showAppSnackBar(context, message, tone: tone);
  }

  Future<void> _save(BuildContext context) async {
    final vm = widget.viewModel;
    if (vm.hasErrors) {
      _showFeedback(
        context,
        'Corrija ${vm.errorCount} nota(s) inválida(s) antes de salvar.',
        tone: AppTone.danger,
      );
      return;
    }

    final success = await vm.saveGrades();
    if (!context.mounted) return;

    if (success) {
      _showFeedback(
        context,
        'Notas de "${vm.selectedAssessment?.title}" salvas com sucesso! (${vm.launchedCount} de ${vm.totalStudentsCount} lançadas)',
        tone: AppTone.success,
      );
    } else {
      _showFeedback(
        context,
        vm.errorMessage ?? 'Não foi possível salvar as notas.',
        tone: AppTone.danger,
      );
    }
  }

  Future<void> _openResults(BuildContext context) async {
    final vm = widget.viewModel;
    final assessmentId = await Navigator.of(context).push<String>(
      MaterialPageRoute<String>(
        builder: (_) => GradeResultsView(viewModel: vm),
      ),
    );
    if (assessmentId != null && context.mounted) {
      await _selectAssessment(context, assessmentId);
    }
  }

  void _showAddAssessmentSheet(BuildContext context) {
    final titleCtrl = TextEditingController();
    final maxScoreCtrl = TextEditingController(text: '10');
    final weightCtrl = TextEditingController(text: '1');
    final formKey = GlobalKey<FormState>();
    var type = AssessmentType.exam;
    var date = DateTime.now();

    String? validatePositive(String? v, {required double max}) {
      final value = GradesViewModel.parseScore(v ?? '');
      if (value == null) return 'Informe um número';
      if (value <= 0) return 'Deve ser maior que 0';
      if (value > max) return 'Máximo ${Assessment.formatScore(max)}';
      return null;
    }

    showAppBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                left: AppSpacing.xl,
                right: AppSpacing.xl,
                top: AppSpacing.sm,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + AppSpacing.xl,
              ),
              child: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SheetHeader(
                        title: 'Nova Avaliação',
                        subtitle: 'Defina o tipo, a escala e o peso',
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      TextFormField(
                        controller: titleCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Título da avaliação',
                          hintText: 'Ex: Prova 1, Lista de Exercícios...',
                          prefixIcon: Icon(Icons.assignment_outlined),
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Informe o título'
                            : null,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      DropdownButtonFormField<AssessmentType>(
                        initialValue: type,
                        decoration: const InputDecoration(
                          labelText: 'Tipo',
                        ),
                        items: AssessmentType.values
                            .map(
                              (t) => DropdownMenuItem(
                                value: t,
                                child: Text(t.label),
                              ),
                            )
                            .toList(),
                        onChanged: (t) => type = t ?? type,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: maxScoreCtrl,
                              keyboardType: const TextInputType.numberWithOptions(
                                decimal: true,
                              ),
                              decoration: const InputDecoration(
                                labelText: 'Nota máxima',
                                hintText: 'Ex: 10',
                                    ),
                              validator: (v) => validatePositive(v, max: 100),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: TextFormField(
                              controller: weightCtrl,
                              keyboardType: const TextInputType.numberWithOptions(
                                decimal: true,
                              ),
                              decoration: const InputDecoration(
                                labelText: 'Peso',
                                hintText: 'Ex: 2',
                                    ),
                              validator: (v) => validatePositive(v, max: 10),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),
                      OutlinedButton.icon(
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: ctx,
                            initialDate: date,
                            firstDate: DateTime(date.year - 1),
                            lastDate: DateTime(date.year + 1),
                            helpText: 'DATA DA AVALIAÇÃO',
                            confirmText: 'CONFIRMAR',
                            cancelText: 'CANCELAR',
                          );
                          if (picked != null) {
                            setSheetState(() => date = picked);
                          }
                        },
                        icon: const Icon(
                          Icons.calendar_today_rounded,
                          size: AppSizes.iconSm,
                        ),
                        label: Text(
                          'Data: ${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}',
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xxl),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: () async {
                            if (!(formKey.currentState?.validate() ?? false)) {
                              return;
                            }
                            final title = titleCtrl.text.trim();
                            final created =
                                await widget.viewModel.createAssessment(
                              title: title,
                              type: type,
                              maxScore:
                                  GradesViewModel.parseScore(maxScoreCtrl.text)!,
                              weight:
                                  GradesViewModel.parseScore(weightCtrl.text)!,
                              date: date,
                            );
                            if (ctx.mounted) Navigator.of(ctx).pop();
                            if (context.mounted) {
                              _showFeedback(
                                context,
                                created
                                    ? 'Avaliação "$title" cadastrada!'
                                    : 'Não foi possível cadastrar a avaliação.',
                                tone: created
                                    ? AppTone.success
                                    : AppTone.danger,
                              );
                            }
                          },
                          child: const Text('Salvar Avaliação'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _addAssessment(BuildContext context) async {
    if (await _confirmDiscard(context) && context.mounted) {
      widget.viewModel.discardChanges();
      _showAddAssessmentSheet(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.viewModel,
      builder: (context, _) {
        final vm = widget.viewModel;
        final status = vm.status;

        return PopScope(
          canPop: !vm.hasUnsavedChanges,
          onPopInvokedWithResult: (didPop, _) async {
            if (didPop) return;
            final navigator = Navigator.of(context);
            if (await _confirmDiscard(context)) {
              vm.discardChanges();
              navigator.pop();
            }
          },
          child: Scaffold(
            extendBody: true,
            appBar: AppBar(
              title: const Text('Lançamento de Notas'),
              actions: [
                if (status == GradesStatus.success)
                  IconButton(
                    icon: const Icon(Icons.bar_chart_rounded),
                    tooltip: 'Consultar Resultados',
                    onPressed: () => _openResults(context),
                  ),
                if (status == GradesStatus.success ||
                    status == GradesStatus.empty)
                  IconButton(
                    icon: const Icon(Icons.add_rounded),
                    tooltip: 'Nova Avaliação',
                    onPressed: () => _addAssessment(context),
                  ),
                const SizedBox(width: AppSpacing.xs),
              ],
            ),
            bottomNavigationBar: status == GradesStatus.success
                ? _SaveBar(
                    launchedCount: vm.launchedCount,
                    totalCount: vm.totalStudentsCount,
                    errorCount: vm.errorCount,
                    hasUnsavedChanges: vm.hasUnsavedChanges,
                    isSaving: vm.isSaving,
                    isExistingLaunch: vm.isExistingLaunch,
                    onSave: vm.canSave || vm.hasErrors
                        ? () => _save(context)
                        : null,
                  )
                : null,
            // Builder garante o padding inferior da barra translúcida.
            body: Builder(
              builder: (context) => _buildBody(context, vm, status),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBody(
    BuildContext context,
    GradesViewModel vm,
    GradesStatus status,
  ) {
    // 1. Estado de Carregamento
    if (status == GradesStatus.loading || status == GradesStatus.initial) {
      return const LoadingStateView(message: 'Carregando avaliações...');
    }

    // 2. Estado de Erro
    if (status == GradesStatus.error) {
      return ErrorStateView(
        title: 'Falha ao carregar notas',
        message: vm.errorMessage ??
            'Ocorreu uma falha inesperada ao carregar as avaliações da turma.',
        retryLabel: 'Tentar novamente',
        onRetry: vm.loadAssessments,
      );
    }

    // 3. Estado Vazio (sem avaliações cadastradas)
    if (status == GradesStatus.empty) {
      return EmptyStateView(
        icon: Icons.assignment_outlined,
        title: 'Nenhuma avaliação cadastrada',
        message:
            'Cadastre uma avaliação para ${vm.academicClass.name} e defina a escala de notas antes de lançar os resultados.',
        actionLabel: 'Cadastrar avaliação',
        onActionPressed: () => _showAddAssessmentSheet(context),
      );
    }

    // 4. Estado de Sucesso
    final academicClass = vm.academicClass;
    final assessment = vm.selectedAssessment!;
    final filteredStudents = vm.filteredStudents;

    return CustomScrollView(
      slivers: [
        // Cabeçalho da Turma
        SliverToBoxAdapter(
          child: PageHeader(
            title: academicClass.name,
            subtitle:
                '${academicClass.code} • ${academicClass.semester} • ${vm.totalStudentsCount} estudantes',
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.page,
              AppSpacing.sm,
              AppSpacing.page,
              AppSpacing.md,
            ),
          ),
        ),

        // Seleção da Avaliação
        SliverToBoxAdapter(
          child: SizedBox(
            height: 48,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
              itemCount: vm.assessments.length,
              separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
              itemBuilder: (context, index) {
                final item = vm.assessments[index];
                return Center(
                  child: ChoiceChip(
                    label: Text(item.title),
                    selected: item.id == assessment.id,
                    onSelected: (_) => _selectAssessment(context, item.id),
                  ),
                );
              },
            ),
          ),
        ),

        // Resumo da Avaliação
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.page,
              AppSpacing.md,
              AppSpacing.page,
              0,
            ),
            child: _AssessmentSummaryCard(
              assessment: assessment,
              launchedCount: vm.launchedCount,
              pendingCount: vm.pendingCount,
              average: vm.currentAverage,
              hasUnsavedChanges: vm.hasUnsavedChanges,
            ),
          ),
        ),

        // Campo de Pesquisa de Estudantes
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.page),
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
                  return _StudentGradeCard(
                    key: ValueKey(
                      'grade-${assessment.id}-${student.id}-${vm.inputsVersion}',
                    ),
                    student: student,
                    maxScore: assessment.maxScore,
                    initialValue: vm.scoreInput(student.id),
                    errorText: vm.scoreError(student.id),
                    onChanged: (value) => vm.setScoreInput(student.id, value),
                  );
                },
                childCount: filteredStudents.length,
              ),
            ),
          ),
      ],
    );
  }
}

class _AssessmentSummaryCard extends StatelessWidget {
  const _AssessmentSummaryCard({
    required this.assessment,
    required this.launchedCount,
    required this.pendingCount,
    required this.average,
    required this.hasUnsavedChanges,
  });

  final Assessment assessment;
  final int launchedCount;
  final int pendingCount;
  final double? average;
  final bool hasUnsavedChanges;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '${assessment.type.label} • ${assessment.formattedDate}',
                  style: textTheme.labelMedium,
                ),
              ),
              StatusBadge(
                label: hasUnsavedChanges ? 'Pendente' : 'Salva',
                icon: hasUnsavedChanges
                    ? Icons.edit_note_rounded
                    : Icons.check_circle_rounded,
                tone: hasUnsavedChanges ? AppTone.warning : AppTone.success,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: MetricTile(
                  label: 'Escala',
                  value: assessment.scaleLabel,
                ),
              ),
              Expanded(
                child: MetricTile(
                  label: 'Peso',
                  value: Assessment.formatScore(assessment.weight),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          const Divider(),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: MetricTile(
                  label: 'Lançadas',
                  value: '$launchedCount',
                  tone: AppTone.success,
                ),
              ),
              Expanded(
                child: MetricTile(
                  label: 'Pendentes',
                  value: '$pendingCount',
                  tone: AppTone.warning,
                ),
              ),
              Expanded(
                child: MetricTile(
                  label: 'Média',
                  value: average == null
                      ? '—'
                      : Assessment.formatScore(average!),
                  tone: AppTone.accent,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StudentGradeCard extends StatelessWidget {
  const _StudentGradeCard({
    super.key,
    required this.student,
    required this.maxScore,
    required this.initialValue,
    required this.errorText,
    required this.onChanged,
  });

  final Student student;
  final double maxScore;
  final String initialValue;
  final String? errorText;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final hasError = errorText != null;

    return AppCard(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      borderColor: hasError
          ? AppColors.danger.withValues(alpha: 0.5)
          : AppColors.border,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.xxs),
            child: AppAvatar(
              initials: student.initials,
              size: AppSizes.avatarSm + 4,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: AppSpacing.xs),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    student.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.titleSmall,
                  ),
                  Text(
                    'Matrícula ${student.registration}',
                    style: textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          SizedBox(
            width: 108,
            child: TextFormField(
              initialValue: initialValue,
              onChanged: onChanged,
              textAlign: TextAlign.center,
              style: AppTypography.numeric(textTheme.titleSmall),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                LengthLimitingTextInputFormatter(6),
              ],
              decoration: InputDecoration(
                isDense: true,
                hintText: '—',
                suffixText: '/${Assessment.formatScore(maxScore)}',
                errorText: errorText,
                errorMaxLines: 2,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.md,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SaveBar extends StatelessWidget {
  const _SaveBar({
    required this.launchedCount,
    required this.totalCount,
    required this.errorCount,
    required this.hasUnsavedChanges,
    required this.isSaving,
    required this.isExistingLaunch,
    required this.onSave,
  });

  final int launchedCount;
  final int totalCount;
  final int errorCount;
  final bool hasUnsavedChanges;
  final bool isSaving;
  final bool isExistingLaunch;
  final VoidCallback? onSave;

  @override
  Widget build(BuildContext context) {
    final String statusText;
    final AppTone statusTone;
    if (errorCount > 0) {
      statusText = '$errorCount nota(s) inválida(s)';
      statusTone = AppTone.danger;
    } else if (hasUnsavedChanges) {
      statusText = 'Alterações pendentes de envio';
      statusTone = AppTone.warning;
    } else {
      statusText = 'Notas salvas no sistema';
      statusTone = AppTone.success;
    }

    return BottomActionBar(
      title: '$launchedCount de $totalCount notas lançadas',
      status: statusText,
      statusTone: statusTone,
      action: FilledButton.icon(
        onPressed: isSaving ? null : onSave,
        icon: isSaving
            ? const SizedBox(
                width: AppSizes.iconSm,
                height: AppSizes.iconSm,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.textSecondary,
                ),
              )
            : const Icon(Icons.check_rounded, size: AppSizes.iconMd),
        label: Text(isExistingLaunch ? 'Atualizar Notas' : 'Salvar Notas'),
      ),
    );
  }
}
