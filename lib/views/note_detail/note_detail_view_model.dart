import 'dart:io';

import 'package:next_page/core/base/base_view_model.dart';
import 'package:next_page/models/note.dart';
import 'package:next_page/note_storage.dart';

class NoteDetailViewModel extends BaseViewModel {
  // Logger _log = getLogger('NoteDetailViewModel');

  NoteStorage _noteStorage;
  Note _currentNote;

  NoteDetailViewModel(Note note) {
    _currentNote = note;
  }

  Note get currentNote => _currentNote;

  // Add ViewModel specific code here
  Future<bool> initialize() async {
    _noteStorage = NoteStorage();
    await _noteStorage.initializationDone;
    return Future.value(true);
  }

  Future saveNote(Note note) async {
    File file = await _noteStorage.writeFile(note.fileName, note.content);
    FileStat stat = file.statSync();
    _currentNote.modified = stat.modified;
    _currentNote.accessed = stat.accessed;
    _currentNote.changed = stat.changed;
    notifyListeners();
    return file;
  }
}
