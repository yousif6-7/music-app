import 'dart:io';

import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:music_app/download_provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import 'isar_database.dart';

class IsarProvider extends ChangeNotifier {
  late Future<Isar> db;

  IsarProvider() {
    db = openDB();
  }

  Future<Isar> openDB() async {
    if (Isar.instanceNames.isEmpty) {
      final appDir =await  getApplicationDocumentsDirectory();

      return await Isar.open(
        [AudioInfoSchema],
        directory: appDir.path,
      );

    }
    return await Future.value(Isar.getInstance());
  }

  Future<void> saveData(AudioInfo audio) async {
    final isar = await db;
    await isar.writeTxn<int>(() async {
      isar.audioInfos.put(audio);
      AudiosDownloader().downloadedAudios.add(audio);
      return 0;
    });
  }

  Future<List<AudioInfo>> fetchDownloadedAudiosFromDatabase() async {
    final isar = await db;

    final audioInfos = await isar.audioInfos.where().findAll();
    return audioInfos
        .map((audioInfo) => AudioInfo(
              id: audioInfo.id,
              title: audioInfo.title,
              artistName: audioInfo.artistName,
              coverImage: audioInfo.coverImage,
              filePath: audioInfo.filePath,
              audioDuration: audioInfo.audioDuration,
            ))
        .toList();
  }

  Future<void> deleteVideo(int index) async {
    final isar = await db;
    final appDir =await  getApplicationDocumentsDirectory();
    late List<AudioInfo> downloadedAudios = AudiosDownloader().downloadedAudios;
    final file = File('${appDir.path}/${downloadedAudios[index].title}.mp3');
    if (await file.exists() && index <0) {
      await file.delete();

    }
    final d = downloadedAudios.removeAt(index);
    await isar.writeTxn<int>(() async {
      await isar.audioInfos.delete(d.id);

      return 0;
    });
    downloadedAudios = await isar.audioInfos.where().findAll();

    notifyListeners();
  }


  @override
  notifyListeners();
}
