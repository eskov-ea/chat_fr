import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_sound/public/flutter_sound_player.dart';
import 'package:flutter_sound_platform_interface/flutter_sound_platform_interface.dart';
import 'package:path_provider/path_provider.dart';
import '../../services/global.dart';
import '../../services/messages/messages_repository.dart';
import 'app_bar.dart';

class AudioPlayerWidget extends StatefulWidget {
  const AudioPlayerWidget({
    required this.attachmentId,
    required this.fileName,
    Key? key,
  }) : super(key: key);

  final int attachmentId;
  final String fileName;

  @override
  State<AudioPlayerWidget> createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<AudioPlayerWidget> {

  final MessagesRepository _messagesRepository = MessagesRepository();
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
    // player.startPlayer(fromURI: "https://dl.espressif.com/dl/audio/ff-16b-2c-44100hz.mp4", codec: Codec.aacMP4);
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
    return Scaffold(
      appBar: AppBar(
        iconTheme: Theme
            .of(context)
            .iconTheme,
        backgroundColor: Colors.blue,
        automaticallyImplyLeading: true,
        elevation: 0,
        leadingWidth: 100,
        leading: Align(
          child: GestureDetector(
            onTap: () {
              Navigator.of(context).pop();
            },
            child: Padding(
              padding: EdgeInsets.only(left: 10),
              child: Row(
                children: const [
                  Padding(padding:EdgeInsets.only(bottom: 5), child: Icon( CupertinoIcons.back, color: Colors.white,)),
                  Padding(padding:EdgeInsets.only(bottom: 5), child: Text('Назад', style: TextStyle(fontSize: 20), textAlign: TextAlign.center,)),
                ],
              ),
            ),
          ),
        ),
        title: Padding(
          padding: const EdgeInsets.only(bottom: 4, right: 50),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Text("Audio message",
                style: TextStyle(fontSize: 22),)
            ],
          ),
        ),
      ),
      body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _playerIsInited && _dataIsLoaded
                ? Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  _controlButtons(),
                  Slider(
                    value: position.inSeconds.toDouble(),
                    min: 0,
                    max: duration.inSeconds.toDouble(),
                    onChanged: setSubscriptionDuration,
                    // divisions: 100
                  ),
                  // _slider(_mSubscriptionDuration, setSubscriptionDuration),
                  // _timing(snapshot.data),
                  Text(
                    getAudioMessageDuration(duration.inSeconds),
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  )
                ],
              ),
            )
                : const Expanded(
                child: Center(
                    child: CircularProgressIndicator()
                )
            ),
            Container(
              width: MediaQuery
                  .of(context)
                  .size
                  .width,
              height: 60,
              color: Colors.blue,
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).pop();
                },
                child: const Center(
                    child: Text(
                      "Готово",
                      style: TextStyle(fontSize: 26,
                          color: Colors.white,
                          fontWeight: FontWeight.bold),
                    )
                ),
              ),
            )
          ]),
    );
  }

  Widget _slider(duration, durationCallback) {
    print("SLIDER   $duration, $durationCallback");
    return Slider(
      value: duration,
      min: 0.0,
      max: 10.0,
      onChanged: durationCallback,
      divisions: 1
    );
  }

  Widget _controlButtons() {
    final color = isPlaying ? Colors.red : Colors.blue;
    final icon = isPlaying ? Icons.pause : Icons.play_arrow;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.all(4.0),
          child: GestureDetector(
            onTap: () {
              if (isPlaying) {
                pause();
              } else {
                play();
              }
            },
            child: SizedBox(
              width: 60,
              height: 60,
              child: Icon(icon, color: color, size: 60),
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

