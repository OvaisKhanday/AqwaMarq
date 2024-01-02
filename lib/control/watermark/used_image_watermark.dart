import 'dart:io';

import 'package:path_provider/path_provider.dart';

class UsedImageWatermark {
  List<String> _imagePaths = [];
  List<String> _imageFilenames = [];

  List<String> get imagePaths => _imagePaths;
  List<String> get imageFilenames => _imageFilenames;

  Future<void> getPathsOfCacheImageWatermarks() async {
    Directory? appDocDir = await getExternalStorageDirectory();
    String path = '${appDocDir!.path}/watermark/images';

    Directory imagesDirectory = Directory(path);

    if (imagesDirectory.existsSync()) {
      // Get a list of files in the images folder
      List<FileSystemEntity> files = imagesDirectory.listSync();

      // Filter only the files that are images (you can customize this filter)
      List<File> imageFiles = files.cast<File>().toList();

      // Get the paths of the image files
      _imagePaths = imageFiles.map((file) => file.path).toList();

      _imageFilenames = imageFiles.map((file) => file.uri.pathSegments.last).toList();
    }
  }
}
