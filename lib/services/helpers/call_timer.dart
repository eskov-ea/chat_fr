import 'dart:async';

class CallTimer {
  static CallTimer? instance;
  int seconds = 0;
  int minutes = 0;
  int hours = 0;
  StreamController<String>? _streamController;
  Timer? _timer;
  bool isRunning = false;
  String lastValue = "00:00:00";

  static CallTimer getInstance() {
    if (instance == null) {
      instance = CallTimer();
      instance!.init();
      return instance!;
    } else {
      return instance!;
    }
  }

  void start() {
    print("TIMER START");
    if (_streamController == null) init();
    if (!isRunning) {
      _startTimer();
      isRunning = true;
    }
  }

  void init() {
    print("TIMER INIT");
    _streamController = StreamController.broadcast();
  }

  void stop() {
    print("Stop the timer");
    _timer?.cancel();
    isRunning = false;
    seconds = 0;
    minutes = 0;
    hours = 0;
    lastValue = "00:00:00";
  }

  void dispose() async {
    await _streamController?.close();
    _streamController = null;
  }

  Stream<String> stream() {
    print("TIMER STREAM");
    // if (_streamController == null) start();
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
      print("timer  -->  $digitHours:$digitMinutes:$digitSeconds");
      _streamController!.sink.add("$digitHours:$digitMinutes:$digitSeconds");
      lastValue = "$digitHours:$digitMinutes:$digitSeconds";
    });
  }



}