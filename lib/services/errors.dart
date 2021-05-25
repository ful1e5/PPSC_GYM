import 'package:ppscgym/services/database/handler.dart';
import 'package:ppscgym/services/database/models.dart';

String handleMemberErrors(String error, Member member) {
  if (error.contains('UNIQUE constraint failed:')) {
    if (error.contains("$memberTable.id")) {
      return "Error: Duplicate identification found for ${member.id}";
    } else if (error.contains("$memberTable.mobile")) {
      return "Error: Duplicate mobile number ${member.mobile}";
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
