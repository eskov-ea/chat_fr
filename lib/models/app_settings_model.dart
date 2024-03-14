class AppSettings {
  final String? deviceId;
  final int? userId;
  final String? authToken;
  final String lastUpdate;
  final int dialogsLoaded;
  final int usersLoaded;
  final int profileLoaded;
  final int callsLoaded;
  final int firstInitialized;
  final String? sipContacts;

  AppSettings({
    required this.deviceId,
    required this.userId,
    required this.authToken,
    required this.lastUpdate,
    required this.dialogsLoaded,
    required this.usersLoaded,
    required this.profileLoaded,
    required this.callsLoaded,
    required this.firstInitialized,
    required this.sipContacts
  });

  static AppSettings fromJson(json) =>
    AppSettings(
      deviceId: json["device_id"],
      userId: json["user_id"],
      authToken: json["auth_token"],
      lastUpdate: json["last_update"],
      dialogsLoaded: json["dialogs_loaded"],
      usersLoaded: json["users_loaded"],
      profileLoaded: json["profile_loaded"],
      callsLoaded: json["calls_loaded"],
      firstInitialized: json["first_initialize"],
      sipContacts: json["sip_contacts"]
    );
}