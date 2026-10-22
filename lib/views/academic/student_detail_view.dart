import 'package:flutter/material.dart';

import '../../models/academic/academic_class.dart';
import '../../models/academic/student.dart';

class StudentDetailView extends StatelessWidget {
  const StudentDetailView({
    super.key,
    required this.student,
    required this.academicClass,
  });

  final Student student;
  final AcademicClass academicClass;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Detalhes do estudante')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          CircleAvatar(
            radius: 42,
            child: Text(student.initials, style: theme.textTheme.headlineSmall),
          ),
          const SizedBox(height: 14),
          Text(
            student.name,
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            academicClass.name,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          _DetailRow(label: 'Matrícula', value: student.registration),
          _DetailRow(label: 'E-mail', value: student.email),
          _DetailRow(
            label: 'Turma',
            value: '${academicClass.code} • ${academicClass.semester}',
          ),
          _DetailRow(label: 'Frequência', value: '${student.attendance}%'),
          _DetailRow(
            label: 'Média atual',
            value: student.averageGrade.toStringAsFixed(1),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Card(
    child: ListTile(title: Text(label), subtitle: Text(value)),
  );
}
