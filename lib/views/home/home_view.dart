import 'package:flutter/material.dart';

import '../../models/academic/academic_class.dart';
import '../../viewmodels/attendance/attendance_view_model.dart';
import '../../viewmodels/grades/grades_view_model.dart';
import '../../viewmodels/home_view_model.dart';
import '../../widgets/academic_feature_button.dart';
import '../../widgets/class_card.dart';
import '../../widgets/empty_state_view.dart';
import '../../widgets/section_header.dart';
import '../../widgets/stat_card.dart';
import '../academic/classes_view.dart';
import '../attendance/attendance_view.dart';
import '../grades/grades_view.dart';

/// Tela inicial (Dashboard) do professor no EduGuard.
class HomeView extends StatefulWidget {
  const HomeView({super.key, required this.viewModel});

  final HomeViewModel viewModel;

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  @override
  void dispose() {
    widget.viewModel.dispose();
    super.dispose();
  }

  void _navigateToClasses(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ClassesView(
          viewModel: widget.viewModel.classesViewModel,
        ),
      ),
    );
  }

  void _showClassSelectionForAttendance(BuildContext context) {
    _showClassSelection(
      context,
      featureTitle: 'Frequência dos Estudantes',
      sheetTitle: 'Selecione a Turma para Chamada',
      emptyMessage: 'Não há turmas cadastradas para realizar a chamada.',
      builder: (item) => AttendanceView(
        viewModel: AttendanceViewModel(academicClass: item),
      ),
    );
  }

  void _showClassSelectionForGrades(BuildContext context) {
    _showClassSelection(
      context,
      featureTitle: 'Lançamento de Notas',
      sheetTitle: 'Selecione a Turma para Notas',
      emptyMessage: 'Não há turmas cadastradas para lançar notas.',
      builder: _gradesPageFor,
    );
  }

  Widget _gradesPageFor(AcademicClass item) =>
      GradesView(viewModel: GradesViewModel(academicClass: item));

  void _showClassSelection(
    BuildContext context, {
    required String featureTitle,
    required String sheetTitle,
    required String emptyMessage,
    required Widget Function(AcademicClass item) builder,
  }) {
    final classes = widget.viewModel.classesViewModel.filteredClasses;
    if (classes.isEmpty) {
      _showFeatureNotice(context, featureTitle, emptyMessage);
      return;
    }

    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      sheetTitle,
                      style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
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
                ...classes.map(
                  (item) => ListTile(
                    leading: CircleAvatar(
                      backgroundColor:
                          Theme.of(ctx).colorScheme.primaryContainer,
                      child: const Icon(Icons.school_outlined, size: 20),
                    ),
                    title: Text(item.name),
                    subtitle: Text('${item.code} • ${item.studentsCount} alunos'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.of(ctx).pop();
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => builder(item),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showFeatureNotice(
    BuildContext context,
    String title,
    String description,
  ) {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        final theme = Theme.of(ctx);
        final colorScheme = theme.colorScheme;

        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.info_outline,
                      color: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                description,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('Entendi'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.viewModel,
      builder: (context, _) {
        final identity = widget.viewModel.identity;
        final teacher = widget.viewModel.teacher;
        final colorScheme = Theme.of(context).colorScheme;
        final theme = Theme.of(context);

        return Scaffold(
          appBar: AppBar(
            title: Text(identity.name),
            actions: [
              IconButton(
                icon: const Icon(Icons.notifications_none_outlined),
                tooltip: 'Notificações',
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Sem novas notificações no momento.'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              ),
            ],
          ),
          body: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 600;
                final horizontalPadding = isWide ? 28.0 : 16.0;

                return SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.symmetric(
                    horizontal: horizontalPadding,
                    vertical: 16,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Cartão de Identificação do Professor e do Sistema
                      _TeacherProfileHeader(
                        identityName: identity.name,
                        tagline: identity.tagline,
                        version: identity.version,
                        teacherName: teacher.name,
                        teacherTitle: teacher.title,
                        institution: teacher.institution,
                        initials: teacher.initials,
                      ),
                      const SizedBox(height: 16),

                      // Métricas rápidas / Estatísticas
                      _StatsGrid(
                        totalClasses: widget.viewModel.totalClassesCount,
                        totalStudents: widget.viewModel.totalStudentsCount,
                        todayClasses: widget.viewModel.todayClassesCount,
                        onClassesTap: () => _navigateToClasses(context),
                      ),
                      const SizedBox(height: 20),

                      // Seção: Funcionalidades Acadêmicas
                      const SectionHeader(
                        title: 'Funcionalidades Acadêmicas',
                        subtitle: 'Acesse rapidamente suas atividades docentes',
                      ),
                      const SizedBox(height: 8),

                      AcademicFeatureButton(
                        isPrimary: true,
                        title: 'Minhas Turmas',
                        description:
                            'Consulte turmas cadastradas, quantidade de estudantes e horários.',
                        icon: Icons.groups_outlined,
                        badgeText:
                            '${widget.viewModel.totalClassesCount} turmas',
                        onTap: () => _navigateToClasses(context),
                      ),
                      const SizedBox(height: 10),

                      AcademicFeatureButton(
                        title: 'Frequência dos Estudantes',
                        description:
                            'Registro diário de presenças e faltas por turma.',
                        icon: Icons.checklist_outlined,
                        onTap: () => _showClassSelectionForAttendance(context),
                      ),
                      const SizedBox(height: 10),

                      AcademicFeatureButton(
                        title: 'Lançamento de Notas',
                        description:
                            'Acompanhe avaliações, provas, trabalhos e médias parciais.',
                        icon: Icons.grade_outlined,
                        onTap: () => _showClassSelectionForGrades(context),
                      ),
                      const SizedBox(height: 10),

                      AcademicFeatureButton(
                        title: 'Grade de Horários',
                        description:
                            'Visualização da grade horária semanal e salas de aula.',
                        icon: Icons.schedule_outlined,
                        onTap: () => _showFeatureNotice(
                          context,
                          'Grade de Horários',
                          'Visualização completa da alocação de horários e salas de aula de cada disciplina.',
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Seção: Turmas em Destaque
                      SectionHeader(
                        title: 'Turmas em Andamento',
                        subtitle: 'Acesso rápido às suas turmas ativas',
                        actionLabel: 'Ver todas',
                        onActionPressed: () => _navigateToClasses(context),
                      ),
                      const SizedBox(height: 8),

                      if (widget.viewModel.previewClasses.isEmpty)
                        EmptyStateView(
                          icon: Icons.school_outlined,
                          title: 'Nenhuma turma ativa',
                          message:
                              'Não há turmas cadastradas para o seu usuário neste período.',
                          actionLabel: 'Cadastrar Turma',
                          onActionPressed: () => _navigateToClasses(context),
                        )
                      else
                        ...widget.viewModel.previewClasses.map(
                          (academicClass) => ClassCard(
                            academicClass: academicClass,
                            onTap: () => _navigateToClasses(context),
                            onAttendanceTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder: (_) => AttendanceView(
                                    viewModel: AttendanceViewModel(
                                      academicClass: academicClass,
                                    ),
                                  ),
                                ),
                              );
                            },
                            onGradesTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder: (_) =>
                                      _gradesPageFor(academicClass),
                                ),
                              );
                            },
                          ),
                        ),

                      const SizedBox(height: 16),
                      Center(
                        child: Text(
                          '${identity.name} • ${identity.tagline}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant.withValues(
                              alpha: 0.6,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}

class _TeacherProfileHeader extends StatelessWidget {
  const _TeacherProfileHeader({
    required this.identityName,
    required this.tagline,
    required this.version,
    required this.teacherName,
    required this.teacherTitle,
    required this.institution,
    required this.initials,
  });

  final String identityName;
  final String tagline;
  final String version;
  final String teacherName;
  final String teacherTitle;
  final String institution;
  final String initials;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.primary.withValues(alpha: 0.15),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: colorScheme.primary,
                child: Text(
                  initials,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bem-vindo(a),',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    Text(
                      teacherName,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '$teacherTitle • $institution',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  tagline,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontStyle: FontStyle.italic,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'Versão $version',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatsGrid extends StatelessWidget {
  const _StatsGrid({
    required this.totalClasses,
    required this.totalStudents,
    required this.todayClasses,
    required this.onClassesTap,
  });

  final int totalClasses;
  final int totalStudents;
  final int todayClasses;
  final VoidCallback onClassesTap;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Se a tela for pequena (< 340px), divide verticalmente ou empilha
        final isVeryNarrow = constraints.maxWidth < 340;

        if (isVeryNarrow) {
          return Column(
            children: [
              StatCard(
                title: 'Turmas Ativas',
                value: '$totalClasses',
                subtitle: 'Toque p/ ver',
                icon: Icons.groups_outlined,
                onTap: onClassesTap,
              ),
              const SizedBox(height: 8),
              StatCard(
                title: 'Total Estudantes',
                value: '$totalStudents',
                subtitle: 'Matriculados',
                icon: Icons.people_alt_outlined,
              ),
              const SizedBox(height: 8),
              StatCard(
                title: 'Aulas Hoje',
                value: '$todayClasses',
                subtitle: 'Semestre 2026/2',
                icon: Icons.calendar_today_outlined,
              ),
            ],
          );
        }

        return Row(
          children: [
            Expanded(
              child: StatCard(
                title: 'Turmas',
                value: '$totalClasses',
                subtitle: 'Ativas',
                icon: Icons.groups_outlined,
                onTap: onClassesTap,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: StatCard(
                title: 'Estudantes',
                value: '$totalStudents',
                subtitle: 'Total',
                icon: Icons.people_alt_outlined,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: StatCard(
                title: 'Aulas Hoje',
                value: '$todayClasses',
                subtitle: '2026/2',
                icon: Icons.calendar_today_outlined,
              ),
            ),
          ],
        );
      },
    );
  }
}
