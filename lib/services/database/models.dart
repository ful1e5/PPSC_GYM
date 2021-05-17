class Client {
  final int id;
  final String name;
  final String gender;
  final String dob;
  final String session;
  final int mobile;

  Client({
    required this.id,
    required this.name,
    required this.gender,
    required this.dob,
    required this.session,
    required this.mobile,
  });

  Client.fromMap(Map<String, dynamic> res)
      : id = res["id"],
        name = res["name"],
        gender = res["gender"],
        dob = res["dob"],
        session = res["session"],
        mobile = res["mobile"];

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'name': name,
      'gender': gender,
      'dob': dob,
      'session': session,
      'mobile': mobile,
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
  final String startDate;
  final String endDate;
  final int money;

  Payment(
      {this.id,
      required this.clientId,
      required this.startDate,
      required this.endDate,
      required this.money});

  Payment.fromMap(Map<String, dynamic> res)
      : id = res["id"],
        clientId = res["clientId"],
        startDate = res["startDate"],
        endDate = res["endDate"],
        money = res["money"];

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'clientId': clientId,
      'startDate': startDate,
      'endDate': endDate,
      'money': money,
    };
  }
}
