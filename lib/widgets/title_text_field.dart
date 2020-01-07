import 'package:flutter/material.dart';

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
