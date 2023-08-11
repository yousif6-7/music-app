import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

import 'isar_database.dart';

class PlayingProvider with ChangeNotifier {
  final AudioPlayer _player = AudioPlayer();
  int _currentIndex = -1;
  bool _isPlaying = false;
  bool _showContainer = false;
  int get currentIndex => _currentIndex;
  bool get isPlaying => _isPlaying;
  bool get showContainer => _showContainer;

  AudioPlayer get player => _player;
  Duration _pausedPosition = Duration.zero;

  Future play(int index, AudioInfo audioInfo) async {
    try {
      final audioFile = File(audioInfo.filePath);

      if (_isPlaying) {
        if (_currentIndex == index) {
          _player.pause();
          _pausedPosition = _player.position;
          _isPlaying = false;
          _showContainer = true;
          return;
        }
      }

      await _player.setFilePath(audioFile.path);
      if (_pausedPosition != Duration.zero) {
        await _player.seek(_pausedPosition);
      }

      _player.play();
      _currentIndex = index;
      _isPlaying = true;
      _showContainer = true;
    } on Exception catch (e) {
      // Handle exceptions
      if (kDebugMode) {
        print(e);
      }
    }



    // if (_player.playerState.processingState == ProcessingState.loading ||
    //     _player.playerState.processingState == ProcessingState.buffering) {
    //   return Container(
    //     margin: const EdgeInsets.all(8.0),
    //     width: 64.0,
    //     height: 64.0,
    //     child: const CircularProgressIndicator(),
    //   );
    // } else if (_player.playerState.processingState == ProcessingState.idle) {
    //   final audioFile = File(audioInfo.filePath);
    //   if (await audioFile.exists()) {
    //     await _player.setFilePath(audioFile.path);
    //   }
    // } else if (_player.playerState.processingState == ProcessingState.ready) {
    //   await _player.play();
    //   _currentIndex = index;
    //   _isPlaying = true;
    //   _showContainer = true;
    // } else if (_player.playerState.playing == true) {
    //   await _player.pause();
    // } else if (_player.playerState.processingState ==
    //     ProcessingState.completed) {
    //   await _player.stop();
    // }

    // if (_currentIndex == index) {
    //   if (_isPlaying == false) {
    //     await _player.play();
    //     _isPlaying = true;
    //     _showContainer =true;
    //   } else {
    //     await _player.pause();
    //     _isPlaying = false;
    //     _showContainer =true;
    //   }
    // } else {
    //   final audioFile = File(audioInfo.filePath);
    //   if (await audioFile.exists()) {
    //     await _player.setFilePath(audioFile.path);
    //     await _player.play();
    //     _currentIndex = index;
    //     _isPlaying = true;
    //     _showContainer =true;
    //   } else {
    //     if (kDebugMode) {
    //       print("Audio file does not exist.");
    //     }
    //   }
    // }
    notifyListeners();
  }

  // Future<void> pause(index) async {
  //   try {
  //     _player.pause();
  //     _showContainer = true;
  //     _currentIndex = index;
  //     _isPlaying = false;
  //   } on Exception catch (e) {
  //     if (kDebugMode) {
  //       print(e);
  //     }
  //   }
  //   notifyListeners();
  // }
    // Method to stop audio
    Future<void> stop() async {
      await _player.stop();
      _isPlaying = false;
      _showContainer = false;

      notifyListeners();
    }
  }
