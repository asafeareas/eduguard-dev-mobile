import 'package:flutter/material.dart';

import '../../models/academic/student.dart';
import '../../viewmodels/academic/students_view_model.dart';
import 'student_detail_view.dart';

class StudentsView extends StatelessWidget {
  const StudentsView({super.key, required this.viewModel});

  final StudentsViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final students = viewModel.students;
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Estudantes')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  viewModel.academicClass.name,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${viewModel.academicClass.code} • ${students.length} estudantes',
                ),
              ],
            ),
          ),
          Expanded(
            child: students.isEmpty
                ? const Center(child: Text('Nenhum estudante nesta turma.'))
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    itemCount: students.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (context, index) => _StudentTile(
                      student: students[index],
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => StudentDetailView(
                            student: students[index],
                            academicClass: viewModel.academicClass,
                          ),
                        ),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _StudentTile extends StatelessWidget {
  const _StudentTile({required this.student, required this.onTap});

  final Student student;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: colorScheme.primaryContainer,
          foregroundColor: colorScheme.onPrimaryContainer,
          child: Text(student.initials),
        ),
        title: Text(student.name),
        subtitle: Text('Matrícula ${student.registration}'),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}
