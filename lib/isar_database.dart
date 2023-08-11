import 'package:isar/isar.dart';
part 'isar_database.g.dart';

@Collection()
class AudioInfo {
  Id id =  Isar.autoIncrement;
  String title;
  String artistName;
  String coverImage;
  String filePath;
  double? audioDuration;
  AudioInfo({
    required this.title,
    required this.artistName,
    required this.coverImage,
    required this.filePath,
    required this.audioDuration,
    required Id id,
  });
}

