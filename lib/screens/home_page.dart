import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:music_app/screens/test_sec.dart';
import 'package:provider/provider.dart';
import '../download_provider.dart';

class HomePage extends StatefulWidget {
  final FocusNode focusNode = FocusNode();

   HomePage({Key? key, required focusNode}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _videoLinkController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            TextField(
              controller: _videoLinkController,
              focusNode: widget.focusNode,
              decoration: InputDecoration(
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                // set padding
                prefixIcon: const Icon(Icons.search),
                hintText: 'Search...',
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              onChanged: (value) {},
              style: const TextStyle(fontSize: 15, color: Colors.white),
              maxLines: 1,
              keyboardType: TextInputType.text,
              textInputAction: TextInputAction.done,
              cursorColor: Colors.white,
              cursorWidth: 2,
              cursorHeight: 30,
              enableSuggestions: true,
              autocorrect: true,
              smartDashesType: SmartDashesType.enabled,
              smartQuotesType: SmartQuotesType.enabled, // enable smart quotes
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: Provider.of<AudiosDownloader>(context).isDownloading
                  ? null
                  : () {
                      Provider.of<AudiosDownloader>(context, listen: false)
                          .downloadAudios(_videoLinkController.text,_videoLinkController);

                    },
              child: const Text(' Download'),
            ),

            const SizedBox(height: 16.0),
            if (Provider.of<AudiosDownloader>(context).isDownloading)
              LinearProgressIndicator(
                value: Provider.of<AudiosDownloader>(context).downloadProgress,
              ),
          ],
        ),
      ),
    );

  }

}
