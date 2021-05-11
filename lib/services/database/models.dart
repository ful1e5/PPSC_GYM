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
