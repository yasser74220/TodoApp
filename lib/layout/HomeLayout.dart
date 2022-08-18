import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';
import 'package:todoapp/modules/archive_tasks_screen.dart';
import 'package:todoapp/modules/done_tasks_screen.dart';
import 'package:todoapp/modules/new_tasks_screen.dart';
import 'package:todoapp/shared/components/components.dart';
import 'package:todoapp/shared/cubit/cubit.dart';
import 'package:todoapp/shared/cubit/states.dart';

import '../main.dart';
import '../shared/components/constant.dart';
import '../shared/cubit/observer.dart';

class HomeLayout extends StatelessWidget {


  late Database database;
  var scaffoldKey = GlobalKey<ScaffoldState>();
  var validate = GlobalKey<FormState>();
  TextEditingController titleController = TextEditingController();
  TextEditingController timeController = TextEditingController();
  TextEditingController dateController = TextEditingController();
  bool isBottomshow = false;
  IconData fabicon = Icons.edit;


  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) => AppCubit(),
      child: BlocConsumer<AppCubit, AppStates>(
        listener:(BuildContext context,AppStates state) {

        },
        builder:(BuildContext context,AppStates state) {
          AppCubit cubit = AppCubit.get(context);
          return   Scaffold(
            key: scaffoldKey,
            appBar: AppBar(
              title: Text(cubit.titles[cubit.currentIndex]),
            ),
            floatingActionButton: FloatingActionButton(
                onPressed: () {
                  if (isBottomshow) {
                    if (validate.currentState!.validate()) {
                      insertDatabase(
                          title: titleController.text,
                          time: timeController.text,
                          date: dateController.text)
                          .then((value) {
                        Navigator.pop(context);
                        isBottomshow = false;
                        // setState(() {
                        //   fabicon = Icons.edit;
                        // });
                      });
                    }
                  } else {
                    scaffoldKey.currentState!
                        .showBottomSheet(
                          (context) => Container(
                        padding: EdgeInsets.all(20),
                        child: Form(
                          key: validate,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              defualtInput(
                                controller: titleController,
                                inputType: TextInputType.text,
                                text: 'Title',
                                iconPre: Icons.title,
                                validate: (value) {
                                  if (value!.isEmpty) {
                                    return 'title must not be empty';
                                  }

                                  return null;
                                },
                              ),
                              SizedBox(
                                height: 15.0,
                              ),
                              defualtInput(
                                controller: timeController,
                                inputType: TextInputType.datetime,
                                text: 'Time',
                                iconPre: Icons.watch_later_outlined,
                                onTap: () {
                                  showTimePicker(
                                      context: context,
                                      initialTime: TimeOfDay.now())
                                      .then((value) {
                                    timeController.text =
                                        value!.format(context).toString();
                                  });
                                },
                                validate: (value) {
                                  if (value!.isEmpty) {
                                    return 'Time must not be empty';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(
                                height: 15.0,
                              ),
                              defualtInput(
                                controller: dateController,
                                inputType: TextInputType.datetime,
                                text: 'Date',
                                iconPre: Icons.calendar_month,
                                onTap: () {
                                  showDatePicker(
                                      context: context,
                                      initialDate: DateTime.now(),
                                      firstDate: DateTime.now(),
                                      lastDate: DateTime(2040))
                                      .then((value) {
                                    dateController.text =
                                        DateFormat.yMMMd().format(value!);
                                  });
                                },
                                validate: (value) {
                                  if (value!.isEmpty) {
                                    return 'Time must not be empty';
                                  }
                                  return null;
                                },
                              )
                            ],
                          ),
                        ),
                      ),
                    )
                        .closed
                        .then((value) {
                      isBottomshow = false;
                      // setState(() {
                      //   fabicon = Icons.edit;
                      // });
                    });
                    isBottomshow = true;
                    // setState(() {
                    //   fabicon = Icons.add;
                    // });
                  }
                },
                child: Icon(fabicon)),
            bottomNavigationBar: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              currentIndex: cubit.currentIndex,
              onTap: (index) {
              cubit.changeIndex(index);
              },
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.new_label), label: "Tasks"),
                BottomNavigationBarItem(
                    icon: Icon(Icons.check_circle_outline), label: "Done"),
                BottomNavigationBarItem(
                    icon: Icon(Icons.archive_rounded), label: "Archived"),
              ],
            ),
            body: ConditionalBuilder(
              condition: tasks.length > 0,
              builder: (context) => cubit.screens[cubit.currentIndex],
              fallback: (context) => Center(child: CircularProgressIndicator()),
            ),
          );

        },

      ),);
  }

  void createDatabase() async {
    database = await openDatabase('todo.db', version: 1,
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
            // setState(() {
            //   tasks = value;
            // });
          });
        });
  }

  Future insertDatabase({
    required String title,
    required String time,
    required String date,
  }) async {
    await database.transaction((txn) =>
        txn
            .rawInsert(
            'INSERT INTO tasks(title, date, time, status) VALUES("$title", "$date", "$time", "new")')
            .then((value) {
          print('$value inserted successfully');
        }).catchError((error) {
          print('Error When Inserting New Record ${error.toString()}');
        }));
  }

  Future<List<Map>> getDatabase(database) {
    return database.rawQuery('SELECT * FROM tasks');
  }
}






