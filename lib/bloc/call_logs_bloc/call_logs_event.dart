

abstract class CallLogsEvent{}

class LoadCallLogsEvent extends CallLogsEvent {
  final String passwd;

  LoadCallLogsEvent({
    required this.passwd
  });
}