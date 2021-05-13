import 'package:ppscgym/services/database/models.dart';

String handleClientErrors(String error, Client client) {
  if (error.contains('UNIQUE constraint failed:')) {
    if (error.contains("clients.id")) {
      return "Error: Dublicate identication found for ${client.id}";
    } else if (error.contains("clients.mobile")) {
      return "Error: Dublicate mobile number ${client.mobile}";
    } else {
      return "Error: Unhanlded Unique Constraint";
    }
  } else {
    return "Unhandled Error Occurred";
  }
}

String handlePlanErrors(String error, int month) {
  if (error.contains('UNIQUE constraint failed:')) {
    if (error.contains("plans.months")) {
      return "Error: $month months plan already existed";
    } else {
      return "Error: Unhanlded Unique Constraint";
    }
  } else {
    return "Unhandled Error Occurred";
  }
}
