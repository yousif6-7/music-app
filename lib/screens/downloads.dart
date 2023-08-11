import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

import '../download_provider.dart';
import '../isar_database.dart';

class AudioPlayerWidget extends StatefulWidget {

  const AudioPlayerWidget({Key? key, }) : super(key: key);

  @override
  _AudioPlayerWidgetState createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<AudioPlayerWidget> {
  final String url= "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-13.mp3";

  late AudioPlayer _audioPlayer;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _initAudioPlayer();
  }

  Future<void> _initAudioPlayer() async {
    _audioPlayer = AudioPlayer();
    await _audioPlayer.setUrl(url);
    _audioPlayer.playbackEventStream.listen((event) {
      if (event.processingState == ProcessingState.completed ) {
        setState(() {
          _isPlaying = false;
        });
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _audioPlayer.dispose();
  }
  final List<AudioInfo> display = AudiosDownloader().downloadedAudios;

  @override
  Widget build(BuildContext context) =>
      GestureDetector(
        onTap: () async {

          // if (_isPlaying) {
          //   await _audioPlayer.pause();
          //   setState(() {
          //     _isPlaying = false;
          //   });
          // } else {
          //   await _audioPlayer.play();
          //   setState(() {
          //     _isPlaying = true;
          //   });
          // }
        },
        child: ListView.builder(
  itemCount: display.length,
  itemBuilder: (context, index) {
    final audioI = display[index];
  }
  ),
        // Icon(
        //   _isPlaying ? Icons.pause : Icons.play_arrow,
        //   size: 64,
        // ),
      );
}