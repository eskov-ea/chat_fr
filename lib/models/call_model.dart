class Call {
  final String state;
  final String username;

  Call({
    required this.state,
    required this.username,
  });

  static Call fromJson(json) => Call(
    state: json["state"],
    username: json["username"],
  );

}