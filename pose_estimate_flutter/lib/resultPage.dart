import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:pose_estimate_sample/video_items.dart';
import 'package:video_player/video_player.dart';

class ResultPage extends StatefulWidget {
  ResultPage({
    Key? key,
    required this.title,
    required this.video1File,
  }) : super(key: key);
  XFile video1File;

  final String title;

  @override
  _ResultPageState createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  VideoPlayerController? _controller1;
  bool isAnalyzed = true;

  @override
  void initState() {
    super.initState();
    uploadFileToServer();
  }

  Future<void> _setVideoController(String path) async {
    VideoPlayerController controller;
    controller = VideoPlayerController.networkUrl(Uri.parse(path));
    setState(() {
      _controller1 = controller;
      print(_controller1!.value.aspectRatio);
    });
  }

  void uploadFileToServer() async {
    // This url is for local server.
    var url = 'http://10.0.2.2:5000/'; // local host

    Map<String, String> headers = {
      "Connection": "Keep-Alive",
      "Keep-Alive": "timeout=5, max=1000"
    };

    http.MultipartRequest request = http.MultipartRequest(
        'POST', Uri.parse('$url/analyze')); //post request to URL/analize
    request.headers.addAll(headers);
    request.files.add(
      await http.MultipartFile.fromPath(
        'video1',
        widget.video1File.path,
        contentType: MediaType('application', 'MOV'), //Media type
      ),
    );

    request.send().then((r) async {
      print(r.statusCode);

      if (r.statusCode == 200) {
        var result = json.decode(await r.stream.transform(utf8.decoder).join());
        print(result);
        setState(() {
          _setVideoController(result);
        });
        isAnalyzed = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: !isAnalyzed
          ? Center(
              child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        color: Colors.black,
                        height: 400,
                        child: VideoItems(
                            videoPlayerController: _controller1!,
                            looping: false,
                            autoplay: false),
                      )
                    ],
                  )))
          : const Center(
              child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('Analyzing videos'),
                )
              ],
            )),
    );
  }
}
