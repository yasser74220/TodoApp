import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todoapp/shared/cubit/states.dart';

import '../../modules/archive_tasks_screen.dart';
import '../../modules/done_tasks_screen.dart';
import '../../modules/new_tasks_screen.dart';

class AppCubit extends Cubit<AppStates>{
  AppCubit() : super (AppInitialState());
  static AppCubit get(context) => BlocProvider.of(context);

  int currentIndex = 0;
  List<Widget> screens = [
    NewTasksScreen(),
    DoneTasksScreen(),
    ArchivedTasksScreen(),
  ];
  List<String> titles = [
    "New Tasks",
    "Done Tasks",
    "Archived Tasks",
  ];
  void changeIndex(int index)
  {
    currentIndex = index;
    emit(AppChangeBottomNavBarState());
  }


}