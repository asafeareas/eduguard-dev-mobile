/// Catálogo inicial de módulos acadêmicos.
/// As funcionalidades completas serão implementadas em etapas futuras.
enum AcademicModule {
  classes,
  attendance,
  grades,
  timetable,
}

extension AcademicModuleInfo on AcademicModule {
  String get title {
    return switch (this) {
      AcademicModule.classes => 'Turmas',
      AcademicModule.attendance => 'Frequência',
      AcademicModule.grades => 'Notas',
      AcademicModule.timetable => 'Horários',
    };
  }

  String get description {
    return switch (this) {
      AcademicModule.classes => 'Organização das turmas e disciplinas.',
      AcademicModule.attendance => 'Registro de presença dos estudantes.',
      AcademicModule.grades => 'Acompanhamento de avaliações e médias.',
      AcademicModule.timetable => 'Visualização da grade de horários.',
    };
  }
}
