import 'dart:async';

class CallTimer {
  static CallTimer? instance;
  int seconds = 0;
  int minutes = 0;
  int hours = 0;
  StreamController<String>? _streamController;
  Timer? _timer;

  static CallTimer getInstance() {
    if (instance == null) {
      instance = CallTimer();
      return instance!;
    } else {
      return instance!;
    }
  }

  void start() {
    if (_streamController == null) {
      _streamController = StreamController.broadcast();
    }
    _startTimer();

  }

  void stop() async {
    print("Stop the timer");
    _timer?.cancel();
    await _streamController?.close();
    _streamController = null;
    seconds = 0;
    minutes = 0;
    hours = 0;
  }

  Stream<String> stream() {
    return _streamController!.stream;
  }

  _startTimer() {
    _streamController!.sink.add("00:00:00");
    _timer = Timer.periodic(const Duration(seconds: 1), (_timer) {
      if(seconds == 59) {
        if (minutes == 59) {
          ++hours;
          minutes = 0;
          seconds = 0;
        } else {
          ++minutes;
          seconds = 0;
        }
      } else {
        ++seconds;
      }
      final  digitSeconds = (seconds >= 10) ? "$seconds" : "0$seconds";
      final  digitMinutes = (minutes >= 10) ? "$minutes" : "0$minutes";
      final  digitHours = (hours >= 10) ? "$hours" : "0$hours";
      _streamController!.sink.add("$digitHours:$digitMinutes:$digitSeconds");
    });
  }



}