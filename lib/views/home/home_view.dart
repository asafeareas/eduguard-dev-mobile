import 'package:flutter/material.dart';

import '../../models/academic/academic_class.dart';
import '../../theme/app_theme.dart';
import '../../viewmodels/attendance/attendance_view_model.dart';
import '../../viewmodels/grades/grades_view_model.dart';
import '../../viewmodels/home_view_model.dart';
import '../../widgets/academic_feature_button.dart';
import '../../widgets/app_avatar.dart';
import '../../widgets/app_bottom_sheet.dart';
import '../../widgets/app_card.dart';
import '../../widgets/class_card.dart';
import '../../widgets/empty_state_view.dart';
import '../../widgets/icon_tile.dart';
import '../../widgets/section_header.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/status_badge.dart';
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

    showAppBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xl,
            AppSpacing.sm,
            AppSpacing.xl,
            AppSpacing.xl,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SheetHeader(
                title: sheetTitle,
                subtitle: '${classes.length} turma(s) disponíveis',
              ),
              const SizedBox(height: AppSpacing.lg),
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: classes.length,
                  separatorBuilder: (_, _) =>
                      const SizedBox(height: AppSpacing.sm),
                  itemBuilder: (_, index) {
                    final item = classes[index];
                    return AppCard(
                      color: AppColors.surfaceHighest.withValues(alpha: 0.6),
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.md,
                      ),
                      onTap: () {
                        Navigator.of(ctx).pop();
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => builder(item),
                          ),
                        );
                      },
                      child: Row(
                        children: [
                          const IconTile(icon: Icons.school_outlined),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.name,
                                  style: Theme.of(ctx).textTheme.titleSmall,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  '${item.code} • ${item.studentsCount} alunos',
                                  style: Theme.of(ctx).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.chevron_right_rounded,
                            color: AppColors.textTertiary,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
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
    showAppBottomSheet<void>(
      context: context,
      builder: (ctx) {
        final textTheme = Theme.of(ctx).textTheme;

        return SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xxl,
              AppSpacing.xl,
              AppSpacing.xxl,
              AppSpacing.xxl,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const IconTile(
                  icon: Icons.info_outline_rounded,
                  size: 56,
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: textTheme.titleLarge,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  description,
                  textAlign: TextAlign.center,
                  style: textTheme.bodyMedium,
                ),
                const SizedBox(height: AppSpacing.xxl),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    child: const Text('Entendi'),
                  ),
                ),
              ],
            ),
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
        final textTheme = Theme.of(context).textTheme;

        return Scaffold(
          appBar: AppBar(
            title: Text(identity.name),
            actions: [
              IconButton(
                icon: const Icon(Icons.notifications_none_rounded),
                tooltip: 'Notificações',
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Sem novas notificações no momento.'),
                    ),
                  );
                },
              ),
              const SizedBox(width: AppSpacing.xs),
            ],
          ),
          body: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final horizontalPadding =
                    AppSpacing.pagePadding(constraints.maxWidth);

                return SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(
                    horizontalPadding,
                    AppSpacing.sm,
                    horizontalPadding,
                    AppSpacing.xxl,
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxWidth: AppSpacing.maxContentWidth,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Cartão de Identificação do Professor e do Sistema
                          _TeacherProfileHeader(
                            tagline: identity.tagline,
                            version: identity.version,
                            teacherName: teacher.name,
                            teacherTitle: teacher.title,
                            institution: teacher.institution,
                            initials: teacher.initials,
                          ),
                          const SizedBox(height: AppSpacing.md),

                          // Métricas rápidas / Estatísticas
                          _StatsGrid(
                            totalClasses: widget.viewModel.totalClassesCount,
                            totalStudents: widget.viewModel.totalStudentsCount,
                            todayClasses: widget.viewModel.todayClassesCount,
                            onClassesTap: () => _navigateToClasses(context),
                          ),
                          const SizedBox(height: AppSpacing.xxxl),

                          // Seção: Funcionalidades Acadêmicas
                          const SectionHeader(
                            title: 'Funcionalidades Acadêmicas',
                            subtitle:
                                'Acesse rapidamente suas atividades docentes',
                          ),

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
                          const SizedBox(height: AppSpacing.sm),

                          AcademicFeatureButton(
                            title: 'Frequência dos Estudantes',
                            description:
                                'Registro diário de presenças e faltas por turma.',
                            icon: Icons.checklist_rounded,
                            onTap: () =>
                                _showClassSelectionForAttendance(context),
                          ),
                          const SizedBox(height: AppSpacing.sm),

                          AcademicFeatureButton(
                            title: 'Lançamento de Notas',
                            description:
                                'Acompanhe avaliações, provas, trabalhos e médias parciais.',
                            icon: Icons.grade_outlined,
                            onTap: () => _showClassSelectionForGrades(context),
                          ),
                          const SizedBox(height: AppSpacing.sm),

                          AcademicFeatureButton(
                            title: 'Grade de Horários',
                            description:
                                'Visualização da grade horária semanal e salas de aula.',
                            icon: Icons.schedule_rounded,
                            onTap: () => _showFeatureNotice(
                              context,
                              'Grade de Horários',
                              'Visualização completa da alocação de horários e salas de aula de cada disciplina.',
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xxxl),

                          // Seção: Turmas em Destaque
                          SectionHeader(
                            title: 'Turmas em Andamento',
                            subtitle: 'Acesso rápido às suas turmas ativas',
                            actionLabel: 'Ver todas',
                            onActionPressed: () => _navigateToClasses(context),
                          ),

                          if (widget.viewModel.previewClasses.isEmpty)
                            EmptyStateView(
                              icon: Icons.school_outlined,
                              title: 'Nenhuma turma ativa',
                              message:
                                  'Não há turmas cadastradas para o seu usuário neste período.',
                              actionLabel: 'Cadastrar Turma',
                              onActionPressed: () =>
                                  _navigateToClasses(context),
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

                          const SizedBox(height: AppSpacing.lg),
                          Center(
                            child: Text(
                              '${identity.name} • ${identity.tagline}',
                              style: textTheme.bodySmall?.copyWith(
                                color: AppColors.textTertiary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
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
    required this.tagline,
    required this.version,
    required this.teacherName,
    required this.teacherTitle,
    required this.institution,
    required this.initials,
  });

  final String tagline;
  final String version;
  final String teacherName;
  final String teacherTitle;
  final String institution;
  final String initials;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AppAvatar(
                initials: initials,
                tone: AppTone.accent,
                size: 56,
                filled: true,
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Bem-vindo(a),', style: textTheme.bodySmall),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      teacherName,
                      style: textTheme.titleLarge,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      '$teacherTitle • $institution',
                      style: textTheme.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          const Divider(),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: Text(
                  tagline,
                  style: textTheme.labelMedium?.copyWith(
                    color: AppColors.textTertiary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              StatusBadge(label: 'Versão $version'),
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
        // Em telas muito estreitas (< 340px), empilha os cards verticalmente
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
              const SizedBox(height: AppSpacing.sm),
              StatCard(
                title: 'Total Estudantes',
                value: '$totalStudents',
                subtitle: 'Matriculados',
                icon: Icons.people_alt_outlined,
                tone: AppTone.info,
              ),
              const SizedBox(height: AppSpacing.sm),
              StatCard(
                title: 'Aulas Hoje',
                value: '$todayClasses',
                subtitle: 'Semestre 2026/2',
                icon: Icons.today_outlined,
                tone: AppTone.success,
              ),
            ],
          );
        }

        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
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
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: StatCard(
                  title: 'Estudantes',
                  value: '$totalStudents',
                  subtitle: 'Total',
                  icon: Icons.people_alt_outlined,
                  tone: AppTone.info,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: StatCard(
                  title: 'Aulas Hoje',
                  value: '$todayClasses',
                  subtitle: '2026/2',
                  icon: Icons.today_outlined,
                  tone: AppTone.success,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
