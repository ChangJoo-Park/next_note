part of setting_view;

class _SettingMobile extends StatefulWidget {
  final SettingViewModel viewModel;
  _SettingMobile(this.viewModel);

  @override
  __SettingMobileState createState() => __SettingMobileState(viewModel);
}

class __SettingMobileState extends State<_SettingMobile> {
  Logger _log = getLogger('_SettingMobile');
  final SettingViewModel viewModel;
  bool fingerprint = false;
  final LocalAuthentication auth = LocalAuthentication();
  bool _canCheckBiometrics;
  List<BiometricType> _availableBiometrics;
  String _authorized = 'Not Authorized';
  bool _isAuthenticating = false;
  bool _keyboardAction = false;

  Future<void> _checkBiometrics() async {
    bool canCheckBiometrics;
    try {
      canCheckBiometrics = await auth.canCheckBiometrics;
    } on PlatformException catch (e) {
      print(e);
    }
    if (!mounted) return;

    setState(() {
      _canCheckBiometrics = canCheckBiometrics;
    });
  }

  Future<void> _getAvailableBiometrics() async {
    List<BiometricType> availableBiometrics;
    try {
      availableBiometrics = await auth.getAvailableBiometrics();
    } on PlatformException catch (e) {
      print(e);
    }
    if (!mounted) return;

    setState(() {
      _availableBiometrics = availableBiometrics;
    });
  }

  Future<void> _authenticate() async {
    bool authenticated = false;
    try {
      setState(() {
        _isAuthenticating = true;
        _authorized = 'Authenticating';
      });
      authenticated = await auth.authenticateWithBiometrics(
        localizedReason: 'Scan your fingerprint to authenticate',
        useErrorDialogs: true,
        stickyAuth: true,
      );
      setState(() {
        _isAuthenticating = false;
        _authorized = 'Authenticating';
      });
    } on PlatformException catch (e) {
      print(e);
    }
    if (!mounted) return;

    final String message = authenticated ? 'Authorized' : 'Not Authorized';
    setState(() {
      _authorized = message;
    });
  }

  void _cancelAuthentication() {
    auth.stopAuthentication();
  }

  __SettingMobileState(this.viewModel);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text('Setting'),
      ),
      body: Container(
        child: Column(
          children: <Widget>[
            ListTile(
              title: Text('Use Fingerprint authentication'),
              trailing: Switch(
                value: viewModel.useAuthentication,
                onChanged: (bool value) async {
                  viewModel.useAuthentication = value;
                  if (value) {
                    await _checkBiometrics();
                    debugPrint('can local auth -> $_canCheckBiometrics');
                    if (_canCheckBiometrics) {
                      _authenticate();
                    }
                  }
                },
              ),
            ),
            ListTile(
              title: Text('Use Keyboard action extension'),
              trailing: Switch(
                value: viewModel.useKeyboardAction,
                onChanged: (bool value) async {
                  viewModel.useKeyboardAction = value;
                },
              ),
            ),
            ListTile(
              title: Text('Select Theme'),
              trailing: Text(''),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return SimpleDialog(
                      title: Text('Choose Theme'),
                      children: <Widget>[
                        SimpleDialogOption(
                          child: Text('Light'),
                          onPressed: () {
                            MyThemes.changeTheme(context, MyThemeKeys.LIGHT);
                            viewModel.theme =
                                MyThemes.getThemeString(MyThemeKeys.LIGHT);
                            Navigator.of(context).pop();
                          },
                        ),
                        SimpleDialogOption(
                          child: Text('Blue'),
                          onPressed: () {
                            MyThemes.changeTheme(context, MyThemeKeys.BLUE);
                            viewModel.theme =
                                MyThemes.getThemeString(MyThemeKeys.BLUE);
                            Navigator.of(context).pop();
                          },
                        ),
                        SimpleDialogOption(
                          child: Text('Dark'),
                          onPressed: () {
                            MyThemes.changeTheme(context, MyThemeKeys.DARK);
                            viewModel.theme =
                                MyThemes.getThemeString(MyThemeKeys.DARK);
                            Navigator.of(context).pop();
                          },
                        ),
                        SimpleDialogOption(
                          child: Text('Darker'),
                          onPressed: () {
                            MyThemes.changeTheme(context, MyThemeKeys.DARKER);
                            viewModel.theme =
                                MyThemes.getThemeString(MyThemeKeys.DARKER);
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
