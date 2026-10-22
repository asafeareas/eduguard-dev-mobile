import 'package:flutter/foundation.dart';

import '../models/academic/academic_class.dart';
import '../models/academic/academic_module.dart';
import '../models/app_identity.dart';
import '../models/teacher/teacher_profile.dart';
import 'academic/classes_view_model.dart';

class HomeViewModel extends ChangeNotifier {
  HomeViewModel({
    this.identity = AppIdentity.current,
    this.teacher = TeacherProfile.defaultTeacher,
    ClassesViewModel? classesViewModel,
  }) : classesViewModel = classesViewModel ?? ClassesViewModel() {
    this.classesViewModel.addListener(_onClassesChanged);
  }

  final AppIdentity identity;
  final TeacherProfile teacher;
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
    super.dispose();
  }
}
