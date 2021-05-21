import 'package:ppscgym/services/database/handler.dart';
import 'package:ppscgym/services/database/models.dart';

String handleClientErrors(String error, Client client) {
  if (error.contains('UNIQUE constraint failed:')) {
    if (error.contains("$clientTable.id")) {
      return "Error: Duplicate identification found for ${client.id}";
    } else if (error.contains("$clientTable.mobile")) {
      return "Error: Duplicate mobile number ${client.mobile}";
    } else {
      return "Error: Unhandled Unique Constraint";
    }
  } else {
    return "Unhandled Error Occurred";
  }
}

String handlePlanErrors(String error, Plan plan) {
  if (error.contains('UNIQUE constraint failed:')) {
    if (error.contains("$planTable.months")) {
      return "Error: ${plan.months} Months plan already existed";
    } else {
      return "Error: Unhandled Unique Constraint";
    }
  } else {
    return "Unhandled Error Occurred";
  }
}
