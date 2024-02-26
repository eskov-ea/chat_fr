import 'package:chat/services/database/db_provider.dart';
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
        child: ElevatedButton(
          onPressed: () async {
            final db = DBProvider.db;
            final dbs = await db.database;
            await db.createTables(dbs);
          },
          child: Text('Initialize'),
        ),
      )
    );
  }
}
