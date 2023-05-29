class CallModel {
  final String date;
  final String fromCaller;
  final String toCaller;
  final String duration;
  final String callStatus;
  final String id;


  CallModel({
    required this.date,
    required this.fromCaller,
    required this.toCaller,
    required this.duration,
    required this.callStatus,
    required this.id
  });

  static CallModel fromJson(json) => CallModel(
      date: getDateFromUnix(json["date"]),
      fromCaller: json["sip_from"],
      toCaller: json["sip_to"],
      duration: json["duration"] ?? "00:00:00",
      callStatus: json["reason"],
      id: json["call_id"],
  );

}

String getDateFromUnix(json) {
  print("getDateFromUnix   $json");
  try {
    final seconds = int.parse(json);
    final date =  DateTime.fromMillisecondsSinceEpoch(seconds * 1000).toString();
    return date;
  } catch (_) {
    return json;
  }
}