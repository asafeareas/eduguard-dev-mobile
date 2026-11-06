class Student {
  const Student({
    required this.id,
    required this.classId,
    required this.name,
    required this.registration,
    required this.email,
    required this.attendance,
    required this.averageGrade,
  });

  final String id;
  final String classId;
  final String name;
  final String registration;
  final String email;
  final int attendance;
  final double averageGrade;

  String get initials => name
      .trim()
      .split(RegExp(r'\s+'))
      .where((part) => part.isNotEmpty)
      .take(2)
      .map((part) => part[0])
      .join()
      .toUpperCase();

  Student copyWith({
    String? id,
    String? classId,
    String? name,
    String? registration,
    String? email,
    int? attendance,
    double? averageGrade,
  }) {
    return Student(
      id: id ?? this.id,
      classId: classId ?? this.classId,
      name: name ?? this.name,
      registration: registration ?? this.registration,
      email: email ?? this.email,
      attendance: attendance ?? this.attendance,
      averageGrade: averageGrade ?? this.averageGrade,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'classId': classId,
    'name': name,
    'registration': registration,
    'email': email,
    'attendance': attendance,
    'averageGrade': averageGrade,
  };

  factory Student.fromJson(Map<String, dynamic> json) => Student(
    id: json['id'] as String,
    classId: json['classId'] as String,
    name: json['name'] as String,
    registration: json['registration'] as String,
    email: json['email'] as String,
    attendance: (json['attendance'] as num?)?.toInt() ?? 100,
    averageGrade: (json['averageGrade'] as num?)?.toDouble() ?? 0.0,
  );
}
