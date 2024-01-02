import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart' as sfp;
import 'package:vector_math/vector_math.dart';
import 'package:image/image.dart' as img;
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';

import '../providers/preview_provider.dart';
import '../subject/image_subject.dart';
import '../subject/pdf_subject.dart';
import '../subject/subject.dart';
import 'watermark.dart';
import 'watermark_parameters.dart';

class ImageWatermark implements Watermark {
  late img.Image _image;
  late String _path;
  late double _widthOfSubject;
  late double _heightOfSubject;

  img.Image get image => _image;
  String get path => _path;

  @override
  Future<bool> apply(Subject subject, WatermarkParameters parameters, BuildContext context,
      {ScreenshotController? screenshotController}) async {
    if (subject.runtimeType == ImageSubject) {
      subject = subject as ImageSubject;
      if (screenshotController == null) return Future.value(false);
      print(screenshotController.toString());
      Uint8List? imageBytes;
      await screenshotController.capture().then((Uint8List? image) {
        //Capture Done
        print(image);
        imageBytes = image;
      }).catchError((onError) {
        print(onError);
        return;
      });

      Directory? appDocDir = await getExternalStorageDirectory();
      String path = appDocDir!.path;
      // // Text on Image
      String fileName = subject.fileNameWithExtension;
      // await screenshotController.captureAndSave(path,
      //     fileName: fileName, delay: const Duration(milliseconds: 10));
      String filenameWithPath = '$path/$fileName';
      File(filenameWithPath).writeAsBytesSync(imageBytes!);
      final result = await Share.shareXFiles([XFile(filenameWithPath)]);

      if (result.status == ShareResultStatus.success) {
        print('Thank you for sharing the picture!');
      }
    } else if (subject.runtimeType == PdfSubject) {
      subject = subject as PdfSubject;

      img.Image imageWithAlpha = image.convert(numChannels: 4, alpha: parameters.getOpacity().toInt());
      List<int> imageData = img.encodePng(imageWithAlpha);

      final double ratioOfImage = imageWithAlpha.width / imageWithAlpha.height;

      print('image size w/h');
      print(imageWithAlpha.width);
      print(imageWithAlpha.height);

      for (int i = 0; i < subject.document.pages.count; i++) {
        Size size = subject.document.pages[i].size;
        print('pdf page size w/h');
        print(size.width);
        print(size.height);

        Offset center = Offset(size.width / 2, size.height / 2);
        final sfp.PdfPage page = subject.document.pages[i];
        double widthOfImageWatermark = (size.width / 100) * parameters.getSize();
        sfp.PdfGraphics pageGraphics = page.graphics;
        sfp.PdfGraphicsState state = pageGraphics.save();
        pageGraphics.setTransparency(parameters.getOpacity() / 100);
        pageGraphics.drawImage(
            sfp.PdfBitmap(imageData),
            Rect.fromCenter(
                center: center, width: widthOfImageWatermark, height: widthOfImageWatermark * ratioOfImage));
        pageGraphics.restore(state);
      }

      //! will give error if not run on android
      Directory? appDocDir = await getExternalStorageDirectory();
      String appDocPath = appDocDir!.path;

      // Specify the file path where you want to save the PDF in the android/data folder
      // String fileName = 'document.pdf';
      String fileName = subject.fileNameWithExtension;
      String filePath = '$appDocPath/$fileName';
      //Save the document.
      await File(filePath).writeAsBytes(await subject.document.save());
      print('done saved at');
      print(filePath);
      //Dispose the document.

      final result = await Share.shareXFiles([XFile(filePath)]);

      if (result.status == ShareResultStatus.success) {
        print('Thank you for sharing the picture!');
      }
    }
    return Future.value(true);
  }

