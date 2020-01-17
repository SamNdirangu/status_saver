import 'dart:io';
import 'dart:ui';

import 'package:path/path.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

import 'package:sam_status_saver/constants/paths.dart';
import 'package:sam_status_saver/constants/strings.dart';
import 'package:sam_status_saver/widgets/backdrop.dart';
import 'package:sam_status_saver/providers/providers.dart';
import 'package:sam_status_saver/views/backdropPanel.dart';
import 'package:sam_status_saver/screens/homeScreen/tabs/statusImages.dart';
import 'package:sam_status_saver/screens/homeScreen/tabs/statusVideos.dart';

class HomeScreenContent extends StatefulWidget {
  final TabController tabController;
  final bool isReadEnabled;

  HomeScreenContent(
      {Key key, @required this.tabController, @required this.isReadEnabled})
      : super(key: key);

  @override
  _HomeScreenContentState createState() => _HomeScreenContentState();
}

class _HomeScreenContentState extends State<HomeScreenContent>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  ///The function is called whrn the app lifestyle changes
  ///This allows for the calling of get content if one returns to the app
  ///automatically refreshing the content displayed
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    //print('called');
    if (state == AppLifecycleState.resumed) {
      //print('refreshed');
      if (!isContentLoading) {
        //print('lifecycle: content called');
        getContent();
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

//-----------------------------------------------------------------------------------
  Key imageTab = UniqueKey();
  Key videoTab = UniqueKey();

  bool isReadEnabled = false;
  //Image Preparation
  Directory statusDirectory; //To store our status directory

  List<FileSystemEntity>
      statusFiles; //List to store our files in the status folder
  List<FileSystemEntity>
      statusTempFiles; //List for all files in the temp folder

  List<String> imagePaths = List(); //List to store the image paths of pictures
  List<String> videoPaths = List(); //List to store the video paths of videos
  List<String> thumbnailPaths =
      List(); //List to store the paths of thumbanils of videos

  String appDirectoryTempPath; //String to hold the temp directory path
  String versionExt =
      ''; //To store the version whatsapp extension to distinguish between different versions

  bool loadGetter = true; //Whether to load getContent function automatically
  bool isScanningBegan = false; //To store the state of scanning progress.
  bool isContentLoading =
      false; //Store the state whether th getContent function is still running

  //Get out contnet
  Future<void> getContent() async {
    //print('content started');
    if (statusDirectory != null) {
      if (statusDirectory.existsSync()) {
        isContentLoading = true; //Store our content loading status

        if (!isReadEnabled) {
          setState(() {
            isReadEnabled = true;
          });
        }
        int _refreshCount = 0;
        bool _inTemp =
            false; //Store whhether a file is present in temp directory
        String _fileName; //Store file name without file extension
        String _fileNameExt; //store our file name with extension
        //Reset our lists
        thumbnailPaths = List();
        imagePaths = List();
        videoPaths = List();
        //Get our temp directory
        appDirectoryTempPath = (await getApplicationDocumentsDirectory()).path;
        //generate list of our status and temp directories
        statusFiles = statusDirectory.listSync(followLinks: false);
        statusTempFiles =
            Directory(appDirectoryTempPath).listSync(followLinks: false);

        //Sort newest to old files.
        statusFiles.sort((a, b) => File(b.path)
            .lastModifiedSync()
            .toString()
            .compareTo(File(a.path).lastModifiedSync().toString()));

        //Start looping through each of the files
        for (var file in statusFiles) {
          _fileName = versionExt + basenameWithoutExtension(file.path);
          //add the version textension to the name string.
          _fileNameExt = versionExt + basename(file.path);

          //Check if file is an image
          if (_fileNameExt.contains('.jpg')) {
            imagePaths.add(file.path);
          }

          //Check if file is a video
          if (_fileNameExt.contains('.mp4')) {
            final _thumbnailTempPath =
                appDirectoryTempPath + '/' + _fileName + '.webp';
            //Check if video thumbnail exists in temp directory
            _inTemp = false;
            for (var tempFile in statusTempFiles) {
              final tempFileName = basenameWithoutExtension(tempFile.path);
              if (_fileName == tempFileName) {
                _inTemp = true;
                break;
              }
            }
            //if file was not found in temp directory
            if (!_inTemp) {
              //Create a thumbanil of the video
              await VideoThumbnail.thumbnailFile(
                video: file.path,
                thumbnailPath: _thumbnailTempPath,
                imageFormat: ImageFormat.WEBP,
                quality: 3,
              );
              _refreshCount++;
            }
            videoPaths.add(file.path);
            thumbnailPaths.add(_thumbnailTempPath);
          }
          //Refresh so as not to keep user waiting
          if (_refreshCount > 1) {
            _refreshCount = 0;
            setState(() {
              isScanningBegan = true;
              imagePaths = imagePaths;
              videoPaths = videoPaths;
            });
          }
        }
        //print('content generated');
        setState(() {
          isScanningBegan = true;
          isContentLoading = false;
          imagePaths = imagePaths;
          videoPaths = videoPaths;
        });
        cleanUpGarbage();
      } else {
        setState(() {
          isContentLoading = false;
          isScanningBegan = true;
          isReadEnabled = false;
        });
      }
    }
  }

  //=======================Garbage Cleanup=======================================
  void cleanUpGarbage() async {
    bool _isDelete;
    String _thumbName;
    String _fileName;

    for (var file in statusTempFiles) {
      _isDelete = true;
      _fileName = basename(file.path);
      if (_fileName.contains(versionExt)) {
        //print(_fileName);
        //print('');
        //print('FileCheck: '+_fileName);
        for (var thumbnail in thumbnailPaths) {
          _thumbName = basename(thumbnail);
          //print(_thumbName);
          if (_fileName == _thumbName) {
            _isDelete = false;
            break;
          }
        }
        if (_isDelete) {
          //print('deleted: ' + _fileName);
          file.delete();
        }
      }
    }
  }
  //=======================Garbage Cleanup End=======================================

  //=======================Call Getters=======================================
  callGetter(statusPath) {
    statusDirectory = Directory(statusPath);
    if (statusPath == statusPathStandard) {
      versionExt = 'standard-';
    } else if (statusPath == statusPathGB) {
      versionExt = 'gb-';
    } else {
      versionExt = 'business-';
    }

    if (!isContentLoading) {
      setState(() {
        isScanningBegan = false;
      });
      //print('callGetter: content called');
      getContent();
    }
  }
  //=======================Call Getters=======================================

  @override
  Widget build(BuildContext context) {
    isReadEnabled = widget.isReadEnabled;
    if (widget.isReadEnabled) {
      final statusPath =
          Provider.of<StatusDirectoryFavourite>(context).statusPathsFavourite;

      if (loadGetter) {
        if (Directory(statusPath).existsSync()) {
          loadGetter = false;
          //print('caller triggered');
          callGetter(statusPath);
        }
      }

      if (statusPath != statusDirectory.path) {
        if (Directory(statusPath).existsSync()) {
          //print('caller triggered');
          callGetter(statusPath);
        }
      }
    }

    return TabBarView(
      controller: widget.tabController,
      children: <Widget>[
        StatusImages(
          key: imageTab,
          imagePaths: imagePaths,
          isScanningBegan: isScanningBegan,
          readEnabled: isReadEnabled,
          getContentCallBack: getContent,
        ),
        StatusVideos(
            key: videoTab,
            videoPaths: videoPaths,
            thumbnailPaths: thumbnailPaths,
            isScanningBegan: isScanningBegan,
            readEnabled: isReadEnabled,
            getContentCallBack: getContent),
      ],
    );
  }
}

class HomeScreen extends StatefulWidget {
  final bool isReadEnabled;
  const HomeScreen({Key key, @required this.isReadEnabled}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  TabController _tabController;
  AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _animationController = AnimationController(
        duration: Duration(milliseconds: 300), value: 1.0, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //print('homePrinted');
    return Backdrop(
        controller: _animationController,
        backTitle: const Text('More'),
        backLayer: BackdropPanel(),
        frontTitle: const Text(appTitle),
        frontLayer: Scaffold(
            appBar: PreferredSize(
              preferredSize: Size.fromHeight(kToolbarHeight),
              child: Material(
                color: Theme.of(context).primaryColor,
                child: TabBar(
                  controller: _tabController,
                  indicatorWeight: 3,
                  indicatorColor: Colors.white,
                  tabs: <Widget>[
                    const Tab(
                      text: 'Images',
                    ),
                    const Tab(text: 'Videos')
                  ],
                ),
              ),
            ),
            backgroundColor: Colors.black,
            body: HomeScreenContent(
              tabController: _tabController,
              isReadEnabled: widget.isReadEnabled,
            )));
  }
}
