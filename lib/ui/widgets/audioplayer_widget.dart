import 'dart:async';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_sound/public/flutter_sound_player.dart';
import 'package:flutter_sound_platform_interface/flutter_sound_platform_interface.dart';
import '../../services/global.dart';
import '../../services/messages/messages_repository.dart';

class AudioPlayerWidget extends StatefulWidget {
  const AudioPlayerWidget({
    required this.attachmentId,
    required this.fileName,
    required this.isMe,
    Key? key,
  }) : super(key: key);

  final int attachmentId;
  final String fileName;
  final bool isMe;

  @override
  State<AudioPlayerWidget> createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<AudioPlayerWidget> {

  StreamSubscription? _mPlayerSubscription;
  String pos = '0:00';
  Duration position = Duration.zero;
  Duration duration = Duration.zero;
  final FlutterSoundPlayer player = FlutterSoundPlayer();
  bool isPlaying = false;
  File? file;
  bool _playerIsInited = false;
  bool _dataIsLoaded = false;
  late final AudioPlayer audioPlayer;

  @override
  void dispose() {
    player.stopPlayer();
    cancelPlayerSubscriptions();
    player.closePlayer();
    super.dispose();
  }

  @override
  void initState() {
    audioPlayer = AudioPlayer();
    init().then((value) {
      setState(() {
        _playerIsInited = true;
      });
    decodeBase64File();
    });
    super.initState();
  }

  Future<void> init() async {
    await player.openPlayer();
    print("INIT NEW AUDIO PLAYER");
    _mPlayerSubscription = player.onProgress!.listen((e) {
      print("subscription    ${e.position}");
      setState(() {
        pos = getAudioMessageDuration(e.position.inSeconds);
        position = e.position;
        duration = e.duration;
      });
    });
    player.setSubscriptionDuration(Duration(milliseconds: 100));
    print(_mPlayerSubscription);
  }

  void play() async {
    print("PLAYAUDIO   ${file!.path}");
    if (position > Duration.zero) {
      await player.resumePlayer();
    } else {
      player.startPlayer(
          fromURI: file!.path,
          codec: Codec.aacMP4,
          whenFinished: () {
            reset();
          }
      );
    }
    setState(() {
      isPlaying = true;
    });
  }

  void pause() async {
    await player.pausePlayer();
    setState(() {
      isPlaying = false;
    });
  }

  Future<void> reset() async {
    // await player.stopPlayer();
    await player.seekToPlayer(const Duration(milliseconds: 0));
    setState(() {
      isPlaying = false;
      position = Duration.zero;
    });
    // return widget.player.seek(const Duration(milliseconds: 0));
  }

  // void playerStateListener(PlayerState state) async {
  //   if (state.processingState == ProcessingState.completed) {
  //     await reset();
  //   }
  // }

  Future<void> setSubscriptionDuration(double d) async {
    print('FuturesetSubscriptionDuration   $d');
    // _mSubscriptionDuration = d;
    setState(() {
      position = Duration(seconds: d.toInt());
    });
    await player.seekToPlayer(position);
    // await player.setSubscriptionDuration(
    //   Duration(milliseconds: d.floor()),
    // );
  }

  decodeBase64File() async {
    final rawFile = await loadFileAndSaveLocally(attachmentId: widget.attachmentId, fileName: widget.fileName);
    if (rawFile != null) {
      file = rawFile;
      await audioPlayer.setSourceDeviceFile(file!.path);
      final d = await audioPlayer.getDuration();
      setState(() {
        duration = d!;
        _dataIsLoaded = true;
      });
    }
  }

  void cancelPlayerSubscriptions() {
    if (player != null) {
      _mPlayerSubscription!.cancel();
      _mPlayerSubscription = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    //TODO: fix it. It is temporary solution to have audio messaging feature.
    return audioWidget();
  }

  Widget _slider(duration, durationCallback) {
    print("SLIDER   $duration, $durationCallback");
    return SizedBox(
      width: 100,
      child: Slider(
        value: duration,
        min: 0.0,
        max: 10.0,
        onChanged: durationCallback,
        divisions: 1
      ),
    );
  }

  Widget audioWidget() {
    return Container(
      child: _playerIsInited && _dataIsLoaded
          ? Row(
            mainAxisAlignment: widget.isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              _controlButtons(),
              SizedBox(
                width: 150,
                child: Slider(
                  value: position.inSeconds.toDouble(),
                  min: 0,
                  max: duration.inSeconds.toDouble(),
                  onChanged: setSubscriptionDuration,
                  // divisions: 100
                ),
              ),
              // _slider(_mSubscriptionDuration, setSubscriptionDuration),
              // _timing(snapshot.data),
              Text(
                getAudioMessageDuration(duration.inSeconds),
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              )
            ],
          )
          : Center(
              child: CircularProgressIndicator()
          ),
    );
  }

  Widget _controlButtons() {
    final color = isPlaying ? Colors.red : Colors.blue;
    final icon = isPlaying ? Icons.pause : Icons.play_arrow;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.all(0),
          child: GestureDetector(
            onTap: () {
              if (isPlaying) {
                pause();
              } else {
                play();
              }
            },
            child: SizedBox(
              width: 30,
              height: 35,
              child: Icon(icon, color: color, size: 35),
            ),
          ),
        )
      ],
    );
  }
}

class AudioLoadingMessage extends StatelessWidget {
  const AudioLoadingMessage({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(
              strokeWidth: 3,
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: 16.0),
            child: Icon(Icons.mic),
          ),
        ],
      ),
    );
  }
}

