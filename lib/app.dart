import 'dart:io';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import 'package:sam_status_saver/assets/customColor.dart';
import 'package:sam_status_saver/constants/paths.dart';
import 'package:sam_status_saver/constants/strings.dart';
import 'package:sam_status_saver/providers/providers.dart';
import 'package:sam_status_saver/screens/homeScreen/home.dart';

class App extends StatelessWidget {
  const App({Key key}) : super(key: key);

  requestWritePermission(context) async {
    //Check permission status
    PermissionStatus permissionStatus = await PermissionHandler()
        .checkPermissionStatus(PermissionGroup.storage);

    if (permissionStatus.value == 2) {
      //If permission present set provider
      Provider.of<PermissionProvider>(context).setNewPermission();
    } else {
      //Request permmission
      Map<PermissionGroup, PermissionStatus> permissions =
          await PermissionHandler()
              .requestPermissions([PermissionGroup.storage]);

      if (permissions.values.first.value == 2) {
        Provider.of<PermissionProvider>(context).setNewPermission();
      }
    }
  }

  appInitializer(BuildContext context) async {
    bool isExist = Directory(appDirectoryPath).existsSync();
    if (isExist) {
      isExist = Directory(appDirectoryVideoPath).existsSync();
      if (!isExist) {
        Directory(appDirectoryVideoPath).createSync();
      }
      isExist = Directory(appDirectoryImagePath).existsSync();
      if (!isExist) {
        Directory(appDirectoryImagePath).createSync();
      }
    } else {
      Directory(appDirectoryPath).createSync();
      Directory(appDirectoryVideoPath).createSync();
      Directory(appDirectoryImagePath).createSync();
    }
    Provider.of<AppDirectoryState>(context).setDirectoryState();

    //=============================================================================
    final statusPaths = Provider.of<StatusDirectoryPath>(context);
    //Check which status folder exists
    isExist = Directory(statusPathStandard).existsSync();
    if (isExist) {
      statusPaths.addStatusPath(statusPathStandard);
    }

    isExist = Directory(statusPathBusiness).existsSync();
    if (isExist) {
      statusPaths.addStatusPath(statusPathBusiness);
    }

    if (statusPaths.statusPathsAvailable.isNotEmpty) {
      final path = await Provider.of<StatusDirectoryFavourite>(context)
          .getFavouritePath();
      if (path == '') {
        Provider.of<StatusDirectoryFavourite>(context)
            .setFavouritePath(statusPaths.statusPathsAvailable[0]);
      } else {
        bool pathExist = false;
        for (var pathValue in statusPaths.statusPathsAvailable) {
          if (pathValue == path) {
            pathExist = true;
          }
        }
        if (!pathExist) {
          Provider.of<StatusDirectoryFavourite>(context)
              .setFavouritePath(statusPaths.statusPathsAvailable[0]);
        }
      }

      Provider.of<StatusDirectoryState>(context).setDirectoryState();
      Provider.of<RefreshControl>(context).setRefreshState(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    //Get theme
    final themeProvider = Provider.of<DarkThemeState>(context);

    //Do we refresh
    if (Provider.of<RefreshControl>(context).refresh) {
      if (!Provider.of<PermissionProvider>(context).readEnabled) {
        //If we dont have permission to read get permissions
        requestWritePermission(context);
      } else if (Provider.of<PermissionProvider>(context).readEnabled) {
        //if we have them initialize app.
        appInitializer(context);
      }
    }

    final readEnabled = Provider.of<PermissionProvider>(context).readEnabled;
    final isWhatsAppInstalled =
        Provider.of<StatusDirectoryState>(context).directoryExists;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: appTitle,
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        buttonColor: Colors.black54,
      ),
      theme: ThemeData(
          primarySwatch: colorCustom,
          accentColor: colorCustom,
          brightness: themeProvider.darkThemeState
              ? Brightness.dark
              : Brightness.light),
      themeMode:
          themeProvider.darkThemeState ? ThemeMode.dark : ThemeMode.light,
      home: HomeScreen(
        isReadEnabled: readEnabled && isWhatsAppInstalled,
      ),
    );
  }
}
