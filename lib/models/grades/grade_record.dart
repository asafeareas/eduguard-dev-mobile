/// Nota de um estudante em uma avaliação de uma turma.
class GradeRecord {
  const GradeRecord({
    required this.studentId,
    required this.studentName,
    required this.classId,
    required this.assessmentId,
    required this.score,
    required this.updatedAt,
  });

  final String studentId;
  final String studentName;
  final String classId;
  final String assessmentId;
  final double score;
  final DateTime updatedAt;

  /// Chave única por avaliação e estudante, evitando notas duplicadas.
  static String generateId(String assessmentId, String studentId) =>
      'nota-$assessmentId-$studentId';

  String get id => generateId(assessmentId, studentId);

  GradeRecord copyWith({
    String? studentId,
    String? studentName,
    String? classId,
    String? assessmentId,
    double? score,
    DateTime? updatedAt,
  }) {
    return GradeRecord(
      studentId: studentId ?? this.studentId,
      studentName: studentName ?? this.studentName,
      classId: classId ?? this.classId,
      assessmentId: assessmentId ?? this.assessmentId,
      score: score ?? this.score,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'studentId': studentId,
    'studentName': studentName,
    'classId': classId,
    'assessmentId': assessmentId,
    'score': score,
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory GradeRecord.fromJson(Map<String, dynamic> json) => GradeRecord(
    studentId: json['studentId'] as String,
    studentName: json['studentName'] as String,
    classId: json['classId'] as String,
    assessmentId: json['assessmentId'] as String,
    score: (json['score'] as num).toDouble(),
    updatedAt: DateTime.parse(json['updatedAt'] as String),
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GradeRecord &&
          runtimeType == other.runtimeType &&
          studentId == other.studentId &&
          classId == other.classId &&
          assessmentId == other.assessmentId &&
          score == other.score;

  @override
  int get hashCode => Object.hash(studentId, classId, assessmentId, score);
}
