import 'dart:developer';

import 'package:chat/models/dialog_model.dart';
import 'package:chat/services/database/db_provider.dart';
import 'package:chat/services/dialogs/dialogs_api_provider.dart';
import 'package:chat/services/messages/messages_api_provider.dart';
import 'package:chat/services/users/users_api_provider.dart';
import 'package:chat/storage/data_storage.dart';
import 'package:flutter/material.dart';

class DBScreen extends StatefulWidget {
  const DBScreen({Key? key}) : super(key: key);

  @override
  State<DBScreen> createState() => _DBScreenState();
}

class _DBScreenState extends State<DBScreen> {


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 100),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  GestureDetector(
                    onTap: () async {
                      final db = DBProvider.db;
                      await db.initDB();
                    },
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.45,
                      height: 70,
                      padding: EdgeInsets.all(5),
                      color: Colors.blueAccent.shade200,
                        child: Center(
                          child: Text('Initialize DB',
                            style: TextStyle(color: Colors.white),
                          )
                        )
                    ),
                  ),
                  GestureDetector(
                    onTap: () async {
                      final db = DBProvider.db;
                      final result = await db.checkExistingTables();
                      log('DB result:: $result');
                    },
                    child: Container(
                        width: MediaQuery.of(context).size.width * 0.45,
                        height: 70,
                        padding: EdgeInsets.all(5),
                        color: Colors.redAccent.shade100,
                        child: Center(
                          child: Text('Check tables',
                            style: TextStyle(color: Colors.white),
                          )
                        )
                    ),
                  )
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  GestureDetector(
                    onTap: () async {
                      final db = DBProvider.db;
                      await db.initializeChatTypeValues();
                      print('Chat types initialized::');
                    },
                    child: Container(
                        width: MediaQuery.of(context).size.width * 0.45,
                        height: 70,
                        padding: const EdgeInsets.all(5),
                        color: Colors.purple.shade200,
                        child: const Center(
                            child: Text('Init chat types',
                              style: TextStyle(color: Colors.white),
                            )
                        )
                    ),
                  ),
                  GestureDetector(
                    onTap: () async {
                      final db = DBProvider.db;
                      final res = await db.readChatTypes();
                      print('Chat types::  $res');
                    },
                    child: Container(
                        width: MediaQuery.of(context).size.width * 0.45,
                        height: 70,
                        padding: const EdgeInsets.all(5),
                        color: Colors.grey.shade500,
                        child: const Center(
                            child: Text('Read chat types',
                              style: TextStyle(color: Colors.white),
                            )
                        )
                    ),
                  )
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  GestureDetector(
                    onTap: () async {
                      // final db = DBProvider.db;
                      // final dialogs = await DialogsProvider().getDialogs();
                      // List<DialogData> fiveDialogs = [];
                      // for (var i=0; i<5; ++i) {
                      //   for (var chatUser in dialogs[i].chatUsers) {
                      //     await db.saveChatUsers(chatUserDB);
                      //   }
                      //   fiveDialogs.add(dialogs[i]);
                      // }
                      // await db.saveDialogs(fiveDialogs);
                      // print('Dialogs saved to db::');
                    },
                    child: Container(
                        width: MediaQuery.of(context).size.width * 0.45,
                        height: 70,
                        padding: const EdgeInsets.all(5),
                        color: Colors.green.shade200,
                        child: const Center(
                            child: Text('Save dialogs',
                              style: TextStyle(color: Colors.white),
                            )
                        )
                    ),
                  ),
                  GestureDetector(
                    onTap: () async {
                      final db = DBProvider.db;
                      final result = await db.getDialogs();
                      print('DB result:: $result');
                    },
                    child: Container(
                        width: MediaQuery.of(context).size.width * 0.45,
                        height: 70,
                        padding: const EdgeInsets.all(5),
                        color: Colors.orange.shade200,
                        child: const Center(
                            child: Text('Read dialogs',
                              style: TextStyle(color: Colors.white),
                            )
                        )
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  GestureDetector(
                    onTap: () async {
                      final db = DBProvider.db;
                      final token = await DataProvider.storage.getToken();
                      final users = await UsersProvider().getUsers(token);
                      await db.saveUsers(users);
                      print('Users saved');
                    },
                    child: Container(
                        width: MediaQuery.of(context).size.width * 0.45,
                        height: 70,
                        padding: const EdgeInsets.all(5),
                        color: Colors.redAccent.shade200,
                        child: const Center(
                            child: Text('Save users',
                              style: TextStyle(color: Colors.white),
                            )
                        )
                    ),
                  ),
                  GestureDetector(
                    onTap: () async {
                      final db = DBProvider.db;
                      final res = await db.getUsers();
                      print('DB result:: $res');
                    },
                    child: Container(
                        width: MediaQuery.of(context).size.width * 0.45,
                        height: 70,
                        padding: const EdgeInsets.all(5),
                        color: Colors.blueAccent.shade200,
                        child: const Center(
                            child: Text('Read users',
                              style: TextStyle(color: Colors.white),
                            )
                        )
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  GestureDetector(
                    onTap: () async {
                      final db = await DBProvider.db.database;
                      return db.transaction((txn) async {
                      await txn.rawUpdate(
                      'DROP TABLE IF EXISTS app_settings;'
                      );
                      print('table dropped');
                      });
                    },
                    child: Container(
                        width: MediaQuery.of(context).size.width * 0.45,
                        height: 70,
                        padding: const EdgeInsets.all(5),
                        color: Colors.grey.shade500,
                        child: const Center(
                            child: Text('Drop app settings',
                              style: TextStyle(color: Colors.white),
                            )
                        )
                    ),
                  ),
                  GestureDetector(
                    onTap: () async {
                      final db = DBProvider.db;
                      final res = await db.getChatUsers();
                      log('DB result:: $res\r\n\r\n');
                    },
                    child: Container(
                        width: MediaQuery.of(context).size.width * 0.45,
                        height: 70,
                        padding: const EdgeInsets.all(5),
                        color: Colors.purple.shade400,
                        child: const Center(
                            child: Text('Read chat users',
                              style: TextStyle(color: Colors.white),
                            )
                        )
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  GestureDetector(
                    onTap: () async {

                    },
                    child: Container(
                        width: MediaQuery.of(context).size.width * 0.45,
                        height: 70,
                        padding: const EdgeInsets.all(5),
                        color: Colors.orange.shade500,
                        child: const Center(
                            child: Text('Drop app settings',
                              style: TextStyle(color: Colors.white),
                            )
                        )
                    ),
                  ),
                  GestureDetector(
                    onTap: () async {
                      final db = DBProvider.db;
                      final res = await db.getMessageStatusesByMessageId(6551);
                      print('::::::::::::::::::   $res');
                    },
                    child: Container(
                        width: MediaQuery.of(context).size.width * 0.45,
                        height: 70,
                        padding: const EdgeInsets.all(5),
                        color: Colors.green.shade400,
                        child: const Center(
                            child: Text('Message w file',
                              style: TextStyle(color: Colors.white),
                            )
                        )
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  GestureDetector(
                    onTap: () async {
                      final db = DBProvider.db;
                      final res = await db.getAttachmentById(415);
                      print('jkhjk:::::  $res');
                    },
                    child: Container(
                        width: MediaQuery.of(context).size.width * 0.45,
                        height: 70,
                        padding: const EdgeInsets.all(5),
                        color: Colors.blueAccent.shade200,
                        child: const Center(
                            child: Text('Message file',
                              style: TextStyle(color: Colors.white),
                            )
                        )
                    ),
                  ),
                  GestureDetector(
                    onTap: () async {
                      final db = DBProvider.db;
                      final res = await db.getLastUpdateTime();
                      final now = DateTime.now();
                      final tRawDifference = (now.millisecondsSinceEpoch - DateTime.parse(res).millisecondsSinceEpoch) / 1000;

                      final Map<String, dynamic>? newUpdates =
                      await MessagesProvider().getNewUpdatesOnResume(tRawDifference.ceil() + 250000);

                      print('jkhjk:::::  ${newUpdates}');
                    },
                    child: Container(
                        width: MediaQuery.of(context).size.width * 0.45,
                        height: 70,
                        padding: const EdgeInsets.all(5),
                        color: Colors.redAccent.shade100,
                        child: const Center(
                            child: Text('last update',
                              style: TextStyle(color: Colors.white),
                            )
                        )
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              GestureDetector(
                onTap: () async {
                  final db = DBProvider.db;
                  await db.DeveloperModeClearPersonTable();
                },
                child: Container(
                    width: MediaQuery.of(context).size.width,
                    margin: EdgeInsets.symmetric(horizontal: 10),
                    height: 70,
                    padding: const EdgeInsets.all(5),
                    color: Colors.red.shade400,
                    child: const Center(
                        child: Text('Delete database',
                          style: TextStyle(color: Colors.white),
                        )
                    )
                ),
              ),
            ],
          ),
        ),
      )
    );
  }
}
