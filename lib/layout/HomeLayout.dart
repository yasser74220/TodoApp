import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:todoapp/modules/archive_tasks_screen.dart';
import 'package:todoapp/modules/done_tasks_screen.dart';
import 'package:todoapp/modules/new_tasks_screen.dart';

class HomeLayout extends StatefulWidget {
  const HomeLayout({Key? key}) : super(key: key);

  @override
  State<HomeLayout> createState() => _HomeLayoutState();
}

class _HomeLayoutState extends State<HomeLayout> {
  late Database database;
  var scaffoldKey = GlobalKey<ScaffoldState>();
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
              Navigator.pop(context);
              isBottomshow = false;
              setState(() {
                fabicon = Icons.edit;
              });
            } else {
              scaffoldKey.currentState!.showBottomSheet(
                (context) => Container(
                  color: Colors.red,
                  height: 120.0,
                  width: double.infinity,
                ),
              );
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
      body: screens[currentIndex],
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
    }, onOpen: (database) {});
  }

  void insertDatabase() {
    database.transaction((txn) => txn
            .rawInsert(
                'INSERT INTO tasks(title, date, time, status) VALUES("asfa", "231", "234", "new")')
            .then((value) {
          print('$value inserted successfully');
        }).catchError((error) {
          print('Error When Inserting New Record ${error.toString()}');
        }));
  }
}
