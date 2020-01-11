import 'dart:io';

import 'package:logger/logger.dart';
import 'package:next_page/core/base/base_view_model.dart';
import 'package:next_page/core/logger.dart';
import 'package:next_page/models/note.dart';
import 'package:next_page/note_storage.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';

class HomeViewModel extends BaseViewModel {
  Logger _log = getLogger('HomeViewModel');
  NoteStorage _noteStorage;
  List<Note> _items = [];
  Note _currentNote;
  String _currentNoteStatus = '';
  SharedPreferences prefs;
  bool done = false;

  initialize() async {
    _noteStorage = NoteStorage();

    await _noteStorage.initializationDone;

    _loadNotes();

    // Create New One when empty list

    notifyListeners();
  }

  String get currentNoteStatus => _currentNoteStatus;
  set currentNoteStatus(String value) {
    this.currentNoteStatus = value;
  }

  void _loadNotes() {
    List<FileSystemEntity> files = _noteStorage.readDirectory();
    this._items = files
        .where((fileEntity) => fileEntity.path.contains('.md'))
        .map((markdownFileEntity) => File(markdownFileEntity.path))
        .map(
      (markdownFile) {
        FileStat noteFileStat = markdownFile.statSync();
        return Note(
          filePath: markdownFile.path,
          fileName: path.basename(markdownFile.path),
          content: '',
          accessed: noteFileStat.accessed,
          changed: noteFileStat.changed,
          modified: noteFileStat.modified,
          size: noteFileStat.size,
        );
      },
    ).toList();
  }

  Note get currentNote => this._currentNote;
  set currentNote(Note note) {
    this._currentNote = note;
    this._currentNote.content =
        _noteStorage.readFile(note.fileName).readAsStringSync();
    notifyListeners();
  }

  List<Note> get items => this._items;
  List<Note> get sortByUpdatedItems {
    List<Note> targetList = List.from(this._items);
    targetList.sort((Note a, Note b) => b.accessed.compareTo(a.accessed));
    return targetList;
  }

  set items(List<Note> value) {
    this._items = value;
    notifyListeners();
  }

  createNewNote(String fileName) async {
    await _noteStorage.writeFile(fileName, '');
    _loadNotes();
    notifyListeners();
  }

  Note get firstItem => this._items.first;

  Future<void> updateNote(Note note) async {
    await _noteStorage.writeFile(note.fileName, note.content);
    notifyListeners();
  }

  loadItems() async {
    _loadNotes();
    notifyListeners();
  }

  removeNote(Note note) {
    bool hasNote = _items.contains(note);
    if (!hasNote) {
      return;
    }
    _items.remove(note);
    _noteStorage.removeFile(note.fileName);
    notifyListeners();
  }
}
