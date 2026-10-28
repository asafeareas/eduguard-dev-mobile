import 'package:flutter/widgets.dart';

import 'attendance_repository.dart';
import 'classes_repository.dart';
import 'grades_repository.dart';
import 'storage/key_value_store.dart';

/// Repositórios acadêmicos de um único professor autenticado.
///
/// Todos os dados são gravados sob o namespace `eduguard.v1.<uid>`, de modo
/// que cada professor visualiza e gerencia apenas as próprias turmas,
/// frequências e avaliações. Encerrar a sessão descarta este escopo da
/// memória, mas não apaga os dados persistidos.
class AcademicDataScope {
  AcademicDataScope({
    required this.ownerId,
    required KeyValueStore store,
    bool populateSamples = true,
  }) : _store = NamespacedKeyValueStore(store, 'eduguard.v1.$ownerId') {
    classes = ClassesRepository(
      store: _store,
      populateSamples: populateSamples,
    );
    attendance = AttendanceRepository(
      store: _store,
      populateSamples: populateSamples,
    );
    grades = GradesRepository(store: _store, populateSamples: populateSamples);
  }

  /// UID do professor dono dos dados.
  final String ownerId;
  final KeyValueStore _store;

  late final ClassesRepository classes;
  late final AttendanceRepository attendance;
  late final GradesRepository grades;
}

/// Disponibiliza o [AcademicDataScope] do professor autenticado para todas
/// as rotas do app.
class AcademicScope extends InheritedWidget {
  const AcademicScope({super.key, required this.scope, required super.child});

  final AcademicDataScope scope;

  static AcademicDataScope of(BuildContext context) {
    final widget = context.getInheritedWidgetOfExactType<AcademicScope>();
    assert(
      widget != null,
      'AcademicScope não encontrado: as telas acadêmicas exigem um professor autenticado.',
    );
    return widget!.scope;
  }

  @override
  bool updateShouldNotify(AcademicScope oldWidget) => oldWidget.scope != scope;
}
