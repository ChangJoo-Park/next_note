class Note {
  String fileName;
  String filePath;
  String content;
  DateTime accessed;
  DateTime changed;
  DateTime modified;
  int size;

  Note({
    this.fileName,
    this.filePath,
    this.content,
    this.accessed,
    this.changed,
    this.modified,
    this.size,
  });
}