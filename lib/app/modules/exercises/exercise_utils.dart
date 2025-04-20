// lib/app/utils/exercise_utils.dart

import 'package:skystudy/app/routes/app_pages.dart';

String? getRouteByExercise(int exercise) {
  switch (exercise) {
    case 1:
      return Routes.exercise1;
    case 2:
      return Routes.exercise2;
    case 3:
      return Routes.exercise3;
    case 4:
      return Routes.exercise4;
    default:
      return Routes.home;
  }
}
