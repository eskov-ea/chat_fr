import 'package:chat/models/user_model.dart';
import 'package:chat/models/user_profile_model.dart';

final userProfileMock = UserProfileData(
    user: UserModel(
      id: 40,
      firstname: 'Евгений',
      lastname: 'Еськов',
      middlename: 'Александрович',
      company: 'ООО \"Кашалот\"',
      position: 'Программист',
      phone: '79140774664',
      dept: 'Отдел разработки ПО',
      email: 'eskov@cashalot.co',
      birthdate: '1992-03-18',
      avatar: null,
      banned: 0,
      lastAccess: null
    ),
    sipSettings: UserProfileAsteriskSettings(
      userDomain: 'aster.mcfef.com',
      asteriskPort: '5060',
      stunHost: 'aster.mcfef.com',
      stunPort: '7078',
      asteriskUserLogin: '40',
      asteriskUserPassword: 'cf087dd812961ea6fc05',
      sipPrefix: '7',
      asteriskHost: 'aster.mcfef.com',
      asteriskCert: 'secret'
    ),
    appSettings: VersionSettings(
        versionIos: '1.1.3',
        versionAndroid: '1.1.3',
        downloadUrlIos: 'https://chat.mcfef.com/ios/mcfef.ipa',
        downloadUrlAndroid: 'https://chat.mcfef.com/apk/app-release.apk'
    ),
    chatSettings: ChatSettings(
        autoJoinChats: [207, 208]
    )
);