part of note_detail_view;

class _NoteDetailMobile extends StatelessWidget {
  final NoteDetailViewModel viewModel;
  final _formKey = GlobalKey<FormState>();
  final FocusNode noteFocusNode =
      FocusNode(debugLabel: 'NOTE_FOCUS_NODE', canRequestFocus: true);
  final TextEditingController noteController = TextEditingController();

  _NoteDetailMobile(this.viewModel);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: PageView(children: <Widget>[
          Container(
            padding: EdgeInsets.all(8.0),
            child: Column(
              children: <Widget>[
                Container(
                  child: Hero(
                    tag: 'filename${viewModel.currentNote.fileName}',
                    child: Material(
                      type: MaterialType.transparency,
                      child: Text(
                        viewModel.currentNote.fileName,
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
                      onChanged: (String value) {},
                      onEditingComplete: () {},
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container()
        ]),
      ),
    );
  }
}
