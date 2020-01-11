import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../logger.dart';

class BaseViewModel extends ChangeNotifier {
  Logger _log = getLogger('BaseViewModel');

  SharedPreferences prefs;
  String _title;
  bool _busy;
  Logger log;
  bool _isDisposed = false;
  // Settings
  bool _useAuthentication;
  bool _useKeyboardAction;
  ThemeData _themeData;
  String _theme;

  BaseViewModel({
    bool busy = false,
    String title,
  })  : _busy = busy,
        _title = title {
    log = getLogger(title ?? this.runtimeType.toString());
  }

  bool get busy => this._busy;
  bool get isDisposed => this._isDisposed;
  String get title => _title ?? this.runtimeType.toString();

  set busy(bool busy) {
    log.i(
      'busy: '
      '$title is entering '
      '${busy ? 'busy' : 'free'} state',
    );
    this._busy = busy;
    notifyListeners();
  }

  get useAuthentication => this._useAuthentication;
  set useAuthentication(bool auth) {
    this._useAuthentication = auth;
    prefs.setBool('auth', auth);
    notifyListeners();
  }

  get useKeyboardAction => this._useKeyboardAction;
  set useKeyboardAction(bool use) {
    this._useKeyboardAction = use;
    prefs.setBool('keyboard-action', use);
    notifyListeners();
  }

  Future<bool> loadBaseSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    this.prefs = prefs;
    if (!this.prefs.containsKey('auth')) {
      await this.prefs.setBool('auth', false);
    }
    _useAuthentication = this.prefs.getBool('auth');
    if (!this.prefs.containsKey('keyboard-action')) {
      await this.prefs.setBool('keyboard-action', true);
    }
    _useKeyboardAction = this.prefs.getBool('keyboard-action');

    if (!this.prefs.containsKey('theme')) {
      await this.prefs.setString('theme', 'light');
    }
    _theme = this.prefs.getString('theme');
    return Future.value(true);
  }

  get themeData => _themeData;
  set themeData(ThemeData value) {
    _themeData = value;
    notifyListeners();
  }

  get theme => _theme;
  set theme(String value) {
    _theme = value;
    notifyListeners();
    prefs.setString('theme', value);
  }

  @override
  void notifyListeners() {
    if (!isDisposed) {
      super.notifyListeners();
    } else {
      log.w('notifyListeners: Notify listeners called after '
          '${title ?? this.runtimeType.toString()} has been disposed');
    }
  }

  @override
  void dispose() {
    log.i('dispose');
    _isDisposed = true;
    super.dispose();
  }
}
