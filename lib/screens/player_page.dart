import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:music_app/playing_provider.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:provider/provider.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';
import '../download_provider.dart';
import '../utils.dart';

class PlayerPage extends StatefulWidget {
  PlayerPage({
    Key? key,
    required this.currentI,
    required this.playerI,
    required this.playing,
  }) : super(key: key);

  final PlayingProvider playerI;
  final int currentI;
  late final bool playing;

  @override
  State<PlayerPage> createState() => _PlayerPageState();
}

class _PlayerPageState extends State<PlayerPage> {
  Duration duration = Duration.zero;
  Duration position = Duration.zero;

  @override
  void initState() {
    widget.playerI.player.playbackEventStream.listen((event) {
      if (event.processingState == ProcessingState.completed) {
        setState(() {
          widget.playing = false;
          widget.playerI.stop();
        });
      }
    });
    widget.playerI.player.durationStream.listen((
      newDuration,
    ) {
      if (mounted) {
        setState(() {
          duration = newDuration!;
        });
      }
    });

    widget.playerI.player.positionStream.listen((newPosition) {
      position = widget.playerI.player.position;
      if (mounted) {
        setState(() {
          position = newPosition;
        });
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: Padding(
          padding: const EdgeInsets.only(left: 10),
          child: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(
                Icons.keyboard_arrow_down,
                size: 30,
                color: Colors.white,
              )),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: Consumer<AudiosDownloader>(builder: (context, downloader, _) {
        final audioI = downloader.downloadedAudios[widget.currentI];
        return Stack(
          alignment: Alignment.center,
          children: [
            FutureBuilder<PaletteGenerator>(
              future: getImageColors(downloader, widget.playerI.currentIndex),
              builder: (context, snapshot) {
                return Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    decoration: BoxDecoration(
                        gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                          snapshot.data?.lightMutedColor?.color ?? Colors.grey,
                          snapshot.data?.mutedColor?.color ?? Colors.grey,
                        ])),
                  ),
                );
              },
            ),
            Positioned(
              height: MediaQuery.of(context).size.height / 1.5,
              child: Column(
                children: [
                  Text(
                    audioI.title,
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Text(
                    audioI.artistName,
                    style: const TextStyle(fontSize: 20, color: Colors.white70),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height / 20,
                  ),
                  IntrinsicHeight(
                    child: Row(
                      children: [
                        Text(
                          durationFormat(position),
                          style: const TextStyle(color: Colors.white70),
                        ),
                        const VerticalDivider(
                          color: Colors.white54,
                          thickness: 2,
                          width: 25,
                          indent: 2,
                          endIndent: 2,
                        ),
                        Text(
                          durationFormat(duration - position),
                          style: const TextStyle(color: kPrimaryColor),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Center(
                child: SleekCircularSlider(
              min: 0,
              max: duration.inSeconds.toDouble(),
              initialValue: position.inSeconds.toDouble(),
              onChange: (value) async {
// Calculate the new position duration based on the audioD duration

                Duration newPosition = Duration(seconds: value.toInt());

                // Seek to the new position
                setState(() {
                  widget.playerI.player.seek(newPosition);
                });

                if (kDebugMode) {
                  print(duration);
                }
              },
              innerWidget: (percentage) {
                return Padding(
                  padding: const EdgeInsets.all(25.0),
                  child: CircleAvatar(
                    backgroundColor: Colors.grey,
                    backgroundImage: NetworkImage(audioI.coverImage),
                  ),
                );
              },
              appearance: CircularSliderAppearance(
                  size: 330,
                  angleRange: 300,
                  startAngle: 300,
                  customColors: CustomSliderColors(
                      progressBarColor: kPrimaryColor,
                      dotColor: kPrimaryColor,
                      trackColor: Colors.grey.withOpacity(.4)),
                  customWidths: CustomSliderWidths(
                      trackWidth: 6, handlerSize: 10, progressBarWidth: 6)),
            )),
            Positioned(
              top: MediaQuery.of(context).size.height / 1.3,
              left: 0,
              right: 0,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  StreamBuilder(
                    stream: widget.playerI.player.playerStateStream,
                    builder: (context, snapshot) {

                      if (snapshot.hasData) {
                        final playerState = snapshot.data;
                        final processingState =
                            (playerState! as PlayerState).processingState;
                        if (processingState == ProcessingState.buffering ||
                            processingState == ProcessingState.loading) {
                          return const SizedBox(
                            width: 60,
                            height: 60,
                            child: CircularProgressIndicator(),
                          );
                        } else if (!widget.playerI.player.playing) {
                          return IconButton(
                            onPressed: (){
                              widget.playerI.player.play;
                              if (kDebugMode) {
                                print(processingState);

                              }} ,
                            icon: const Icon(Icons.play_circle),
                          );
                        } else if (processingState !=
                            ProcessingState.completed) {
                          return IconButton(
                            onPressed: widget.playerI.player.pause,
                            icon: const Icon(Icons.pause_circle),
                          );
                        } else {
                         return IconButton(
                            onPressed: () => widget.playerI.player.seek(
                                Duration.zero,
                                index: widget
                                    .playerI.player.effectiveIndices!.first),
                            icon: const Icon(
                                Icons.replay_circle_filled_outlined),
                          );
                        }
                      } else {
                        return const CircularProgressIndicator();
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }
}
