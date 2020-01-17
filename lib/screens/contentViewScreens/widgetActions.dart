import 'dart:io';
import 'package:path/path.dart';
import 'package:flutter/material.dart';
import 'package:sam_status_saver/widgets/unicorndial.dart';
import 'package:sams_flutter_share/sams_flutter_share.dart';

import 'package:sam_status_saver/constants/paths.dart';
import 'package:sam_status_saver/assets/customColor.dart';

class ShareActions {
  saveFile(String filePath, bool isImage) {
    String fileName = basenameWithoutExtension(filePath);
    if (isImage) {
      File(filePath).copy(appDirectoryImagePath + '/' + fileName + '.jpg');
    } else {
      File(filePath).copy(appDirectoryVideoPath + '/' + fileName + '.mp4');
    }
  }

  shareFile(String filePath, bool repost, bool isImage) async {
    String memeType = 'video/mp4';
    String repostTo = 'com.whatsapp';

    if (isImage) memeType = 'image/jpg';
    if (!repost) repostTo = '';
    try {
      final fileBytes = File(filePath).readAsBytesSync();
      await SamsFlutterShare.shareFile(fileBytes, basename(filePath), memeType,
          shareTitle: 'Share with', appToShare: repostTo);
    } catch (e) {
      //print(e);
    }
  }
}

class FunctionButtons extends StatelessWidget {
  const FunctionButtons({
    Key key,
    @required GlobalKey<ScaffoldState> scaffoldKey,
    @required this.snackBar,
    @required this.filePath,
    @required this.isImage,
  })  : _scaffoldKey = scaffoldKey,
        super(key: key);

  final bool isImage;
  final GlobalKey<ScaffoldState> _scaffoldKey;
  final SnackBar snackBar;
  final String filePath;

  @override
  Widget build(BuildContext context) {
    return UnicornDialer(
      animationDuration: 200,
      parentHeroTag: 'mainFab',
      hasBackground: false,
      hasNotch: false,
      parentButtonBackground: colorCustom,
      parentButton: const Icon(
        Icons.add,
        color: Colors.white,
      ),
      childButtons: [
        UnicornButton(
          hasLabel: false,
          currentButton: FloatingActionButton(
            backgroundColor: colorCustom,
            heroTag: 'saveFab',
            onPressed: () {
              ShareActions().saveFile(filePath, isImage);
              _scaffoldKey.currentState.showSnackBar(snackBar);
            },
            tooltip: 'Save',
            mini: true,
            child: const Icon(
              Icons.save,
              color: Colors.white,
            ),
          ),
        ),
        UnicornButton(
          hasLabel: false,
          currentButton: FloatingActionButton(
            backgroundColor: colorCustom,
            heroTag: 'repostFab',
            onPressed: () {
              ShareActions().shareFile(filePath, true, isImage);
            },
            tooltip: 'repost',
            mini: true,
            child: const Icon(
              Icons.reply,
              color: Colors.white,
            ),
          ),
        ),
        UnicornButton(
          hasLabel: false,
          currentButton: FloatingActionButton(
            backgroundColor: colorCustom,
            heroTag: 'shareFab',
            onPressed: () {
              ShareActions().shareFile(filePath, false, isImage);
            },
            tooltip: 'Share',
            mini: true,
            child: const Icon(
              Icons.share,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}
