import 'package:flutter/material.dart';

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
