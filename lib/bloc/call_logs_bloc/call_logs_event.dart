

import '../../models/call_model.dart';

abstract class CallLogsEvent{}

class LoadCallLogsEvent extends CallLogsEvent {
  final String passwd;

  LoadCallLogsEvent({
    required this.passwd
  });
}

class AddCallToLogEvent extends CallLogsEvent {
  final CallModel call;

  AddCallToLogEvent({
    required this.call
  });
}

class UpdateCallLogsEvent extends CallLogsEvent {
  final String passwd;

  UpdateCallLogsEvent({
    required this.passwd
  });
}

