import 'dart:io';
import 'package:flutter/material.dart';
import 'package:sam_status_saver/screens/contentViewScreens/Imagecontent.dart';
import 'package:sam_status_saver/widgets/pageTransition.dart';
import 'package:sam_status_saver/widgets/permRequester.dart';

class StatusImages extends StatelessWidget {
  final bool readEnabled;
  final bool isScanningBegan;
  final List<String> imagePaths;
  final ContentCallBack getContentCallBack;

  const StatusImages(
      {Key key,
      @required this.imagePaths,
      @required this.readEnabled,
      @required this.isScanningBegan,
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
              const Text('Keep calm.\nGrabbing them pics',
                  textAlign: TextAlign.center,
                  textScaleFactor: 1.2,
                  style: TextStyle(color: Colors.white)),
            ]);
      }
      if (imagePaths.isEmpty) {
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
                  'Hey it seems you dont have any status pictues yet.\n\n Once you view a few come back and see them here',
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
            itemCount: imagePaths.length,
            itemBuilder: (BuildContext context, int index) {
              return Padding(
                padding: const EdgeInsets.all(1.0),
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(pageRouter(ImageContentView(
                            imagePaths: imagePaths, currentIndex: index)));
                  },
                  child: Image.file(
                    File(imagePaths[index]),
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
