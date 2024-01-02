import 'package:flutter/material.dart';
import 'package:screenshot/screenshot.dart';

import '../../control/subject/subject.dart';
import '../../control/watermark/watermark.dart';
import '../../control/watermark/watermark_parameters.dart';

class ProcessingScreen extends StatelessWidget {
  const ProcessingScreen(
      {super.key,
      required this.watermark,
      required this.watermarkParameters,
      required this.subject,
      required this.screenshotController});

  final Watermark watermark;
  final WatermarkParameters watermarkParameters;
  final Subject subject;
  final ScreenshotController screenshotController;

  // bool isProcessing = true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('Processing')),
        body: Center(
          child: FutureBuilder(
              future:
                  watermark.apply(subject, watermarkParameters, context, screenshotController: screenshotController),
              // future: Future.delayed(const Duration(seconds: 5)),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return const CircleAvatar(
                      radius: 50,
                      child: Icon(
                        Icons.done,
                        size: 50,
                      ));
                }
                return const CircularProgressIndicator.adaptive();
              }),
        )
        // body: isProcessing
        //     ? const Center(child: CircularProgressIndicator.adaptive())
        //     : const Center(
        //         child: CircleAvatar(
        //             radius: 50,
        //             child: Icon(
        //               Icons.done,
        //               size: 50,
        //             )))
        );
  }
}
