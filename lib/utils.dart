import 'dart:core';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

String datePattern = "dd/MM/yyyy";

Future<DateTime?> pickDate(BuildContext context,
    {DateTime? initialDate}) async {
  final DateTime? date = await showDatePicker(
    context: context,
    initialDate: initialDate ?? DateTime.now(),
    firstDate: DateTime(1950),
    lastDate: DateTime(2050),
  );

  return date;
}

String toDDMMYYYY(DateTime date) {
  // dd/MM/YYYY
  return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year.toString()}";
}

DateTime stringToDateTime(String date) {
  return DateFormat(datePattern).parse(date);
}

bool isDatePassed(String date) {
  DateTime expireDate = stringToDateTime(date);
  return DateTime.now().isAfter(expireDate);
}

bool is12YearOld(String dobStr) {
  DateTime today = DateTime.now();
  DateTime dob = stringToDateTime(dobStr);

  // Date to check but moved 12 years ahead
  DateTime adultDate = DateTime(
    dob.year + 12,
    dob.month,
    dob.day,
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
