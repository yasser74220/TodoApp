import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sqflite/sqflite.dart';
import 'package:todoapp/shared/cubit/states.dart';

import '../../modules/archive_tasks_screen.dart';
import '../../modules/done_tasks_screen.dart';
import '../../modules/new_tasks_screen.dart';

class AppCubit extends Cubit<AppStates>{
  AppCubit() : super (AppInitialState());
  static AppCubit get(context) => BlocProvider.of(context);
    late Database database;
  List<Map> tasks = [];

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

  void createDatabase()  {
   openDatabase('todo.db', version: 1,
        onCreate: (database, version) {
          //int id
          //title str
          //date str
          //time str
          //status str
          print("database created");
          database
              .execute(
              "CREATE TABLE tasks (id INTEGER PRIMARY KEY, title TEXT, date TEXT, time TEXT, status TEXT)")
              .then((value) {
            print("tables created");
          });
        }, onOpen: (database) {
          getDatabase(database).then((value) {
              tasks = value;
              print(tasks);
              emit(AppGetDatabaseState());
          });
          print("database opened");
        }).then((value) {
          database = value;
          emit(AppCreateDatabaseState());

   });
  }

   insertDatabase({
    required String title,
    required String time,
    required String date,
  }) async {
    await database.transaction((txn) => txn
        .rawInsert(
        'INSERT INTO tasks(title, date, time, status) VALUES("$title", "$date", "$time", "new")')
        .then((value) {
      print('$value inserted successfully');
      emit(AppInsertDatabaseState());
      getDatabase(database).then((value) {
        tasks = value;
        print(tasks);
        emit(AppGetDatabaseState());
      });
    }).catchError((error) {
      print('Error When Inserting New Record ${error.toString()}');
    }));
  }

  Future<List<Map>> getDatabase(database) {
    return database.rawQuery('SELECT * FROM tasks');
  }

  bool isBottomshow = false;
  IconData fabicon = Icons.edit;

  void ChangeBottomSheetState({
  required bool isShow,
    required IconData icon,
})
  {
    isBottomshow = isShow;
    fabicon = icon;
    emit(AppChangeBottomSheetState());
  }
}