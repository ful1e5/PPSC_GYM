import 'package:path/path.dart';
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
            "mobile INTEGER UNIQUE NOT NULL"
            ")");

        await database.execute("CREATE TABLE $planTable("
            "id INTEGER PRIMARY KEY AUTOINCREMENT,"
            "months INTEGER UNIQUE NOT NULL,"
            "price INTEGER NOT NULL"
            ")");

        // Client -> Payments (one to many relation)

        await database.execute("CREATE TABLE $paymentTable("
            "id INTEGER PRIMARY KEY AUTOINCREMENT,"
            "startDate TEXT NOT NULL,"
            "endDate TEXT NOT NULL,"
            "money INTEGER NOT NULL,"
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

  Future<String?> insertPayment(Payment payment) async {
    final Database db = await initializeDB();
    await db.insert(paymentTable, payment.toMap());
    return null;
  }

  Future<List<Payment>> retriveClientPayments(int clientId) async {
    final Database db = await initializeDB();
    final List<Map<String, Object?>> queryResult = await db.query(paymentTable,
        where: "clientId = ?", whereArgs: [clientId], orderBy: "id DESC");
    return queryResult.map((e) => Payment.fromMap(e)).toList();
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
