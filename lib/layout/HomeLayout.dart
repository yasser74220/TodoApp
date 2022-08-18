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

import '../shared/components/constant.dart';

class HomeLayout extends StatelessWidget {
  var scaffoldKey = GlobalKey<ScaffoldState>();
  var validate = GlobalKey<FormState>();
  TextEditingController titleController = TextEditingController();
  TextEditingController timeController = TextEditingController();
  TextEditingController dateController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) => AppCubit()..createDatabase(),
      child: BlocConsumer<AppCubit, AppStates>(
        listener: (BuildContext context, AppStates state) {
          if (state is AppInsertDatabaseState) {
            Navigator.pop(context);
          }
        },
        builder: (BuildContext context, AppStates state) {
          AppCubit cubit = AppCubit.get(context);
          return Scaffold(
            key: scaffoldKey,
            appBar: AppBar(
              title: Text(cubit.titles[cubit.currentIndex]),
            ),
            floatingActionButton: FloatingActionButton(
                onPressed: () {
                  if (cubit.isBottomshow) {
                    if (validate.currentState!.validate()) {
                      cubit.insertDatabase(
                          title: titleController.text,
                          time: timeController.text,
                          date: dateController.text);
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
                      cubit.ChangeBottomSheetState(
                          isShow: false, icon: Icons.edit);
                    });
                    cubit.ChangeBottomSheetState(isShow: true, icon: Icons.add);
                  }
                },
                child: Icon(cubit.fabicon)),
            bottomNavigationBar: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              currentIndex: cubit.currentIndex,
              onTap: (index) {
                cubit.changeIndex(index);
              },
              items: const [
                BottomNavigationBarItem(
                    icon: Icon(Icons.new_label), label: "Tasks"),
                BottomNavigationBarItem(
                    icon: Icon(Icons.check_circle_outline), label: "Done"),
                BottomNavigationBarItem(
                    icon: Icon(Icons.archive_rounded), label: "Archived"),
              ],
            ),
            body: ConditionalBuilder(
              condition: 5 > 0,
              builder: (context) => cubit.screens[cubit.currentIndex],
              fallback: (context) => Center(child: CircularProgressIndicator()),
            ),
          );
        },
      ),
    );
  }
}
