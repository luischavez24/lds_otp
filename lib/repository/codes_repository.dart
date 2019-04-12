import 'dart:async';
import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import 'package:lds_otp/models/code_model.dart';

class CodesRepository {

  static Database _database;

  Future<Database> get database async {
    if (_database != null) {
      return _database;
    } else {
      // if _database is null we instantiate it
      _database = await initDB();
      return _database;
    }
  }

  Future<Database> initDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "codes.db");

    return await openDatabase(
        path,
        version: 1,
        onOpen: (db) {},
        onCreate: _createDatabase
    );
  }

  Future<int> addCode(CodeModel code) async {
    final db = await database;
    return await db.insert("Codes", code.toMap());
  }

  Future<int> deleteCode(String user, String domain) async {
    final db = await database;
    return await db.delete(
        "Codes",
        where: "user = ? and domain = ?",
        whereArgs: [user, domain]
    );
  }

  Future<List<CodeModel>> getAllCodes() async {
    final db = await database;
    var res = await db.query("Codes");
    return res.isNotEmpty ? res.map((c) => CodeModel.fromMap(c)).toList() : [];
  }

  Future _createDatabase(Database db, int version) async {
    var sSQL = StringBuffer();
    sSQL.write(" CREATE TABLE Codes ( ");
    sSQL.write(" user TEXT, ");
    sSQL.write(" domain TEXT, ");
    sSQL.write(" issuer TEXT, ");
    sSQL.write(" secret TEXT, ");
    sSQL.write(" PRIMARY KEY(user, domain) )");
    await db.execute(sSQL.toString());
  }
}
