import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../watermark/watermark_parameters.dart';

class ProcessingProvider with ChangeNotifier, DiagnosticableTreeMixin {
  ProcessingProvider();

  void startProcessing() {}
  void endProcessing() {}
}
