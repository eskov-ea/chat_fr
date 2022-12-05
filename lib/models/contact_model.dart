
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
  final String? image = null;

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
  });

  static UserContact fromJson(json) => UserContact(
    id: json['id'],
    firstname: json['staff']['firstname'],
    lastname: json['staff']['lastname'],
    middlename: json['staff']['middlename'] ?? "",
    company: json['staff']['company'] ?? "",
    position: json['staff']['position'] ?? "",
    phone: json['staff']['phone'] ?? "",
    dept: json['staff']['dept'] ?? "",
    email: json['email'] ?? "",
  );

}