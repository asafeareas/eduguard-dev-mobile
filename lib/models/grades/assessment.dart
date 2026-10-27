/// Tipos de avaliação suportados no diário de notas.
enum AssessmentType {
  exam,
  assignment,
  activity,
  presentation,
}

extension AssessmentTypeInfo on AssessmentType {
  String get label {
    return switch (this) {
      AssessmentType.exam => 'Prova',
      AssessmentType.assignment => 'Trabalho',
      AssessmentType.activity => 'Atividade',
      AssessmentType.presentation => 'Seminário',
    };
  }
}

/// Avaliação aplicada a uma turma, com a escala de notas permitida (0 a [maxScore]).
class Assessment {
  const Assessment({
    required this.id,
    required this.classId,
    required this.title,
    required this.type,
    required this.maxScore,
    required this.weight,
    required this.date,
  });

  final String id;
  final String classId;
  final String title;
  final AssessmentType type;
  final double maxScore;
  final double weight;
  final DateTime date;

  static const double minScore = 0;

  /// Quantidade máxima de casas decimais aceitas em uma nota.
  static const int maxDecimalPlaces = 2;

  /// Gera um identificador único da avaliação vinculado à turma.
  static String generateId(String classId) =>
      'aval-$classId-${DateTime.now().microsecondsSinceEpoch}';

  /// Indica se a nota respeita a escala definida para esta avaliação.
  bool isValidScore(double score) =>
      !score.isNaN && score >= minScore && score <= maxScore;

  /// Formata um valor numérico no padrão brasileiro (ex: 7,5).
  static String formatScore(double value) {
    var text = value.toStringAsFixed(maxDecimalPlaces);
    if (text.contains('.')) {
      text = text.replaceFirst(RegExp(r'\.?0+$'), '');
    }
    return text.replaceAll('.', ',');
  }

  String get scaleLabel => '0 a ${formatScore(maxScore)}';

  String get formattedDate {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
  }

  Assessment copyWith({
    String? id,
    String? classId,
    String? title,
    AssessmentType? type,
    double? maxScore,
    double? weight,
    DateTime? date,
  }) {
    return Assessment(
      id: id ?? this.id,
      classId: classId ?? this.classId,
      title: title ?? this.title,
      type: type ?? this.type,
      maxScore: maxScore ?? this.maxScore,
      weight: weight ?? this.weight,
      date: date ?? this.date,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'classId': classId,
    'title': title,
    'type': type.name,
    'maxScore': maxScore,
    'weight': weight,
    'date': date.toIso8601String(),
  };

  factory Assessment.fromJson(Map<String, dynamic> json) => Assessment(
    id: json['id'] as String,
    classId: json['classId'] as String,
    title: json['title'] as String,
    type: AssessmentType.values.asNameMap()[json['type']] ??
        AssessmentType.exam,
    maxScore: (json['maxScore'] as num).toDouble(),
    weight: (json['weight'] as num?)?.toDouble() ?? 1,
    date: DateTime.parse(json['date'] as String),
  );
}
