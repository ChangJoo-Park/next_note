import 'package:logger/logger.dart';
import 'package:next_page/core/base/base_view_model.dart';
import 'package:next_page/core/logger.dart';
import 'package:next_page/models/note.dart';
import 'package:next_page/note_storage.dart';

class NoteDetailViewModel extends BaseViewModel {
  Logger _log = getLogger('NoteDetailViewModel');

  NoteStorage _noteStorage;
  Note _currentNote;
  bool initialized = false;

  NoteDetailViewModel(Note note) {
    _currentNote = note;
  }

  Note get currentNote => _currentNote;

  // Add ViewModel specific code here
  initialize() async {
    _noteStorage = NoteStorage();
    await _noteStorage.initializationDone;
    notifyListeners();
    initialized = true;
  }
}
