
final UserContact chatBot = UserContact(
    id: 5,
    firstname: "MCFEF Чат-бот",
    lastname: "",
    middlename: "",
    company: "Кашалот",
    position: "Виртуальный помощник",
    phone: "",
    dept: "",
    email: "",
    avatar: null
);

class UserContact {
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

  UserContact({
    required this.id,
    required this.firstname,
    required this.lastname,
    required this.middlename,
    required this.company,
    required this.position,
    required this.phone,
    required this.dept,
    required this.email,
    required this.avatar
  });

  static UserContact fromJson(json) {
    if (json['id'] == 5) {
      return chatBot;
    } else {
      return UserContact(
          id: json['id'],
          firstname: json['staff']['firstname'] ?? "",
          lastname: json['staff']['lastname'] ?? "",
          middlename: json['staff']['middlename'] ?? "",
          company: json['staff']['company'] ?? "",
          position: json['staff']['position'] ?? "",
          phone: json['staff']['phone'] ?? "",
          dept: json['staff']['dept'] ?? "",
          email: json['email'] ?? "",
          avatar: json['staff']['avatar']
      );
    }
  }
}