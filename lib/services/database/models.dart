class Cleint {
  final int id;
  final String name;
  final String dob;
  final String session;
  final int mobile;

  Cleint({
    required this.id,
    required this.name,
    required this.dob,
    required this.session,
    required this.mobile,
  });

  Cleint.fromMap(Map<String, dynamic> res)
      : id = res["id"],
        name = res["name"],
        dob = res["dob"],
        session = res["session"],
        mobile = res["mobile"];

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'name': name,
      'dob': dob,
      'session': session,
      'mobile': mobile,
    };
  }
}
