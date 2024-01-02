import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:image/image.dart' as img;

import 'subject.dart';

class ImageSubject implements Subject {
  late img.Image _image;
  late String _path;
  late String _fileNameWithExtension;

  String getPath() => _path;

  String get fileNameWithExtension => _fileNameWithExtension;
  img.Image get image => _image;
  String get path => _path;
  String _getFileName(FilePickerResult result) {
    return result.files.single.name;
  }

  @override
  Future<bool> load() async {
    String? path = await _loadPath();
    if (path == null) return false;

    _path = path;
    _image = _loadImage(_path);
    return true;
  }

  img.Image _loadImage(String path) {
    List<int> bytes = File(path).readAsBytesSync();
    img.Image? image = img.decodeImage(Uint8List.fromList(bytes));

    if (image == null) {
      //todo: handle this
      return image!;
    } else {
      return image;
    }
  }

  Future<String?> _loadPath() async {
    FilePickerResult? result;
    try {
      result = await FilePicker.platform.pickFiles(type: FileType.image);
      if (result != null) {
        _fileNameWithExtension = _getFileName(result);

        return result.files.single.path;
      }
      ;
    } catch (e) {
      return null;
    }
    return null;
  }
}
