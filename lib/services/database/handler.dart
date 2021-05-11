import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import 'package:ppscgym/services/database/models.dart';

class DatabaseHandler {
  Future<Database> initializeDB() async {
    String path = await getDatabasesPath();
    return openDatabase(
      join(path, 'ppscgym.db'),
      onCreate: (database, version) async {
        await database.execute(
          "CREATE TABLE clients(id INTEGER PRIMARY KEY, name TEXT NOT NULL,dob TEXT NOT NULL, session TEXT NOT NULL, mobile INTEGER UNIQUE NOT NULL)",
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
        final eStr = e.toString();
        if (eStr.contains('UNIQUE constraint failed:')) {
          if (eStr.contains("clients.id")) {
            return "Error: Dublicate identication found for ${client.id}";
          } else if (eStr.contains("clients.mobile")) {
            return "Error: Dublicate mobile number ${client.mobile}";
          } else {
            return "Error: Unhanlded Unique Constraint";
          }
        } else {
          return "Unhandled Error Occurred";
        }
      }
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
