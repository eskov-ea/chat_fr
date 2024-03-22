import 'package:chat/models/user_model.dart';
import 'package:chat/models/dialog_model.dart';
import 'package:equatable/equatable.dart';

class UserProfileData extends Equatable{

  final UserModel user;
  final UserProfileAsteriskSettings sipSettings;
  final VersionSettings appSettings;
  final ChatSettings? chatSettings;

  const UserProfileData({
    required this.user,
    required this.sipSettings,
    required this.appSettings,
    required this.chatSettings
  });

  static UserProfileData fromJson(json) => UserProfileData(
          user: UserModel.fromJsonAPI(json['user']),
          sipSettings: UserProfileAsteriskSettings.fromJson(json['settings']),
          appSettings: VersionSettings.fromJson(json['settings']),
          chatSettings: ChatSettings.fromJson(json['settings'])
  );

  static UserProfileData fromJsonDB(json) => UserProfileData(
          user: UserModel.fromJsonDB(json),
          sipSettings: UserProfileAsteriskSettings.fromJsonDB(json),
          appSettings: VersionSettings.fromJsonDB(json),
          chatSettings: ChatSettings.fromJsonDB(json)
  );

  @override
  List<Object?> get props => [];

  @override
  String toString() => "'Instance of UserProfileData' sipSettings: $sipSettings\r\n"
  "autoLoin chats: ${chatSettings?.autoJoinChats}";

}

class UserProfileAsteriskSettings extends Equatable{
  final String userDomain;
  final String asteriskPort;
  final String stunHost;
  final String stunPort;
  final String asteriskUserLogin;
  final String? asteriskUserPassword;
  final String? sipPrefix;
  final String asteriskHost;
  final String asteriskCert;

  const UserProfileAsteriskSettings({
    required this.userDomain,
    required this.asteriskPort,
    required this.stunHost,
    required this.stunPort,
    required this.asteriskUserLogin,
    required this.asteriskUserPassword,
    required this.sipPrefix,
    required this.asteriskHost,
    required this.asteriskCert
  });

  static UserProfileAsteriskSettings fromJson(json) {
    return UserProfileAsteriskSettings(
          userDomain: json["asterisk"]["asterisk_domain"],
          asteriskPort: json["asterisk"]["asterisk_port"],
          stunHost: json["asterisk"]["stun_host"],
          stunPort: json["asterisk"]["stun_port"],
          asteriskUserLogin: json["asterisk"]["asterisk_user_login"].toString(),
          asteriskUserPassword: json["asterisk"]["asterisk_user_password"],
          sipPrefix: json["asterisk"]["asterisk_prefix"],
          asteriskHost: json["asterisk"]["asterisk_host"],
          asteriskCert: json["asterisk"]["asterisk_cert"]
        );
  }

  static UserProfileAsteriskSettings fromJsonDB(json) {
    return UserProfileAsteriskSettings(
          userDomain: json["user_domain"],
          asteriskPort: json["sip_port"],
          stunHost: json["stun_host"],
          stunPort: json["stun_port"],
          asteriskUserLogin: json["sip_user_login"],
          asteriskUserPassword: json["sip_user_password"],
          sipPrefix: json["sip_prefix"],
          asteriskHost: json["sip_host"],
          asteriskCert: json["sip_cert"]
        );
  }


  @override
  List<Object?> get props => [asteriskHost, asteriskPort, stunHost, stunPort];

}
class VersionSettings extends Equatable{
  final String? versionIos;
  final String? versionAndroid;
  final String downloadUrlAndroid;
  final String downloadUrlIos;

  const VersionSettings({
    required this.versionIos,
    required this.versionAndroid,
    required this.downloadUrlIos,
    required this.downloadUrlAndroid
  });

  static VersionSettings fromJson(json) {
    return VersionSettings(
          versionAndroid: json['app']["version_android"],
          versionIos: json['app']["version_ios"],
          downloadUrlAndroid: json['app']["download_url_android"],
          downloadUrlIos: json['app']["download_url_ios"]
        );
  }

  static VersionSettings fromJsonDB(json) {
    return VersionSettings(
          versionAndroid: json['version_android'],
          versionIos: json['version_ios'],
          downloadUrlAndroid: json['android_download_link'],
          downloadUrlIos: json['ios_download_link']
        );
  }

  @override
  List<Object?> get props => [downloadUrlIos, versionAndroid];

}
class ChatSettings extends Equatable{
  final List<int> autoJoinChats;

  const ChatSettings({
    required this.autoJoinChats
  });

  static ChatSettings? fromJson(json) {
    return json == null
        ? null
        : ChatSettings(
          autoJoinChats: json['chat']["autojoin"]
              .map<int?>((dialog) => DialogData.fromJson(dialog)?.dialogId)
              .whereType<int>()
              .toList()
        );
  }

  static ChatSettings? fromJsonDB(json) {
    if (json == null) return null;
    final array = json['autojoin_chats'].split(',');
    final List<int> dialogsIds = array.map((e) => int.tryParse(e))
        .whereType<int>()
        .toList();
    print('_autoJoinChats  ${dialogsIds}');
    return ChatSettings(
      autoJoinChats: dialogsIds
    );

  }

  @override
  List<Object?> get props => [autoJoinChats];

}