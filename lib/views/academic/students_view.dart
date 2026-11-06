import 'package:flutter/material.dart';

import '../../models/academic/student.dart';
import '../../services/academic_data_scope.dart';
import '../../theme/app_theme.dart';
import '../../viewmodels/academic/students_view_model.dart';
import '../../viewmodels/attendance/attendance_view_model.dart';
import '../../widgets/app_avatar.dart';
import '../../widgets/app_bottom_sheet.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_search_field.dart';
import '../../widgets/empty_state_view.dart';
import '../../widgets/loading_state_view.dart';
import '../../widgets/page_header.dart';
import '../attendance/attendance_view.dart';
import 'student_detail_view.dart';

class StudentsView extends StatefulWidget {
  const StudentsView({super.key, required this.viewModel});

  final StudentsViewModel viewModel;

  @override
  State<StudentsView> createState() => _StudentsViewState();
}

class _StudentsViewState extends State<StudentsView> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openAttendance(BuildContext context, List<Student> students) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => AttendanceView(
          viewModel: AttendanceViewModel(
            academicClass: widget.viewModel.academicClass,
            students: students,
            repository: AcademicScope.of(context).attendance,
          ),
        ),
      ),
    );
  }

  void _showAddStudentDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final regCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
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
                    title: 'Novo Estudante',
                    subtitle: 'Cadastre um novo aluno nesta turma',
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  TextFormField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Nome Completo',
                      hintText: 'Ex: Mariana Silva Souza',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Informe o nome do aluno' : null,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  TextFormField(
                    controller: regCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Matrícula',
                      hintText: 'Ex: 202610045',
                      prefixIcon: Icon(Icons.badge_outlined),
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Informe a matrícula';
                      }
                      final exists = widget.viewModel.students.any(
                        (s) => s.registration.trim().toLowerCase() == v.trim().toLowerCase(),
                      );
                      if (exists) {
                        return 'Já existe um aluno com esta matrícula';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSpacing.md),
                  TextFormField(
                    controller: emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'E-mail Acadêmico',
                      hintText: 'aluno@exemplo.edu.br',
                      prefixIcon: Icon(Icons.mail_outline_rounded),
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Informe o e-mail';
                      }
                      final emailRegex = RegExp(r'^[\w\.\-]+@[\w\.\-]+\.\w+$');
                      if (!emailRegex.hasMatch(v.trim())) {
                        return 'Formato de e-mail inválido';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () {
                        if (formKey.currentState?.validate() ?? false) {
                          final name = nameCtrl.text.trim();
                          widget.viewModel.addStudent(
                            name: name,
                            registration: regCtrl.text.trim(),
                            email: emailCtrl.text.trim(),
                          );
                          Navigator.of(ctx).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Estudante "$name" cadastrado!')),
                          );
                        }
                      },
                      child: const Text('Cadastrar Estudante'),
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

  void _showEditStudentDialog(BuildContext context, Student student) {
    final nameCtrl = TextEditingController(text: student.name);
    final regCtrl = TextEditingController(text: student.registration);
    final emailCtrl = TextEditingController(text: student.email);
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
                    title: 'Editar Estudante',
                    subtitle: 'Atualize os dados cadastrais do aluno',
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  TextFormField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Nome Completo',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Informe o nome' : null,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  TextFormField(
                    controller: regCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Matrícula',
                      prefixIcon: Icon(Icons.badge_outlined),
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Informe a matrícula';
                      }
                      final exists = widget.viewModel.students.any(
                        (s) =>
                            s.id != student.id &&
                            s.registration.trim().toLowerCase() == v.trim().toLowerCase(),
                      );
                      if (exists) {
                        return 'Já existe outro aluno com esta matrícula';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSpacing.md),
                  TextFormField(
                    controller: emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'E-mail Acadêmico',
                      prefixIcon: Icon(Icons.mail_outline_rounded),
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Informe o e-mail';
                      }
                      final emailRegex = RegExp(r'^[\w\.\-]+@[\w\.\-]+\.\w+$');
                      if (!emailRegex.hasMatch(v.trim())) {
                        return 'Formato de e-mail inválido';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () {
                        if (formKey.currentState?.validate() ?? false) {
                          final updated = student.copyWith(
                            name: nameCtrl.text.trim(),
                            registration: regCtrl.text.trim(),
                            email: emailCtrl.text.trim(),
                          );
                          widget.viewModel.updateStudent(updated);
                          Navigator.of(ctx).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Dados de "${updated.name}" atualizados!')),
                          );
                        }
                      },
                      child: const Text('Salvar Alterações'),
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

  void _showDeleteStudentDialog(BuildContext context, Student student) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remover Estudante'),
        content: Text('Deseja realmente remover "${student.name}" desta turma?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () {
              widget.viewModel.removeStudent(student.id);
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Estudante "${student.name}" removido.')),
              );
            },
            child: const Text('Remover'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.viewModel,
      builder: (context, _) {
        if (widget.viewModel.isLoading) {
          return Scaffold(
            appBar: AppBar(title: const Text('Estudantes')),
            body: const LoadingStateView(message: 'Carregando estudantes...'),
          );
        }

        final students = widget.viewModel.students;
        final totalCount = widget.viewModel.totalStudentsCount;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Estudantes'),
            actions: [
              IconButton(
                icon: const Icon(Icons.person_add_alt_1_outlined),
                tooltip: 'Novo Estudante',
                onPressed: () => _showAddStudentDialog(context),
              ),
              if (totalCount > 0)
                IconButton(
                  icon: const Icon(Icons.fact_check_outlined),
                  tooltip: 'Fazer Chamada',
                  onPressed: () => _openAttendance(context, students),
                ),
              const SizedBox(width: AppSpacing.xs),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _showAddStudentDialog(context),
            icon: const Icon(Icons.person_add_alt_1_rounded),
            label: const Text('Novo Aluno'),
          ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PageHeader(
                title: widget.viewModel.academicClass.name,
                subtitle:
                    '${widget.viewModel.academicClass.code} • $totalCount estudantes matriculados',
              ),
              if (totalCount > 0)
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.page,
                    0,
                    AppSpacing.page,
                    AppSpacing.md,
                  ),
                  child: AppSearchField(
                    controller: _searchController,
                    hintText: 'Buscar por nome, matrícula ou e-mail...',
                    onChanged: widget.viewModel.updateSearchQuery,
                    onClear: widget.viewModel.clearSearch,
                  ),
                ),
              Expanded(
                child: totalCount == 0
                    ? EmptyStateView(
                        icon: Icons.person_off_outlined,
                        title: 'Nenhum estudante',
                        message: 'Nenhum estudante matriculado nesta turma ainda.',
                        actionLabel: 'Cadastrar primeiro aluno',
                        onActionPressed: () => _showAddStudentDialog(context),
                      )
                    : students.isEmpty
                        ? EmptyStateView(
                            icon: Icons.search_off_rounded,
                            title: 'Nenhum resultado',
                            message:
                                'Nenhum estudante encontrado para "${widget.viewModel.searchQuery}".',
                            actionLabel: 'Limpar busca',
                            onActionPressed: () {
                              _searchController.clear();
                              widget.viewModel.clearSearch();
                            },
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.fromLTRB(
                              AppSpacing.page,
                              0,
                              AppSpacing.page,
                              96,
                            ),
                            itemCount: students.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(height: AppSpacing.sm),
                            itemBuilder: (context, index) {
                              final student = students[index];
                              return _StudentTile(
                                student: student,
                                onTap: () => Navigator.of(context).push(
                                  MaterialPageRoute<void>(
                                    builder: (_) => StudentDetailView(
                                      student: student,
                                      academicClass: widget.viewModel.academicClass,
                                      onEdit: () => _showEditStudentDialog(context, student),
                                      onDelete: () => _showDeleteStudentDialog(context, student),
                                    ),
                                  ),
                                ),
                                onEdit: () => _showEditStudentDialog(context, student),
                                onDelete: () => _showDeleteStudentDialog(context, student),
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
}

class _StudentTile extends StatelessWidget {
  const _StudentTile({
    required this.student,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  final Student student;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md + 2,
        vertical: AppSpacing.md,
      ),
      child: Row(
        children: [
          AppAvatar(initials: student.initials),
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
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  'Matrícula ${student.registration}',
                  style: textTheme.bodySmall,
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            padding: EdgeInsets.zero,
            icon: const Icon(
              Icons.more_vert,
              size: AppSizes.iconSm,
              color: AppColors.textTertiary,
            ),
            onSelected: (val) {
              if (val == 'edit') onEdit();
              if (val == 'delete') onDelete();
            },
            itemBuilder: (ctx) => [
              const PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit_outlined, size: 20),
                    SizedBox(width: AppSpacing.md),
                    Text('Editar Aluno'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline, size: 20, color: AppColors.danger),
                    SizedBox(width: AppSpacing.md),
                    Text('Remover da Turma', style: TextStyle(color: AppColors.danger)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
