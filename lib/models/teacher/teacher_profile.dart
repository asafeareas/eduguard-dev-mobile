import '../auth/auth_user.dart';

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

  /// Perfil básico do professor autenticado. Dados institucionais ainda não
  /// são coletados no cadastro, por isso ficam vazios.
  factory TeacherProfile.fromAuthUser(AuthUser user) {
    final displayName = user.displayName?.trim() ?? '';
    return TeacherProfile(
      id: user.uid,
      name: displayName.isNotEmpty ? displayName : user.email.split('@').first,
      title: 'Docente',
      institution: '',
      department: '',
      email: user.email,
    );
  }

  /// Linha de apoio exibida abaixo do nome do professor.
  String get subtitle =>
      institution.isEmpty ? email : '$title • $institution';

  static const defaultTeacher = TeacherProfile(
    id: 'prof-01',
    name: 'Prof. Carlos Eduardo',
    title: 'Professor Adjunto',
    institution: 'Faculdade EduGuard',
    department: 'Ciência da Computação & TI',
    email: 'carlos.eduardo@eduguard.edu.br',
  );
}
