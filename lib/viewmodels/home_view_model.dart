import 'package:flutter/foundation.dart';

import '../models/academic/academic_module.dart';
import '../models/app_identity.dart';

class HomeViewModel extends ChangeNotifier {
  HomeViewModel({this._identity = AppIdentity.current});

  final AppIdentity _identity;

  AppIdentity get identity => _identity;

  List<AcademicModule> get upcomingModules => AcademicModule.values;
}
