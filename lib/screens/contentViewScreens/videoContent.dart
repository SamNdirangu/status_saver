import 'dart:io';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:sam_status_saver/screens/contentViewScreens/widgetActions.dart';

class VideoContentView extends StatefulWidget {
  final currentIndex;
  final List<String> videoPaths;
  const VideoContentView(
      {Key key, @required this.currentIndex, this.videoPaths})
      : super(key: key);

  @override
  _VideoContentViewState createState() => _VideoContentViewState();
}

class _VideoContentViewState extends State<VideoContentView>
    with SingleTickerProviderStateMixin {
  //
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final snackBar = SnackBar(
    content: Text('Video saved!'),
    duration: Duration(seconds: 1),
  );

  List<VideoPlayerController> _videoPlayerController = List();
  double _fabOpacity = 0.0; // Control Opacity animation

  bool videoPlay = true;
  bool isThereNext = true;
  bool isTherePrev = true;

  bool nextLoading = false;
  bool previousLoading = false;

  int currentIndex;
  int currentController = 0;
  List<String> videoPaths;

  double aspectRatio = 1.0;
  int currrentPosition = 0;
  Duration videoLength = Duration();

  @override
  void initState() {
    super.initState();
    currentIndex = widget.currentIndex;
    videoPaths = widget.videoPaths;
    _loadVideo();
  }

  @override
  void dispose() {
    if (currentController > 0) {
      //print('Controller ' + (currentController - 1).toString() + ': Disposed');
      _videoPlayerController[currentController - 1].dispose();
    }
    //print('Controller ' + (currentController).toString() + ': Disposed');
    _videoPlayerController[currentController].dispose();
    super.dispose();
  }

  void _toggleFullScreen() {
    setState(() {
      _fabOpacity = 1.0 - _fabOpacity;
    });
  }

  void _loadVideo() async {
    _checkOtherVideos();
    //print('Controller ' + (currentController).toString() + ': Added');
    _videoPlayerController
        .add(VideoPlayerController.file(File(videoPaths[currentIndex])));
    await _videoPlayerController[currentController].initialize();

    setState(() {
      aspectRatio = _videoPlayerController[currentController].value.aspectRatio;
      videoLength = _videoPlayerController[currentController].value.duration;
      _videoPlayerController[currentController]
        ..play()
        ..addListener(listener);
    });
  }

  void _checkOtherVideos() {
    //print(currentIndex.toString());
    //print(videoPaths.length);
    if (currentIndex == 0) {
      setState(() {
        isTherePrev = false;
      });
    } else if (!isTherePrev) {
      isTherePrev = true;
    }
    if (currentIndex == (videoPaths.length - 1)) {
      //print('object');
      //print(currentIndex.toString());
      //print(videoPaths.length);
      setState(() {
        isThereNext = false;
      });
    } else if (!isThereNext) {
      setState(() {
        isThereNext = true;
      });
    }
  }

  void _playPause() {
    if (videoPlay) {
      _videoPlayerController[currentController].pause();
    } else {
      _videoPlayerController[currentController].play();
    }
    setState(() {
      videoPlay = !videoPlay;
    });
  }

  void _goNext() async {
    if (isThereNext && !nextLoading) {
      nextLoading = true;

      if (File(videoPaths[currentIndex + 1]).existsSync()) {
        //print('Controller ' + (currentController + 1).toString() + ': Added');
        _videoPlayerController.add(
            VideoPlayerController.file(File(videoPaths[currentIndex + 1])));
        await _videoPlayerController[currentController + 1].initialize();

        setState(() {
          aspectRatio =
              _videoPlayerController[currentController + 1].value.aspectRatio;
          videoLength =
              _videoPlayerController[currentController + 1].value.duration;
          currentIndex++;
          currentController++;
          _videoPlayerController[currentController]
            ..play()
            ..addListener(listener);
          videoPlay = true;
        });

        await _videoPlayerController[currentController - 1].pause();
        _videoPlayerController[currentController - 1].removeListener(listener);
        if (currentController > 1) {
          //print('Controller ' + (currentController - 2).toString() + ': Disposed');
          _videoPlayerController[currentController - 2].dispose();
        }
        _checkOtherVideos();
        nextLoading = false;
      } else {
        Navigator.of(context).pop();
      }
    }
  }

  void _goPrevious() async {
    if (isTherePrev && !previousLoading) {
      previousLoading = true;

      if (File(videoPaths[currentIndex - 1]).existsSync()) {
        //print('Controller ' + (currentController + 1).toString() + ': Added');
        _videoPlayerController.add(
            VideoPlayerController.file(File(videoPaths[currentIndex - 1])));
        await _videoPlayerController[currentController + 1].initialize();

        setState(() {
          aspectRatio =
              _videoPlayerController[currentController + 1].value.aspectRatio;
          videoLength =
              _videoPlayerController[currentController + 1].value.duration;
          currentIndex--;
          currentController++;
          _videoPlayerController[currentController]
            ..play()
            ..addListener(listener);
          videoPlay = true;
        });

        await _videoPlayerController[currentController - 1].pause();
        _videoPlayerController[currentController - 1].removeListener(listener);
        if (currentController > 1) {
          //print('Controller ' + (currentController - 2).toString() + ': Disposed');
          _videoPlayerController[currentController - 2].dispose();
        }
        _checkOtherVideos();
        previousLoading = false;
      } else {
        Navigator.of(context).pop();
      }
    }
  }

  void seekTo(double value) {
    if (!previousLoading && !nextLoading) {
      final position = Duration(seconds: value.toInt());
      _videoPlayerController[currentController].seekTo(position);
    }
  }

  void listener() {
    if (_videoPlayerController[currentController].value.position ==
        videoLength) {
      if (videoPlay) {
        if (isThereNext) {
          _goNext();
        } else {
          Navigator.of(context).pop();
        }
      }
    }
    if (_fabOpacity != 1.0) setState(() {}); //Set state when neccessary
  }

  Widget controlButtons(BuildContext context) {
    if (_videoPlayerController[currentController].value != null) {
      currrentPosition =
          _videoPlayerController[currentController].value.position.inSeconds;
    }
    final displayWidth = MediaQuery.of(context).size.width;
    return Positioned(
      bottom: 0,
      child: AnimatedOpacity(
        opacity: 1.0 - _fabOpacity,
        duration: const Duration(milliseconds: 300),
        child: IgnorePointer(
          ignoring: _fabOpacity == 1.0,
          child: Material(
            color: Colors.black87,
            child: Container(
              width: displayWidth,
              child: Column(
                children: <Widget>[
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      const SizedBox(width: 10),
                      Text(
                        currrentPosition < 10
                            ? '0:0' + currrentPosition.toString()
                            : '0:' + currrentPosition.toString(),
                        style: TextStyle(color: Colors.white),
                      ),
                      Container(
                        width: displayWidth * 0.8,
                        child: SliderTheme(
                          data: SliderThemeData(
                            trackHeight: 10.0,
                            thumbShape: SliderComponentShape.noThumb,
                          ),
                          child: Slider(
                            min: 0.0,
                            value: currrentPosition.toDouble(),
                            max: videoLength.inSeconds.toDouble(),
                            onChanged: (e) => seekTo(e),
                            activeColor: Colors.white,
                            inactiveColor: Colors.white38,
                          ),
                        ),
                      ),
                      Text(
                        videoLength.inSeconds < 10
                            ? '0:0' + videoLength.inSeconds.toString()
                            : '0:' + videoLength.inSeconds.toString(),
                        style: TextStyle(color: Colors.white),
                      ),
                      const SizedBox(width: 10),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Container(
                    width: displayWidth * 0.8,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        IconButton(
                          iconSize: 42,
                          icon: Icon(Icons.skip_previous,
                              color:
                                  isTherePrev ? Colors.white : Colors.white38),
                          onPressed: _goPrevious,
                        ),
                        IconButton(
                          iconSize: 42,
                          icon: Icon(
                              !videoPlay ? Icons.play_arrow : Icons.pause,
                              color: Colors.white),
                          onPressed: _playPause,
                        ),
                        IconButton(
                          iconSize: 42,
                          icon: Icon(Icons.skip_next,
                              color:
                                  isThereNext ? Colors.white : Colors.white38),
                          onPressed: _goNext,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        backgroundColor: Colors.black,
        body: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            GestureDetector(
                onTap: _toggleFullScreen,
                child: Center(
                  child: AspectRatio(
                      aspectRatio: aspectRatio,
                      child: VideoPlayer(
                          _videoPlayerController[currentController])),
                )),
            controlButtons(context),
          ],
        ),
        floatingActionButton: AnimatedOpacity(
            opacity: _fabOpacity,
            duration: const Duration(milliseconds: 300),
            child: FunctionButtons(
              scaffoldKey: _scaffoldKey,
              snackBar: snackBar,
              isImage: false,
              filePath: videoPaths[currentIndex],
            )));
  }
}
