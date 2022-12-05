import 'dart:typed_data';

class DBSavingFile {
  final int attachmentId;
  final String fileName;
  final Uint8List file;

  DBSavingFile({required this.attachmentId,
      required this.fileName, required this.file});

   Map fromMap(Map map) => {
    fileName: map["fileName"],
    file: map["file"],
    attachmentId: map["attachmentId"]
  };

  Map<String, dynamic> toMap() => {
    "attachmentId": attachmentId,
    "fileName": fileName,
    "file" : file,
  };
}