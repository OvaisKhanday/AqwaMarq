import 'dart:ui';

abstract class WatermarkParameters {
  double getSize();
  double getOpacity();
  double getRotationAngle();
  // dynamic getPosition();

  void setSize(double size);
  void setOpacity(double opacity);
  void setRotationAngle(double rotationAngle);
}

class TextWatermarkParameters implements WatermarkParameters {
  /// Represents the font size.
  double _size = 24;

  /// Represents the opacity of [Watermark].
  /// Ranges between [0-100], 0 being transparent.
  double _opacity = 50;

  /// Represents the angle of rotation of [Watermark].
  /// Ranges between [0-360].
  double _rotationAngle = 0;

  /// Name for the file which is to be exported.
  // String _outputFilename;

  /// Represents the position of [Watermark] relative to the [Subject].
  /// Ranges from [0-100] for width and height, (0,0) being top left corner.
  // Point _position =const  Point(0, 0);

  @override
  double getSize() => _size;
  @override
  double getOpacity() => _opacity;
  @override
  double getRotationAngle() => _rotationAngle;

  // Setters
  @override
  void setSize(double value) {
    _size = value;
  }

  @override
  void setOpacity(double value) => _opacity = value;
  @override
  void setRotationAngle(double value) => _rotationAngle = value;
}

class ImageWatermarkParameters implements WatermarkParameters {
  /// Represents the size of [Watermark] relative to the [Subject].
  /// Ranges from [0-100] for width and height, (100,100) will occupy the whole [Subject].
  // Size _size = const Size(50, 50);
  double _size = 50;

  /// Represents the opacity of [Watermark].
  /// Ranges between [0-100], 0 being transparent.
  double _opacity = 50;

  /// Represents the angle of rotation of [Watermark].
  /// Ranges between [0-360].
  double _rotationAngle = 0;

  // Setters

  @override
  void setSize(double value) => _size = value;
  @override
  void setOpacity(double value) => _opacity = value;
  @override
  void setRotationAngle(double value) => _rotationAngle = value;

  @override
  double getSize() => _size;
  @override
  double getOpacity() => _opacity;
  @override
  double getRotationAngle() => _rotationAngle;
}
