import 'package:chat/services/global.dart';


class CallModel {
  final String date;
  final String fromCaller;
  final String toCaller;
  final String duration;
  final int callStatus;
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
      callStatus: mapCallReasonToStatusCode(json["reason"]),
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
  String toString() {
    return "Instance of CallModel: $date, from: $fromCaller to $toCaller, status: $callStatus";
  }

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

String getCallReason(String reason) {
  // Ok, Decline, Request Timeout, Busy here, Ringing
  return reason == "Ok" ? "ANSWERED" : "NO ANSWER";
}

String getDateFromUnix(json) {
  try {
    final seconds = int.parse(json);
    final date =  DateTime.fromMillisecondsSinceEpoch(seconds * 1000).toUtc();
    return date.toString();
  } catch (_) {
    final date = DateTime.parse(json).toUtc();
    return date.toString();
  }
}

String getDate(json) {
  final date = DateTime.parse(json);
  return date.toUtc().toString();
}

int mapCallReasonToStatusCode(String name) {
  print('call name:  $name');
  switch(name) {
    case "Ok": return 0;
    case "Decline": return 3;
    case "Request Timeout": return 1;
    case "Busy here": return 1;
    case "Ringing": return 1;
    default: return 1;
  }
}


// 0 "Success" -> "ANSWERED"
// 1 "Aborted" -> "DECLINED"
// 2 "Missed" -> "NO ANSWER"
// 3 "Declined" -> "DECLINED"
// 4 "EarlyAborted" -> "NO ANSWER"
// 5 "AcceptedElsewhere" -> "ANSWERED"
// 6 "DeclinedElsewhere" -> "DECLINED"