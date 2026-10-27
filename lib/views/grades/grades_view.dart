import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../models/academic/student.dart';
import '../../models/grades/assessment.dart';
import '../../viewmodels/grades/grades_view_model.dart';
import '../../widgets/empty_state_view.dart';
import '../../widgets/error_state_view.dart';
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

  void _showFeedback(BuildContext context, String message, {Color? color}) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: color,
      ),
    );
  }

  Future<void> _save(BuildContext context) async {
    final vm = widget.viewModel;
    if (vm.hasErrors) {
      _showFeedback(
        context,
        'Corrija ${vm.errorCount} nota(s) inválida(s) antes de salvar.',
        color: Theme.of(context).colorScheme.error,
      );
      return;
    }

    final success = await vm.saveGrades();
    if (!context.mounted) return;

    if (success) {
      _showFeedback(
        context,
        'Notas de "${vm.selectedAssessment?.title}" salvas com sucesso! (${vm.launchedCount} de ${vm.totalStudentsCount} lançadas)',
        color: Colors.green.shade800,
      );
    } else {
      _showFeedback(
        context,
        vm.errorMessage ?? 'Não foi possível salvar as notas.',
        color: Theme.of(context).colorScheme.error,
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

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
              ),
              child: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Nova Avaliação',
                            style: Theme.of(ctx).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.of(ctx).pop(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: titleCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Título da avaliação',
                          hintText: 'Ex: Prova 1, Lista de Exercícios...',
                          prefixIcon: Icon(Icons.assignment_outlined),
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Informe o título'
                            : null,
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<AssessmentType>(
                        initialValue: type,
                        decoration: const InputDecoration(
                          labelText: 'Tipo',
                          border: OutlineInputBorder(),
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
                      const SizedBox(height: 12),
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
                                border: OutlineInputBorder(),
                              ),
                              validator: (v) => validatePositive(v, max: 100),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: weightCtrl,
                              keyboardType: const TextInputType.numberWithOptions(
                                decimal: true,
                              ),
                              decoration: const InputDecoration(
                                labelText: 'Peso',
                                hintText: 'Ex: 2',
                                border: OutlineInputBorder(),
                              ),
                              validator: (v) => validatePositive(v, max: 10),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
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
                        icon: const Icon(Icons.calendar_today_outlined, size: 18),
                        label: Text(
                          'Data: ${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}',
                        ),
                      ),
                      const SizedBox(height: 20),
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
            appBar: AppBar(
              title: const Text('Lançamento de Notas'),
              actions: [
                if (status == GradesStatus.success)
                  IconButton(
                    icon: const Icon(Icons.bar_chart_outlined),
                    tooltip: 'Consultar Resultados',
                    onPressed: () => _openResults(context),
                  ),
                if (status == GradesStatus.success ||
                    status == GradesStatus.empty)
                  IconButton(
                    icon: const Icon(Icons.add_task_outlined),
                    tooltip: 'Nova Avaliação',
                    onPressed: () => _addAssessment(context),
                  ),
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
            body: _buildBody(context, vm, status),
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
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Carregando avaliações...'),
          ],
        ),
      );
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final academicClass = vm.academicClass;
    final assessment = vm.selectedAssessment!;
    final filteredStudents = vm.filteredStudents;

    return CustomScrollView(
      slivers: [
        // Cabeçalho da Turma
        SliverToBoxAdapter(
          child: Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
            color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  academicClass.name,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '${academicClass.code} • ${academicClass.semester} • ${vm.totalStudentsCount} estudantes',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Seleção da Avaliação
        SliverToBoxAdapter(
          child: SizedBox(
            height: 56,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              itemCount: vm.assessments.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final item = vm.assessments[index];
                return ChoiceChip(
                  label: Text(item.title),
                  selected: item.id == assessment.id,
                  onSelected: (_) => _selectAssessment(context, item.id),
                );
              },
            ),
          ),
        ),

        // Resumo da Avaliação
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
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
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
            child: TextField(
              controller: _searchController,
              onChanged: vm.updateSearchFilter,
              decoration: InputDecoration(
                hintText: 'Filtrar estudante por nome ou matrícula...',
                prefixIcon: const Icon(Icons.search, size: 20),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          vm.clearSearch();
                        },
                      )
                    : null,
                filled: true,
                fillColor:
                    colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
        ),

        // Lista de Estudantes
        if (filteredStudents.isEmpty)
          const SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: Text('Nenhum estudante corresponde ao filtro.'),
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final statusColor =
        hasUnsavedChanges ? Colors.orange.shade800 : Colors.green.shade700;

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${assessment.type.label} • ${assessment.formattedDate}',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        hasUnsavedChanges ? Icons.edit_note : Icons.check_circle,
                        size: 14,
                        color: statusColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        hasUnsavedChanges ? 'Pendente' : 'Salva',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _Metric(
                  label: 'Escala',
                  value: assessment.scaleLabel,
                ),
                _Metric(
                  label: 'Peso',
                  value: Assessment.formatScore(assessment.weight),
                ),
                _Metric(
                  label: 'Lançadas',
                  value: '$launchedCount',
                  color: Colors.green.shade700,
                ),
                _Metric(
                  label: 'Pendentes',
                  value: '$pendingCount',
                  color: Colors.orange.shade800,
                ),
                _Metric(
                  label: 'Média',
                  value: average == null ? '—' : Assessment.formatScore(average!),
                  color: colorScheme.primary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value, this.color});

  final String label;
  final String value;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
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
    final colorScheme = Theme.of(context).colorScheme;
    final hasError = errorText != null;

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: hasError
              ? colorScheme.error.withValues(alpha: 0.6)
              : colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: CircleAvatar(
                backgroundColor: colorScheme.primaryContainer,
                foregroundColor: colorScheme.onPrimaryContainer,
                child: Text(student.initials),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      student.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    Text(
                      'Matrícula ${student.registration}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 110,
              child: TextFormField(
                initialValue: initialValue,
                onChanged: onChanged,
                textAlign: TextAlign.center,
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
                  border: const OutlineInputBorder(),
                ),
              ),
            ),
          ],
        ),
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final String statusText;
    final Color statusColor;
    if (errorCount > 0) {
      statusText = '$errorCount nota(s) inválida(s)';
      statusColor = colorScheme.error;
    } else if (hasUnsavedChanges) {
      statusText = 'Alterações pendentes de envio';
      statusColor = colorScheme.onSurfaceVariant;
    } else {
      statusText = 'Notas salvas no sistema';
      statusColor = Colors.green.shade700;
    }

    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              offset: const Offset(0, -3),
              blurRadius: 8,
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$launchedCount de $totalCount notas lançadas',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    statusText,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: statusColor,
                    ),
                  ),
                ],
              ),
            ),
            FilledButton.icon(
              onPressed: isSaving ? null : onSave,
              icon: isSaving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save_outlined),
              label: Text(isExistingLaunch ? 'Atualizar Notas' : 'Salvar Notas'),
            ),
          ],
        ),
      ),
    );
  }
}
