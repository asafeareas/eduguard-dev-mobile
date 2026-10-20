import 'package:flutter/material.dart';

import '../../models/academic/academic_module.dart';
import '../../viewmodels/home_view_model.dart';

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

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.viewModel,
      builder: (context, _) {
        final identity = widget.viewModel.identity;
        final colorScheme = Theme.of(context).colorScheme;
        final textTheme = Theme.of(context).textTheme;

        return Scaffold(
          appBar: AppBar(title: Text(identity.name)),
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                Icon(
                  Icons.school_outlined,
                  size: 72,
                  color: colorScheme.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  identity.name,
                  textAlign: TextAlign.center,
                  style: textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  identity.tagline,
                  textAlign: TextAlign.center,
                  style: textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'Versão ${identity.version}',
                  textAlign: TextAlign.center,
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 32),
                Text('Módulos acadêmicos', style: textTheme.titleLarge),
                const SizedBox(height: 4),
                Text(
                  'Estrutura inicial. As funcionalidades serão adicionadas nas próximas etapas.',
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 16),
                ...widget.viewModel.upcomingModules.map(
                  (module) => _ModuleCard(module: module),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ModuleCard extends StatelessWidget {
  const _ModuleCard({required this.module});

  final AcademicModule module;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(_iconFor(module)),
        title: Text(module.title),
        subtitle: Text(module.description),
        trailing: const Text('Em breve'),
      ),
    );
  }

  IconData _iconFor(AcademicModule module) {
    return switch (module) {
      AcademicModule.classes => Icons.groups_outlined,
      AcademicModule.attendance => Icons.checklist_outlined,
      AcademicModule.grades => Icons.grade_outlined,
      AcademicModule.timetable => Icons.schedule_outlined,
    };
  }
}
