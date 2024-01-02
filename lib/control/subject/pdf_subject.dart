import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:file_picker/file_picker.dart';
import 'package:pdf_render/pdf_render.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart' as sfp;
// import 'package:syncfusion_flutter_pdf/pdf.dart';

import 'subject.dart';

class PdfSubject implements Subject {
  late sfp.PdfDocument _pdfDocument;
  late String _path;
  late String _fileNameWithExtension;

  String getPath() => _path;
  sfp.PdfDocument get document => _pdfDocument;

  String get fileNameWithExtension => _fileNameWithExtension;
  int get countOfPages => _pdfDocument.pages.count;

  @override
  Future<bool> load() async {
    String? path = await _getPath();
    if (path == null) return false;

    _path = path;
    _pdfDocument = sfp.PdfDocument(inputBytes: File(_path).readAsBytesSync());
    return true;
  }

  String _getFileName(FilePickerResult result) {
    return result.files.single.name;
  }

  Future<Uint8List> getFirstImage() async {
    // PdfDocumentLoader pdfDocumentLoader = PdfDocumentLoader(doc: PdfDocument.openFile(_path) ,pageNumber: 1,);
    print('here 1');
    print(_path);
    if (File(_path).existsSync()) {
      print('File does exist at $_path');
    }
    Uint8List pdfFileBytes = File(_path).readAsBytesSync();
    PdfDocument pdfDocument = await PdfDocument.openData(pdfFileBytes);
    print('here 2');
    PdfPage page = await pdfDocument.getPage(1);
    print('here 3');
    final width = (page.width * 300 / 72).ceil();
    final height = (page.height * 300 / 72).ceil();
    // 2. PdfPage => PdfPageImage
    PdfPageImage pagePdfImage = await page.render(width: width, height: height, allowAntialiasingIOS: true);
    print('here 4');

    // 3. PdfPageImage => ui.Image
    Image pageImage = await pagePdfImage.createImageDetached();
    print('here 5');
    // // 4. ui.Image => PNG binary representation
    ByteData? imageBytes = await pageImage.toByteData(format: ImageByteFormat.png);
    print('here 6');

    return imageBytes!.buffer.asUint8List();
    // img.Image? image = img.decodeImage(imageBytes!.buffer.asUint8List());
    // return Future.value(image);
  }

  void applyTextToPdf() {}

  Future<String?> _getPath() async {
    FilePickerResult? result;
    try {
      result =
          await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['pdf'], allowMultiple: false);
      if (result != null) {
        _fileNameWithExtension = _getFileName(result);
        return result.files.single.path;
      }
    } catch (e) {
      return null;
    }
    return null;
  }
}
