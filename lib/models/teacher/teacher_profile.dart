class TeacherProfile {
  const TeacherProfile({
    required this.id,
    required this.name,
    required this.title,
    required this.institution,
    required this.department,
    required this.email,
  });

  final String id;
  final String name;
  final String title;
  final String institution;
  final String department;
  final String email;

  String get initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return 'P';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  static const defaultTeacher = TeacherProfile(
    id: 'prof-01',
    name: 'Prof. Carlos Eduardo',
    title: 'Professor Adjunto',
    institution: 'Faculdade EduGuard',
    department: 'Ciência da Computação & TI',
    email: 'carlos.eduardo@eduguard.edu.br',
  );
}
