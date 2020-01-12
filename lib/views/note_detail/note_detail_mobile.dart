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
  final FocusNode noteFocusNode =
      FocusNode(debugLabel: 'NOTE_FOCUS_NODE', canRequestFocus: true);
  final TextEditingController noteController = TextEditingController();
  Timer _debounce;
  AppLifecycleState _notification;
  __NoteDetailMobileState(this.viewModel);

  @override
  initState() {
    WidgetsBinding.instance.addObserver(this);
    noteController.text = viewModel.currentNote.content;
    super.initState();
  }

  @override
  void dispose() {
    _cancelDebounce();
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
        if (viewModel.currentNote != null) {
          noteController.text = viewModel.currentNote.content;
        }
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
    _checkKeyboardAction();

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: _buildFileName(),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.share),
            onPressed: () {
              Share.share(noteController.text);
            },
          ),
          IconButton(
            icon: Icon(FontAwesomeIcons.markdown),
            onPressed: () async {
              _cancelDebounce();
              await _saveNote();
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (BuildContext context) =>
                      MarkdownView(noteController.text),
                ),
              );
            },
          )
        ],
      ),
      resizeToAvoidBottomPadding: true,
      floatingActionButton: _keyboardVisible
          ? Container()
          : FloatingActionButton.extended(
              isExtended: true,
              elevation: 0,
              heroTag: 'fab',
              icon: Icon(Icons.save),
              label: Text('Save'),
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
            Container(
              padding: EdgeInsets.only(bottom: 16.0, left: 16.0, right: 16.0),
              child: Column(
                children: <Widget>[
                  _buildTextFieldWidget(),
                ],
              ),
            ),
            _buildBottomStickyActionBar(),
          ],
        ),
      ),
    );
  }

  void _checkKeyboardAction() {
    if (viewModel.useKeyboardAction) {
      setState(() {
        _keyboardVisible = MediaQuery.of(context).viewInsets.vertical > 0;
      });
    } else {
      setState(() {
        _keyboardVisible = false;
      });
    }
  }

  Widget _buildSavedAt() {
    if (_keyboardVisible) {
      return Container();
    }
    return Positioned(
      bottom: 8.0,
      left: 8.0,
      child: Hero(
        tag: 'note-subtitle-${widget.viewModel.currentNote.fileName}',
        child: Material(
          type: MaterialType.transparency,
          child: Text('Saved at ' +
              formatDate(viewModel.currentNote.changed,
                  [yyyy, '-', mm, '-', dd, ' ', HH, ':', nn])),
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
                // try {
                //   TextSelection selection = noteController.selection;
                //   // 현재 선택된 라인을 찾는다.
                //   List<String> splitted = noteController.text.split('\n');
                //   List<int> charsList = List.filled(splitted.length, 0);
                //   splitted.asMap().forEach((int index, String value) {
                //     int previous = 0;
                //     int current = value.length;
                //     if (index != 0) {
                //       previous = charsList[index - 1];
                //     }
                //     charsList[index] = previous + current;
                //   });
                //   int lastMinIndex = 0;
                //   bool eol = false;
                //   _log.d('start');
                //   for (var i = 0; i < charsList.length; i++) {
                //     _log.d(charsList[i].toString());
                //     if (charsList[i] <= selection.start) {
                //       eol = charsList[i] == selection.start - 1;
                //       lastMinIndex = i;
                //     } else {
                //       _log.d("break");
                //       break;
                //     }
                //   }
                //   _log.d('end');
                //   _log.d('selection -> ${selection.start}');
                //   _log.d('lastMinIndex -> $lastMinIndex');
                //   _log.d('eol -> $eol');
                //   int previousLine = lastMinIndex - 1;
                //   if (previousLine < 0) {
                //     previousLine = 0;
                //   }

                //   if (eol) {
                //     _log.d('eol');
                //   }
                // bool startWithDash = splitted[previousLine].startsWith('- ');
                // if (startWithDash) {
                //   addCharacterAndMoveCaret(character: '- ');
                // }
                // } catch (e) {
                //   print(e);
                //   _log.e(e);
                // }
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
          child: GestureDetector(
            onLongPress: () {},
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
      ),
    );
  }

  Widget _buildBottomStickyActionBar() {
    if (!_keyboardVisible) {
      return _buildSavedAt();
    }
    return BottomStickyActionBar(
      children: <Widget>[
        BottomStickyActionItem(
          child: Icon(
            FontAwesomeIcons.bold,
            size: 16,
          ),
          onTap: () => addCharacterAndMoveCaret(
            character: '****',
            offset: 2,
          ),
        ),
        BottomStickyActionItem(
          child: Icon(
            FontAwesomeIcons.italic,
            size: 16,
          ),
          onTap: () => addCharacterAndMoveCaret(
            character: '**',
            offset: 1,
          ),
        ),
        BottomStickyActionItem(
          child: Icon(
            FontAwesomeIcons.strikethrough,
            size: 16,
          ),
          onTap: () => addCharacterAndMoveCaret(
            character: '~~',
            offset: 1,
          ),
        ),
        BottomStickyActionItem(
          child: Icon(
            FontAwesomeIcons.quoteLeft,
            size: 16,
          ),
          onTap: () => addCharacterAndMoveCaret(
            character: '> ',
          ),
        ),
        BottomStickyActionItem(
          child: Icon(
            FontAwesomeIcons.hashtag,
            size: 16,
          ),
          onTap: () => addCharacterAndMoveCaret(character: '#'),
        ),
        BottomStickyActionItem(
          child: Icon(
            FontAwesomeIcons.listUl,
            size: 16,
          ),
          onTap: () => addCharacterAndMoveCaret(character: '- '),
        ),
        BottomStickyActionItem(
          child: Icon(
            FontAwesomeIcons.listOl,
            size: 16,
          ),
          onTap: () => addCharacterAndMoveCaret(character: '1. '),
        ),
        BottomStickyActionItem(
          child: Icon(
            FontAwesomeIcons.checkSquare,
            size: 16,
          ),
          onTap: () => addCharacterAndMoveCaret(character: '- [ ] '),
        ),
        BottomStickyActionItem(
          child: Icon(
            FontAwesomeIcons.calendarDay,
            size: 16,
          ),
          onTap: () => addCharacterAndMoveCaret(
            character: _dateTimeFormatString(
              date: DateTime.now(),
              format: [yyyy, '-', mm, '-', dd],
            ),
          ),
          onLongPress: () {
            TextSelection selection = noteController.selection;
            DateTime now = DateTime.now();
            Duration twentyYears = Duration(days: 365 * 20);
            showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: now.subtract(twentyYears),
              lastDate: now.add(twentyYears),
              initialDatePickerMode: DatePickerMode.day,
            ).then((DateTime value) {
              addCharacterAndMoveCaret(
                selectionStart: selection.start,
                selectionEnd: selection.end,
                character: _dateTimeFormatString(
                  date: value,
                  format: [yyyy, '-', mm, '-', dd],
                ),
              );
            });
          },
        ),
        BottomStickyActionItem(
          child: Icon(
            FontAwesomeIcons.clock,
            size: 16,
          ),
          onTap: () => addCharacterAndMoveCaret(
            character: _dateTimeFormatString(
              date: DateTime.now(),
              format: [HH, ':', nn, ' '],
            ),
          ),
          onLongPress: () {
            TextSelection selection = noteController.selection;
            TimeOfDay nowTimeOfDay = TimeOfDay.now();
            showTimePicker(context: context, initialTime: nowTimeOfDay)
                .then((TimeOfDay value) {
              DateTime nowDateTime = DateTime.now();
              DateTime targetDateTime = DateTime(nowDateTime.year,
                  nowDateTime.month, nowDateTime.day, value.hour, value.minute);
              addCharacterAndMoveCaret(
                selectionStart: selection.start,
                selectionEnd: selection.end,
                character: _dateTimeFormatString(
                  date: targetDateTime,
                  format: [HH, ':', nn, ' '],
                ),
              );
            });
          },
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

  void addCharacterAndMoveCaret({
    String character,
    int offset = 0,
    int selectionStart,
    int selectionEnd,
  }) {
    int curSelectionStart = selectionStart != null
        ? selectionStart
        : noteController.selection.start;
    int curSelectionEnd =
        selectionEnd != null ? selectionEnd : noteController.selection.end;
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
