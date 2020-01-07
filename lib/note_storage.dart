import 'dart:async';
import 'dart:io';
import 'package:logger/logger.dart';
import 'package:next_page/core/logger.dart';
import 'package:path_provider/path_provider.dart';

class NoteStorage {
  Logger _log = getLogger('NoteStorage');
  Directory _localDirectory;
  String _localPath;
  Future _doneInitialize;

  NoteStorage() {
    _doneInitialize = _init();
  }

  _init() async {
    _log.d('#init -> get directory path');
    _localDirectory = await getApplicationDocumentsDirectory();
    _localPath = _localDirectory.path;
    _log.d('#init -> _localDirectory $_localDirectory');
    _log.d('#init -> _localPath $_localPath');
  }

  Future get initializationDone => _doneInitialize;

  File _localFile(String filename) {
    return File('$_localPath/$filename');
  }

  List<FileSystemEntity> readDirectory() {
    List<FileSystemEntity> files = Directory(_localPath).listSync();
    return files;
  }

  File readFile(filePath) {
    try {
      return _localFile(filePath);
    } catch (e) {
      return null;
    }
  }

  FileStat getFileStat(filePath) {}

  Future<File> writeFile(String filename, String content) async {
    final file = _localFile(filename);
    return file.writeAsString('$content');
  }
}
