// import 'dart:io';
// import 'dart:math' as math;
// import 'package:audioplayers/audioplayers.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:music_app/screens/player_page.dart';
// import 'package:palette_generator/palette_generator.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:provider/provider.dart';
// import '../download_provider.dart';
// import '../utils.dart';
//
// class PlaylistPage extends StatefulWidget {
//   const PlaylistPage({
//     Key? key,
//   }) : super(key: key);
//
//   @override
//   State<PlaylistPage> createState() => _PlaylistPageState();
// }
//
// class _PlaylistPageState extends State<PlaylistPage>
//     with SingleTickerProviderStateMixin {
//   final AudioPlayer _player = AudioPlayer();
//   int _currentIndex = -1;
//   bool _isPlaying = false;
//   bool showContainer = true;
//
//   // define an animation controller for rotate the song cover image
//   late AnimationController _animationController;
//   late Future<Color> _futurePaletteColor;
//
//   @override
//   void initState() {
//     super.initState();
//     _animationController =
//         AnimationController(vsync: this, duration: const Duration(seconds: 3));
//
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       final downloader = Provider.of<AudiosDownloader>(context, listen: false);
//
//       if (downloader.downloadedAudios.isEmpty) {
//         downloader.fetchDownloadedAudiosFromDatabase().then((audioInfos) {
//           setState(() {
//             downloader.downloadedAudios.addAll(audioInfos);
//           });
//         });
//       }
//     });
//
//     _player.onPlayerComplete.listen((event) {
//       setState(() {
//         _isPlaying = false;
//       });
//     });
//   }
//
//   void _play(int index, AudiosDownloader downloader,
//
//       Function(bool) updatedIsPlaying) async {
//     final audioInfo = downloader.downloadedAudios[index];
//     final audioFile = File(audioInfo.filePath);
//     if (_currentIndex == index) {
//       if (_isPlaying == false) {
//         await _player.play(DeviceFileSource( audioFile.path,));
//         setState(() {
//           _isPlaying = true;
//           showContainer = true;
//         });
//       } else {
//         await _player.pause();
//         setState(() {
//           _isPlaying = false;
//           showContainer = true;
//         });
//       }
//     } else {
//
//       if (await audioFile.exists()) {
//         await _player.play(DeviceFileSource( audioFile.path,));
//         setState(() {
//           _currentIndex = index;
//           _isPlaying = true;
//           showContainer = true;
//         });
//       } else {
//         if (kDebugMode) {
//           print("Audio file does not exist.");
//           print(audioInfo.filePath);
//           print(audioFile.existsSync());
//         }
//       }
//     }
//     updatedIsPlaying(_isPlaying);
//   }
//
//   void _stop(int index, AudiosDownloader downloader,
//       Function(bool) updatedIsPlaying) async {
//     await _player.stop();
//     setState(() {
//       _currentIndex = index;
//       _isPlaying = false;
//       showContainer = false;
//     });
//     updatedIsPlaying(_isPlaying);
//   }
//
//
//
//   var appDocumentsDir = getApplicationDocumentsDirectory();
//
//   @override
//   Widget build(BuildContext context) {
//     return Consumer<AudiosDownloader>(builder: (context, downloader, _) {
//       return Stack(children: [
//         downloader.downloadedAudios.isEmpty
//             ? const Center(
//           child: Text('No downloaded data'),
//         )
//             : ListView.separated(
//           separatorBuilder: (context, index) {
//             return const Divider(
//               color: Colors.white30,
//               height: 0,
//               thickness: 1,
//               indent: 85,
//             );
//           },
//           itemCount: downloader.downloadedAudios.length,
//           itemBuilder: (context, index) {
//             final audioI = downloader.downloadedAudios[index];
//
//             return Padding(
//               padding: const EdgeInsets.only(top: 10),
//               child: Dismissible(
//                 key: Key(audioI.filePath),
//                 onDismissed: (direction) async {
//                   await downloader.deleteVideo(index);
//                   if (index >= 1) {
//                     setState(() {
//                       downloader.downloadedAudios.removeAt(index);
//                     });
//                   }
//                 },
//                 background: Container(
//                   color: Colors.red,
//                   alignment: Alignment.centerRight,
//                   padding: const EdgeInsets.only(right: 20),
//                   child: const Icon(
//                     Icons.delete,
//                     color: Colors.white,
//                   ),
//                 ),
//                 child: ListTile(
//                   title: Text(
//                     audioI.title,
//                     style: const TextStyle(color: Colors.white),
//                   ),
//                   subtitle: Text(
//                     audioI.artistName,
//                     style: const TextStyle(color: Colors.white70),
//                   ),
//                   leading: ClipRRect(
//                     borderRadius: BorderRadius.circular(10),
//                     child: Image.network(audioI.coverImage),
//                   ),
//                   onTap: () async {
//                     PermissionStatus micState = await Permission.microphone.request();
//
//                     if (micState == PermissionStatus.granted) {
//                       _play(index, downloader, (isPlaying) {
//                         if (kDebugMode) {
//                           print(_player.state);
//                           print(isPlaying);
//                         }
//                       });
//                     }
//                     if (micState == PermissionStatus.denied) {
//                       showAlertDialog(
//                         context,
//                         'Permission Denied',
//                         'Allow access the mic',
//                         'Cancel',
//                         'Settings',
//                             () => Navigator.of(context).pop(),
//                             () => openAppSettings(),
//                       );
//                     }
//                     if(micState == PermissionStatus.permanentlyDenied){
//                       showAlertDialog(
//                         context,
//                         'Permission Disabled',
//                         'pleas allow access the mic to play your audios',
//                         'Cancel',
//                         'Settings',
//                             () => Navigator.of(context).pop(),
//                             () => openAppSettings(),
//                       );
//                     }
//                   },
//                 ),
//               ),
//             );
//           },
//         ),
//         !showContainer
//             ? const SizedBox.shrink()
//             : FutureBuilder<PaletteGenerator>(
//           future: getImageColors(downloader, _currentIndex),
//           builder: (
//               context,
//               snapshot,
//               ) {
//             if (snapshot.connectionState == ConnectionState.done &&
//                 snapshot.hasData &&
//                 _currentIndex >= 0 &&
//                 _currentIndex < downloader.downloadedAudios.length) {
//               final audioI = downloader.downloadedAudios[_currentIndex];
//
//               return Positioned(
//                 bottom: 0,
//                 left: 0,
//                 right: 0,
//                 child: Container(
//                   margin: const EdgeInsets.symmetric(
//                       horizontal: 15, vertical: 50),
//                   height: 75,
//                   decoration: BoxDecoration(
//                       gradient: LinearGradient(
//                           begin: Alignment.topLeft,
//                           end: const Alignment(0, 5),
//                           colors: [
//                             snapshot.data?.lightMutedColor?.color ??
//                                 Colors.grey,
//                             snapshot.data?.mutedColor?.color ??
//                                 Colors.grey,
//                           ]),
//                       borderRadius: BorderRadius.circular(20)),
//                   child: Row(
//                     children: [
//                       AnimatedBuilder(
// // // rotate the song cover image
//                         animation: _animationController,
//                         builder: (_, child) {
// // if song is not playing
//                           if (!_isPlaying) {
//                             _animationController.stop();
//                           } else {
//                             _animationController.forward();
//                             _animationController.repeat();
//                             if (kDebugMode) {}
//                           }
//                           return Transform.rotate(
//                               angle: _animationController.value *
//                                   2 *
//                                   math.pi,
//                               child: child);
//                         },
//                         child: InkWell(
//                           onTap: () => Navigator.push(
//                               context,
//                               CupertinoPageRoute(
//                                   fullscreenDialog: true,
//                                   builder: (context) => PlayerPage(
//                                     player: _player,
//                                     looping: false,
//                                     title: audioI.title,
//                                     artistName: audioI.artistName,
//                                     coverImage: audioI.coverImage,
//                                     currentI: _currentIndex,
//                                   ))),
//                           child: Padding(
//                             padding: const EdgeInsets.all(8.0),
//                             child: CircleAvatar(
//                                 radius: 30,
//                                 backgroundColor: Colors.grey,
//                                 backgroundImage:
//                                 NetworkImage(audioI.coverImage)),
//                           ),
//                         ),
//                       ),
//                       Expanded(
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             Text(
//                               audioI.title,
//                               maxLines: 2,
//                               overflow: TextOverflow.ellipsis,
//                               style: const TextStyle(fontSize: 16),
//                             ),
//                             Text(
//                               audioI.artistName,
//                               overflow: TextOverflow.ellipsis,
//                               style: const TextStyle(fontSize: 12),
//                             ),
//                           ],
//                         ),
//                       ),
//                       IconButton(
//                         icon: Icon(
//                           !_isPlaying ? Icons.play_arrow : Icons.pause,
//                           size: 30,
//                         ),
//                         onPressed: () async {
//                           _play(_currentIndex, downloader, (isPlaying) {
//                             if (kDebugMode) {
//                               print(isPlaying);
//                             }
//                           });
//                         },
//                       ),
//                       IconButton(
//                         icon: const Icon(
//                           Icons.stop,
//                           size: 30,
//                         ),
//                         onPressed: () async {
//                           _stop(_currentIndex, downloader, (isPlaying) {
//                             if (kDebugMode) {
//                               print(isPlaying);
//                             }
//                           });
//                         },
//                       ),
//                     ],
//                   ),
//                 ),
//               );
//             } else {
//               return const SizedBox.shrink();
//             }
//           },
//         ),
//       ]);
//     });
//   }
//
//   @override
//   void dispose() {
//     if (_animationController.isAnimating) {
//       _animationController.stop();
//     }
//     _player.dispose();
//     _player.stop();
//     _animationController.dispose();
//     super.dispose();
//   }
//
//   dynamic showAlertDialog(dynamic context, String title, String content, String text1,
//       String text2,dynamic Function() onPressed1,dynamic Function() onPressed2) {
//     showCupertinoDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (BuildContext context) => CupertinoAlertDialog(
//         title: Text(title),
//         content: Text(content),
//         actions: <CupertinoDialogAction>[
//           CupertinoDialogAction(
//             onPressed: onPressed1,
//             child: Text(text1),
//           ),
//           CupertinoDialogAction(
//             onPressed: onPressed2,
//             child: Text(text2),
//           ),
//         ],
//       ),
//     );
//   }
// }




import 'package:flutter/cupertino.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

// FFprobeKit.getMediaInformation(audioFile.path).then((session) async {
// final information = session.getMediaInformation();
//
// if (information == null) {
//
// // CHECK THE FOLLOWING ATTRIBUTES ON ERROR
// final state = FFmpegKitConfig.sessionStateToString(await session.getState());
// final returnCode = await session.getReturnCode();
// final failStackTrace = await session.getFailStackTrace();
// final duration = await session.getDuration();
// final output = await session.getOutput();
// }
// });