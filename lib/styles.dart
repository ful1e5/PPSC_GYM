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
    padding: MaterialStateProperty.all<EdgeInsetsGeometry?>(padding),
    shape: MaterialStateProperty.all(
      RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
    ),
  );
}
