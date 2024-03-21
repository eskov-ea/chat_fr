import 'package:chat/services/global.dart';


class CallModel {
  final String date;
  final String fromCaller;
  final String toCaller;
  final String duration;
  final int callStatus;
  final String id;
  final List? participants;
  final int? callState;


  CallModel({
    required this.date,
    required this.fromCaller,
    required this.toCaller,
    required this.duration,
    required this.callStatus,
    required this.participants,
    required this.callState,
    required this.id
  });

  static CallModel fromJson(json) => CallModel(
      date: getDate(json["date"]),
      fromCaller: json["sip_from"],
      toCaller: json["sip_to"],
      duration: json["duration"] ?? "00:00:00",
      callStatus: mapCallReasonToStatusCode(json["reason"]),
      callState: json['call_state'],
      participants: json["participants"],
      id: json["call_id"],
  );

  static CallModel fromJsonOnEndedCall(json) => CallModel(
    date: getDateFromUnix(json["calldate"] ?? json["date"]),
    fromCaller: json["src"] ?? json["sip_from"],
    toCaller: json["dst"] ?? json["sip_to"],
    duration: json["duration"] ?? "00:00:00",
    callStatus: json["disposition"] ?? json["reason"],
    callState: json['call_state'],
    participants: json["participants"],
    id: json["uniqueid"] ?? json["call_id"]
  );

  static CallModel fromJsonOnOutgoingCall(json) => CallModel(
    date: getDateFromUnix(json["calldate"] ?? json["date"]),
    fromCaller: json["src"] ?? json["sip_from"],
    toCaller: json["dst"] ?? json["sip_to"],
    duration: json["duration"] ?? "00:00:00",
    callStatus: json["disposition"] ?? json["reason"],
    callState: json['call_state'],
    participants: json["participants"],
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

String mapCallStateToStateName(int? state) {
  if (state == null) return "Released";
  switch(state) {
    case 0: return "Idle";
    case 1: return "IncomingReceived";
    case 2: return "PushIncomingReceived";
    case 3: return "OutgoingInit";
    case 4: return "OutgoingProgress";
    case 5: return "OutgoingRinging";
    case 6: return "OutgoingEarlyMedia";
    case 7: return "Connected";
    case 8: return "StreamsRunning";
    case 9: return "Pausing";
    case 10: return "Paused";
    case 11: return "Resuming";
    case 12: return "Referred";
    case 13: return "Error";
    case 14: return "End";
    case 15: return "PausedByRemote";
    case 16: return "UpdatedByRemote";
    case 17: return "IncomingEarlyMedia";
    case 18: return "Updating";
    case 19: return "Released";
    case 20: return "EarlyUpdatedByRemote";
    case 21: return "EarlyUpdating";
    default: return "Released";
  }
}


// 0 "Success" -> "ANSWERED"
// 1 "Aborted" -> "DECLINED"
// 2 "Missed" -> "NO ANSWER"
// 3 "Declined" -> "DECLINED"
// 4 "EarlyAborted" -> "NO ANSWER"
// 5 "AcceptedElsewhere" -> "ANSWERED"
// 6 "DeclinedElsewhere" -> "DECLINED"