class Client {
  final int id;
  final String name;
  final String gender;
  final String dob;
  final String session;
  final int mobile;
  final int totalMoney;
  final String? planExpiryDate;

  Client({
    required this.id,
    required this.name,
    required this.gender,
    required this.dob,
    required this.session,
    required this.mobile,
    this.totalMoney = 0,
    this.planExpiryDate,
  });

  Client.fromMap(Map<String, dynamic> res)
      : id = res["id"],
        name = res["name"],
        gender = res["gender"],
        dob = res["dob"],
        session = res["session"],
        mobile = res["mobile"],
        planExpiryDate = res["planExpiryDate"],
        totalMoney = res["totalMoney"];

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'name': name,
      'gender': gender,
      'dob': dob,
      'session': session,
      'mobile': mobile,
      'planExpiryDate': planExpiryDate,
      'totalMoney': totalMoney,
    };
  }
}

class Plan {
  final int? id;
  final int months;
  final int price;

  Plan({this.id, required this.months, required this.price});

  Plan.fromMap(Map<String, dynamic> res)
      : id = res["id"],
        months = res["months"],
        price = res["price"];

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'months': months,
      'price': price,
    };
  }
}

class Payment {
  final int? id;
  final int clientId;
  final int months;
  final String startDate;
  final String endDate;
  final int money;
  final String? note;

  Payment({
    this.id,
    required this.clientId,
    required this.months,
    required this.startDate,
    required this.endDate,
    required this.money,
    this.note,
  });

  Payment.fromMap(Map<String, dynamic> res)
      : id = res["id"],
        clientId = res["clientId"],
        months = res["months"],
        startDate = res["startDate"],
        endDate = res["endDate"],
        money = res["money"],
        note = res["note"];

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'clientId': clientId,
      'months': months,
      'startDate': startDate,
      'endDate': endDate,
      'money': money,
      'note': note,
    };
  }
}
