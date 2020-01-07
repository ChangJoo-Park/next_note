import 'dart:io';

import 'package:flutter/services.dart';
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

  initialize() async {
    _noteStorage = NoteStorage();
    await _noteStorage.initializationDone;

    SharedPreferences prefs = await SharedPreferences.getInstance();

    if (!prefs.containsKey('initialized')) {
      _noteStorage.writeFile('getting-started.md',
          await rootBundle.loadString('assets/notes/getting-started.md'));
      _log.d('#initialize -> write getting started');
      // TODO: SET Initialized key true
    }

    _loadNotes();

    // Create New One when empty list
    _log.d('#initialize -> load ${_items.length} notes');
    notifyListeners();
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
  set items(List<Note> value) {
    this._items = value;
    notifyListeners();
  }

  createNewNote(String fileName) async {
    _log.d('#createNewNote -> $fileName');
    await _noteStorage.writeFile(fileName, '');
    _loadNotes();
    notifyListeners();
  }

  Note get firstItem => this._items.first;

  Future<void> updateNote(Note note) async {
    _log.d('#updateNote -> ');
    await _noteStorage.writeFile(note.fileName, note.content);
    notifyListeners();
  }

  loadItems() async {
    notifyListeners();
  }
}
