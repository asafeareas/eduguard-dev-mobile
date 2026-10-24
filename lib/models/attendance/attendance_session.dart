import 'attendance_record.dart';

/// Representa a sessão de chamada realizada para uma turma em uma data específica.
class AttendanceSession {
  const AttendanceSession({
    required this.id,
    required this.classId,
    required this.date,
    required this.records,
    required this.updatedAt,
    this.topic,
  });

  final String id;
  final String classId;
  final DateTime date;
  final List<AttendanceRecord> records;
  final DateTime updatedAt;
  final String? topic;

  /// Retorna apenas a data sem horário (normalizada)
  static DateTime normalizeDate(DateTime dt) =>
      DateTime(dt.year, dt.month, dt.day);

  /// Gera chave única por turma e dia para prevenir chamadas duplicadas
  static String generateId(String classId, DateTime date) {
    final d = normalizeDate(date);
    final month = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return 'att-${classId}-${d.year}$month$day';
  }

  int get totalStudents => records.length;
  int get presentCount => records.where((r) => r.isPresent).length;
  int get absentCount => totalStudents - presentCount;

  double get attendanceRate =>
      totalStudents == 0 ? 0.0 : (presentCount / totalStudents) * 100;

  String get formattedDate {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
  }

  AttendanceRecord? recordForStudent(String studentId) {
    for (final r in records) {
      if (r.studentId == studentId) return r;
    }
    return null;
  }

  AttendanceSession copyWith({
    String? id,
    String? classId,
    DateTime? date,
    List<AttendanceRecord>? records,
    DateTime? updatedAt,
    String? topic,
  }) {
    return AttendanceSession(
      id: id ?? this.id,
      classId: classId ?? this.classId,
      date: date ?? this.date,
      records: records ?? this.records,
      updatedAt: updatedAt ?? this.updatedAt,
      topic: topic ?? this.topic,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'classId': classId,
    'date': date.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    'records': records.map((r) => r.toJson()).toList(),
    if (topic != null) 'topic': topic,
  };

  factory AttendanceSession.fromJson(Map<String, dynamic> json) {
    return AttendanceSession(
      id: json['id'] as String,
      classId: json['classId'] as String,
      date: DateTime.parse(json['date'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      records: (json['records'] as List<dynamic>?)
              ?.map((item) =>
                  AttendanceRecord.fromJson(item as Map<String, dynamic>))
              .toList() ??
          const [],
      topic: json['topic'] as String?,
    );
  }
}
