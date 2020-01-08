part of note_detail_view;

class _NoteDetailMobile extends StatefulWidget {
  final NoteDetailViewModel viewModel;

  _NoteDetailMobile(this.viewModel);

  @override
  __NoteDetailMobileState createState() => __NoteDetailMobileState(viewModel);
}

class __NoteDetailMobileState extends State<_NoteDetailMobile> {
  final NoteDetailViewModel viewModel;
  final Logger _log = getLogger('_NoteDetailMobile');
  bool _keyboardVisible = false;
  final _formKey = GlobalKey<FormState>();
  int _listener;
  final FocusNode noteFocusNode =
      FocusNode(debugLabel: 'NOTE_FOCUS_NODE', canRequestFocus: true);
  final TextEditingController noteController = TextEditingController();
  Timer _debounce;

  __NoteDetailMobileState(this.viewModel);

  @override
  initState() {
    super.initState();
    _log.d('init state');
    noteController.text = viewModel.currentNote.content;
    _listener = KeyboardVisibilityNotification().addNewListener(
      onChange: _onKeyboardVisibility,
    );
  }

  @override
  void dispose() {
    _cancelDebounce();
    KeyboardVisibilityNotification().removeListener(_listener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: true,
      body: WillPopScope(
        onWillPop: () async {
          _cancelDebounce();
          await _saveNote();
          return Future.value(true);
        },
        child: Stack(
          children: <Widget>[
            SafeArea(
              child: PageView(
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      children: <Widget>[
                        Container(
                          child: Hero(
                            tag:
                                'filename${widget.viewModel.currentNote.fileName}',
                            child: Material(
                              type: MaterialType.transparency,
                              child: Text(
                                widget.viewModel.currentNote.fileName,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
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
                                _onNoteChanged();
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Markdown(data: noteController.text),
                ],
              ),
            ),
            BottomStickyActionBar(
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
            ),
          ],
        ),
      ),
    );
  }

  void _cancelDebounce() {
    if (_debounce != null) {
      _debounce.cancel();
      _debounce = null;
    }
  }

  void _onNoteChanged({String value}) {
    if (viewModel.currentNote == null) {
      return;
    }
    if (_debounce?.isActive ?? false) _debounce.cancel();
    _debounce = Timer(const Duration(milliseconds: 1000), () async {
      await _saveNote();
    });
  }

  Future _saveNote() async {
    viewModel.currentNote.content = noteController.text;
    await viewModel.saveNote(viewModel.currentNote);
  }

  _onKeyboardVisibility(bool visible) {
    setState(() {
      this._keyboardVisible = visible;
    });
    if (!this._keyboardVisible) {}
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
