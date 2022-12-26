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
      date: json["calldate"],
      fromCaller: json["src"],
      toCaller: json["dst"],
      duration: json["duration"],
      callStatus: json["disposition"],
      id: json["uniqueid"],
  );

}