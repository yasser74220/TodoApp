import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';

import '../cubit/cubit.dart';

Widget defualtButton({
  double width = double.infinity,
  Color color = Colors.blue,
  required Function() test,
  required String text,
}) =>
    Container(
      width: width,
      color: color,
      child: MaterialButton(
        onPressed: test,
        child: Text(
          "$text",
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
    );

Widget defualtInput({

  required TextEditingController controller,
   Function(String)? onSubmitted,
   Function(String)? change,
  required TextInputType inputType,

  void Function()? suffPressed,
  bool issuffix = false,
  bool isPassword = false,
  String? text,
  IconData? iconPre,
  IconData? iconSuff,
  Function ()? onTap,

  required FormFieldValidator<String>  validate,
}) =>
    TextFormField(

      obscureText: isPassword? true : false,
      controller: controller,
      onFieldSubmitted: onSubmitted,
      onChanged: change,
      keyboardType: inputType,
      validator: validate,
      onTap: onTap,
      decoration: InputDecoration(

        labelText: "$text",
        prefixIcon: Icon(iconPre),
        suffixIcon: issuffix != null ? IconButton(onPressed: suffPressed, icon: Icon(iconSuff)): null,
        border: OutlineInputBorder(),
      ),
    );

Widget taskItem(Map model, context) => Dismissible(
  key: Key(model['id'].toString()),
  child: Padding(
    padding: const EdgeInsets.all(20.0),
    child: Row(
      children: [
        CircleAvatar(
          radius: 40.0,
          child: Text(
            '${model['time']}',
          ),
        ),
        SizedBox(
          width: 20.0,
        ),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${model['title']}',
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${model['date']}',
                style: TextStyle(
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          width: 20.0,
        ),
        IconButton(
          onPressed: ()
          {
            AppCubit.get(context).updateData(
              status: 'done',
              id: model['id'],
            );
          },
          icon: Icon(
            Icons.check_box,
            color: Colors.green,
          ),
        ),
        IconButton(
          onPressed: () {
            AppCubit.get(context).updateData(
              status: 'archive',
              id: model['id'],
            );
          },
          icon: Icon(
            Icons.archive,
            color: Colors.black45,
          ),
        ),
      ],
    ),
  ),
  onDismissed: (direction)
  {
    AppCubit.get(context).deleteData(id: model['id'],);
  },
);
Widget tasksBuilder({
  required List<Map> tasks,
}) => ConditionalBuilder(
  condition: tasks.length > 0,
  builder: (context) => ListView.separated(
    itemBuilder: (context, index)
    {
      return taskItem(tasks[index], context);
    },
    separatorBuilder: (context, index) => Padding(
      padding: const EdgeInsetsDirectional.only(
        start: 20.0,
      ),
      child: Container(
        width: double.infinity,
        height: 1.0,
        color: Colors.grey[300],
      ),
    ),
    itemCount: tasks.length,
  ),
  fallback: (context) => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.menu,
          size: 100.0,
          color: Colors.grey,
        ),
        Text(
          'No Tasks Yet, Please Add Some Tasks',
          style: TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
      ],
    ),
  ),
);