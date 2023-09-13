import 'dart:io';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/basic.dart';
import 'package:image_picker/image_picker.dart';
import 'resultPage.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter/cupertino.dart';
import 'video_items.dart';

class UploadPage extends StatefulWidget {
  UploadPage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _UploadPageState createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  final ImagePicker _picker = ImagePicker();
  VideoPlayerController? _controller1;
  XFile? _video1File;

  Future<void> _setVideoController(XFile file) async {
    if (file != null && mounted) {
      VideoPlayerController controller;
      print('play video ');

      controller = VideoPlayerController.file(File(file.path));
      print('file:' + file.path);
      setState(() {
        _controller1 = controller;
      });
    }
  }

  @override
  void dispose(){
    super.dispose();
    _controller1!.dispose();


  }

  void _onVideo1ButtonPressed(ImageSource source) async {
    _video1File = await _picker.pickVideo(
        source: source, maxDuration: const Duration(seconds: 10));
    await _setVideoController(_video1File!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: _controller1 != null
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  color: Colors.black,
                  height: 400,
                  child: VideoItems(
                    videoPlayerController: _controller1!,
                    autoplay: false,
                    looping: false,
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                SizedBox(
                  width: 250,
                  child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            CupertinoPageRoute(
                                builder: (context) => ResultPage(
                                      title: 'Upload Video Page',
                                      video1File: _video1File!,
                                    )));
                      },
                      child: const Text(
                        'Analyze',
                        style: TextStyle(fontSize: 30),
                      )),
                )
              ],
            )
          : Center(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                  const Text(
                    'Upload Video Page',
                    style: TextStyle(fontSize: 30),
                  ),
                  const SizedBox(
                    height: 50,
                  ),
                  SizedBox(
                    width: 250,
                    child: ElevatedButton(
                      onPressed: () {
                        _onVideo1ButtonPressed(ImageSource.gallery);
                      },
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.upload_rounded,
                            size: 50.0,
                            semanticLabel: 'Upload Video #1',
                          ),
                          Text('Upload Video #1'),
                        ],
                      ),
                    ),
                  ),
                  Text(_video1File != null ? _video1File!.path : ''),
                ])),
    );
  }
}
