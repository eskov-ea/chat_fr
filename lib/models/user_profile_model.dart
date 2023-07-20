import 'package:chat/models/dialog_model.dart';
import 'package:equatable/equatable.dart';

class UserProfileData extends Equatable{

  final int id;
  final String firstname;
  final String lastname;
  final String middlename;
  final String company;
  final String dept;
  final String position;
  final String phone;
  final String email;
  final String? avatar;
  final UserProfileAsteriskSettings? userProfileSettings;
  final AppSettings? appSettings;
  final ChatSettings? chatSettings;

  const UserProfileData({
    required this.id,
    required this.firstname,
    required this.lastname,
    required this.middlename,
    required this.company,
    required this.position,
    required this.phone,
    required this.dept,
    required this.avatar,
    required this.email,
    required this.userProfileSettings,
    required this.appSettings,
    required this.chatSettings
  });

  static UserProfileData fromJson(json) => UserProfileData(
          id: json['user']['id'],
          firstname: json['user']['staff']['firstname'],
          lastname: json['user']['staff']['lastname'],
          middlename: json['user']['staff']['middlename'] ?? "",
          company: json['user']['staff']['company'] ?? "",
          position: json['user']['staff']['position'] ?? "",
          phone: json['user']['staff']['phone'] ?? "",
          dept: json['user']['staff']['dept'] ?? "",
          email: json['user']['email'] ?? "",
          avatar: json['user']['staff']["avatar"],
          userProfileSettings: UserProfileAsteriskSettings.fromJson(json['settings']),
          appSettings: AppSettings.fromJson(json['settings']),
          chatSettings: ChatSettings.fromJson(json['settings'])
      );


  Map<String, dynamic> toMap() => {
    "id": id,
    "firstname": firstname,
    "lastname": lastname,
    "middlename": middlename,
    "company": company,
    "position": position,
    "phone": phone,
    "avatar": avatar,
    "dept": dept,
    "email": email
  };

  @override
  List<Object?> get props => [id, firstname, lastname, middlename, company, position, phone, dept, email, avatar, appSettings, userProfileSettings];

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

  const UserProfileAsteriskSettings({
    required this.userDomain,
    required this.asteriskPort,
    required this.stunHost,
    required this.stunPort,
    required this.asteriskUserLogin,
    required this.asteriskUserPassword,
    required this.sipPrefix,
    required this.asteriskHost
  });

  static UserProfileAsteriskSettings? fromJson(json) {
    return json == null
        ? null
        : UserProfileAsteriskSettings(
          userDomain: json["asterisk"]["asterisk_domain"],
          asteriskPort: json["asterisk"]["asterisk_port"],
          stunHost: json["asterisk"]["stun_host"],
          stunPort: json["asterisk"]["stun_port"],
          asteriskUserLogin: json["asterisk"]["asterisk_user_login"].toString(),
          asteriskUserPassword: json["asterisk"]["asterisk_user_password"],
          sipPrefix: json["asterisk"]["asterisk_prefix"],
          asteriskHost: json["asterisk"]["asterisk_host"]
        );
  }


  @override
  List<Object?> get props => [asteriskHost, asteriskPort, stunHost, stunPort];

}
class AppSettings extends Equatable{
  final String? version;
  final String downloadUrlAndroid;

  const AppSettings({
    required this.version,
    required this.downloadUrlAndroid
  });

  static AppSettings? fromJson(json) {
    return json == null
        ? null
        : AppSettings(
          version: json['app']["version"],
          downloadUrlAndroid: json['app']["download_url_android"]
        );
  }

  @override
  List<Object?> get props => [version, downloadUrlAndroid];

}
class ChatSettings extends Equatable{
  final List<DialogData> autoJoinChats;

  const ChatSettings({
    required this.autoJoinChats
  });

  static ChatSettings? fromJson(json) {
    return json == null
        ? null
        : ChatSettings(
          autoJoinChats: json['chat']["autojoin"]
              .map<DialogData>((dialog) => DialogData.fromJson(dialog))
              .toList()
        );
  }

  @override
  List<Object?> get props => [autoJoinChats];

}