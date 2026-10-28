import 'package:flutter/material.dart';

import '../../models/academic/academic_class.dart';
import '../../services/academic_data_scope.dart';
import '../../theme/app_theme.dart';
import '../../viewmodels/academic/classes_view_model.dart';
import '../../viewmodels/academic/students_view_model.dart';
import '../../viewmodels/attendance/attendance_view_model.dart';
import '../../viewmodels/grades/grades_view_model.dart';
import '../../widgets/app_bottom_sheet.dart';
import '../../widgets/app_search_field.dart';
import '../../widgets/class_card.dart';
import '../../widgets/empty_state_view.dart';
import '../../widgets/error_state_view.dart';
import '../../widgets/loading_state_view.dart';
import '../../widgets/status_badge.dart';
import '../attendance/attendance_view.dart';
import '../grades/grades_view.dart';
import 'students_view.dart';

/// Tela responsável pela visualização e gestão das turmas do professor.
class ClassesView extends StatefulWidget {
  const ClassesView({
    super.key,
    required this.viewModel,
  });

  final ClassesViewModel viewModel;

  @override
  State<ClassesView> createState() => _ClassesViewState();
}

class _ClassesViewState extends State<ClassesView> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showAddClassDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final courseCtrl = TextEditingController();
    final codeCtrl = TextEditingController();
    final studentsCtrl = TextEditingController(text: '30');
    final shiftCtrl = TextEditingController(text: 'Noturno');
    final roomCtrl = TextEditingController(text: 'Sala 101');
    final formKey = GlobalKey<FormState>();

    showAppBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
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
                    title: 'Nova Turma',
                    subtitle: 'Preencha os dados da turma ou disciplina',
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  TextFormField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Nome da Turma / Disciplina',
                      hintText: 'Ex: Programação Orientada a Objetos',
                      prefixIcon: Icon(Icons.menu_book_outlined),
                    ),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Informe o nome' : null,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  TextFormField(
                    controller: courseCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Curso',
                      hintText: 'Ex: Ciência da Computação',
                      prefixIcon: Icon(Icons.school_outlined),
                    ),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Informe o curso' : null,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: codeCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Código',
                            hintText: 'Ex: CC-202',
                                ),
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? 'Informe o código'
                              : null,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: TextFormField(
                          controller: studentsCtrl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Estudantes',
                            hintText: 'Ex: 35',
                                ),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return 'Informe a qtd';
                            }
                            if (int.tryParse(v) == null) {
                              return 'Valor inválido';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: shiftCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Turno',
                            hintText: 'Noturno',
                                ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: TextFormField(
                          controller: roomCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Sala / Local',
                            hintText: 'Lab 01',
                                ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () {
                        if (formKey.currentState?.validate() ?? false) {
                          final newClass = AcademicClass(
                            id: 'turma-${DateTime.now().millisecondsSinceEpoch}',
                            name: nameCtrl.text.trim(),
                            course: courseCtrl.text.trim(),
                            code: codeCtrl.text.trim(),
                            studentsCount:
                                int.tryParse(studentsCtrl.text.trim()) ?? 30,
                            semester: '2026/2',
                            shift: shiftCtrl.text.trim().isEmpty
                                ? 'Noturno'
                                : shiftCtrl.text.trim(),
                            room: roomCtrl.text.trim().isEmpty
                                ? 'Sala a definir'
                                : roomCtrl.text.trim(),
                            nextClass: 'Em breve',
                          );

                          widget.viewModel.addClass(newClass);
                          Navigator.of(ctx).pop();

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Turma "${newClass.name}" cadastrada!'),
                            ),
                          );
                        }
                      },
                      child: const Text('Salvar Turma'),
                    ),
                  ),
                ],
              ),
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
        final status = widget.viewModel.status;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Turmas Cadastradas'),
            actions: [
              // Menu interativo para demonstrar/testar os estados solicitados
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_horiz_rounded),
                tooltip: 'Opções de Demonstração',
                onSelected: (value) {
                  switch (value) {
                    case 'error':
                      widget.viewModel.simulateError();
                      break;
                    case 'empty':
                      widget.viewModel.simulateEmpty();
                      break;
                    case 'restore':
                      widget.viewModel.restoreSamples();
                      _searchController.clear();
                      break;
                  }
                },
                itemBuilder: (ctx) => [
                  const PopupMenuItem(
                    value: 'restore',
                    child: ListTile(
                      leading: Icon(Icons.restore_rounded),
                      title: Text('Restaurar Turmas'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'empty',
                    child: ListTile(
                      leading: Icon(Icons.folder_off_outlined),
                      title: Text('Simular Sem Turmas'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'error',
                    child: ListTile(
                      leading: Icon(Icons.error_outline_rounded),
                      title: Text('Simular Erro de Carga'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: AppSpacing.xs),
            ],
          ),
          floatingActionButton: status == ClassesStatus.success ||
                  status == ClassesStatus.empty
              ? FloatingActionButton.extended(
                  onPressed: () => _showAddClassDialog(context),
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Nova Turma'),
                )
              : null,
          body: SafeArea(
            child: RefreshIndicator(
              onRefresh: () => widget.viewModel.loadClasses(),
              child: _buildBody(context, status),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBody(
    BuildContext context,
    ClassesStatus status,
  ) {
    // 1. Estado de Carregamento
    if (status == ClassesStatus.loading) {
      return const LoadingStateView(message: 'Carregando turmas...');
    }

    // 2. Estado de Erro
    if (status == ClassesStatus.error) {
      return ErrorStateView(
        title: 'Falha ao sincronizar turmas',
        message: widget.viewModel.errorMessage ??
            'Ocorreu uma falha inesperada ao tentar carregar suas turmas. Verifique sua conexão e tente novamente.',
        retryLabel: 'Recarregar turmas',
        onRetry: () => widget.viewModel.loadClasses(),
        secondaryActionLabel: 'Restaurar dados locais',
        onSecondaryAction: () => widget.viewModel.restoreSamples(),
      );
    }

    // 3. Estado Vazio Global (sem turmas cadastradas)
    if (status == ClassesStatus.empty) {
      return EmptyStateView(
        icon: Icons.school_outlined,
        title: 'Nenhuma turma cadastrada',
        message:
            'Você ainda não possui turmas vinculadas ao seu perfil neste semestre. Cadastre uma nova turma ou restaure os exemplos.',
        actionLabel: 'Cadastrar primeira turma',
        onActionPressed: () => _showAddClassDialog(context),
        secondaryActionLabel: 'Restaurar turmas de exemplo',
        onSecondaryActionPressed: () => widget.viewModel.restoreSamples(),
      );
    }

    // 4. Estado de Sucesso com lista
    final filtered = widget.viewModel.filteredClasses;

    return LayoutBuilder(
      builder: (context, constraints) {
        // Responsividade para diferentes larguras de tela
        final horizontalPadding = AppSpacing.pagePadding(constraints.maxWidth);

        return CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // Barra de busca e estatísticas
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  horizontalPadding,
                  AppSpacing.sm,
                  horizontalPadding,
                  AppSpacing.lg,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppSearchField(
                      controller: _searchController,
                      hintText: 'Buscar por turma, curso ou código...',
                      onChanged: widget.viewModel.updateSearchQuery,
                      onClear: widget.viewModel.clearSearch,
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // Resumo de contagem adaptável a qualquer largura
                    Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.sm,
                      children: [
                        StatusBadge(
                          label:
                              '${widget.viewModel.totalClassesCount} turmas encontradas',
                          icon: Icons.school_outlined,
                        ),
                        StatusBadge(
                          label:
                              '${widget.viewModel.totalStudentsCount} estudantes no total',
                          icon: Icons.people_alt_outlined,
                          tone: AppTone.accent,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Resultado da busca vazio
            if (filtered.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: EmptyStateView(
                  icon: Icons.search_off_rounded,
                  title: 'Nenhum resultado',
                  message:
                      'Nenhuma turma corresponde aos termos informados: "${widget.viewModel.searchQuery}".',
                  actionLabel: 'Limpar busca',
                  actionIcon: Icons.close_rounded,
                  onActionPressed: () {
                    _searchController.clear();
                    widget.viewModel.clearSearch();
                  },
                ),
              )
            else
              // Lista de turmas
              SliverPadding(
                padding: EdgeInsets.fromLTRB(
                  horizontalPadding,
                  0,
                  horizontalPadding,
                  96, // Espaço extra para o FloatingActionButton
                ),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final item = filtered[index];
                      return ClassCard(
                        academicClass: item,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => StudentsView(
                                viewModel: StudentsViewModel(
                                  academicClass: item,
                                ),
                              ),
                            ),
                          );
                        },
                        onAttendanceTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => AttendanceView(
                                viewModel: AttendanceViewModel(
                                  academicClass: item,
                                  repository:
                                      AcademicScope.of(context).attendance,
                                ),
                              ),
                            ),
                          );
                        },
                        onGradesTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => GradesView(
                                viewModel: GradesViewModel(
                                  academicClass: item,
                                  repository: AcademicScope.of(context).grades,
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                    childCount: filtered.length,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
