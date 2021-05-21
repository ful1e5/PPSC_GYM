import 'package:flutter/material.dart';

final TextStyle slightBoldText = TextStyle(
    fontSize: 16.0, color: Colors.white12, fontWeight: FontWeight.bold);

ButtonStyle materialButtonStyle(
    {Color? backgroundColor,
    Color? foregroundColor,
    EdgeInsetsGeometry? padding}) {
  return ButtonStyle(
    backgroundColor:
        MaterialStateProperty.all<Color>(backgroundColor ?? Colors.white),
    foregroundColor:
        MaterialStateProperty.all<Color>(foregroundColor ?? Colors.blue),
    padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
      padding ??
          EdgeInsets.only(top: 10.0, bottom: 10.0, right: 40.0, left: 40.0),
    ),
    shape: MaterialStateProperty.all(
      RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30.0),
      ),
    ),
  );
}
