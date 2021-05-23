import 'package:path/path.dart';
import 'package:ppscgym/utils.dart';
import 'package:sqflite/sqflite.dart';

import 'package:ppscgym/services/errors.dart';
import 'package:ppscgym/services/database/models.dart';

final String clientTable = "client";
final String planTable = "plan";
final String paymentTable = "payment";

class DatabaseHandler {
  Future<Database> initializeDB() async {
    String path = await getDatabasesPath();
    return openDatabase(
      join(path, 'ppscgym.db'),
      onCreate: (database, version) async {
        await database.execute('PRAGMA foreign_keys = ON;');
        await database.execute("CREATE TABLE $clientTable("
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

        // Client -> Payments (one to many relation)

        await database.execute("CREATE TABLE $paymentTable("
            "id INTEGER PRIMARY KEY AUTOINCREMENT,"
            "months INTEGER NOT NULL,"
            "startDate TEXT NOT NULL,"
            "endDate TEXT NOT NULL,"
            "money INTEGER NOT NULL,"
            "note TEXT,"
            "clientId INTEGER NOT NULL,"
            "FOREIGN KEY (clientId) REFERENCES $clientTable (id) ON DELETE CASCADE"
            ")");
      },
      version: 1,
    );
  }

  //
  // Client
  //

  Future<String?> insertClient(Client client) async {
    final Database db = await initializeDB();
    try {
      await db.insert(clientTable, client.toMap());
      return null;
    } catch (e) {
      return handleClientErrors(e.toString(), client);
    }
  }

  Future<String?> updateClient(Client client) async {
    final Database db = await initializeDB();
    try {
      await db.update(
        clientTable,
        client.toMap(),
        where: "id = ?",
        whereArgs: [client.id],
      );
      return null;
    } catch (e) {
      return handleClientErrors(e.toString(), client);
    }
  }

  Future<void> deleteClient(int id) async {
    final db = await initializeDB();
    await db.delete(
      clientTable,
      where: "id = ?",
      whereArgs: [id],
    );
    await db.delete(
      paymentTable,
      where: "clientId = ?",
      whereArgs: [id],
    );
  }

  Future<List<Client>> retrieveClients() async {
    final Database db = await initializeDB();
    final List<Map<String, Object?>> queryResult = await db.query(clientTable);
    return queryResult.map((e) => Client.fromMap(e)).toList();
  }

  Future<Client> retrieveClient(int id) async {
    final Database db = await initializeDB();
    final List<Map<String, Object?>> result =
        await db.query(clientTable, where: "id = ?", whereArgs: [id]);
    return Client.fromMap(result.first);
  }

  //
  // Payment
  //

  Future<void> insertPayment(Payment payment) async {
    final Database db = await initializeDB();
    await db.insert(paymentTable, payment.toMap());
    await updateClientInfo(payment.clientId);
  }

  Future<void> deletePayment(Payment payment) async {
    final Database db = await initializeDB();
    await db.delete(
      paymentTable,
      where: "id = ?",
      whereArgs: [payment.id],
    );
    await updateClientInfo(payment.clientId);
  }

  Future<List<Payment>> retriveClientPayments(int clientId) async {
    final Database db = await initializeDB();
    final List<Map<String, Object?>> queryResult = await db.query(paymentTable,
        where: "clientId = ?", whereArgs: [clientId], orderBy: "id DESC");
    return queryResult.map((e) => Payment.fromMap(e)).toList();
  }

  Future<void> updateClientInfo(int clientId) async {
    final Database db = await initializeDB();
    final List<Map<String, Object?>> queryResult = await db.query(paymentTable,
        where: "clientId = ?", whereArgs: [clientId], orderBy: "endDate DESC");

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

    // Updating client info
    final List<Map<String, Object?>> result =
        await db.query(clientTable, where: "id = ?", whereArgs: [clientId]);
    Map<String, Object?> map = Map<String, Object?>.from(result.first);

    if (dates.isNotEmpty) {
      map['planExpiryDate'] = toDDMMYYYY(dates.last[0]);
      map['planMonth'] = dates.last[1];
    } else {
      map['planExpiryDate'] = null;
      map['planMonth'] = null;
    }
    map['totalMoney'] = totalMoney;

    final Client client = Client.fromMap(map);

    await db.update(
      clientTable,
      client.toMap(),
      where: "id = ?",
      whereArgs: [client.id],
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
}
