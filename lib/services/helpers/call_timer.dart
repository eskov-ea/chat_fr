import 'dart:async';

class CallTimer {
  final String callId;
  int seconds = 0;
  int minutes = 0;
  int hours = 0;
  Timer? _timer;
  bool isRunning = false;
  bool isPaused = false;
  String lastValue = "00:00:00";
  Stream<String> get stream => _streamController.stream;
  late final StreamController<String> _streamController;

  CallTimer(this.callId) {
    _streamController = StreamController.broadcast();
  }


  void start() {
    if (!isRunning) {
      _startTimer();
      isRunning = true;
    }
  }

  void stop() {
    _timer?.cancel();
    isRunning = false;
    seconds = 0;
    minutes = 0;
    hours = 0;
    lastValue = "00:00:00";
  }

  void pause() {
    isPaused = true;
  }

  void resume() {
    isPaused = false;
  }

  void dispose() async {
    await _streamController.close();
  }

  void close() {
    _streamController.close();
  }



  _startTimer() {
    _streamController!.sink.add("00:00:00");
    _timer = Timer.periodic(const Duration(seconds: 1), (_timer) {
      if (isPaused) return;
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
      lastValue = "$digitHours:$digitMinutes:$digitSeconds";
    });
  }
}