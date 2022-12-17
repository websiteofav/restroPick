import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:flutter/cupertino.dart';
import 'package:restropick/homepage/model/menu_model.dart';
import 'package:restropick/utils/constants.dart';

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class LocalDBRepository {
  LocalDBRepository();
  static final LocalDBRepository instance = LocalDBRepository._init();

  static Database? _database;
  LocalDBRepository._init();

  Future<Database> get database async {
    try {
      if (_database != null) return _database!;

      _database = await _initDB('news.db');
      return _database!;
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  Future<Database> _initDB(String filepath) async {
    try {
      final dbPath = await getDatabasesPath();
      final path = join(dbPath, filepath);

      return await openDatabase(
        path,
        version: 1,
      );
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  Future<bool> createMenuDB() async {
    try {
      final Database db = await database;
      const keyType = "TEXT PRIMARY KEY";
      const descriptionType = "TEXT";
      const value = "INTEGER";

      await db.execute('''
      CREATE TABLE IF NOT EXISTS ${Keys.userBoughtItems} (
       ${MenuItenFields.name} $keyType,

       ${MenuItenFields.category} $descriptionType,
       ${MenuItenFields.instock} $value,
       ${MenuItenFields.quantity} $value,
       ${MenuItenFields.price} $value
    )

       ''');

      // await db.execute(
      //     '''DROP TABLE IF EXISTS  ${Keys.localBookmarkedArticlesTable}''');

      return true;
    } catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }

  Future<bool> insertToMenuDB(List<MenuIten> models) async {
    try {
      Database? db = await database;

      // bool table = await createMenuDB();

      models.map((model) async {
        List<Map> count = await db.query(Keys.userBoughtItems,
            where: "${MenuItenFields.name} = ?", whereArgs: [model.name]);
        int result;

        if (count.isEmpty) {
          result = await db.insert(Keys.userBoughtItems, model.toJson());

          return result > 0 ? true : false;
        } else {
          count.map((e) {
            model.quantity = e[MenuItenFields.quantity] + model.quantity;
          }).toList();
          result = await db.update(
            Keys.userBoughtItems,
            model.toJson(),
            where: '${MenuItenFields.name} = ?',
            whereArgs: [model.name],
          );
          return result > 0 ? true : false;
        }
      }).toList();

      return true;
    } catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }

  Future<List<MenuIten>> getAllMenuItem() async {
    try {
      Database? db = await database;

      final List<Map<String, dynamic>> menu = await db.query(
        Keys.userBoughtItems,
      );

      debugPrint(menu.toString());

      List<MenuIten> model = [];

      model = menu.map((e) => MenuIten.fromJson(e, 'Popular Items')).toList();

      model.sort(
        (a, b) => b.quantity!.compareTo((a.quantity as num)),
      );

      if (model.length > 3) {
        model = model.sublist(0, 3);
      }

      return model;
    } catch (e) {
      debugPrint(e.toString());
      throw false;
    }
  }

  // user_primary_detail_databse
}
