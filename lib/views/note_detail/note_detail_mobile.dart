part of note_detail_view;

class _NoteDetailMobile extends StatefulWidget {
  final NoteDetailViewModel viewModel;

  _NoteDetailMobile(this.viewModel);

  @override
  __NoteDetailMobileState createState() => __NoteDetailMobileState(viewModel);
}

class __NoteDetailMobileState extends State<_NoteDetailMobile>
    with WidgetsBindingObserver {
  final NoteDetailViewModel viewModel;
  final Logger _log = getLogger('_NoteDetailMobile');
  bool _keyboardVisible = false;
  final _formKey = GlobalKey<FormState>();
  int _listener;
  final FocusNode noteFocusNode =
      FocusNode(debugLabel: 'NOTE_FOCUS_NODE', canRequestFocus: true);
  final TextEditingController noteController = TextEditingController();
  Timer _debounce;
  AppLifecycleState _notification;

  __NoteDetailMobileState(this.viewModel);

  @override
  initState() {
    super.initState();
    timeago.setLocaleMessages('ko', timeago.KoMessages());

    WidgetsBinding.instance.addObserver(this);
    noteController.text = viewModel.currentNote.content;
    _listener = KeyboardVisibilityNotification().addNewListener(
      onChange: _onKeyboardVisibility,
    );
  }

  @override
  void dispose() {
    _cancelDebounce();
    KeyboardVisibilityNotification().removeListener(_listener);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    setState(() {
      _notification = state;
    });

    switch (_notification) {
      case AppLifecycleState.paused:
        _log.d('AppLifecycleState.paused');
        break;
      case AppLifecycleState.resumed:
        _log.d('AppLifecycleState.resumed');
        noteController.text = viewModel.currentNote.content;
        break;
      case AppLifecycleState.inactive:
        _log.d('AppLifecycleState.inactive');
        _cancelDebounce();
        _log.d('cancelDebounce');
        await _saveNote();
        _log.d('after save note');
        break;
      case AppLifecycleState.detached:
        _log.d('AppLifecycleState.detached');
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: true,
      floatingActionButton: _keyboardVisible
          ? Container()
          : FloatingActionButton(
              heroTag: 'fab',
              child: Icon(Icons.save),
              onPressed: () async {
                await _saveNote();
              },
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: WillPopScope(
        onWillPop: () async {
          _cancelDebounce();
          _log.d('Saved when pop');
          await _saveNote();
          return Future.value(true);
        },
        child: Stack(
          children: <Widget>[
            SafeArea(
              child: PageView(
                children: <Widget>[
                  Stack(children: [
                    Positioned(
                      bottom: 8.0,
                      left: 8.0,
                      child: Hero(
                        tag:
                            'note-subtitle-${widget.viewModel.currentNote.fileName}',
                        child: Material(
                          type: MaterialType.transparency,
                          child: Text(
                            formatDate(viewModel.currentNote.changed, [
                                  yyyy,
                                  '-',
                                  mm,
                                  '-',
                                  dd,
                                  ' ',
                                  HH,
                                  ':',
                                  nn
                                ]) +
                                ' 저장함 ',
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 4.0,
                      right: 2.0,
                      child: Hero(
                        tag: 'app-icon',
                        child: Material(
                          type: MaterialType.transparency,
                          child: IconButton(
                            icon: Icon(Icons.share),
                            onPressed: () {
                              Share.share(noteController.text);
                            },
                          ),
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(16.0),
                      child: Column(
                        children: <Widget>[
                          _buildFileName(),
                          _buildTextFieldWidget(),
                        ],
                      ),
                    ),
                  ]),
                  // Markdown(data: noteController.text),
                ],
              ),
            ),
            _buildBottomStickyActionBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildTextFieldWidget() {
    return ScrollConfiguration(
      behavior: NoGlowScrollBehavior(),
      child: Expanded(
        flex: 1,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 24.0),
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
                _onNoteChanged();
              },
              onEditingComplete: () {
                _log.d('onEditingComplete');
              },
            ),
          ),
        ),
      ),
    );
  }

  Container _buildFileName() {
    return Container(
      child: Hero(
        tag: 'note-title-${widget.viewModel.currentNote.fileName}',
        child: Material(
          type: MaterialType.transparency,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(4)),
              color: Colors.grey,
            ),
            child: Text(
              widget.viewModel.currentNote.fileName,
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomStickyActionBar() {
    if (!_keyboardVisible) {
      return Container();
    }
    return BottomStickyActionBar(
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
          callback: () => addCharacterAndMoveCaret(character: '#'),
        ),
        BottomStickyActionItem(
          child: Icon(
            FontAwesomeIcons.listUl,
            size: 16,
          ),
          callback: () => addCharacterAndMoveCaret(character: '- '),
        ),
        BottomStickyActionItem(
          child: Icon(
            FontAwesomeIcons.listOl,
            size: 16,
          ),
          callback: () => addCharacterAndMoveCaret(character: '1. '),
        ),
        BottomStickyActionItem(
          child: Icon(
            FontAwesomeIcons.checkSquare,
            size: 16,
          ),
          callback: () => addCharacterAndMoveCaret(character: '- [ ] '),
        ),
        BottomStickyActionItem(
          child: Icon(
            FontAwesomeIcons.calendarDay,
            size: 16,
          ),
          callback: () => addCharacterAndMoveCaret(
            character: _dateTimeFormatString(
              date: DateTime.now(),
              format: [yyyy, '-', mm, '-', dd],
            ),
          ),
        ),
        BottomStickyActionItem(
          child: Icon(
            FontAwesomeIcons.clock,
            size: 16,
          ),
          callback: () => addCharacterAndMoveCaret(
            character: _dateTimeFormatString(
              date: DateTime.now(),
              format: [HH, ':', nn, ' ', am],
            ),
          ),
        ),
      ],
    );
  }

  void _cancelDebounce() {
    if (_debounce != null) {
      _debounce.cancel();
      _debounce = null;
    }
  }

  void _onNoteChanged({String value}) {
    _log.d('_onNoteChanged');
    if (viewModel.currentNote == null) {
      return;
    }
    if (_debounce?.isActive ?? false) _debounce.cancel();
    _debounce = Timer(const Duration(milliseconds: 250), () async {
      _log.d('Saved automatically');
      await _saveNote();
    });
  }

  Future _saveNote() async {
    viewModel.currentNote.content = noteController.text;

    await viewModel.saveNote(viewModel.currentNote);
  }

  _onKeyboardVisibility(bool visible) {
    _log.d('_onKeyboardVisibility');
    setState(() {
      this._keyboardVisible = visible;
    });
    _log.d('_onKeyboardVisibility -> $_keyboardVisible');
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

  String _dateTimeFormatString({DateTime date, List<String> format}) {
    DateTime targetDateTime = date;
    if (targetDateTime == null) {
      targetDateTime = DateTime.now();
    }

    List<String> targetFormat = format;

    if (format == null) {
      targetFormat = [yyyy, '-', mm, '-', dd, ' ', HH, ':', nn, ' ', am];
    }

    return formatDate(targetDateTime, targetFormat);
  }
}
