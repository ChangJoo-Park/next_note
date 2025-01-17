part of home_view;

class _HomeMobile extends StatefulWidget {
  final HomeViewModel viewModel;
  _HomeMobile(this.viewModel);

  @override
  __HomeMobileState createState() => __HomeMobileState(viewModel: viewModel);
}

class __HomeMobileState extends State<_HomeMobile> {
  Logger _log = getLogger('_HomeMobileState');
  final _newNoteFormKey = GlobalKey<FormState>();
  final FocusNode titleFocusNode =
      FocusNode(debugLabel: 'TITLE_FOCUS_NODE', canRequestFocus: true);
  final TextEditingController titleController = TextEditingController();
  final FocusNode noteFocusNode =
      FocusNode(debugLabel: 'NOTE_FOCUS_NODE', canRequestFocus: true);
  final TextEditingController noteController = TextEditingController();

  String _newNoteName = '';
  bool _keyboardVisible = false;
  HomeViewModel viewModel;
  __HomeMobileState({this.viewModel});

  @protected
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: true,
      appBar: _keyboardVisible ? null : buildAppBar(),
      body: DoubleBackToCloseApp(
        snackBar: const SnackBar(
          content: Text('Tap back again to leave'),
        ),
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: () {
              viewModel.loadItems();
              return Future.value(true);
            },
            child: AutoAnimatedList(
              // Start animation after (default zero)
              delay: Duration(milliseconds: 300),
              // Show each item through
              showItemInterval: Duration(milliseconds: 100),
              // Animation duration
              showItemDuration: Duration(milliseconds: 300),
              itemCount: viewModel.sortByUpdatedItems.length,
              itemBuilder:
                  (BuildContext ctx, int index, Animation<double> animation) {
                Note note = viewModel.sortByUpdatedItems[index];
                return FadeTransition(
                  key: ValueKey('fade-transition-${note.filePath}'),
                  opacity: Tween<double>(
                    begin: 0,
                    end: 1,
                  ).animate(animation),
                  child: SlideTransition(
                    key: ValueKey('slide-transition-${note.filePath}'),
                    position: Tween<Offset>(
                      begin: Offset(0, -0.1),
                      end: Offset.zero,
                    ).animate(animation),
                    child: NoteListTile(
                      key: ValueKey(note.filePath),
                      note: note,
                      onTap: () {
                        _openNote(note);
                      },
                      onLongPress: () {
                        _openNoteDeleteDialog(context, note);
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        isExtended: true,
        elevation: 0,
        heroTag: 'fab',
        label: Text('New Note'),
        icon: Icon(Icons.add),
        onPressed: () {
          _openNewNoteModal(context);
        },
      ),
    );
  }

  Future _openNoteDeleteDialog(BuildContext context, Note note) {
    return showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: Text(note.fileName),
          actions: <Widget>[
            FlatButton(
              onPressed: () {
                viewModel.removeNote(note);
                Navigator.of(context).pop();
              },
              child: Text('DELETE'),
            ),
            FlatButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('CLOSE'),
            )
          ],
        );
      },
    );
  }

  void _openNewNoteModal(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('New Note'),
            content: Form(
              key: _newNoteFormKey,
              child: TextFormField(
                initialValue: '${_nowString()}.md',
                validator: (String value) {
                  if (value.isEmpty) {
                    return 'Please enter some text';
                  }
                  return null;
                },
                onSaved: (String value) {
                  setState(() {
                    _newNoteName = value;
                  });
                },
              ),
            ),
            actions: <Widget>[
              FlatButton(
                child: Text('취소'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              FlatButton(
                child: Text('만들기'),
                onPressed: () {
                  if (_newNoteFormKey.currentState.validate()) {
                    _newNoteFormKey.currentState.save();
                    viewModel.createNewNote(_newNoteName);
                  }
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }

  void _openNote(Note note) {
    viewModel.currentNote = note;
    Navigator.of(context)
        .push(
      MaterialPageRoute(
        builder: (BuildContext context) => NoteDetailView(
          note: viewModel.currentNote,
        ),
      ),
    )
        .then(
      (value) {
        viewModel.loadItems();
      },
    );
  }

  AppBar buildAppBar() {
    return AppBar(
      elevation: 0,
      title: Text('NextPage'),
      actions: <Widget>[
        _simplePopup(),
      ],
    );
  }

  void _openSettingView() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (BuildContext context) => SettingView(),
      ),
    );
  }

  String _nowString() {
    DateTime now = DateTime.now();
    List<String> format = [yyyy, '-', mm, '-', dd, ' ', HH, ':', nn];
    String nowString = formatDate(now, format);
    return nowString;
  }

  Widget _simplePopup() {
    return PopupMenuButton<int>(
      onSelected: (int selected) {
        switch (selected) {
          case 0:
            _openSettingView();
            break;
          case 1:
            _openAppStore();
            break;
          case 2:
            _openAboutDialog();
            break;
          default:
            break;
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 0,
          child: Text(optionItemLabel(OptionItem.SETTING)),
        ),
        PopupMenuItem(
          value: 1,
          child: Text(optionItemLabel(OptionItem.RATE_APP)),
        ),
        PopupMenuItem(
          value: 2,
          child: Text(optionItemLabel(OptionItem.ABOUT)),
        ),
      ],
    );
  }

  void _openAppStore() {
    _log.d('message');
    OpenAppstore.launch(
      androidAppId: "com.facebook.katana&hl=ko",
      iOSAppId: "284882215",
    );
  }

  void _openAboutDialog() {
    showAboutDialog(
      context: context,
      applicationIcon: Icon(FontAwesomeIcons.markdown),
      applicationName: 'NextPage',
      applicationVersion: '1.0.0',
      children: [
        Text('Thank you for use :)'),
      ],
      useRootNavigator: true,
    );
  }
}

enum OptionItem { SETTING, ABOUT, RATE_APP }

String optionItemLabel(OptionItem option) {
  String label = '';
  switch (option) {
    case OptionItem.SETTING:
      label = 'Settings';
      break;
    case OptionItem.ABOUT:
      label = 'About';
      break;
    case OptionItem.RATE_APP:
      label = 'Rate App';
      break;
    default:
      break;
  }
  return label;
}