  @override
  Widget preview(BuildContext context, Subject subject, {Uint8List? firstImageBytes}) {
    if (subject.runtimeType == ImageSubject) {
      _widthOfSubject = MediaQuery.of(context).size.width - 24;
      _heightOfSubject = MediaQuery.of(context).size.height - 24;

      return SizedBox(
          width: MediaQuery.of(context).size.width,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Stack(alignment: Alignment.center, children: [
              Image.file(File(subject.getPath()), width: _widthOfSubject),
              InteractiveViewer(
                boundaryMargin: const EdgeInsets.all(double.infinity),
                minScale: 0.1, // Set the minimum scale factor
                maxScale: 1.0, // Set the maximum scale factor
                child: Transform.rotate(
                  angle: radians(context.watch<PreviewProvider>().parameters.getRotationAngle()),
                  child: Opacity(
                    opacity: context.watch<PreviewProvider>().parameters.getOpacity() / 100,
                    child: Image.file(
                      File(_path),
                      width: _widthOfSubject,
                      // width: context.watch<PreviewProvider>().parameters.getSize().width,
                    ),
                  ),
                ),
              )
            ]),
          ));
    } else if (subject.runtimeType == PdfSubject) {
      // subject = subject as PdfSubject;
      // Uint8List firstImage = subject.getFirstImage();

      return Stack(
        alignment: Alignment.center,
        children: [
          Image.memory(firstImageBytes!),
          Transform.rotate(
            angle: radians(context.watch<PreviewProvider>().parameters.getRotationAngle()),
            child: Transform.scale(
              scale: context.watch<PreviewProvider>().parameters.getSize() / 100,
              child: Opacity(
                  opacity: context.watch<PreviewProvider>().parameters.getOpacity() / 100,
                  child: Image.file(File(_path), fit: BoxFit.scaleDown)),
            ),
          ),
        ],
      );
    }
    ;
    return const Text('');
  }

  @override
  Widget showBottomSheetSettings(BuildContext context, WatermarkParameters parameters) {
    return Builder(builder: (context) {
      return Padding(
        padding: const EdgeInsets.all(12),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Row(children: [
            const Text('Size'),
            Expanded(
              child: Slider.adaptive(
                  min: 0,
                  max: 100,
                  value: context.watch<PreviewProvider>().parameters.getSize(),
                  onChanged: (val) {
                    context.read<PreviewProvider>().updateSize(val);
                  }),
            ),
            Text(context.watch<PreviewProvider>().parameters.getSize().toInt().toString())
          ]),
          const SizedBox(height: 12),
          Row(children: [
            const Text('Opacity'),
            Expanded(
              child: Slider.adaptive(
                  min: 0,
                  max: 100,
                  value: context.watch<PreviewProvider>().parameters.getOpacity(),
                  onChanged: (val) {
                    context.read<PreviewProvider>().updateOpacity(val);
                  }),
            ),
            Text(context.watch<PreviewProvider>().parameters.getOpacity().toInt().toString())
          ]),
          const SizedBox(height: 12),
          Row(children: [
            const Text('Rotation'),
            Expanded(
              child: Slider.adaptive(
                  min: 0,
                  max: 360,
                  value: context.watch<PreviewProvider>().parameters.getRotationAngle(),
                  onChanged: (val) {
                    context.read<PreviewProvider>().updateRotationAngle(val.roundToDouble());
                  }),
            ),
            Text(context.watch<PreviewProvider>().parameters.getRotationAngle().toInt().toString())
          ])
        ]),
      );
    });
  }

  bool _loadFromPath(String path) {
    _path = path;
    List<int> bytes = File(path).readAsBytesSync();
    print(bytes);
    img.Image? image = img.decodeImage(Uint8List.fromList(bytes));
    print(image);

    _image = image!;
    return true;
  }

  @override
  Future<bool> load({dynamic value}) async {
    if (value.runtimeType == String) {
      print('1212121212121212121');
      return Future.value(_loadFromPath(value));
    }
    ImageSubject subject = ImageSubject();
    if (await subject.load() == false) return Future.value(false);

    _path = subject.path;
    _image = subject.image;

    // save image for cache
    bool imageSaved = await saveImage(_image, subject.fileNameWithExtension);
    return true;
  }

  Future<bool> saveImage(img.Image image, String filename) async {
    filename = filename.split('.')[0];
    filename = '$filename.png';
    try {
      Directory? appDocDir = await getExternalStorageDirectory();
      print('0000000000000000000000000000000000000000000000000000000');
      print(appDocDir);
      // String path = appDocDir!.path;
      String path = '${appDocDir!.path}/watermark/images';
      await Directory(path).create(recursive: true);
      print(path);
      String pathWithFilename = '$path/$filename';
      print(pathWithFilename);
      File(pathWithFilename).writeAsBytesSync(img.encodePng(image));
      print('done');
    } catch (e) {
      return false;
    }
    return true;
  }
}
