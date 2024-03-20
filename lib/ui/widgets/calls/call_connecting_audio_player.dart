import 'package:just_audio/just_audio.dart';


class CallConnectingAudioPlayer {

  const CallConnectingAudioPlayer._();

  static AudioPlayer? _player;
  static CallConnectingAudioPlayer? _instance;

  static Future<CallConnectingAudioPlayer> get player async {
    if (_instance != null) {
      return _instance!;
    } else {
      _player = AudioPlayer();
      _instance = const CallConnectingAudioPlayer._();
      return _instance!;
    }
  }

  Future<void> startPlayConnectingSound() async {
    if(_player == null) {
      await CallConnectingAudioPlayer.player;
    }
    await _player!.setAsset("assets/sounds/connecting_sound.mp3");
    await _player!.setLoopMode(LoopMode.one);
    await _player!.play();
  }

  Future<void> stopPlayConnectingSound() async {
    if(_player != null) {
      await _player!.stop();
    }
  }

  Future<void> playErrorSound() async {
    print("playErrorSound");
    if(_player!.playing) {
      await _player!.stop();
      _player = null;
    }
    if(_player == null) {
      await CallConnectingAudioPlayer.player;
    }
    await _player!.setAsset("assets/sounds/error_call_sound.mp3");
    await _player!.setLoopMode(LoopMode.off);
    await _player!.play();
    _player = null;
  }

  Future<void> destroyPlayer() async {
    if(_player != null) {
      await _player!.dispose();
      _player = null;
    }
  }

}