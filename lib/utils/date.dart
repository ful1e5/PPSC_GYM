import 'dart:core';
import 'package:flutter/material.dart';

Future<DateTime?> pickDate(BuildContext context) async {
  final DateTime? date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1975),
      lastDate: DateTime(2024));

  return date;
}

String formateDate(DateTime date) {
  // dd-MM-YYYY
  return "${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year.toString()}";
}
