import 'package:flutter/material.dart';

import '../../models/academic/academic_class.dart';
import '../../viewmodels/academic/classes_view_model.dart';
import '../../widgets/class_card.dart';
import '../../widgets/empty_state_view.dart';
import '../../widgets/error_state_view.dart';

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

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
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
                        'Nova Turma',
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
                    controller: nameCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Nome da Turma / Disciplina',
                      hintText: 'Ex: Programação Orientada a Objetos',
                      prefixIcon: Icon(Icons.book_outlined),
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Informe o nome' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: courseCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Curso',
                      hintText: 'Ex: Ciência da Computação',
                      prefixIcon: Icon(Icons.school_outlined),
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Informe o curso' : null,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: codeCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Código',
                            hintText: 'Ex: CC-202',
                            border: OutlineInputBorder(),
                          ),
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? 'Informe o código'
                              : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: studentsCtrl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Estudantes',
                            hintText: 'Ex: 35',
                            border: OutlineInputBorder(),
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
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: shiftCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Turno',
                            hintText: 'Noturno',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: roomCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Sala / Local',
                            hintText: 'Lab 01',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
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
                              behavior: SnackBarBehavior.floating,
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

  void _showFeedback(BuildContext context, String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.viewModel,
      builder: (context, _) {
        final status = widget.viewModel.status;
        final colorScheme = Theme.of(context).colorScheme;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Turmas Cadastradas'),
            actions: [
              // Menu interativo para demonstrar/testar os estados solicitados
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert),
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
                      leading: Icon(Icons.restore),
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
                      leading: Icon(Icons.error_outline),
                      title: Text('Simular Erro de Carga'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
            ],
          ),
          floatingActionButton: status == ClassesStatus.success ||
                  status == ClassesStatus.empty
              ? FloatingActionButton.extended(
                  onPressed: () => _showAddClassDialog(context),
                  icon: const Icon(Icons.add),
                  label: const Text('Nova Turma'),
                )
              : null,
          body: SafeArea(
            child: RefreshIndicator(
              onRefresh: () => widget.viewModel.loadClasses(),
              child: _buildBody(context, status, colorScheme),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBody(
    BuildContext context,
    ClassesStatus status,
    ColorScheme colorScheme,
  ) {
    // 1. Estado de Carregamento
    if (status == ClassesStatus.loading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Carregando turmas...'),
          ],
        ),
      );
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
    final theme = Theme.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        // Responsividade para diferentes larguras de tela
        final horizontalPadding = constraints.maxWidth > 600 ? 32.0 : 16.0;

        return CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // Barra de busca e estatísticas
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  horizontalPadding,
                  16,
                  horizontalPadding,
                  8,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Campo de Busca
                    TextField(
                      controller: _searchController,
                      onChanged: (val) => widget.viewModel.updateSearchQuery(val),
                      decoration: InputDecoration(
                        hintText: 'Buscar por turma, curso ou código...',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  _searchController.clear();
                                  widget.viewModel.clearSearch();
                                },
                              )
                            : null,
                        filled: true,
                        fillColor: colorScheme.surfaceContainerHighest
                            .withValues(alpha: 0.4),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Resumo de contagem adaptável a qualquer largura
                    Wrap(
                      alignment: WrapAlignment.spaceBetween,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        Text(
                          '${widget.viewModel.totalClassesCount} turmas encontradas',
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '${widget.viewModel.totalStudentsCount} estudantes no total',
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
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
                  4,
                  horizontalPadding,
                  80, // Espaço extra para o FloatingActionButton
                ),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final item = filtered[index];
                      return ClassCard(
                        academicClass: item,
                        onTap: () {
                          _showFeedback(
                            context,
                            'Visualizando detalhes da turma: ${item.name}',
                          );
                        },
                        onAttendanceTap: () {
                          _showFeedback(
                            context,
                            'Iniciando frequência para ${item.code} (${item.studentsCount} alunos)',
                          );
                        },
                        onGradesTap: () {
                          _showFeedback(
                            context,
                            'Abrindo diário de notas de ${item.name}',
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
