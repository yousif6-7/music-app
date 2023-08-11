import 'package:flutter/material.dart';
import 'package:music_app/isar_provider.dart';
import 'package:music_app/playing_provider.dart';
import 'package:music_app/screens/nav_bar.dart';
import 'package:music_app/screens/playlist_page.dart';
import 'package:music_app/screens/settings.dart';
import 'package:music_app/screens/test_sec.dart';
import 'package:provider/provider.dart';
import 'download_provider.dart';

void main() async {
  runApp(
     MultiProvider(
       providers: [
         ChangeNotifierProvider<IsarProvider>(
           create: (_) => IsarProvider(),
         ),
         ChangeNotifierProvider<AudiosDownloader>(
           create: (_) => AudiosDownloader(),
         ),
         ChangeNotifierProvider<PlayingProvider>(
           create: (_) => PlayingProvider(),
         ),
       ],
         child: const MyApp()),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
        textTheme:
            const TextTheme(bodyMedium: TextStyle(color: Colors.white)),
      ),
      debugShowCheckedModeBanner: false,
      title: 'YouTube Video Downloader',
      initialRoute: '/',
      routes: {
        '/': (context) => const NavBar(),
        '/PlaylistPage': (context) => const PlaylistPage(),
        '/Settings': (context) => const Settings(),
      },
    );
  }
}

