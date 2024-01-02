import 'dart:typed_data';

import 'package:aqwamarq/control/watermark/watermark_parameters.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';

import '../../control/providers/preview_provider.dart';
import '../../control/subject/pdf_subject.dart';
import '../../control/subject/subject.dart';
import '../../control/watermark/text_watermark.dart';
import '../../control/watermark/watermark.dart';
import 'screens.dart';

// ignore: must_be_immutable
class PreviewScreen extends StatefulWidget {
  PreviewScreen({super.key, required this.subject, required this.watermark});

  final Subject subject;
  late Watermark watermark;

  @override
  State<PreviewScreen> createState() => _PreviewScreenState();
}

class _PreviewScreenState extends State<PreviewScreen> {
  late WatermarkParameters watermarkParameters;

  @override
  void initState() {
    super.initState();
    watermarkParameters =
        widget.watermark.runtimeType == TextWatermark ? TextWatermarkParameters() : ImageWatermarkParameters();
  }
  // create: (BuildContext c) => PreviewProvider(parameters: watermarkParameters),

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ChangeNotifierProvider<PreviewProvider>(
        create: (_) => PreviewProvider(parameters: watermarkParameters),
        child: PreviewWidget(widget: widget, watermarkParameters: watermarkParameters),
      ),
    );
  }
}

class PreviewWidget extends StatefulWidget {
  const PreviewWidget({
    super.key,
    required this.widget,
    required this.watermarkParameters,
  });

  final PreviewScreen widget;
  final WatermarkParameters watermarkParameters;

  @override
  State<PreviewWidget> createState() => _PreviewWidgetState();
}

class _PreviewWidgetState extends State<PreviewWidget> {
  bool arrowUp = true;
  final ScreenshotController screenshotController = ScreenshotController();
  Uint8List? firstImageBytes;

  void _toggleFab() {
    setState(() {
      arrowUp = !arrowUp;
    });
  }

  @override
  void initState() {
    super.initState();
    if (widget.widget.subject.runtimeType == PdfSubject) {
      _getFirstImageOfPdf();
    }
  }

  void _getFirstImageOfPdf() async {
    firstImageBytes = await (widget.widget.subject as PdfSubject).getFirstImage();
    setState(() {});
  }

  Widget _buildFabArrowUp(BuildContext context) {
    return FloatingActionButton.small(
        child: const Icon(Icons.arrow_upward_rounded),
        onPressed: () {
          _toggleFab();
          showBottomSheet(
              context: context,
              enableDrag: false,
              builder: (_) {
                return widget.widget.watermark.showBottomSheetSettings(_, widget.watermarkParameters);
              });
        });
  }

  Widget _buildFabArrowDown(BuildContext context) {
    return FloatingActionButton.small(
      child: const Icon(Icons.arrow_downward_rounded),
      onPressed: () {
        _toggleFab();
        Navigator.of(context).pop();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          OutlinedButton.icon(
              label: const Text('Next'),
              onPressed: () {
                // if(widget.widget.subject.runtimeType == ImageSubject)
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => ProcessingScreen(
                          watermark: widget.widget.watermark,
                          subject: widget.widget.subject,
                          watermarkParameters: widget.watermarkParameters,
                          screenshotController: screenshotController,
                        )));
              },
              icon: const Icon(Icons.arrow_forward_outlined)),
          const SizedBox(width: 12),
        ],
      ),
      floatingActionButton: Builder(builder: (_) {
        return arrowUp ? _buildFabArrowUp(_) : _buildFabArrowDown(_);
      }),
      body: Screenshot(
          controller: screenshotController,
          child: Builder(builder: (context) {
            if (widget.widget.subject.runtimeType == PdfSubject) {
              if (firstImageBytes == null) {
                return const Center(child: CircularProgressIndicator.adaptive());
              } else {
                return widget.widget.watermark
                    .preview(context, widget.widget.subject, firstImageBytes: firstImageBytes!);
              }
            }
            return widget.widget.watermark.preview(context, widget.widget.subject);
          })),
    );
  }
}
