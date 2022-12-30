

abstract class CallLogsEvent{}

class LoadCallLogsEvent extends CallLogsEvent {
  final String passwd;

  LoadCallLogsEvent({
    required this.passwd
  });
}

class UpdateCallLogsEvent extends CallLogsEvent {
  // final String passwd;

  // UpdateCallLogsEvent({
  //   required this.passwd
  // });
}

