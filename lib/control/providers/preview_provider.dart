import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../watermark/watermark_parameters.dart';

class PreviewProvider with ChangeNotifier, DiagnosticableTreeMixin {
  PreviewProvider({required this.parameters});
  WatermarkParameters parameters;

  void updateSize(dynamic size) {
    parameters.setSize(size);
    notifyListeners();
  }

  void updateOpacity(double opacity) {
    parameters.setOpacity(opacity);
    notifyListeners();
  }

  void updateRotationAngle(double angle) {
    parameters.setRotationAngle(angle);
    notifyListeners();
  }
}
