class AppIdentity {
  const AppIdentity({
    required this.name,
    required this.tagline,
    required this.version,
  });

  final String name;
  final String tagline;
  final String version;

  static const current = AppIdentity(
    name: 'EduGuard',
    tagline: 'Gestão acadêmica para docentes',
    version: '1.0.0',
  );
}
