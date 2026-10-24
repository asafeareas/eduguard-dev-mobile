class AttendanceRecord {
  const AttendanceRecord({
    required this.studentId,
    required this.studentName,
    required this.isPresent,
    this.observation,
  });

  final String studentId;
  final String studentName;
  final bool isPresent;
  final String? observation;

  AttendanceRecord copyWith({
    String? studentId,
    String? studentName,
    bool? isPresent,
    String? observation,
  }) {
    return AttendanceRecord(
      studentId: studentId ?? this.studentId,
      studentName: studentName ?? this.studentName,
      isPresent: isPresent ?? this.isPresent,
      observation: observation ?? this.observation,
    );
  }

  Map<String, dynamic> toJson() => {
    'studentId': studentId,
    'studentName': studentName,
    'isPresent': isPresent,
    if (observation != null) 'observation': observation,
  };

  factory AttendanceRecord.fromJson(Map<String, dynamic> json) =>
      AttendanceRecord(
        studentId: json['studentId'] as String,
        studentName: json['studentName'] as String,
        isPresent: json['isPresent'] as bool? ?? false,
        observation: json['observation'] as String?,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AttendanceRecord &&
          runtimeType == other.runtimeType &&
          studentId == other.studentId &&
          studentName == other.studentName &&
          isPresent == other.isPresent &&
          observation == other.observation;

  @override
  int get hashCode => Object.hash(studentId, studentName, isPresent, observation);
}
