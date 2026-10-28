class AcademicClass {
  const AcademicClass({
    required this.id,
    required this.name,
    required this.course,
    required this.code,
    required this.studentsCount,
    required this.semester,
    required this.shift,
    required this.room,
    required this.nextClass,
  });

  final String id;
  final String name;
  final String course;
  final String code;
  final int studentsCount;
  final String semester;
  final String shift;
  final String room;
  final String nextClass;

  AcademicClass copyWith({
    String? id,
    String? name,
    String? course,
    String? code,
    int? studentsCount,
    String? semester,
    String? shift,
    String? room,
    String? nextClass,
  }) {
    return AcademicClass(
      id: id ?? this.id,
      name: name ?? this.name,
      course: course ?? this.course,
      code: code ?? this.code,
      studentsCount: studentsCount ?? this.studentsCount,
      semester: semester ?? this.semester,
      shift: shift ?? this.shift,
      room: room ?? this.room,
      nextClass: nextClass ?? this.nextClass,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'course': course,
    'code': code,
    'studentsCount': studentsCount,
    'semester': semester,
    'shift': shift,
    'room': room,
    'nextClass': nextClass,
  };

  factory AcademicClass.fromJson(Map<String, dynamic> json) => AcademicClass(
    id: json['id'] as String,
    name: json['name'] as String,
    course: json['course'] as String,
    code: json['code'] as String,
    studentsCount: json['studentsCount'] as int,
    semester: json['semester'] as String,
    shift: json['shift'] as String,
    room: json['room'] as String,
    nextClass: json['nextClass'] as String,
  );

  /// Lista inicial com turmas de exemplo.
  static const List<AcademicClass> sampleClasses = [
    AcademicClass(
      id: 'turma-01',
      name: 'Engenharia de Software II',
      course: 'Ciência da Computação',
      code: 'CC-401',
      studentsCount: 38,
      semester: '2026/2',
      shift: 'Noturno',
      room: 'Laboratório 04 - Bloco C',
      nextClass: 'Hoje às 19:00',
    ),
    AcademicClass(
      id: 'turma-02',
      name: 'Desenvolvimento Mobile com Flutter',
      course: 'Sistemas de Informação',
      code: 'SI-305',
      studentsCount: 42,
      semester: '2026/2',
      shift: 'Noturno',
      room: 'Laboratório Maker',
      nextClass: 'Amanhã às 20:50',
    ),
    AcademicClass(
      id: 'turma-03',
      name: 'Algoritmos e Estrutura de Dados',
      course: 'Engenharia de Software',
      code: 'ES-102',
      studentsCount: 35,
      semester: '2026/2',
      shift: 'Matutino',
      room: 'Sala 204 - Bloco A',
      nextClass: 'Quinta às 08:00',
    ),
    AcademicClass(
      id: 'turma-04',
      name: 'Banco de Dados Relacional',
      course: 'Análise e Des. de Sistemas',
      code: 'ADS-201',
      studentsCount: 29,
      semester: '2026/2',
      shift: 'Vespertino',
      room: 'Laboratório 02 - Bloco B',
      nextClass: 'Sexta às 14:00',
    ),
  ];
}
