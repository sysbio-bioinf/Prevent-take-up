import 'dart:async';
import 'dart:io';
import 'package:meta/meta.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart' as sqflite;
import 'package:sqflite/sqflite.dart';
import 'package:flutter/widgets.dart';
import 'package:questionnaires/models/answer.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseConnector {
  final String databasePath;
  final database;

  DatabaseConnector._create(
      {required this.databasePath, required this.database});

  static Future<DatabaseConnector> initiate(String databasePath) async {
    WidgetsFlutterBinding.ensureInitialized();
    final database = sqflite.openDatabase(
      join("./", databasePath),
      onCreate: (db, version) {
        return db.execute(
            'CREATE TABLE answers(answer STRING, timeAdded DATE PRIMARY KEY');
      },
      version: 1,
    );

    return DatabaseConnector._create(
        databasePath: databasePath, database: database);
  }

  Future<void> insertAnswerSet(List<Answer> answerSet) async {
    String res = "";

    answerSet.forEach((answer) {
      res = res + answer.text + ";";
    });

    Map<String, dynamic> entry = {'answer': res, 'timeAdded': DateTime.now()};
    final Database db = await this.database;

    await db.insert('answers', entry,
        conflictAlgorithm: ConflictAlgorithm.abort);
  }
}
