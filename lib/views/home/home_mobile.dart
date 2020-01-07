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
    debugPrint(viewModel.items.length.toString());
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
    return Scaffold(
      resizeToAvoidBottomPadding: true,
      appBar: _keyboardVisible ? null : buildAppBar(),
      drawer: Drawer(
        child: ListView(
          padding: const EdgeInsets.all(0.0),
          children: buildNoteList(),
        ),
      ),
      body: DoubleBackToCloseApp(
        snackBar: const SnackBar(
          content: Text('Tap back again to leave'),
        ),
        child: SafeArea(
          child: Center(
            child: Stack(
              fit: StackFit.expand,
              children: <Widget>[
                viewModel.currentNote == null
                    ? Container()
                    : Container(
                        padding: EdgeInsets.all(8.0),
                        child: Column(
                          children: <Widget>[
                            Container(
                              child: Text(
                                viewModel.currentNote.fileName,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Form(
                                key: _formKey,
                                child: TextField(
                                  controller: noteController,
                                  focusNode: noteFocusNode,
                                  cursorColor: Colors.black,
                                  style: TextStyle(fontFamily: 'Monospace'),
                                  decoration: InputDecoration(
                                    hintText: "Insert your message",
                                    border: InputBorder.none,
                                  ),
                                  scrollPadding: EdgeInsets.all(20.0),
                                  keyboardType: TextInputType.multiline,
                                  maxLines: 99999,
                                  autofocus: false,
                                  onChanged: (String value) {
                                    if (!_fileOpening) {
                                      _onNoteChanged(value: value);
                                    }
                                  },
                                  onEditingComplete: () {},
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                _keyboardVisible
                    ? BottomStickyActionBar(
                        children: <Widget>[
                          BottomStickyActionItem(
                            child: Icon(
                              FontAwesomeIcons.bold,
                              size: 16,
                            ),
                            callback: () => addCharacterAndMoveCaret(
                              character: '****',
                              offset: 2,
                            ),
                          ),
                          BottomStickyActionItem(
                            child: Icon(
                              FontAwesomeIcons.italic,
                              size: 16,
                            ),
                            callback: () => addCharacterAndMoveCaret(
                              character: '**',
                              offset: 1,
                            ),
                          ),
                          BottomStickyActionItem(
                            child: Icon(
                              FontAwesomeIcons.strikethrough,
                              size: 16,
                            ),
                            callback: () => addCharacterAndMoveCaret(
                              character: '~~',
                              offset: 1,
                            ),
                          ),
                          BottomStickyActionItem(
                            child: Icon(
                              FontAwesomeIcons.quoteLeft,
                              size: 16,
                            ),
                            callback: () => addCharacterAndMoveCaret(
                              character: '> ',
                            ),
                          ),
                          BottomStickyActionItem(
                            child: Icon(
                              FontAwesomeIcons.hashtag,
                              size: 16,
                            ),
                            callback: () =>
                                addCharacterAndMoveCaret(character: '#'),
                          ),
                          BottomStickyActionItem(
                            child: Icon(
                              FontAwesomeIcons.listUl,
                              size: 16,
                            ),
                            callback: () =>
                                addCharacterAndMoveCaret(character: '- '),
                          ),
                          BottomStickyActionItem(
                            child: Icon(
                              FontAwesomeIcons.listOl,
                              size: 16,
                            ),
                            callback: () =>
                                addCharacterAndMoveCaret(character: '1. '),
                          ),
                          BottomStickyActionItem(
                            child: Icon(
                              FontAwesomeIcons.checkSquare,
                              size: 16,
                            ),
                            callback: () =>
                                addCharacterAndMoveCaret(character: '- [ ] '),
                          ),
                        ],
                      )
                    : Container()
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: _keyboardVisible
          ? null
          : FloatingActionButton(
              child: Icon(Icons.accessibility_new),
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
            ),
    );
  }

  List<Widget> buildNoteList() {
    List<Widget> drawerList = [];
    DrawerHeader header = DrawerHeader(
      child: Text('Drawer Header', style: TextStyle(color: Colors.grey)),
      decoration: BoxDecoration(
        color: Colors.black,
      ),
    );
    drawerList.add(header);
    drawerList += (viewModel.items.map((note) {
      return ListTile(
        title: Text(
          note.fileName,
          overflow: TextOverflow.ellipsis,
        ),
        onTap: () {
          _openNote(note);
          Navigator.of(context).pop();
        },
      );
    }).toList());
    return drawerList;
  }

  void _openNote(Note note) {
    _fileOpening = true;
    viewModel.currentNote = note;
    noteController.text = viewModel.currentNote.content;
    _fileOpening = false;
    _log.d('#buildNoteList -> set current note -> ${viewModel.currentNote}');
  }

  AppBar buildAppBar() {
    return AppBar(
      title: GestureDetector(
        onTap: () {},
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Text('NextNote'),
            SizedBox(width: 4.0),
            Icon(
              FontAwesomeIcons.chevronDown,
              size: 16,
            ),
          ],
        ),
      ),
      backgroundColor: Colors.black,
      actions: <Widget>[
        IconButton(
          icon: Icon(FontAwesomeIcons.markdown),
          onPressed: () {},
        ),
        IconButton(
          icon: Icon(FontAwesomeIcons.glasses),
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

  void addCharacterAndMoveCaret({String character, int offset = 0}) {
    int curSelectionStart = noteController.selection.start;
    int curSelectionEnd = noteController.selection.end;
    int curTextLength = noteController.text.length;
    String midText = '';
    int position = 0;

    String leftText = noteController.text.substring(0, curSelectionStart);
    String selectionWord =
        noteController.text.substring(curSelectionStart, curSelectionEnd);
    String rightText =
        noteController.text.substring(curSelectionEnd, curTextLength);

    if (offset > 0) {
      midText = character.substring(0, offset) +
          selectionWord +
          character.substring(offset, character.length);
      position = curSelectionStart + selectionWord.length + offset;
    } else {
      midText = character;
      position = curSelectionStart + midText.length;
    }
    String text = leftText + midText + rightText;
    TextSelection selection = TextSelection.fromPosition(
      TextPosition(offset: position),
    );
    noteController.value = TextEditingValue(
      text: text,
      selection: selection,
    );
  }

  String _nowString() {
    DateTime now = DateTime.now();
    List<String> format = [yyyy, '-', mm, '-', dd, ' ', HH, ':', nn, ' ', am];
    String nowString = formatDate(now, format);
    return nowString;
  }
}
