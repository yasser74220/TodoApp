import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';
import 'package:todoapp/modules/archive_tasks_screen.dart';
import 'package:todoapp/modules/done_tasks_screen.dart';
import 'package:todoapp/modules/new_tasks_screen.dart';
import 'package:todoapp/shared/components/components.dart';

import '../shared/components/constant.dart';

class HomeLayout extends StatefulWidget {
  const HomeLayout({Key? key}) : super(key: key);

  @override
  State<HomeLayout> createState() => _HomeLayoutState();
}

class _HomeLayoutState extends State<HomeLayout> {
  late Database database;
  var scaffoldKey = GlobalKey<ScaffoldState>();
  var validate = GlobalKey<FormState>();
  TextEditingController titleController = TextEditingController();
  TextEditingController timeController = TextEditingController();
  TextEditingController dateController = TextEditingController();
  bool isBottomshow = false;
  IconData fabicon = Icons.edit;
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

  @override
  void initState() {
    super.initState();
    createDatabase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: Text(titles[currentIndex]),
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
                  setState(() {
                    fabicon = Icons.edit;
                  });
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
                setState(() {
                  fabicon = Icons.edit;
                });
              });
              isBottomshow = true;
              setState(() {
                fabicon = Icons.add;
              });
            }
          },
          child: Icon(fabicon)),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: currentIndex,
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
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
        builder: (context) => screens[currentIndex],
        fallback: (context) => Center(child: CircularProgressIndicator()),
      ),
    );
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
        setState(() {
          tasks = value;
        });
      });
    });
  }

  Future insertDatabase({
    required String title,
    required String time,
    required String date,
  }) async {
    await database.transaction((txn) => txn
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
