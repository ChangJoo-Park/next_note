part of home_view;

class _HomeMobile extends StatefulWidget {
  final HomeViewModel viewModel;
  _HomeMobile(this.viewModel);

  @override
  __HomeMobileState createState() => __HomeMobileState(viewModel: viewModel);
}

class __HomeMobileState extends State<_HomeMobile> {
  Logger _log = getLogger('_HomeMobileState');
  final _formKey = GlobalKey<FormState>();
  final _newNoteFormKey = GlobalKey<FormState>();
  final FocusNode titleFocusNode =
      FocusNode(debugLabel: 'TITLE_FOCUS_NODE', canRequestFocus: true);
  final TextEditingController titleController = TextEditingController();
  final FocusNode noteFocusNode =
      FocusNode(debugLabel: 'NOTE_FOCUS_NODE', canRequestFocus: true);
  final TextEditingController noteController = TextEditingController();

  String _newNoteName = '';
  bool _keyboardVisible = false;
  bool _fileOpening = false;
  Timer _debounce;
  int _listener;
  HomeViewModel viewModel;
  __HomeMobileState({this.viewModel});

  @protected
  void initState() {
    super.initState();

    _listener = KeyboardVisibilityNotification().addNewListener(
      onChange: _onKeyboardVisibility,
    );
  }

  @override
  void dispose() {
    if (_debounce != null) {
      _debounce.cancel();
      _debounce = null;
    }

    KeyboardVisibilityNotification().removeListener(_listener);

    super.dispose();
  }

  _onKeyboardVisibility(bool visible) {
    setState(() {
      this._keyboardVisible = visible;
    });
    if (!this._keyboardVisible) {
      _onNoteChanged();
    }
  }

  void _onNoteChanged({String value}) {
    if (viewModel.currentNote == null) {
      return;
    }
    if (_debounce?.isActive ?? false) _debounce.cancel();
    _debounce = Timer(const Duration(milliseconds: 1000), () async {
      viewModel.currentNote.content = noteController.text;
      await viewModel.updateNote(viewModel.currentNote);
      _log.d('#onNoteChanged -> updated');
    });
  }

  @override
  Widget build(BuildContext context) {
    var childButtons = List<UnicornButton>();

    childButtons.add(UnicornButton(
        currentButton: FloatingActionButton(
      heroTag: "train",
      backgroundColor: Colors.redAccent,
      mini: true,
      child: Icon(Icons.train),
      onPressed: () {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('새 노트'),
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
      },
    )));

    childButtons.add(UnicornButton(
        currentButton: FloatingActionButton(
            heroTag: "airplane",
            backgroundColor: Colors.greenAccent,
            mini: true,
            child: Icon(Icons.airplanemode_active))));

    childButtons.add(UnicornButton(
        currentButton: FloatingActionButton(
            heroTag: "directions",
            backgroundColor: Colors.blueAccent,
            mini: true,
            child: Icon(Icons.directions_car))));

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
              return Future.value(true);
            },
            child: ListView.builder(
              itemCount: viewModel.items.length,
              itemBuilder: (BuildContext ctx, int index) {
                return Hero(
                  tag: 'filename${viewModel.items[index].fileName}',
                  child: Material(
                    type: MaterialType.transparency,
                    child: ListTile(
                      title: Text(
                        viewModel.items[index].fileName,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        viewModel.items[index].modified.toString(),
                        style: TextStyle(color: Colors.black),
                      ),
                      onTap: () {
                        _openNote(viewModel.items[index]);
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
      floatingActionButton: UnicornDialer(
        backgroundColor: Colors.transparent,
        parentButtonBackground: Colors.black,
        orientation: UnicornOrientation.VERTICAL,
        parentButton: Icon(Icons.menu),
        childButtons: childButtons,
      ),
    );
  }

  void _openNote(Note note) {
    viewModel.currentNote = note;
    _log.d('current note');
    _log.d(viewModel.currentNote.content);
    _log.d(viewModel.currentNote.filePath);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (BuildContext context) => NoteDetailView(
          note: viewModel.currentNote,
        ),
      ),
    );
  }

  AppBar buildAppBar() {
    return AppBar(
      elevation: 0,
      title: Text('NextNote'),
      actions: <Widget>[
        IconButton(
          icon: Icon(FontAwesomeIcons.cog),
          onPressed: () {},
        )
      ],
    );
  }

  void _createNewNote() async {
    // titleController.text = '';
    // noteController.text = '';
    // await viewModel.createNewItem();
    // _setCurrentItemToController();
    // noteFocusNode.requestFocus();
  }

  void _setCurrentItemToController() {
    // titleController.text = viewModel.currentItem.title;
    // noteController.text = viewModel.currentItem.note;
  }

  String _nowString() {
    DateTime now = DateTime.now();
    List<String> format = [yyyy, '-', mm, '-', dd, ' ', HH, ':', nn, ' ', am];
    String nowString = formatDate(now, format);
    return nowString;
  }
}
