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
    KeyboardVisibilityNotification().removeListener(_listener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: true,
      body: Stack(
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
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Markdown(data: noteController.text),
              ],
            ),
          ),
          // Keyboard
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
              : Container(),
        ],
      ),
    );
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
}
