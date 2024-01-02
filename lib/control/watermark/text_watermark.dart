import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart' as sfp;
import 'package:vector_math/vector_math.dart';
import 'package:image/image.dart' as img;

import '../providers/preview_provider.dart';
import '../providers/processing_provider.dart';
import '../subject/image_subject.dart';
import '../subject/pdf_subject.dart';
import '../subject/subject.dart';
import 'watermark.dart';
import 'watermark_parameters.dart';

class TextWatermark implements Watermark {
  /// [Watermark] string
  String _text = 'WaterMarkWater';

  String? get text => _text;

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
      for (int i = 0; i < subject.document.pages.count; i++) {
        final sfp.PdfPage page = subject.document.pages[i];
        Size size = subject.document.pages[i].size;
        Offset center = Offset(size.width / 2, size.height / 2);
        sfp.PdfGraphics pageGraphics = page.graphics;
        sfp.PdfGraphicsState state = pageGraphics.save();
        sfp.PdfFont font =
            sfp.PdfStandardFont(sfp.PdfFontFamily.helvetica, parameters.getSize(), style: sfp.PdfFontStyle.bold);

        pageGraphics.setTransparency(parameters.getOpacity() / 100);

        pageGraphics.drawString((text == null || text == "") ? 'Watermark' : text!, font,
            pen: sfp.PdfPens.black,
            brush: sfp.PdfBrushes.black,
            format: sfp.PdfStringFormat(
                alignment: sfp.PdfTextAlignment.center, lineAlignment: sfp.PdfVerticalAlignment.middle),
            bounds: Rect.fromCenter(center: center, width: size.width, height: size.height));
        pageGraphics.restore(state);
      }

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
      return SizedBox(
          width: MediaQuery.of(context).size.width,
          child: Padding(
            padding: EdgeInsets.all(12),
            child: PreviewTextWatermarkOnImageWidget(watermark: this, subject: subject as ImageSubject),
          ));
    } else if (subject.runtimeType == PdfSubject) {
      // load 1st page
      // apply watermark on stack
      // initialize parameters

      print('done here 1');
      // subject = subject as PdfSubject;
      // Uint8List firstImage = await subject.getFirstImage();
      print('done here 2');
      return Stack(
        alignment: Alignment.center,
        children: [
          Image.memory(firstImageBytes!),
          Opacity(
              opacity: context.watch<PreviewProvider>().parameters.getOpacity() / 100,
              child: Transform.rotate(
                  angle: radians(context.watch<PreviewProvider>().parameters.getRotationAngle()),
                  child: Text(text ?? "Watermark",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Helvetica',
                        fontSize: context.watch<PreviewProvider>().parameters.getSize(),
                      ))))
        ],
      );
    }
    return const Text('Something went wrong');
  }

  Widget showBottomSheetSettings(BuildContext context, WatermarkParameters parameters) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: const Padding(
        padding: EdgeInsets.all(12),
        child: BottomSheetSettingsWidget(),
      ),
    );
  }

  @override
  Future<bool> load({dynamic value}) {
    if (value == null || value == '') {
      _text = 'Watermark';
    } else {
      _text = value;
    }
    return Future<bool>.value(true);
  }
}

class PreviewTextWatermarkOnImageWidget extends StatelessWidget {
  const PreviewTextWatermarkOnImageWidget({super.key, required this.watermark, required this.subject});

  final TextWatermark watermark;
  final ImageSubject subject;

  @override
  Widget build(BuildContext context) {
    return Stack(alignment: Alignment.center, children: [
      Image.file(
        File(subject.getPath()),
      ),
      Transform.rotate(
        angle: radians(context.watch<PreviewProvider>().parameters.getRotationAngle()),
        child: Opacity(
          opacity: context.watch<PreviewProvider>().parameters.getOpacity() / 100,
          child: Text(watermark.text ?? 'Watermark',
              style: TextStyle(
                fontSize: context.watch<PreviewProvider>().parameters.getSize(),
              )),
        ),
      ),
    ]);
  }
}

class BottomSheetSettingsWidget extends StatelessWidget {
  const BottomSheetSettingsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(mainAxisSize: MainAxisSize.min, children: [
      Row(
        children: [
          const Text('Size'),
          Expanded(
            child: Slider.adaptive(
                min: 8,
                max: 64,
                value: context.watch<PreviewProvider>().parameters.getSize(),
                onChanged: (val) {
                  context.read<PreviewProvider>().updateSize(val.roundToDouble());
                }),
          ),
          Text(context.watch<PreviewProvider>().parameters.getSize().toInt().toString())
        ],
      ),
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
    ]);
  }
}
