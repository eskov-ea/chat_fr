import '../services/global.dart';

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
      date: getDate(json["date"]),
      fromCaller: json["sip_from"],
      toCaller: json["sip_to"],
      duration: json["duration"] ?? "00:00:00",
      callStatus: gerCallReason(json["reason"]),
      id: json["call_id"],
  );

  static CallModel fromJsonOnEndedCall(json) => CallModel(
    date: getDateFromUnix(json["calldate"] ?? json["date"]),
    fromCaller: json["src"] ?? json["sip_from"],
    toCaller: json["dst"] ?? json["sip_to"],
    duration: json["duration"] ?? "00:00:00",
    callStatus: json["disposition"] ?? json["reason"],
    id: json["uniqueid"] ?? json["call_id"]
  );

}

String gerCallReason(String reason) {
  return reason == "Decline" ? "NO ANSWER" : "ANSWERED";
}

String getDateFromUnix(json) {
  try {
    final seconds = int.parse(json);
    final date =  DateTime.fromMillisecondsSinceEpoch(seconds * 1000).subtract(getTZ());
    return date.toString();
  } catch (_) {
    final date = DateTime.parse(json).subtract(getTZ());
    return date.toString();
  }
}

String getDate(json) {
  final date = DateTime.parse(json);
  return date.toString();
}