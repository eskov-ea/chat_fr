import 'dart:io';
import 'dart:typed_data';

import 'package:chat/models/file_to_save_in_db.dart';
import 'package:chat/models/user_profile_model.dart';
import 'package:chat/storage/db_contract.dart';
import 'package:sqflite/sqflite.dart';

class SqfliteDatabase implements IDatabase{

  late final Database _db;
  final String filesTable = "files";

  Future<Database> initDb() async {
    final databasesPath = await getDatabasesPath();
    String path = "$databasesPath/database.db";
    print(path);
    Database database = await openDatabase(path, version: 1,
        onCreate: (Database db, int version) async {
          await db.execute(
              'CREATE TABLE $filesTable (id INTEGER PRIMARY KEY, fileName TEXT, fileData BLOB, attachmentId INTEGER)');
        });
    _db = database;
    return _db;
  }

  Future closeDb() async {
    await _db.close();
  }

  @override
  Future<void> addChat() {
    // TODO: implement addChat
    throw UnimplementedError();
  }

  @override
  Future<void> addFile({required DBSavingFile file}) async {

    // await _db.insert(filesTable, file.toMap());
    // print(_db);
    // _db.insert(filesTable, fileName, file, attachmentId);
    _db.transaction((txn) async {
      await txn.insert(filesTable, {"fileName": file.fileName, "fileData": file.file, "attachmentId": file.attachmentId}, conflictAlgorithm: ConflictAlgorithm.rollback);
    });
    print("Adding file ${file.toMap()}");
    // throw UnimplementedError();
  }

  @override
  Future<void> addMessage() {
    // TODO: implement addMessage
    throw UnimplementedError();
  }

  @override
  Future<void> deleteChat() {
    // TODO: implement deleteChat
    throw UnimplementedError();
  }

  @override
  Future<void> findAllChats() {
    // TODO: implement findAllChats
    throw UnimplementedError();
  }

  @override
  Future<void> findChat() {
    // TODO: implement findChat
    throw UnimplementedError();
  }

  @override
  Future<void> findMessages() {
    // TODO: implement findMessages
    throw UnimplementedError();
  }

  @override
  Future<void> saveProfile(UserProfileData profile) async {
    await _db.transaction((txn) async {
      await txn.insert('profile', profile.toMap(),
          conflictAlgorithm: ConflictAlgorithm.rollback);
    });
  }

  @override
  Future<void> updateMessage() {
    // TODO: implement updateMessage
    throw UnimplementedError();
  }


  Future<List<Map>> getFiles(attachmentId) async {
    print('files');
    final files = await _db.query(filesTable,
      columns: ['attachmentId', 'fileName', 'fileData'], where: 'attachmentId=$attachmentId'
    );
    return files;
  }

  Future getAll() async {
    print('db path ${_db.path}');
    // final files = await _db.delete(filesTable);filesTable
    File file = File(_db.path);
    file.delete();
    // print(files);
  }

}