import 'dart:developer';
import 'dart:io';

import 'package:chat/models/dialog_model.dart';
import 'package:chat/services/database/db_provider.dart';
import 'package:chat/services/dialogs/dialogs_api_provider.dart';
import 'package:chat/services/dialogs/dialogs_repository.dart';
import 'package:chat/services/messages/messages_api_provider.dart';
import 'package:chat/services/users/users_api_provider.dart';
import 'package:chat/storage/data_storage.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

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
                      final res = await db.getDialogById(256);
                      print('256 dialogs::: ${res.length}');
                    },
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.45,
                      height: 70,
                      padding: EdgeInsets.all(5),
                      color: Colors.blueAccent.shade200,
                        child: Center(
                          child: Text('get 265 dialog',
                            style: TextStyle(color: Colors.white),
                          )
                        )
                    ),
                  ),
                  GestureDetector(
                    onTap: () async {
                      final db = DBProvider.db;
                      await db.initializeChatTypeValues();
                      final res = await db.readChatTypes();
                      print('chat types::: $res');
                    },
                    child: Container(
                        width: MediaQuery.of(context).size.width * 0.45,
                        height: 70,
                        padding: EdgeInsets.all(5),
                        color: Colors.redAccent.shade100,
                        child: Center(
                          child: Text('add chat types',
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
                      final res = await (await db.database).transaction((txn) async {
                        return await txn.rawDelete(
                          'DELETE FROM attachments WHERE chat_message_id = 7137; '
                        );
                      });
                      print('Delete file $res');
                    },
                    child: Container(
                        width: MediaQuery.of(context).size.width * 0.45,
                        height: 70,
                        padding: const EdgeInsets.all(5),
                        color: Colors.purple.shade200,
                        child: const Center(
                            child: Text('Delete file',
                              style: TextStyle(color: Colors.white),
                            )
                        )
                    ),
                  ),
                  GestureDetector(
                    onTap: () async {
                      final db = DBProvider.db;
                      final res = await db.getMessagesByDialog(349);
                      log('Messages for 349::  $res');
                    },
                    child: Container(
                        width: MediaQuery.of(context).size.width * 0.45,
                        height: 70,
                        padding: const EdgeInsets.all(5),
                        color: Colors.grey.shade500,
                        child: const Center(
                            child: Text('Read messages 349',
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
                      await db.getMessageInfo();
                      print('Chat types initialized::');
                    },
                    child: Container(
                        width: MediaQuery.of(context).size.width * 0.45,
                        height: 70,
                        padding: const EdgeInsets.all(5),
                        color: Colors.purple.shade200,
                        child: const Center(
                            child: Text('Get last message',
                              style: TextStyle(color: Colors.white),
                            )
                        )
                    ),
                  ),
                  GestureDetector(
                    onTap: () async {
                      // final Directory documentDirectory = await getApplicationDocumentsDirectory();
                      // final String dirPath = documentDirectory.path;
                      // final path = '/var/mobile/Containers/Data/Application/97129959-3781-4898-9545-CB6B46E55DDE/Documents/cache/images/image_picker_3B5A7186-D3B1-44AC-BE09-47546C92B456-76519-0000284372488131.jpg';
                      // File? file = File(path) ;
                      final db = await DBProvider.db.database;
                      return await db.transaction((txn) async {
                        List<Object> res = await txn.rawQuery(
                          'SELECT id FROM message WHERE chat_id = 265 AND created_at < datetime("now", "-1 day"); '
                        );
                        log('fileee::  ${res}');
                      });
                      // final res = await db.getMessageByLocalId('52d3d7b1-92df-5d22-bece-68ded52ab3d8');
                      // final res = await db.getMessageByLocalId(6986);
                    },
                    child: Container(
                        width: MediaQuery.of(context).size.width * 0.45,
                        height: 70,
                        padding: const EdgeInsets.all(5),
                        color: Colors.grey.shade500,
                        child: const Center(
                            child: Text('Check not sent m',
                              style: TextStyle(color: Colors.white),
                            )
                        )
                    ),
                  )
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
