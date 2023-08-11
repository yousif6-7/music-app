import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:music_app/isar_database.dart';
import 'package:music_app/isar_provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class AudiosDownloader extends ChangeNotifier {
  late final List<AudioInfo> _downloadedAudios = [
  ];
  late final TextEditingController textFieldController;
  var appDocumentsDir =  getApplicationDocumentsDirectory();

  bool _isDownloading = false;
  double _downloadProgress = 0.0;

  List<AudioInfo> get downloadedAudios => _downloadedAudios;

  bool get isDownloading => _isDownloading;

  double get downloadProgress => _downloadProgress;



  Future<void> downloadAudios(
      String videoLink, TextEditingController linkController) async {
    try {
      _isDownloading = true;
      _downloadProgress = 0.0;

      notifyListeners();

      // Get the video metadata

      var yt = YoutubeExplode();
      var video = await yt.videos.get(videoLink);

      if (_downloadedAudios.any((audio) => audio.title == video.title)) {
        // Audio already exists, no need to download again
        _isDownloading = false;
        _downloadProgress = 0.0;
        notifyListeners();
        return;
      }

      // Get the video stream to download
      var manifest = await yt.videos.streamsClient.getManifest(video.id.value);
      var streamInfo = manifest.audioOnly.withHighestBitrate();
      var stream = yt.videos.streamsClient.get(streamInfo);

      // Get the app's documents directory to save the video
      final dir =await appDocumentsDir;
      var filePath = '${dir.path}/${video.title}.mp3';
      // Download the video stream and save it to a file
      var fileStream = File(filePath).openWrite();
      var totalBytes = streamInfo.size.totalBytes;
      var receivedBytes = 0;

      stream.listen(
        (data) {
          receivedBytes += data.length;
          var progress = receivedBytes / totalBytes;
          _downloadProgress = progress;
          notifyListeners();
          fileStream.add(data);
        },
        onDone: () async {
          fileStream.close();
          _isDownloading = false;
          _downloadProgress = 0.0;
          var audio = AudioInfo(
            title: video.title,
            artistName: video.author,
            coverImage: video.thumbnails.highResUrl,
            filePath: filePath,
            id: int.parse(video.id.value.replaceAll(RegExp(r'[^0-9]'), '')),
            audioDuration: video.duration?.inSeconds.toDouble(),
          );
          IsarProvider().saveData(audio);

          if (kDebugMode) {
            print(audio.filePath);
          }
          notifyListeners();
        },
        onError: (e) {
          fileStream.close();
          _isDownloading = false;
          _downloadProgress = 0.0;
          notifyListeners();
          throw e;
        },
        cancelOnError: true,
      );
    } catch (e) {
      _isDownloading = false;
      _downloadProgress = 0.0;
      notifyListeners();
      rethrow;
    }
  }



  @override
  notifyListeners();
}
