import 'package:path/path.dart';
import 'dart:convert';

import 'package:sqflite/sqflite.dart';

import 'package:ppscgym/services/errors.dart';
import 'package:ppscgym/services/database/models.dart';
import 'package:ppscgym/utils.dart';

final String memberTable = "member";
final String planTable = "plan";
final String paymentTable = "payment";

class DatabaseHandler {
  Future<Database> initializeDB() async {
    String path = await getDatabasesPath();
    return openDatabase(
      join(path, 'ppscgym.db'),
      onCreate: (database, version) async {
        await database.execute('PRAGMA foreign_keys = ON;');
        await database.execute("CREATE TABLE $memberTable("
            "id INTEGER PRIMARY KEY,"
            "name TEXT NOT NULL,"
            "gender TEXT NOT NULL,"
            "dob TEXT NOT NULL,"
            "session TEXT NOT NULL,"
            "mobile INTEGER UNIQUE NOT NULL,"
            "planExpiryDate TEXT,"
            "planMonth INTEGER,"
            "totalMoney INTEGER"
            ")");

        await database.execute("CREATE TABLE $planTable("
            "id INTEGER PRIMARY KEY AUTOINCREMENT,"
            "months INTEGER UNIQUE NOT NULL,"
            "money INTEGER NOT NULL"
            ")");

        // Member -> Payments (one to many relation)

        await database.execute("CREATE TABLE $paymentTable("
            "id INTEGER PRIMARY KEY AUTOINCREMENT,"
            "months INTEGER NOT NULL,"
            "startDate TEXT NOT NULL,"
            "endDate TEXT NOT NULL,"
            "money INTEGER NOT NULL,"
            "note TEXT,"
            "memberId INTEGER NOT NULL,"
            "FOREIGN KEY (memberId) REFERENCES $memberTable (id) ON DELETE CASCADE"
            ")");
      },
      version: 1,
    );
  }

  //
  // Member
  //

  Future<String?> insertMember(Member member) async {
    final Database db = await initializeDB();
    try {
      await db.insert(memberTable, member.toMap());
      return null;
    } catch (e) {
      return handleMemberErrors(e.toString(), member);
    }
  }

  Future<String?> updateMember(Member member) async {
    final Database db = await initializeDB();
    try {
      await db.update(
        memberTable,
        member.toMap(),
        where: "id = ?",
        whereArgs: [member.id],
      );
      return null;
    } catch (e) {
      return handleMemberErrors(e.toString(), member);
    }
  }

  Future<void> deleteMember(int id) async {
    final db = await initializeDB();
    await db.delete(
      memberTable,
      where: "id = ?",
      whereArgs: [id],
    );
    await db.delete(
      paymentTable,
      where: "memberId = ?",
      whereArgs: [id],
    );
  }

  Future<List<Member>> retrieveMembers() async {
    final Database db = await initializeDB();
    final List<Map<String, Object?>> queryResult = await db.query(memberTable);
    return queryResult.map((e) => Member.fromMap(e)).toList();
  }

  Future<Member> retrieveMember(int id) async {
    final Database db = await initializeDB();
    final List<Map<String, Object?>> result =
        await db.query(memberTable, where: "id = ?", whereArgs: [id]);
    return Member.fromMap(result.first);
  }

  //
  // Payment
  //

  Future<void> insertPayment(Payment payment) async {
    final Database db = await initializeDB();
    await db.insert(paymentTable, payment.toMap());
    await updateMemberInfo(payment.memberId);
  }

  Future<void> deletePayment(Payment payment) async {
    final Database db = await initializeDB();
    await db.delete(
      paymentTable,
      where: "id = ?",
      whereArgs: [payment.id],
    );
    await updateMemberInfo(payment.memberId);
  }

  Future<List<Payment>> retriveMemberPayments(int memberId) async {
    final Database db = await initializeDB();
    final List<Map<String, Object?>> queryResult = await db.query(paymentTable,
        where: "memberId = ?", whereArgs: [memberId], orderBy: "id DESC");
    return queryResult.map((e) => Payment.fromMap(e)).toList();
  }

  Future<void> updateMemberInfo(int memberId) async {
    final Database db = await initializeDB();
    final List<Map<String, Object?>> queryResult = await db.query(paymentTable,
        where: "memberId = ?", whereArgs: [memberId], orderBy: "endDate DESC");

    final List<List> dates = queryResult
        .map(
          (e) => [
            stringToDateTime(Payment.fromMap(e).endDate),
            Payment.fromMap(e).months
          ],
        )
        .toList();

    dates.sort((a, b) => a[0].compareTo(b[0]));

    int totalMoney = 0;
    queryResult.forEach((e) => totalMoney += Payment.fromMap(e).money);

    // Updating member info
    final List<Map<String, Object?>> result =
        await db.query(memberTable, where: "id = ?", whereArgs: [memberId]);
    Map<String, Object?> map = Map<String, Object?>.from(result.first);

    if (dates.isNotEmpty) {
      map['planExpiryDate'] = toDDMMYYYY(dates.last[0]);
      map['planMonth'] = dates.last[1];
    } else {
      map['planExpiryDate'] = null;
      map['planMonth'] = null;
    }
    map['totalMoney'] = totalMoney;

    final Member member = Member.fromMap(map);

    await db.update(
      memberTable,
      member.toMap(),
      where: "id = ?",
      whereArgs: [member.id],
    );
  }

  //
  // Plan
  //

  Future<String?> insertPlan(Plan plan) async {
    final Database db = await initializeDB();
    try {
      await db.insert(planTable, plan.toMap());
      return null;
    } catch (e) {
      return handlePlanErrors(e.toString(), plan);
    }
  }

  Future<String?> updatePlan(Plan plan) async {
    final Database db = await initializeDB();
    try {
      await db.update(
        planTable,
        plan.toMap(),
        where: "id = ?",
        whereArgs: [plan.id],
      );
      return null;
    } catch (e) {
      return handlePlanErrors(e.toString(), plan);
    }
  }

  Future<void> deletePlan(int id) async {
    final db = await initializeDB();
    await db.delete(
      planTable,
      where: "id = ?",
      whereArgs: [id],
    );
  }

  Future<List<Plan>> retrievePlans() async {
    final Database db = await initializeDB();
    final List<Map<String, Object?>> queryResult =
        await db.query(planTable, orderBy: "months ASC");
    return queryResult.map((e) => Plan.fromMap(e)).toList();
  }

  // Backup

  Future<String?> backup(String sep) async {
    final Database db = await initializeDB();

    final members = await this.retrieveMembers();
    if (members.isEmpty) {
      return null;
    } else {
      final paymentsRes = await db.query(paymentTable);
      final payments = paymentsRes.map((e) => Payment.fromMap(e)).toList();

      final plansRes = await db.query(planTable);
      final plans = plansRes.map((e) => Plan.fromMap(e)).toList();

      final backupFile = BackupFile(
        members: members,
        payments: payments,
        plans: plans,
      );

      return jsonEncode(backupFile);
    }
  }

  Future<void> restoreBackup(String data) async {}
}
