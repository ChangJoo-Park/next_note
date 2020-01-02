part of home_view;

class _HomeMobile extends StatelessWidget {
  final HomeViewModel viewModel;
  _HomeMobile(this.viewModel);

  final _formKey = GlobalKey<FormState>();
  final FocusNode titleFocusNode =
      FocusNode(debugLabel: 'TITLE_FOCUS_NODE', canRequestFocus: true);
  final FocusNode noteFocusNode =
      FocusNode(debugLabel: 'NOTE_FOCUS_NODE', canRequestFocus: true);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: true,
      appBar: AppBar(
        title: Text('NextNote'),
        backgroundColor: Colors.black,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {},
          )
        ],
      ),
      body: Center(
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
                child: Column(
                  children: <Widget>[
                    // Title
                    Container(
                      child: TextField(
                        focusNode: titleFocusNode,
                        autofocus: true,
                        cursorColor: Colors.black,
                        enableSuggestions: false,
                        textAlign: TextAlign.center,
                        onSubmitted: (String value) {
                          titleFocusNode.unfocus();
                          FocusScope.of(context).requestFocus(noteFocusNode);
                        },
                        textInputAction: TextInputAction.next,
                        keyboardType: TextInputType.text,
                        style: TextStyle(fontFamily: 'Monospace'),
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
                            borderSide: BorderSide(
                                color: Colors.transparent, width: 1.0),
                          ),
                        ),
                      ),
                    ),
                    // Note
                    Expanded(
                      flex: 1,
                      child: TextField(
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
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8.0, right: 8.0),
              child: DraggableScrollableSheet(
                maxChildSize: 0.9,
                initialChildSize: 0.1,
                minChildSize: 0.1,
                builder: (context, scrollController) {
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
            ),
          ],
        ),
      ),
    );
  }
}
