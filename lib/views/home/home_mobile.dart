part of home_view;

class _HomeMobile extends StatefulWidget {
  final HomeViewModel viewModel;
  _HomeMobile(this.viewModel);

  @override
  __HomeMobileState createState() => __HomeMobileState();
}

class __HomeMobileState extends State<_HomeMobile> {
  Logger _log = getLogger('_HomeMobileState');

  final _formKey = GlobalKey<FormState>();

  final FocusNode titleFocusNode =
      FocusNode(debugLabel: 'TITLE_FOCUS_NODE', canRequestFocus: true);
  final TextEditingController titleController = TextEditingController();
  final FocusNode noteFocusNode =
      FocusNode(debugLabel: 'NOTE_FOCUS_NODE', canRequestFocus: true);
  final TextEditingController noteController = TextEditingController();
  bool _keyboardVisible = false;
  List<Item> _items;
  Timer _debounce;
  int _listener;

  @protected
  void initState() {
    super.initState();
    _listener = KeyboardVisibilityNotification().addNewListener(
      onChange: _onKeyboardVisibility,
    );

    widget.viewModel.addListener(() {
      if (widget.viewModel.items != null) {
        setState(() {
          _items = widget.viewModel.items;
        });
      }
      if (widget.viewModel.itemStatus == null &&
          widget.viewModel.currentItem != null) {
        titleController.text = widget.viewModel.currentItem.title;
        noteController.text = widget.viewModel.currentItem.note;
        widget.viewModel.itemStatus = 'mounted';
        _log.d('Item mounted');
      }
    });
  }

