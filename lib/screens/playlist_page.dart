import 'dart:math' as math;
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:music_app/isar_provider.dart';
import 'package:music_app/screens/player_page.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:provider/provider.dart';
import '../download_provider.dart';
import '../playing_provider.dart';
import '../utils.dart';

class PlaylistPage extends StatefulWidget {
  const PlaylistPage({
    Key? key,
  }) : super(key: key);

  @override
  State<PlaylistPage> createState() => _PlaylistPageState();
}

class _PlaylistPageState extends State<PlaylistPage>
    with SingleTickerProviderStateMixin {
  // define an animation controller for rotate the song cover image
  late AnimationController _animationController;
  bool _showContainer = false;


  @override
  void initState() {
    super.initState();
    _animationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 3));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final downloader = Provider.of<AudiosDownloader>(context, listen: false);
      final fetchingData = Provider.of<IsarProvider>(context, listen: false);
      if (downloader.downloadedAudios.isEmpty) {
        fetchingData.fetchDownloadedAudiosFromDatabase().then((audioInfos) {
          setState(() {
            downloader.downloadedAudios.addAll(audioInfos);
          });
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<AudiosDownloader, PlayingProvider>(
        builder: (context, downloader, playerInstance, _) {
          if (kDebugMode) {
            print('rebuilding');
          }
      if (downloader.downloadedAudios.isEmpty) {
        return const Center(
          child: Text('No downloaded data'),
        );
      } else {
        return Stack(children: [
          downloader.downloadedAudios.isEmpty
              ? const Center(
                  child: Text('No downloaded data'),
                )
              : ListView.separated(
                  separatorBuilder: (context, index) {
                    return const Divider(
                      color: Colors.white30,
                      height: 0,
                      thickness: 1,
                      indent: 85,
                    );
                  },
                  itemCount: downloader.downloadedAudios.length,
                  itemBuilder: (context, index) {
                    final audioI = downloader.downloadedAudios[index];

                    return Dismissible(
                      key: Key(audioI.filePath),
                      onDismissed: (direction) async {
                        await Provider.of<IsarProvider>(context, listen: false)
                            .deleteVideo(index);

                        if (index >= 1) {
                          setState(() {
                            downloader.downloadedAudios.removeAt(index);
                          });
                        }
                      },
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        child: const Icon(
                          Icons.delete,
                          color: Colors.white,
                        ),
                      ),
                      child: ListTile(
                        title: Text(
                          audioI.title,
                          style: const TextStyle(
                            color: Colors.white,
                          ),
                        ),
                        subtitle: Text(
                          audioI.artistName,
                          style: const TextStyle(color: Colors.white70),
                        ),
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(audioI.coverImage),
                        ),
                        onTap: () async {
                          await playerInstance.play(index, audioI);
                            if (kDebugMode) {
                              print(playerInstance.player.processingState);
                              print(playerInstance.player.playerState);
                              print(playerInstance.isPlaying);
                            }
                          //
                        },
                      ),
                    );
                  },
                ),
          // !playerInstance.showContainer
          //     ? const SizedBox.shrink()
          //     :
          FutureBuilder<PaletteGenerator>(
                  future:
                      getImageColors(downloader, playerInstance.currentIndex),
                  builder: (
                    context,
                    snapshot,
                  ) {
                    if (snapshot.connectionState == ConnectionState.done &&
                        snapshot.hasData &&
                        playerInstance.currentIndex >= 0 &&
                        playerInstance.currentIndex <
                            downloader.downloadedAudios.length) {
                      final audioI = downloader
                          .downloadedAudios[playerInstance.currentIndex];
                      final int i = playerInstance.currentIndex;
                      return Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 15, vertical: 50),
                          height: 75,
                          decoration: BoxDecoration(
                              gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: const Alignment(0, 5),
                                  colors: [
                                    snapshot.data?.lightMutedColor?.color ??
                                        Colors.grey,
                                    snapshot.data?.mutedColor?.color ??
                                        Colors.grey,
                                  ]),
                              borderRadius: BorderRadius.circular(20)),
                          child: Row(
                            children: [
                              AnimatedBuilder(
// // rotate the song cover image
                                animation: _animationController,
                                builder: (_, child) {
// if song is not playing
                                  if (!playerInstance.isPlaying) {
                                    _animationController.stop();
                                  } else {
                                    _animationController.forward();
                                    _animationController.repeat();
                                    if (kDebugMode) {}
                                  }
                                  return Transform.rotate(
                                      angle: _animationController.value *
                                          2 *
                                          math.pi,
                                      child: child);
                                },
                                child: InkWell(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      CupertinoPageRoute(
                                        fullscreenDialog: true,
                                        builder: (_) => PlayerPage(
                                          currentI: playerInstance.currentIndex,
                                          playerI: playerInstance,
                                          playing: playerInstance.isPlaying,
                                        ),
                                      ),
                                    );
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: CircleAvatar(
                                        radius: 30,
                                        backgroundColor: Colors.grey,
                                        backgroundImage:
                                            NetworkImage(audioI.coverImage)),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      audioI.title,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                    Text(
                                      audioI.artistName,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: Icon(
                                  !playerInstance.isPlaying
                                      ? Icons.play_arrow
                                      : Icons.pause,
                                  size: 30,
                                ),
                                onPressed: () async {
                                  await playerInstance.play(i, audioI);
                                },
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.stop,
                                  size: 30,
                                ),
                                onPressed: () async {
                                  playerInstance.stop();
                                  // _stop(_currentIndex, downloader,
                                  //     (isPlaying) {});
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    } else {
                      return const SizedBox.shrink();
                    }
                  },
                ),
        ]);
      }
    });
  }

  @override
  void dispose() {
    if (_animationController.isAnimating) {
      _animationController.stop();
    }

    _animationController.dispose();
    super.dispose();
  }

  dynamic showAlertDialog(
      dynamic context,
      String title,
      String content,
      String text1,
      String text2,
      dynamic Function() onPressed1,
      dynamic Function() onPressed2) {
    showCupertinoDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => CupertinoAlertDialog(
        title: Text(title),
        content: Text(content),
        actions: <CupertinoDialogAction>[
          CupertinoDialogAction(
            onPressed: onPressed1,
            child: Text(text1),
          ),
          CupertinoDialogAction(
            onPressed: onPressed2,
            child: Text(text2),
          ),
        ],
      ),
    );
  }
}
