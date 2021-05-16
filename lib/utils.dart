import 'dart:core';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

String datePattern = "dd/MM/yyyy";

Future<DateTime?> pickDate(BuildContext context,
    {DateTime? initialDate}) async {
  final DateTime? date = await showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: DateTime(1975),
      lastDate: DateTime(2024));

  return date;
}

String toDDMMYYYY(DateTime date) {
  // dd/MM/YYYY
  return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year.toString()}";
}

bool is12YearOld(String birthDateString) {
  // Current time - at this moment
  DateTime today = DateTime.now();

  // Parsed date to check
  DateTime birthDate = DateFormat(datePattern).parse(birthDateString);

  // Date to check but moved 12 years ahead
  DateTime adultDate = DateTime(
    birthDate.year + 12,
    birthDate.month,
    birthDate.day,
  );

  return adultDate.isBefore(today);
}

String getSessionString(List<bool> sessionList) {
  if (sessionList[0] == true) {
    return "Morning";
  } else {
    return "Evening";
  }
}

String getGenderString(List<bool> genderList) {
  if (genderList[0] == true) {
    return "Male";
  } else {
    return "Female";
  }
}

// " fIrst  nAMe   " => "First Name"
String formatName(String name) {
  final String formateName = name.replaceAll(RegExp('\\s+'), " ");
  return formateName
      .split(" ")
      .map((str) => toBeginningOfSentenceCase(str.toLowerCase()))
      .join(" ")
      .trim();
}
