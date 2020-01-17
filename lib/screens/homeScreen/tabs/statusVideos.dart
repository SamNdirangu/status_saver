import 'dart:io';
import 'package:flutter/material.dart';
import 'package:sam_status_saver/screens/contentViewScreens/videoContent.dart';
import 'package:sam_status_saver/widgets/pageTransition.dart';
import 'package:sam_status_saver/widgets/permRequester.dart';

class StatusVideos extends StatelessWidget {
  final bool readEnabled;
  final bool isScanningBegan;
  final List<String> videoPaths;
  final List<String> thumbnailPaths;
  final ContentCallBack getContentCallBack;

  const StatusVideos(
      {Key key,
      @required this.readEnabled,
      @required this.isScanningBegan,
      @required this.videoPaths,
      @required this.thumbnailPaths,
      @required this.getContentCallBack})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (readEnabled) {
      if (!isScanningBegan) {
        return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const CircularProgressIndicator(),
              const SizedBox(
                height: 30,
              ),
              const Text('Keep calm.\nGrabbing them videos',
                  textAlign: TextAlign.center,
                  textScaleFactor: 1.2,
                  style: TextStyle(color: Colors.white)),
            ]);
      }
      if (thumbnailPaths.isEmpty) {
        return Center(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Icon(
                  Icons.sentiment_satisfied,
                  size: 56,
                  color: Colors.white,
                ),
                const SizedBox(height: 10),
                const Text(
                  'Hey it seems you dont have any status videos yet.\n\n Once you view a few come back and see them here',
                  style: TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 20),
                RaisedButton.icon(
                  icon: Icon(Icons.refresh, color: Colors.black87),
                  label: Text('Refresh'),
                  textColor: Colors.black87,
                  color: Colors.white,
                  onPressed: getContentCallBack,
                )
              ]),
        );
      }

      //Resize accordingly
      int gridCount = 3;
      final width = MediaQuery.of(context).size.width;
      if (width > 548) {
        gridCount = 4;
      } else if (width < 275) {
        gridCount = 2;
      }

      return RefreshIndicator(
          onRefresh: getContentCallBack,
          child: GridView.builder(
            key: PageStorageKey(key),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: gridCount),
            itemCount: thumbnailPaths.length,
            itemBuilder: (BuildContext context, int index) {
              return Padding(
                padding: const EdgeInsets.all(1.0),
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(pageRouter(VideoContentView(
                            videoPaths: videoPaths, currentIndex: index)));
                  },
                  child: Image.file(
                    File(thumbnailPaths[index]),
                    fit: BoxFit.cover,
                  ),
                ),
              );
            },
          ));
    } else {
      return PermRequester();
    }
  }
}

typedef ContentCallBack = Future<void> Function();
