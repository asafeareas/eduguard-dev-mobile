import 'package:flutter/material.dart';

import '../../models/academic/student.dart';
import '../../services/academic_data_scope.dart';
import '../../theme/app_theme.dart';
import '../../viewmodels/academic/students_view_model.dart';
import '../../viewmodels/attendance/attendance_view_model.dart';
import '../../widgets/app_avatar.dart';
import '../../widgets/app_card.dart';
import '../../widgets/empty_state_view.dart';
import '../../widgets/page_header.dart';
import '../attendance/attendance_view.dart';
import 'student_detail_view.dart';

class StudentsView extends StatelessWidget {
  const StudentsView({super.key, required this.viewModel});

  final StudentsViewModel viewModel;

  void _openAttendance(BuildContext context, List<Student> students) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => AttendanceView(
          viewModel: AttendanceViewModel(
            academicClass: viewModel.academicClass,
            students: students,
            repository: AcademicScope.of(context).attendance,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final students = viewModel.students;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Estudantes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.fact_check_outlined),
            tooltip: 'Fazer Chamada',
            onPressed: () => _openAttendance(context, students),
          ),
          const SizedBox(width: AppSpacing.xs),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openAttendance(context, students),
        icon: const Icon(Icons.fact_check_outlined),
        label: const Text('Fazer Chamada'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PageHeader(
            title: viewModel.academicClass.name,
            subtitle:
                '${viewModel.academicClass.code} • ${students.length} estudantes',
          ),
          Expanded(
            child: students.isEmpty
                ? const EmptyStateView(
                    icon: Icons.person_off_outlined,
                    title: 'Nenhum estudante',
                    message: 'Nenhum estudante nesta turma.',
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
          const Icon(
            Icons.chevron_right_rounded,
            color: AppColors.textTertiary,
          ),
        ],
      ),
    );
  }
}
