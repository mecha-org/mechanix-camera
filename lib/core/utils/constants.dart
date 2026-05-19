import 'package:flutter/cupertino.dart';

class AppConstants {
  static const int minimumStorageRequired = 1024 * 1024 * 10; // 10 MB
  static const Size focusSize = Size(240, 240);

  static const String aspectRatio = 'assets/icons/aspect_ratio.png';
  static const String close = 'assets/icons/close.png';
  static const String settings = 'assets/icons/settings.png';
}

abstract final class CameraFocusConstants {
  // ── Focus box ────────────────────────────────────────────────
  static const double focusBoxSize = 240.0;

  // ── Brightness line ──────────────────────────────────────────
  static const double brightnessIconLeftMargin = 8.0;
  static const double brightnessIconSize = 20.0;
  static const double brightnessContainerWidth = brightnessIconSize + 8.0;
  static const double brightnessHalfLineHeight = 50.0;
  static const double brightnessLineWidth = 1.5;
  static const double brightnessLineIconGap = 4.0;

  static const double brightnessTotalWidth =
      brightnessIconLeftMargin + brightnessContainerWidth;

  static const double brightnessTotalHeight =
      brightnessHalfLineHeight * 2 +
      brightnessIconSize +
      brightnessLineIconGap * 2;

  static const double totalTravel = brightnessHalfLineHeight * 2;
}
