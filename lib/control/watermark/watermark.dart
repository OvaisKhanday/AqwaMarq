import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:screenshot/screenshot.dart';

import '../subject/subject.dart';
import 'watermark_parameters.dart';

abstract class Watermark {
  Future<bool> load({dynamic value});
  Future<bool> apply(Subject subject, WatermarkParameters parameters, BuildContext context,
      {ScreenshotController? screenshotController});
  Widget preview(BuildContext context, Subject subject, {Uint8List firstImageBytes});
  Widget showBottomSheetSettings(BuildContext context, WatermarkParameters parameters);
  // Future<void> save();
}
