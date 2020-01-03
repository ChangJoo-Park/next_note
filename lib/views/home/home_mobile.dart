part of home_view;

class _HomeMobile extends StatefulWidget {
  final HomeViewModel viewModel;
  _HomeMobile(this.viewModel);

  @override
  __HomeMobileState createState() => __HomeMobileState();
}

class __HomeMobileState extends State<_HomeMobile> {
  final _formKey = GlobalKey<FormState>();

  final FocusNode titleFocusNode =
      FocusNode(debugLabel: 'TITLE_FOCUS_NODE', canRequestFocus: true);
  final TextEditingController titleController = TextEditingController();
  final FocusNode noteFocusNode =
      FocusNode(debugLabel: 'NOTE_FOCUS_NODE', canRequestFocus: true);
  final TextEditingController noteController = TextEditingController();
  bool _keyboardVisible = false;

  @protected
  void initState() {
    super.initState();

    KeyboardVisibilityNotification().addNewListener(
      onChange: (bool visible) {
        print('keyboard visible on change => $visible');
        setState(() {
          this._keyboardVisible = visible;
        });
      },
    );
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
                padding: EdgeInsets.only(
                  bottom: 0.0,
                  left: 8.0,
                  right: 8.0,
                  top: 0,
                ),
                child: Form(
                  key: _formKey,
                  onChanged: () {},
                  child: Column(
                    children: <Widget>[
                      // Title
                      TitleTextField(
                        titleFocusNode: titleFocusNode,
                        noteFocusNode: noteFocusNode,
                        controller: titleController,
                        valueChanged: (String value) {
                          if (value.isEmpty) {
                            titleController.text = _nowString();
                          }
                        },
                      ),
                      // Note
                      NoteTextField(
                        noteFocusNode: noteFocusNode,
                        controller: noteController,
                      ),
                    ],
                  ),
                ),
              ),
              _keyboardVisible ? Container() : NoteList(),
            ],
          ),
        ),
      ),
    );
  }

  void _createNewNote() {
    // TODO: 저장해야함
    titleController.text = '';
    noteController.text = '';
    titleFocusNode.requestFocus();
  }

  String _nowString() {
    DateTime now = DateTime.now();
    List<String> format = [yyyy, '-', mm, '-', dd, ' ', HH, ':', nn, ' ', am];
    String nowString = formatDate(now, format);
    return nowString;
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
        autofocus: true,
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
  }) : super(key: key);

  final FocusNode noteFocusNode;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 1,
      child: TextField(
        controller: controller,
        focusNode: noteFocusNode,
        cursorColor: Colors.black,
        onEditingComplete: () {
          print('on editing complete');
        },
        style: TextStyle(fontFamily: 'Monospace'),
        decoration: InputDecoration(
          hintText: "Insert your message",
          border: InputBorder.none,
        ),
        scrollPadding: EdgeInsets.all(20.0),
        keyboardType: TextInputType.multiline,
        maxLines: 99999,
        autofocus: true,
      ),
    );
  }
}

class NoteList extends StatelessWidget {
  const NoteList({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, right: 8.0),
      child: DraggableScrollableSheet(
        maxChildSize: 0.9,
        initialChildSize: 0.08,
        minChildSize: 0.08,
        builder: (context, scrollController) {
          scrollController.addListener(() {
            // TODO: 스크롤 포지션에 따라 opacity를 변경해야함
          });
          return Container(
            child: ListView.builder(
              controller: scrollController,
              itemCount: 25,
              itemBuilder: (BuildContext context, int index) {
                return ListTile(
                    title: Text(
                  'Item $index',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ));
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
    );
  }
}
