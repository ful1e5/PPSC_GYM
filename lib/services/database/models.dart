import 'dart:convert';

class Member {
  final int id;
  final String name;
  final String gender;
  final String dob;
  final String session;
  final int mobile;
  final int totalMoney;
  final String? planExpiryDate;
  final int? planMonth;

  Member({
    required this.id,
    required this.name,
    required this.gender,
    required this.dob,
    required this.session,
    required this.mobile,
    this.totalMoney = 0,
    this.planExpiryDate,
    this.planMonth,
  });

  Member.fromMap(Map<String, dynamic> res)
      : id = res['id'],
        name = res['name'],
        gender = res['gender'],
        dob = res['dob'],
        session = res['session'],
        mobile = res['mobile'],
        planExpiryDate = res['planExpiryDate'],
        planMonth = res['planMonth'],
        totalMoney = res['totalMoney'];

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'name': name,
      'gender': gender,
      'dob': dob,
      'session': session,
      'mobile': mobile,
      'planExpiryDate': planExpiryDate,
      'planMonth': planMonth,
      'totalMoney': totalMoney,
    };
  }

  factory Member.fromJson(Map<String, dynamic> json) {
    return Member(
      id: json['id'],
      name: json['name'],
      gender: json['gender'],
      dob: json['dob'],
      session: json['session'],
      mobile: json['mobile'],
      planExpiryDate: json['planExpiryDate'],
      planMonth: json['planMonth'],
      totalMoney: json['totalMoney'],
    );
  }

  Map toJson() {
    return {
      'id': id,
      'name': name,
      'gender': gender,
      'dob': dob,
      'session': session,
      'mobile': mobile,
      'planExpiryDate': planExpiryDate,
      'planMonth': planMonth,
      'totalMoney': totalMoney,
    };
  }
}

class Plan {
  final int? id;
  final int months;
  final int money;

  Plan.fromMap(Map<String, dynamic> res)
      : id = res['id'],
        months = res['months'],
        money = res['money'];

  Plan({this.id, required this.months, required this.money});

  factory Plan.fromJson(Map<String, dynamic> json) {
    return Plan(
      id: json['id'],
      months: json['months'],
      money: json['money'],
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'months': months,
      'money': money,
    };
  }

  Map toJson() {
    return {
      'id': id,
      'months': months,
      'money': money,
    };
  }
}

class Payment {
  final int? id;
  final int memberId;
  final int months;
  final String startDate;
  final String endDate;
  final int money;
  final String? note;

  Payment({
    this.id,
    required this.memberId,
    required this.months,
    required this.startDate,
    required this.endDate,
    required this.money,
    this.note,
  });

  Payment.fromMap(Map<String, dynamic> res)
      : id = res['id'],
        memberId = res['memberId'],
        months = res['months'],
        startDate = res['startDate'],
        endDate = res['endDate'],
        money = res['money'],
        note = res['note'];

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'memberId': memberId,
      'months': months,
      'startDate': startDate,
      'endDate': endDate,
      'money': money,
      'note': note,
    };
  }

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'],
      memberId: json['memberId'],
      months: json['months'],
      startDate: json['startDate'],
      endDate: json['endDate'],
      money: json['money'],
      note: json['note'],
    );
  }

  Map toJson() {
    return {
      'id': id,
      'memberId': memberId,
      'months': months,
      'startDate': startDate,
      'endDate': endDate,
      'money': money,
      'note': note,
    };
  }
}

class BackupFile {
  final List<Member> members;
  final List<Plan> plans;
  final List<Payment> payments;

  BackupFile({
    required this.members,
    required this.plans,
    required this.payments,
  });

  factory BackupFile.fromJson(Map<String, dynamic> json) {
    return BackupFile(
      members: jsonDecode(json['members']),
      plans: jsonDecode(json['plans']),
      payments: jsonDecode(json['payments']),
    );
  }

  Map toJson() {
    return {
      'members': jsonEncode(members),
      'plans': jsonEncode(plans),
      'payments': jsonEncode(payments),
    };
  }
}
