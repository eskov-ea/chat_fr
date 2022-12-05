import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/contact_model.dart';

class UsersApi {
  static Future <List<UserContact>> getUsersLocally(BuildContext context) async {
    final assetBundle = DefaultAssetBundle.of(context);
    final data = await assetBundle.loadString("assets/mock_data/users.json");
    final body = json.decode(data);

    return body.map<UserContact>(UserContact.fromJson).toList();
  }
}