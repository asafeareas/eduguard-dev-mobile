import 'package:flutter/foundation.dart';

import '../models/academic/academic_class.dart';
import '../models/academic/academic_module.dart';
import '../models/app_identity.dart';
import '../models/teacher/teacher_profile.dart';
import '../services/classes_repository.dart';
import 'academic/classes_view_model.dart';

class HomeViewModel extends ChangeNotifier {
  HomeViewModel({
    this.identity = AppIdentity.current,
    this._teacher = TeacherProfile.defaultTeacher,
    ClassesViewModel? classesViewModel,
    ClassesRepository? classesRepository,
  }) : classesViewModel =
           classesViewModel ?? ClassesViewModel(repository: classesRepository) {
    this.classesViewModel.addListener(_onClassesChanged);
  }

  final AppIdentity identity;
  TeacherProfile _teacher;
  TeacherProfile get teacher => _teacher;

  /// Atualiza o perfil exibido (ex.: nome definido logo após o cadastro).
  void updateTeacher(TeacherProfile teacher) {
    if (teacher.id == _teacher.id &&
        teacher.name == _teacher.name &&
        teacher.email == _teacher.email) {
      return;
    }
    _teacher = teacher;
    notifyListeners();
  }
  final ClassesViewModel classesViewModel;

  void _onClassesChanged() {
    notifyListeners();
  }

  List<AcademicModule> get upcomingModules => AcademicModule.values;

  List<AcademicClass> get previewClasses =>
      classesViewModel.filteredClasses.take(2).toList();

  int get totalClassesCount => classesViewModel.totalClassesCount;

  int get totalStudentsCount => classesViewModel.totalStudentsCount;

  int get todayClassesCount => 2;

  @override
  void dispose() {
    classesViewModel.removeListener(_onClassesChanged);
    classesViewModel.dispose();
    super.dispose();
  }
}
