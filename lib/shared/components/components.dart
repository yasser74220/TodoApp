import 'package:flutter/material.dart';

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