  @override
  void dispose() {
    widget.viewModel.itemProvider.close();
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

  void _onNoteChanged() {
    if (_debounce?.isActive ?? false) _debounce.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () async {
      widget.viewModel.currentItem.title = titleController.text;
      widget.viewModel.currentItem.note = noteController.text;
      await widget.viewModel.updateItem(widget.viewModel.currentItem);
      widget.viewModel.itemStatus = 'updated';
      _log.d('Item updated');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: true,
      appBar: AppBar(
        title: GestureDetector(
          onTap: () {
            showDialog(
                context: context,
                builder: (BuildContext ctx) {
                  return SimpleDialog(
                    title: Text('NextNote'),
                    children: <Widget>[
                      SimpleDialogOption(
                        child: Row(
                          children: <Widget>[
                            Icon(FontAwesomeIcons.infoCircle),
                            SizedBox(width: 8.0),
                            Text('About')
                          ],
                        ),
                      ),
                      SimpleDialogOption(
                        child: Row(
                          children: <Widget>[
                            Icon(FontAwesomeIcons.trashAlt),
                            SizedBox(width: 8.0),
                            Text('Delete')
                          ],
                        ),
                      ),
                    ],
                  );
                });
          },
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
            icon: Icon(
              FontAwesomeIcons.plus,
              size: 16,
            ),
            onPressed: _createNewNote,
          ),
        ],
      ),
      body: DoubleBackToCloseApp(
        snackBar: const SnackBar(
          content: Text('Tap back again to leave'),
        ),
        child: Center(
          child: Stack(
            fit: StackFit.expand,
            children: <Widget>[
              Container(
                child: widget.viewModel.currentItem == null
                    ? Center(child: CircularProgressIndicator())
                    : PageView(
                        children: <Widget>[
                          Container(
                            padding: EdgeInsets.only(
                              left: 8.0,
                              right: 8.0,
                              bottom: 34.0,
                            ),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                children: <Widget>[
                                  // Title
                                  TitleTextField(
                                    titleFocusNode: titleFocusNode,
                                    noteFocusNode: noteFocusNode,
                                    controller: titleController,
                                    valueChanged: (String value) {
                                      _onNoteChanged();
                                    },
                                  ),
                                  // Note
                                  ScrollConfiguration(
                                    behavior: NoGlowScrollBehavior(),
                                    child: NoteTextField(
                                      noteFocusNode: noteFocusNode,
                                      controller: noteController,
                                      valueChanged: (String value) {
                                        // TODO: handle by last
                                        _onNoteChanged();
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Container(
                            child: Markdown(
                                styleSheetTheme:
                                    MarkdownStyleSheetBaseTheme.platform,
                                shrinkWrap: true,
                                data:
                                    '# ${titleController.text}\n${noteController.text}'),
                          ),
                        ],
                      ),
              ),
              _keyboardVisible || widget.viewModel.items == null
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
                              addCharacterAndMoveCaret(character: '\n- '),
                        ),
                        BottomStickyActionItem(
                          child: Icon(
                            FontAwesomeIcons.listOl,
                            size: 16,
                          ),
                          callback: () =>
                              addCharacterAndMoveCaret(character: '\n- '),
                        ),
                        BottomStickyActionItem(
                          child: Icon(
                            FontAwesomeIcons.checkSquare,
                            size: 16,
                          ),
                          callback: () =>
                              addCharacterAndMoveCaret(character: '\n- [ ] '),
                        ),
                      ],
                    )
                  : Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: DraggableScrollableSheet(
                        expand: true,
                        maxChildSize: 0.9,
                        initialChildSize: 0.08,
                        minChildSize: 0.08,
                        builder: (context, scrollController) {
                          return Container(
                            child: ListView.builder(
                              controller: scrollController,
                              itemCount: _items.length,
                              itemBuilder: (BuildContext context, int index) {
                                bool selected =
                                    widget.viewModel.currentItem.id ==
                                        _items[index].id;
                                return Container(
                                  color: Colors.black,
                                  child: ListTile(
                                    onTap: () {
                                      widget.viewModel.currentItem =
                                          _items[index];
                                      _setCurrentItemToController();
                                    },
                                    onLongPress: () {
                                      showDialog(
                                          context: context,
                                          builder: (BuildContext ctx) {
                                            return SimpleDialog(
                                              children: <Widget>[
                                                Container(
                                                  child: Text(''),
                                                ),
                                                SimpleDialogOption(
                                                  child: Row(
                                                    children: <Widget>[
                                                      Icon(FontAwesomeIcons
                                                          .trashAlt),
                                                      SizedBox(width: 8.0),
                                                      Text('Delete')
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            );
                                          });
                                    },
                                    title: Text(
                                      _items[index].title,
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    selected: selected,
                                  ),
                                );
                              },
                            ),
                            decoration: BoxDecoration(
                              shape: BoxShape.rectangle,
                              color: Colors.black,

                              /// To set a shadow behind the parent container
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.white,
                                  offset: Offset(0.0, -2.0),
                                  blurRadius: 4.0,
                                ),
                              ],

                              /// To set radius of top left and top right
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(8.0),
                                topRight: Radius.circular(8.0),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  void _createNewNote() async {
    titleController.text = '';
    noteController.text = '';
    await widget.viewModel.createNewItem();
    _setCurrentItemToController();
    noteFocusNode.requestFocus();
  }

  void _setCurrentItemToController() {
    titleController.text = widget.viewModel.currentItem.title;
    noteController.text = widget.viewModel.currentItem.note;
  }

  void addCharacterAndMoveCaret({String character, int offset = 0}) {
    int curSelectionStart = noteController.selection.start;
    String leftText =
        noteController.text.substring(0, noteController.selection.start);
    String selectionWord = noteController.text.substring(
        noteController.selection.start, noteController.selection.end);
    String rightText = noteController.text
        .substring(noteController.selection.end, noteController.text.length);
    String midText = '';

    if (offset > 0) {
      midText = character.substring(0, offset) +
          selectionWord +
          character.substring(offset, character.length);
    }

    noteController.value = TextEditingValue(
      text: leftText + midText + rightText,
      selection: TextSelection.fromPosition(
        TextPosition(offset: curSelectionStart + selectionWord.length + offset),
      ),
    );
  }
}

class TitleTextField extends StatelessWidget {
  const TitleTextField({
    Key key,
    @required this.titleFocusNode,
    @required this.noteFocusNode,
    @required this.valueChanged,
    @required this.controller,
  }) : super(key: key);

  final FocusNode titleFocusNode;
  final FocusNode noteFocusNode;
  final ValueChanged<String> valueChanged;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: TextField(
        controller: controller,
        focusNode: titleFocusNode,
        autofocus: false,
        cursorColor: Colors.black,
        enableSuggestions: false,
        textAlign: TextAlign.center,
        textInputAction: TextInputAction.next,
        keyboardType: TextInputType.text,
        style: TextStyle(
          fontFamily: 'Monospace',
          fontWeight: FontWeight.bold,
          fontSize: 20.0,
        ),
        decoration: InputDecoration(
          hintText: 'Title',
          border: InputBorder.none,
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(
              color: Colors.black,
              width: 1.0,
            ),
          ),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.transparent, width: 1.0),
          ),
        ),
        onSubmitted: (String value) {
          titleFocusNode.unfocus();
          FocusScope.of(context).requestFocus(noteFocusNode);
          valueChanged(value);
        },
        onEditingComplete: () {
          debugPrint('onEditingComplete');
        },
      ),
    );
  }
}

class NoteTextField extends StatelessWidget {
  const NoteTextField({
    Key key,
    @required this.noteFocusNode,
    @required this.controller,
    @required this.valueChanged,
  }) : super(key: key);

  final FocusNode noteFocusNode;
  final TextEditingController controller;
  final ValueChanged<String> valueChanged;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 1,
      child: TextField(
        controller: controller,
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
        onChanged: valueChanged,
        onEditingComplete: () {
          debugPrint('onEditingCompleted');
        },
      ),
    );
  }
}

class BottomStickyActionBar extends StatelessWidget {
  const BottomStickyActionBar({
    Key key,
    this.children,
  }) : super(key: key);

  final children;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0.0,
      bottom: 1.0,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
        decoration:
            BoxDecoration(border: Border.all(width: 1.0), color: Colors.white),
        width: MediaQuery.of(context).size.width,
        child: Row(children: children),
      ),
    );
  }
}

class BottomStickyActionItem extends StatelessWidget {
  const BottomStickyActionItem({Key key, @required this.child, this.callback})
      : super(key: key);
  final Widget child;
  final VoidCallback callback;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: callback,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
        child: child,
      ),
    );
  }
}

class NoGlowScrollBehavior extends ScrollBehavior {
  @override
  Widget buildViewportChrome(
      BuildContext context, Widget child, AxisDirection axisDirection) {
    return child;
  }
}
