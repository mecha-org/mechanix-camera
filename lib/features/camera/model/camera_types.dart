import 'package:flutter/services.dart';

enum CameraSettingsPanel { aspectRatio, none, zoom }

class SettingsOptionItem {
  final String label;
  final VoidCallback onTap;

  const SettingsOptionItem({required this.label, required this.onTap});
}
