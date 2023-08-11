import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:music_app/playing_provider.dart';
import 'package:provider/provider.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';

import '../download_provider.dart';
import '../utils.dart';

class Test extends StatefulWidget {
  final Duration? audioD;
  final Duration audioP;
  final int currentI;
  final PlayingProvider playerI;


  const Test(
      {super.key,
      required this.audioD,
      required this.audioP,
      required this.currentI, required this.playerI, required this.path});
      final String path;

  @override
  State<Test> createState() => _TestState();
}

class _TestState extends State<Test> {
  Duration duration = Duration.zero;

bool isPlaying = false;

  // duration=Duration(seconds: widget.audioD!.toInt());

  @override
  void initState() {


    widget.playerI.player.playbackEventStream.listen((event) {
      if (event.processingState == ProcessingState.completed) {
        setState(() {
          isPlaying = false;
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


    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.only(left: 10),
          child: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(
                Icons.keyboard_arrow_down,
                size: 30,
                color: Colors.black,
              )),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: Consumer<AudiosDownloader>(builder: (context, testDownloader, _) {
        final audioI = testDownloader.downloadedAudios[widget.currentI];
        Duration audioPosition = widget.playerI.player.position;

        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              IntrinsicHeight(
                child: Center(
                  child: Row(
                    children: [
                      Text(
                        durationFormat(audioPosition),
                        style: const TextStyle(color: Colors.black),
                      ),
                      const VerticalDivider(
                        color: Colors.white54,
                        thickness: 2,
                        width: 25,
                        indent: 2,
                        endIndent: 2,
                      ),
                      Text(
                        durationFormat(duration - audioPosition),
                        style: const TextStyle(color: kPrimaryColor),
                      )
                    ],
                  ),
                ),
              ),
              Center(
                  child: Text(
                audioI.title,
                style: const TextStyle(fontSize: 20, color: Colors.blueGrey),
              )),
              Center(
                  child: Text(
                audioI.artistName,
                style: const TextStyle(fontSize: 20, color: Colors.blueGrey),
              )),
              Center(
                  child: SleekCircularSlider(
                    min: 0,
                    max: duration.inSeconds.toDouble(),
                    initialValue: audioPosition.inSeconds.toDouble(),
                    onChange: (value) async {
// Calculate the new position duration based on the audioD duration

                      Duration newPosition = Duration(seconds: value.toInt());

                      setState(() {
                        widget.playerI.player.seek(newPosition);
                      });

                      if (kDebugMode) {
                        print('duration');
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
              ElevatedButton(
                onPressed
                    : () {
                  if (kDebugMode) {
                    print(duration);
                    print(audioPosition);
                  }

                },
                child: const Text(' Download'),
              ),
            ],
          ),
        );
      }),
    );
  }
}
