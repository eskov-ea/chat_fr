import '../services/global.dart';


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

  static CallModel fromJsonOnOutgoingCall(json) => CallModel(
      date: getDateFromUnix(json["calldate"] ?? json["date"]),
      fromCaller: json["src"] ?? json["sip_from"],
      toCaller: json["dst"] ?? json["sip_to"],
      duration: json["duration"] ?? "00:00:00",
      callStatus: json["disposition"] ?? json["reason"],
      id: "unspecified"
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
        other is CallModel &&
        runtimeType == other.runtimeType &&
        date == other.date &&
        fromCaller == other.fromCaller &&
        toCaller == other.toCaller &&
        duration == other.duration &&
        callStatus == other.callStatus &&
        id == other.id;

  @override
  int get hashCode => date.hashCode ^ fromCaller.hashCode ^
    toCaller.hashCode ^ duration.hashCode ^ callStatus.hashCode ^ id.hashCode;




}

String gerCallReason(String reason) {
  // Ok, Decline, Request Timeout, Busy here, Ringing
  return reason == "Ok" ? "ANSWERED" : "NO ANSWER";
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