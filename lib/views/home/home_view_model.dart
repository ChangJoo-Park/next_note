import 'dart:io';

import 'package:flutter/services.dart';
import 'package:next_page/core/base/base_view_model.dart';
import 'package:next_page/models/note.dart';
import 'package:next_page/note_storage.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:front_matter/front_matter.dart' as fm;

class HomeViewModel extends BaseViewModel {
  // Logger _log = getLogger('HomeViewModel');
  NoteStorage _noteStorage;
  List<Note> _items = [];
  Note _currentNote;
  String _currentNoteStatus = '';
  SharedPreferences prefs;
  bool done = false;

  initialize() async {
    _noteStorage = NoteStorage();

    await _noteStorage.initializationDone;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('initialized') && prefs.getBool('initialized')) {
    } else {
      await prefs.setBool('initialized', true);
      _noteStorage.writeFile(
        'getting-started.md',
        await rootBundle.loadString('assets/notes/getting-started.md'),
      );
    }

    _loadNotes();

    // Create New One when empty list

    notifyListeners();
  }

  String get currentNoteStatus => _currentNoteStatus;
  set currentNoteStatus(String value) {
    this.currentNoteStatus = value;
  }

  void _loadNotes() async {
    List<FileSystemEntity> files = _noteStorage.readDirectory();
    // FIXME: 성능 문제 여지가 있음
    this._items = files
        .where((fileEntity) => fileEntity.path.contains('.md'))
        .map((markdownFileEntity) => File(markdownFileEntity.path))
        .map(_loadMarkdown)
        .toList();
  }

  Note _loadMarkdown(markdownFile) {
    String fileContents = markdownFile.readAsStringSync();
    fm.FrontMatterDocument doc = fm.parse(fileContents);

    FileStat noteFileStat = markdownFile.statSync();
    String title = path.basename(markdownFile.path);
    try {
      title = doc?.data['title'];
    } catch (e) {}

    return Note(
      title: title,
      filePath: markdownFile.path,
      fileName: path.basename(markdownFile.path),
      content: '',
      accessed: noteFileStat.accessed,
      changed: noteFileStat.changed,
      modified: noteFileStat.modified,
      size: noteFileStat.size,
    );
  }

  Note get currentNote => this._currentNote;
  set currentNote(Note note) {
    this._currentNote = note;
    fm.FrontMatterDocument doc =
        fm.parse(_noteStorage.readFile(note.fileName).readAsStringSync());

    this._currentNote.title = note.title;
    this._currentNote.content = doc.content;
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
    String content = '''---
title: $fileName
---

''';
    await _noteStorage.writeFile(fileName, content);
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
