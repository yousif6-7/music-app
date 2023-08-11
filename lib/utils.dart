import 'dart:async';

import 'package:flutter/material.dart';
import 'package:palette_generator/palette_generator.dart';

import 'download_provider.dart';

const kPrimaryColor = Color(0xFFebbe8b);

// playlist songs

String durationFormat(Duration duration) {
  String twoDigits(int n) => n.toString().padLeft(2, '0');
  String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
  String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
  return '$twoDigitMinutes:$twoDigitSeconds';
  // for example => 03:09
}

// get song cover image colors
Future<PaletteGenerator> getImageColors(
    AudiosDownloader downloader, int index) async {
  final audioI = downloader.downloadedAudios[index];
  final imageProvider = NetworkImage(audioI.coverImage);

  final paletteGenerator = await PaletteGenerator.fromImageProvider(
    imageProvider,
    maximumColorCount: 20,
  );

  return paletteGenerator;
}
