import 'package:date_format/date_format.dart';
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
      title: Hero(
        tag: 'note-title-${note.fileName}',
        child: Material(
          type: MaterialType.transparency,
          child: Text(
            note.fileName,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ),
      subtitle: Hero(
        tag: 'note-subtitle-${note.fileName}',
        child: Material(
          type: MaterialType.transparency,
          child: Text(
            'Saved at ' +
                formatDate(
                    note.changed, [yyyy, '-', mm, '-', dd, ' ', HH, ':', nn]),
          ),
        ),
      ),
      onTap: onTap,
      onLongPress: onLongPress,
    );
  }
}
