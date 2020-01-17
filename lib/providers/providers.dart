import 'package:flutter/Material.dart';
import 'package:provider/provider.dart';
import 'package:sam_status_saver/constants/paths.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../app.dart';

class Providers extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<DarkThemeState>.value(
          value: DarkThemeState(),
        ),
        ChangeNotifierProvider<PermissionProvider>.value(
          value: PermissionProvider(),
        ),
        ChangeNotifierProvider<AppDirectoryState>.value(
          value: AppDirectoryState(),
        ),
        ChangeNotifierProvider<StatusDirectoryState>.value(
          value: StatusDirectoryState(),
        ),
        ChangeNotifierProvider<StatusDirectoryPath>.value(
          value: StatusDirectoryPath(),
        ),
        ChangeNotifierProvider<StatusDirectoryState>.value(
          value: StatusDirectoryState(),
        ),
        ChangeNotifierProvider<StatusDirectoryFavourite>.value(
          value: StatusDirectoryFavourite(),
        ),
        ChangeNotifierProvider<RefreshControl>.value(
          value: RefreshControl(),
        ),
      ],
      child: App(),
    );
  }
}

//Dark theme Provider
class DarkThemeState with ChangeNotifier {
  bool _darktheme = false;
  get darkThemeState => _darktheme;

  void setDarkTheme(newDarkTheme) {
    _darktheme = newDarkTheme;
    notifyListeners();
  }
}

///Permission Provider
class PermissionProvider with ChangeNotifier {
  bool _readEnable = false;
  get readEnabled => _readEnable;

  void setNewPermission() {
    _readEnable = true;
    notifyListeners();
  }
}

//App directory Provider
class AppDirectoryState with ChangeNotifier {
  bool _directoryExists = false;
  get directoryExists => _directoryExists;

  void setDirectoryState() {
    _directoryExists = true;
  }
}
///Do we have a status directory
class StatusDirectoryState with ChangeNotifier {
  bool _directoryExists = false;
  get directoryExists => _directoryExists;

  void setDirectoryState() {
    _directoryExists = true;
  }
}

class StatusDirectoryPath with ChangeNotifier {
  List<String> _statusPathsAvailable = List();

  get statusPathsAvailable => _statusPathsAvailable;

  addStatusPath(path) {
    _statusPathsAvailable.add(path);
  }
}

class StatusDirectoryFavourite with ChangeNotifier {
  String _statusPathFavourite = statusPathStandard;

  get statusPathsFavourite => _statusPathFavourite;

  getFavouritePath() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString('favPath');
    if (value != null) {
      _statusPathFavourite = value;
      return _statusPathFavourite;
    }
    return '';
  }

  setFavouritePath(path) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('favPath', path);
    _statusPathFavourite = path;
    notifyListeners();
  }
}

class RefreshControl with ChangeNotifier {
  bool _refresh = true;
  get refresh => _refresh;

  void setRefreshState(state) {
    _refresh = state;
    notifyListeners();
  }
}
