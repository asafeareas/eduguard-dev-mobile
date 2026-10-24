import 'package:flutter/material.dart';

import '../../models/academic/academic_class.dart';
import '../../models/academic/student.dart';
import '../../viewmodels/attendance/attendance_view_model.dart';
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
              border: OutlineInputBorder(),
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
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            if (widget.viewModel.observation(student.id) != null)
              TextButton(
                onPressed: () {
                  widget.viewModel.setStudentObservation(student.id, null);
                  Navigator.of(ctx).pop();
                },
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
        final theme = Theme.of(context);
        final colorScheme = theme.colorScheme;
        final academicClass = vm.academicClass;
        final filteredStudents = vm.filteredStudents;

        return Scaffold(
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
            ],
          ),
          bottomNavigationBar: SafeArea(
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
                          '${vm.presentCount} presentes de ${vm.totalStudentsCount}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          vm.isSaved
                              ? 'Chamada salva no sistema'
                              : 'Alterações pendentes de envio',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: vm.isSaved
                                ? Colors.green.shade700
                                : colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  FilledButton.icon(
                    onPressed: () async {
                      await vm.saveAttendance();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).hideCurrentSnackBar();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Chamada do dia ${vm.formattedSelectedDate} salva com sucesso! (${vm.presentCount} presentes, ${vm.absentCount} faltas)',
                            ),
                            behavior: SnackBarBehavior.floating,
                            backgroundColor: Colors.green.shade800,
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.save_outlined),
                    label: Text(
                      vm.isExistingSession ? 'Atualizar Chamada' : 'Salvar Chamada',
                    ),
                  ),
                ],
              ),
            ),
          ),
          body: vm.isLoading
              ? const Center(child: CircularProgressIndicator())
              : CustomScrollView(
                  slivers: [
                    // Cabeçalho da Turma
                    SliverToBoxAdapter(
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
                        color: colorScheme.surfaceContainerHighest
                            .withValues(alpha: 0.35),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
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
                                        '${academicClass.code} • ${academicClass.shift} • ${academicClass.room}',
                                        style: theme.textTheme.bodySmall?.copyWith(
                                          color: colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                _SaveStatusChip(isSaved: vm.isSaved),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Barra de Navegação de Data
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
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
                        padding: const EdgeInsets.symmetric(horizontal: 16),
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

                    // Barra de Ações Rápidas (Todos Presentes, Todos Ausentes)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                        child: Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () => vm.markAll(true),
                                icon: const Icon(
                                  Icons.check_circle_outline,
                                  size: 18,
                                  color: Colors.green,
                                ),
                                label: const Text('Todos Presentes'),
                                style: OutlinedButton.styleFrom(
                                  visualDensity: VisualDensity.compact,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () => vm.markAll(false),
                                icon: const Icon(
                                  Icons.cancel_outlined,
                                  size: 18,
                                  color: Colors.red,
                                ),
                                label: const Text('Todos Ausentes'),
                                style: OutlinedButton.styleFrom(
                                  visualDensity: VisualDensity.compact,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Campo de Pesquisa de Estudantes
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
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
                            fillColor: colorScheme.surfaceContainerHighest
                                .withValues(alpha: 0.35),
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
                              final isPresent = vm.isPresent(student.id);
                              final obs = vm.observation(student.id);

                              return _StudentAttendanceCard(
                                student: student,
                                isPresent: isPresent,
                                observation: obs,
                                onToggle: () => vm.toggleStudent(student.id),
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
        );
      },
    );
  }
}

class _SaveStatusChip extends StatelessWidget {
  const _SaveStatusChip({required this.isSaved});

  final bool isSaved;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = isSaved ? Colors.green.shade700 : Colors.orange.shade800;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isSaved ? Icons.check_circle : Icons.edit_note,
            size: 14,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            isSaved ? 'Salva' : 'Pendente',
            style: theme.textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final now = DateTime.now();
    final isToday = selectedDate.year == now.year &&
        selectedDate.month == now.month &&
        selectedDate.day == now.day;

    return Row(
      children: [
        IconButton.outlined(
          onPressed: onPrev,
          tooltip: 'Dia anterior',
          visualDensity: VisualDensity.compact,
          icon: const Icon(Icons.chevron_left),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: InkWell(
            onTap: onTapDate,
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.6),
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.calendar_today, size: 16, color: colorScheme.primary),
                  const SizedBox(width: 8),
                  Text(
                    formattedDate,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.arrow_drop_down, size: 18),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 6),
        IconButton.outlined(
          onPressed: onNext,
          tooltip: 'Próximo dia',
          visualDensity: VisualDensity.compact,
          icon: const Icon(Icons.chevron_right),
        ),
        if (!isToday) ...[
          const SizedBox(width: 6),
          ActionChip(
            label: const Text('Hoje'),
            visualDensity: VisualDensity.compact,
            onPressed: onToday,
          ),
        ],
      ],
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _StatBadge(
                    label: 'Presentes',
                    count: presentCount,
                    color: Colors.green.shade700,
                    icon: Icons.check_circle_outline,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _StatBadge(
                    label: 'Faltas',
                    count: absentCount,
                    color: Colors.red.shade700,
                    icon: Icons.highlight_off,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _StatBadge(
                    label: 'Frequência',
                    countString: '${attendanceRate.toStringAsFixed(0)}%',
                    color: colorScheme.primary,
                    icon: Icons.pie_chart_outline,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: totalCount == 0 ? 0 : presentCount / totalCount,
                minHeight: 6,
                backgroundColor: Colors.red.shade200,
                color: Colors.green.shade600,
              ),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: onEditTopic,
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 6),
                child: Row(
                  children: [
                    Icon(
                      Icons.menu_book_outlined,
                      size: 15,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        topic?.isNotEmpty == true
                            ? 'Conteúdo: $topic'
                            : 'Toque para adicionar conteúdo da aula',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: topic?.isNotEmpty == true
                              ? colorScheme.onSurface
                              : colorScheme.onSurfaceVariant,
                          fontStyle: topic?.isNotEmpty == true
                              ? FontStyle.normal
                              : FontStyle.italic,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Icon(
                      Icons.edit_outlined,
                      size: 14,
                      color: colorScheme.primary,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatBadge extends StatelessWidget {
  const _StatBadge({
    required this.label,
    this.count,
    this.countString,
    required this.color,
    required this.icon,
  });

  final String label;
  final int? count;
  final String? countString;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 4),
              Text(
                countString ?? '$count',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w500,
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
    required this.onToggle,
    required this.onSetPresence,
    required this.onAddObservation,
  });

  final Student student;
  final bool isPresent;
  final String? observation;
  final VoidCallback onToggle;
  final ValueChanged<bool> onSetPresence;
  final VoidCallback onAddObservation;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isPresent
              ? colorScheme.outlineVariant.withValues(alpha: 0.4)
              : Colors.red.shade200,
          width: isPresent ? 1 : 1.5,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: isPresent
                      ? Colors.green.shade100
                      : Colors.red.shade100,
                  foregroundColor: isPresent
                      ? Colors.green.shade800
                      : Colors.red.shade800,
                  child: Text(
                    student.initials,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        student.name,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'Matrícula: ${student.registration}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Botões de Presença / Falta
                _PresenceToggle(
                  isPresent: isPresent,
                  onChanged: onSetPresence,
                ),
              ],
            ),
            if (observation != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 14,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        observation!,
                        style: theme.textTheme.bodySmall,
                      ),
                    ),
                    InkWell(
                      onTap: onAddObservation,
                      child: const Icon(Icons.edit, size: 14),
                    ),
                  ],
                ),
              ),
            ] else ...[
              Align(
                alignment: Alignment.centerRight,
                child: InkWell(
                  onTap: onAddObservation,
                  borderRadius: BorderRadius.circular(6),
                  child: Padding(
                    padding: const EdgeInsets.only(top: 4, left: 6, right: 6),
                    child: Text(
                      '+ Adicionar observação',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colorScheme.primary,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

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
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Botão Presente
          InkWell(
            onTap: () => onChanged(true),
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: isPresent ? Colors.green.shade600 : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.check,
                    size: 16,
                    color: isPresent ? Colors.white : Colors.grey.shade600,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'P',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isPresent ? Colors.white : Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Botão Ausente
          InkWell(
            onTap: () => onChanged(false),
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: !isPresent ? Colors.red.shade600 : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.close,
                    size: 16,
                    color: !isPresent ? Colors.white : Colors.grey.shade600,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'F',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: !isPresent ? Colors.white : Colors.grey.shade600,
                    ),
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
