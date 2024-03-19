import 'dart:developer';
import 'package:chat/models/user_profile_model.dart';
import 'package:chat/services/database/db_provider.dart';

class UserProfileDBLayer {


  Future<bool> saveUserProfile(UserProfileData profile) async {
    try {
      final db = await DBProvider.db.database;
      final appSettingsSql =
          'UPDATE app_settings SET '
          'autojoin_chats = "${profile.chatSettings?.autoJoinChats.toString().replaceAll('[', '').replaceAll(']', '').replaceAll(' ', '')}", '
          // 'version_android = "${profile.appSettings.versionAndroid}", '
          // 'version_ios = "${profile.appSettings.versionIos}", '
          // 'android_download_link = "${profile.appSettings.downloadUrlAndroid}", '
          // 'ios_download_link = "${profile.appSettings.downloadUrlIos}"'
          'WHERE id = 1 ';
      final sipSettingsSql =
          'INSERT INTO sip_settings(id, user_domain, sip_port, stun_host, stun_port, '
          'sip_user_login, sip_user_password, sip_prefix, sip_host, sip_cert) '
          'VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?) '
          'ON CONFLICT(id) DO UPDATE SET '
          'user_domain = "${profile.sipSettings.userDomain}", '
          'sip_port = "${profile.sipSettings.asteriskPort}", '
          'stun_host = "${profile.sipSettings.stunHost}", '
          'stun_port = "${profile.sipSettings.stunPort}", '
          'sip_user_login = "${profile.sipSettings.asteriskUserLogin}", '
          'sip_user_password = "${profile.sipSettings.asteriskUserPassword}", '
          'sip_prefix = "${profile.sipSettings.sipPrefix}", '
          'sip_host = "${profile.sipSettings.asteriskHost}", '
          'sip_cert = "${profile.sipSettings.asteriskCert}"';
      return await db.transaction((txn) async {
        await txn.rawUpdate(appSettingsSql);
        await txn.rawInsert(
            sipSettingsSql,
            [1, profile.sipSettings.userDomain, profile.sipSettings.asteriskPort, profile.sipSettings.stunHost,
            profile.sipSettings.stunPort, profile.sipSettings.asteriskUserLogin,
            profile.sipSettings.asteriskUserPassword, profile.sipSettings.sipPrefix,
            profile.sipSettings.asteriskHost, profile.sipSettings.asteriskCert]
        );
        return true;
      });
    } catch (err, stackTrace) {
      log('DB operation error:  $err \r\n  $stackTrace');
      rethrow;
    }
  }

  Future<UserProfileData> getProfile() async {
    try {
      final db = await DBProvider.db.database;
      return await db.transaction((txn) async {
        final res = await txn.rawQuery(
          'SELECT autojoin_chats, version_android, version_ios, android_download_link, ios_download_link, '
          'user_id, firstname, lastname, middlename, company, dept, position, phone, email, birthdate, avatar, banned, last_access, '
          'user_domain, sip_port, stun_host, stun_port, sip_user_login, sip_user_password, sip_prefix, sip_host, sip_cert '
          'FROM app_settings '
          'LEFT JOIN user ON (user.id = app_settings.user_id)'
          'LEFT JOIN sip_settings ON (sip_settings.id = 1); '
        );
        return UserProfileData.fromJsonDB(res.first);
      });
    } catch (err, stackTrace) {
      log('DB operation error:  $err \r\n  $stackTrace');
      rethrow;
    }

  }


}