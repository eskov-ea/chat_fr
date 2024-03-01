

final UserModel chatBot = UserModel(
    id: 5,
    firstname: "MCFEF Чат-бот",
    lastname: "",
    middlename: "",
    company: "Кашалот",
    position: "Виртуальный помощник",
    phone: "",
    dept: "",
    email: "",
    avatar: null,
    banned: 0,
    lastAccess: '',
    birthdate: ''
);

class UserModel {
  final int id;
  final String firstname;
  final String lastname;
  final String middlename;
  final String company;
  final String dept;
  final String position;
  final String phone;
  final String email;
  final String birthdate;
  final String? avatar;
  final int banned;
  final String? lastAccess;

  UserModel({
    required this.id,
    required this.firstname,
    required this.lastname,
    required this.middlename,
    required this.company,
    required this.position,
    required this.phone,
    required this.dept,
    required this.email,
    required this.birthdate,
    required this.avatar,
    required this.banned,
    required this.lastAccess,
  });

  static UserModel fromJsonAPI(json) {
    if (json['id'] == 5) {
      return chatBot;
    } else {
      return UserModel(
          id: json['id'],
          firstname: json['staff']['firstname'] ?? "",
          lastname: json['staff']['lastname'] ?? "",
          middlename: json['staff']['middlename'] ?? "",
          company: json['staff']['company'] ?? "",
          position: json['staff']['position'] ?? "",
          phone: json['staff']['phone'] ?? "",
          dept: json['staff']['dept'] ?? "",
          email: json['email'] ?? "",
          birthdate: json['staff']['birthdate'] ?? "",
          avatar: json['staff']['avatar'],
          banned: 0,
          lastAccess: json['last_access'] ?? ''
      );
    }
  }

  static UserModel fromJsonDB(json) {
    if (json['user_id'] == 5) {
      return chatBot;
    } else {
      return UserModel(
          id: json['user_id'],
          firstname: json['firstname'] ?? "",
          lastname: json['lastname'] ?? "",
          middlename: json['middlename'] ?? "",
          company: json['company'] ?? "",
          position: json['position'] ?? "",
          phone: json['phone'] ?? "",
          dept: json['dept'] ?? "",
          email: json['email'] ?? "",
          birthdate: json['birthdate'] ?? "",
          avatar: json['avatar'],
          banned: 0,
          lastAccess: json['last_access'] ?? ''
      );
    }
  }

  @override
  String toString() {
    return "Instance of UserContact: id: $id, name: $lastname $firstname";
  }
}