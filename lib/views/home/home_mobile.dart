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
                        child: ListTile(
                          leading: Icon(FontAwesomeIcons.info),
                          title: Text('About'),
                        ),
                        onPressed: () {},
                      ),
                      SimpleDialogOption(
                        child: ListTile(
                          leading: Icon(FontAwesomeIcons.trashAlt),
                          title: Text('Trash'),
                        ),
                        onPressed: () {},
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
              Icon(Icons.keyboard_arrow_down),
            ],
          ),
        ),
        backgroundColor: Colors.black,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add),
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
                            padding: EdgeInsets.all(8.0),
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
                                  NoteTextField(
                                    noteFocusNode: noteFocusNode,
                                    controller: noteController,
                                    valueChanged: (String value) {
                                      _onNoteChanged();
                                    },
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
                  ? Container()
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
      ),
    );
  }
}
