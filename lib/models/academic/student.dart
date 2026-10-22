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
}
