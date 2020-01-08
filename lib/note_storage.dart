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
    _localDirectory = await getApplicationDocumentsDirectory();
    _localPath = _localDirectory.path;
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

  removeFile(String filename) {
    final file = _localFile(filename);
    return file.deleteSync();
  }
}
