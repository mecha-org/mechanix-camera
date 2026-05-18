import 'package:flutter/services.dart';

enum CameraSettingsPanel { aspectRatio, none, zoom }

enum ExposureControlPosition { start, end }

class SettingsOptionItem {
  final String label;
  final VoidCallback onTap;

  const SettingsOptionItem({required this.label, required this.onTap});
}
