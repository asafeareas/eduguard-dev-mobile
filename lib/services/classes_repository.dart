import 'dart:convert';

import '../models/academic/academic_class.dart';
import 'storage/key_value_store.dart';

/// Repositório de Turmas do professor.
///
/// Com um [KeyValueStore], persiste as turmas localmente entre sessões;
/// sem ele, mantém os dados apenas em memória (útil em testes).
/// Para migrar para um backend remoto (ex.: Cloud Firestore), basta
/// fornecer outra implementação com a mesma API assíncrona.
class ClassesRepository {
  ClassesRepository({
    KeyValueStore? store,
    bool populateSamples = true,
    this.storageKey = 'classes',
  }) : _store = store {
    if (store == null) {
      if (populateSamples) _classes.addAll(AcademicClass.sampleClasses);
      _ready = Future.value();
    } else {
      _ready = _restore(populateSamples);
    }
  }

  final KeyValueStore? _store;
  final String storageKey;
  final List<AcademicClass> _classes = [];
  late final Future<void> _ready;

  /// Retorna as turmas do professor, na ordem em que foram salvas.
  Future<List<AcademicClass>> getClasses() async {
    await _ready;
    return List.unmodifiable(_classes);
  }

  /// Substitui a lista de turmas do professor.
  Future<void> saveClasses(List<AcademicClass> classes) async {
    await _ready;
    _classes
      ..clear()
      ..addAll(classes);
    await _persist();
  }

  Future<void> _restore(bool populateSamples) async {
    final raw = await _store!.read(storageKey);
    if (raw != null) {
      final list = jsonDecode(raw) as List<dynamic>;
      _classes.addAll(
        list.map((e) => AcademicClass.fromJson(e as Map<String, dynamic>)),
      );
      return;
    }
    // Primeiro acesso do professor: cria uma cópia própria dos exemplos.
    if (populateSamples) {
      _classes.addAll(AcademicClass.sampleClasses);
      await _persist();
    }
  }

  Future<void> _persist() async {
    await _store?.write(
      storageKey,
      jsonEncode(_classes.map((c) => c.toJson()).toList()),
    );
  }
}
