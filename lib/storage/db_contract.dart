import 'dart:typed_data';

import 'package:chat/models/user_profile_model.dart';

import '../models/file_to_save_in_db.dart';

abstract class IDatabase{

  Future<void> addChat();
  Future<void> findChat();
  Future<void> findAllChats();
  Future<void> addFile({required DBSavingFile file});
  Future<void> addMessage();
  Future<void> updateMessage();
  Future<void> findMessages();
  Future<void> deleteChat();
  Future<void> saveProfile(UserProfileData profile);

}