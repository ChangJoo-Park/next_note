import 'package:flutter/material.dart';
import 'package:next_page/models/note.dart';

class NoteListTile extends StatelessWidget {
  const NoteListTile({
    Key key,
    @required this.note,
    this.onTap,
    this.onLongPress,
  }) : super(key: key);

  final Note note;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        note.fileName,
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(note.modified.toString()),
      onTap: onTap,
      onLongPress: onLongPress,
    );
  }
}
