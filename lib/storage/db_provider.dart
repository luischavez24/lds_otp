import 'dart:async';
import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import 'package:lds_otp/models/totp_model.dart';

class DBProvider {
  DBProvider._();

  static final DBProvider db = DBProvider._();

  static Database _database;

  Future<Database> get database async {
    if (_database != null) return _database;
    // if _database is null we instantiate it
    _database = await initDB();
    return _database;
  }

  initDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "codes.db");
    return await openDatabase(path,
        version: 1, onOpen: (db) {}, onCreate: _createDatabase);
  }

  addCode(CodeModel code) async {
    final db = await database;
    return await db.insert("Codes", code.toMap());
  }

  Future<List<CodeModel>> getAllCodes() async {
    final db = await database;
    var res = await db.query("Codes");
    return res.isNotEmpty ? res.map((c) => CodeModel.fromMap(c)).toList() : [];
  }

  _createDatabase(Database db, int version) async {
    var sSQL = StringBuffer();
    sSQL.write(" CREATE TABLE Codes ( ");
    sSQL.write(" barcode TEXT PRIMARY KEY");
    sSQL.write(" ) ");
    await db.execute(sSQL.toString());
  }
}
