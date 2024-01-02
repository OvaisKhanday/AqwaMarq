import 'dart:io';

import 'package:path_provider/path_provider.dart';

class DocumentsCreated {
  List<String> _docPaths = [];
  List<String> _docFilenames = [];

  int get count => _docPaths.length;

  List<String> get docPaths => _docPaths;
  List<String> get docFilenames => _docFilenames;

  Future<void> getPathsOfCreatedDocuments() async {
    Directory? appDocDir = await getExternalStorageDirectory();
    String path = appDocDir!.path;

    Directory docDirectory = Directory(path);

    if (docDirectory.existsSync()) {
      // Get a list of files in the images folder
      List<FileSystemEntity> files = docDirectory.listSync();

      // List<File> docFiles = files.cast<File>().toList();
      List<File> docFiles = files.whereType<File>().toList();

      // Get the paths of the image files
      _docPaths = docFiles.map((file) => file.path).toList();
      _docFilenames = docFiles.map((file) => file.uri.pathSegments.last).toList();
    }
  }

  void share(int index) {}
}
