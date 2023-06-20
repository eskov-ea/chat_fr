const time_zone = 10;

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
      callStatus: gerCallReason(json["reason"]),
      id: json["call_id"],
  );

  static CallModel fromJsonOnEndedCall(json) => CallModel(
    date: getDateFromUnix(json["calldate"]),
    fromCaller: json["src"],
    toCaller: json["dst"],
    duration: json["duration"] ?? "00:00:00",
    callStatus: json["disposition"],
    id: json["uniqueid"],
  );

}

String gerCallReason(String reason) {
  return reason == "Decline" ? "NO ANSWER" : "ANSWERED";
}

String getDateFromUnix(json) {
  try {
    final seconds = int.parse(json);
    final date =  DateTime.fromMillisecondsSinceEpoch(seconds * 1000).add(Duration(hours: time_zone)).toString();
    return date;
  } catch (_) {
    print("getDateFromUnix   $json");
    final dateP = DateTime.parse(json);
    final date =  dateP.add(Duration(hours: time_zone));
    return date.toString();
  }
}