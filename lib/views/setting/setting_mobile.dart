part of setting_view;

class _SettingMobile extends StatefulWidget {
  final SettingViewModel viewModel;

  _SettingMobile(this.viewModel);

  @override
  __SettingMobileState createState() => __SettingMobileState(viewModel);
}

class __SettingMobileState extends State<_SettingMobile> {
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
              onTap: () async {
                setState(() {
                  fingerprint = !fingerprint;
                });
                if (fingerprint) {
                  await _checkBiometrics();
                  debugPrint('can local auth -> $_canCheckBiometrics');
                  if (_canCheckBiometrics) {
                    _authenticate();
                  }
                }
              },
              title: Text('Use Fingerprint authentication'),
              trailing: Switch(
                value: fingerprint,
                onChanged: (bool value) async {
                  fingerprint = value;
                  if (fingerprint) {
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
              onTap: () async {
                setState(() {
                  _keyboardAction = !_keyboardAction;
                });
              },
              title: Text('Use Keyboard action extension'),
              trailing: Switch(
                value: _keyboardAction,
                onChanged: (bool value) async {
                  setState(() {
                    _keyboardAction = value;
                  });
                },
              ),
            ),
            ListTile(),
          ],
        ),
      ),
    );
  }
}
