import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'package:ppscgym/services/errors.dart';
import 'package:ppscgym/services/database/models.dart';

class DatabaseHandler {
  Future<Database> initializeDB() async {
    String path = await getDatabasesPath();
    return openDatabase(
      join(path, 'ppscgym.db'),
      onCreate: (database, version) async {
        await database.execute(
          "CREATE TABLE clients(id INTEGER PRIMARY KEY, name TEXT NOT NULL, gender TEXT NOT NULL, dob TEXT NOT NULL, session TEXT NOT NULL, mobile INTEGER UNIQUE NOT NULL)",
        );

        await database.execute(
          "CREATE TABLE plans(id INTEGER PRIMARY KEY AUTOINCREMENT, months TEXT NOT NULL UNIQUE)",
        );
      },
      version: 1,
    );
  }

  // Init User
  Future<String?> insertClients(List<Client> clients) async {
    final Database db = await initializeDB();
    for (var client in clients) {
      try {
        await db.insert('clients', client.toMap());
        return null;
      } catch (e) {
        handleClientErrors(e.toString(), client);
      }
    }
  }

  Future<String?> updateClient(Client client) async {
    final Database db = await initializeDB();
    try {
      await db.update(
        'clients',
        client.toMap(),
        where: "id = ?",
        whereArgs: [client.id],
      );
      return null;
    } catch (e) {
      handleClientErrors(e.toString(), client);
    }
  }

  // Delete User
  Future<void> deleteClient(int id) async {
    final db = await initializeDB();
    await db.delete(
      'clients',
      where: "id = ?",
      whereArgs: [id],
    );
  }

  // Retrieve clients
  Future<List<Client>> retrieveClients() async {
    final Database db = await initializeDB();
    final List<Map<String, Object?>> queryResult = await db.query('clients');
    return queryResult.map((e) => Client.fromMap(e)).toList();
  }

  // Retrieve client

  Future<Client> retrieveClient(int id) async {
    final Database db = await initializeDB();
    final List<Map<String, Object?>> result =
        await db.query('clients', where: "id = ?", whereArgs: [id]);
    return Client.fromMap(result[0]);
  }
}
