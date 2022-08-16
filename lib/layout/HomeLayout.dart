import 'package:flutter/material.dart';
import 'package:todoapp/modules/archive_tasks_screen.dart';
import 'package:todoapp/modules/done_tasks_screen.dart';
import 'package:todoapp/modules/new_tasks_screen.dart';

class HomeLayout extends StatefulWidget {
  const HomeLayout({Key? key}) : super(key: key);

  @override
  State<HomeLayout> createState() => _HomeLayoutState();
}

class _HomeLayoutState extends State<HomeLayout> {
  int currentIndex =0;
  List<Widget> screens = [
    NewTasksScreen(),
    DoneTasksScreen(),
    ArchivedTasksScreen(),
  ];
  List <String> titles = [
    "New Tasks",
    "Done Tasks",
    "Archived Tasks",
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(titles[currentIndex]),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: currentIndex,
        onTap: (index){
          setState((){
            currentIndex = index;
          });
        },
        items:  const [
          BottomNavigationBarItem(icon: Icon(Icons.new_label),label: "Tasks"),
          BottomNavigationBarItem(icon: Icon(Icons.check_circle_outline),label: "Done"),
          BottomNavigationBarItem(icon: Icon(Icons.archive_rounded),label: "Archived"),

        ],
      ),
      body: screens[currentIndex],
    );
  }
}
